using System.Reflection;
using System.Text;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.IdentityModel.Tokens;
using Scrutor;
using System.IO.Compression;

var builder = WebApplication.CreateBuilder(args);

// ============================================================
// 🔹 1️⃣ Kết nối Database (DAL) - Sử dụng DatabaseHelper thay vì EF Core
// ============================================================
// Không cần AddDbContext vì đã chuyển sang sử dụng DatabaseHelper

// ============================================================
// 🔹 2️⃣ Đăng ký toàn bộ Services + Repositories
// ============================================================
builder.Services.Scan(scan => scan
    .FromAssemblies(
        Assembly.Load("EducationManagement.BLL"),
        Assembly.Load("EducationManagement.DAL")
    )
    .AddClasses(classes => classes.InNamespaces(
        "EducationManagement.BLL.Services",
        "EducationManagement.DAL.Repositories"
    ))
    .AsSelfWithInterfaces()
    .WithScopedLifetime()
);

// ✅ Explicit registration for IRefreshTokenStore (DATABASE storage - SCALABLE!)
// ❌ REMOVED: InMemoryRefreshTokenStore (not scalable for production)
builder.Services.AddScoped<EducationManagement.BLL.Services.IRefreshTokenStore, 
    EducationManagement.BLL.Services.DatabaseRefreshTokenStore>();

// ============================================================
// 🔹 2.5️⃣ REDIS CACHING (OPTIONAL - Fallback to Memory Cache if Redis unavailable)
// ============================================================
var redisConnectionString = builder.Configuration.GetValue<string>("Redis:ConnectionString") ?? "localhost:6379";
var useRedis = builder.Configuration.GetValue<bool>("Redis:Enabled");

if (useRedis)
{
    try
    {
        builder.Services.AddStackExchangeRedisCache(options =>
        {
            options.Configuration = redisConnectionString;
            options.InstanceName = "EduSystem_";
        });
        Console.WriteLine("✅ Redis caching enabled");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"⚠️ Redis connection failed, falling back to Memory Cache: {ex.Message}");
        builder.Services.AddDistributedMemoryCache();
    }
}
else
{
    // Fallback to in-memory cache if Redis is disabled
    builder.Services.AddDistributedMemoryCache();
    Console.WriteLine("⚠️ Redis disabled, using Memory Cache (not recommended for production)");
}

// ============================================================
// 🔹 2.6️⃣ RESPONSE COMPRESSION (Gzip + Brotli)
// ============================================================
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
    options.Providers.Add<BrotliCompressionProvider>();
    options.Providers.Add<GzipCompressionProvider>();
});

builder.Services.Configure<BrotliCompressionProviderOptions>(options =>
{
    options.Level = CompressionLevel.Fastest;
});

builder.Services.Configure<GzipCompressionProviderOptions>(options =>
{
    options.Level = CompressionLevel.Fastest;
});

// ============================================================
// 🔹 2.7️⃣ RATE LIMITING (DDoS Protection)
// ============================================================
builder.Services.AddRateLimiter(options =>
{
    // Global rate limit - 100 requests per minute per user/IP
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
    {
        var username = context.User.Identity?.Name ?? context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        return RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: username,
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 100,
                Window = TimeSpan.FromMinutes(1),
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0
            });
    });
    
    // Stricter rate limit for login endpoint - 5 requests per 15 minutes per IP
    options.AddPolicy("login", context =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 5,
                Window = TimeSpan.FromMinutes(15),
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0
            }));
    
    // Rejection response
    options.OnRejected = async (context, token) =>
    {
        context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;
        await context.HttpContext.Response.WriteAsJsonAsync(new
        {
            error = "Too many requests",
            message = "Rate limit exceeded. Please try again later.",
            retryAfter = context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter) 
                ? (double?)retryAfter.TotalSeconds 
                : (double?)null
        }, cancellationToken: token);
    };
});

// ============================================================
// 🔹 3️⃣ Cấu hình Controller, Swagger, CORS
// ============================================================
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy
            .WithOrigins(
                "https://localhost:3000",  // FE (HTTPS)
                "http://localhost:3000",   // FE (HTTP)
                "https://localhost:7033",  // Gateway (HTTPS)
                "http://localhost:7034",   // Gateway (HTTP fallback)
                "http://localhost:5227",   // Admin API (same port as backend)
                "http://127.0.0.1:5227",   // Admin API (127.0.0.1)
                "http://localhost:5500",   // Live Server (localhost)
                "http://127.0.0.1:5500",   // Live Server (127.0.0.1)
                "http://localhost:5501",   // Live Server port 5501 (localhost)
                "http://127.0.0.1:5501",   // Live Server port 5501 (127.0.0.1)
                "http://localhost:8080",   // Python/Node HTTP Server
                "http://127.0.0.1:8080"    // Python/Node HTTP Server (127.0.0.1)
            )
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

// ============================================================
// 🔹 4️⃣ JWT Authentication
// ============================================================
var jwtSection = builder.Configuration.GetSection("Jwt");
var secretKey = jwtSection.GetValue<string>("SecretKey") ?? "BiLoSecretKeyThiPhaiLamSao?ThiPhaiChiu!!";
var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        // ✅ Cho phép Gateway (HTTPS) gọi tới Admin API (HTTP)
        options.RequireHttpsMetadata = false;
        options.SaveToken = true;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSection["Issuer"],
            ValidAudience = jwtSection["Audience"],
            IssuerSigningKey = key,
            ClockSkew = TimeSpan.Zero
        };

        // ✅ JWT Events (chỉ log lỗi, không log mỗi lần validate)
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                // Chỉ log lỗi authentication
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"❌ JWT Invalid: {context.Exception.Message}");
                Console.ResetColor();
                return Task.CompletedTask;
            }
            // Tắt OnTokenValidated để tránh log quá nhiều
        };
    });

// ============================================================
// 🔹 5️⃣ Build app
// ============================================================
var app = builder.Build();

// ============================================================
// 🔹 6️⃣ SERVE STATIC FILES (Avatars)
// ============================================================
var projectRoot = Directory.GetParent(Directory.GetCurrentDirectory())?.FullName;
var avatarFolder = Path.Combine(projectRoot!, "Avatar_User");

if (!Directory.Exists(avatarFolder))
{
    Directory.CreateDirectory(avatarFolder);
    Console.ForegroundColor = ConsoleColor.Yellow;
    Console.WriteLine($"⚠️ Created Avatar_User folder at: {avatarFolder}");
    Console.ResetColor();
}

// Serve static files từ Avatar_User folder với URL prefix /avatars
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(avatarFolder),
    RequestPath = "/avatars"
});

Console.ForegroundColor = ConsoleColor.Cyan;
Console.WriteLine($"📁 Static avatars served from: {avatarFolder}");
Console.ResetColor();

// ============================================================
// 🔹 7️⃣ Middleware pipeline
// ============================================================

// ⚠️ Response Compression MUST be FIRST (before any output)
app.UseResponseCompression();

// ⚠️ Rate Limiting should be early in the pipeline
app.UseRateLimiter();

// ⚠️ Không redirect HTTPS (Gateway đã xử lý SSL termination)
app.UseCors("AllowFrontend");

app.UseAuthentication();
app.UseAuthorization();

// ✅ Swagger - chỉ bật trong Development
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ✅ Controller endpoints
app.MapControllers();

// ============================================================
// 🚀 Run
// ============================================================
Console.ForegroundColor = ConsoleColor.Green;
Console.WriteLine("✅ EducationManagement.API.Admin started at http://localhost:5227 (HTTP mode for Gateway TLS termination)");
Console.ResetColor();

app.Run();
