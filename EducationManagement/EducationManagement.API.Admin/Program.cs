using System.Reflection;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Scrutor;

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

// ✅ Explicit registration for IRefreshTokenStore (singleton for in-memory store)
builder.Services.AddSingleton<EducationManagement.BLL.Services.IRefreshTokenStore, 
    EducationManagement.BLL.Services.InMemoryRefreshTokenStore>();

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

        // ✅ Debug log cho JWT
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"❌ JWT Invalid: {context.Exception.Message}");
                Console.ResetColor();
                return Task.CompletedTask;
            },
            OnTokenValidated = context =>
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"✅ Token hợp lệ cho user: {context.Principal?.Identity?.Name}");
                Console.ResetColor();
                return Task.CompletedTask;
            }
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
