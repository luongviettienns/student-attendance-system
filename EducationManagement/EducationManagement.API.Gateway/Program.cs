using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.FileProviders;
using Ocelot.DependencyInjection;
using Ocelot.Middleware;
using System.Text;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

// ============================================================
// 🧩 1️⃣ Load cấu hình Ocelot
// ============================================================
builder.Configuration.AddJsonFile("ocelot.json", optional: false, reloadOnChange: true);

// ============================================================
// 🧩 2️⃣ JWT Authentication
// ============================================================
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = false;
        options.SaveToken = true;

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:SecretKey"]!)
            )
        };

        // 🧠 Ghi log JWT để debug và xử lý anonymous requests
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                var path = context.HttpContext.Request.Path.Value ?? "";
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"[Gateway JWT] ❌ Authentication Failed: {path}");
                Console.WriteLine($"[Gateway JWT] Exception: {context.Exception?.Message}");
                Console.ResetColor();
                
                // ✅ Cho phép anonymous requests tiếp tục - Ocelot sẽ quyết định
                context.NoResult();
                return Task.CompletedTask;
            },
            OnChallenge = context =>
            {
                var path = context.HttpContext.Request.Path.Value ?? "";
                var isAuthPath = path.StartsWith("/api-edu/auth", StringComparison.OrdinalIgnoreCase);
                
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine($"[Gateway JWT] OnChallenge: {path}");
                Console.WriteLine($"[Gateway JWT] IsAuthPath: {isAuthPath}");
                Console.WriteLine($"[Gateway JWT] Error: {context.Error}");
                Console.ResetColor();
                
                // ✅ QUAN TRỌNG: Skip challenge cho auth routes
                // Gateway không nên challenge các auth endpoints vì chúng cần anonymous access
                if (isAuthPath)
                {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine($"[Gateway JWT] ✅ Skipping challenge for auth endpoint: {path}");
                    Console.ResetColor();
                    context.HandleResponse();
                    return Task.CompletedTask;
                }
                
                // Cho các protected routes khác, thực hiện challenge bình thường
                return Task.CompletedTask;
            },
            OnTokenValidated = context =>
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"[Gateway JWT] ✅ Token Valid: {context.Principal?.Identity?.Name}");
                Console.ResetColor();
                return Task.CompletedTask;
            }
        };
    });

// ✅ Cấu hình Authorization để cho phép anonymous mặc định
// Gateway chỉ enforce authentication cho routes có AuthenticationOptions trong ocelot.json
builder.Services.AddAuthorization(options =>
{
    // Cho phép anonymous mặc định - Ocelot sẽ quyết định routes nào cần authentication
    options.FallbackPolicy = null;
});

// ============================================================
// 🧩 3️⃣ CORS (cho phép FE gọi Gateway trực tiếp)
// ============================================================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy
            .WithOrigins(
                "http://127.0.0.1:5500",
                "http://localhost:5500",
                "https://localhost:5500",
                "http://127.0.0.1:5501",   // ✅ Live Server port 5501
                "http://localhost:5501",   // ✅ Live Server port 5501
                "https://localhost:5501",  // ✅ Live Server port 5501
                "http://127.0.0.1:3000",   // ✅ Live Server port 3000
                "http://localhost:3000",   // ✅ Live Server port 3000
                "https://localhost:3000"   // ✅ Live Server port 3000
            )
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

// ============================================================
// 🧩 4️⃣ Đăng ký Ocelot
// ============================================================
builder.Services.AddOcelot(builder.Configuration);

// ============================================================
// 🧩 5️⃣ Build app
// ============================================================
var app = builder.Build();

// ============================================================
// 🚀 6️⃣ Middleware Pipeline
// ============================================================

// ============================================================
// 🧩 7️⃣ Static Files – phục vụ ảnh avatar (TRƯỚC OCELOT!)
// ============================================================
var projectRoot = Directory.GetParent(Directory.GetCurrentDirectory())?.FullName;
var avatarFolder = Path.Combine(projectRoot!, "Avatar_User");

// ✅ Đảm bảo thư mục tồn tại
if (!Directory.Exists(avatarFolder))
{
    Directory.CreateDirectory(avatarFolder);
    Console.ForegroundColor = ConsoleColor.Yellow;
    Console.WriteLine($"⚠️ Created Avatar_User folder at: {avatarFolder}");
    Console.ResetColor();
}

Console.ForegroundColor = ConsoleColor.Cyan;
Console.WriteLine($"🖼️ Static avatars will be served from: {avatarFolder}");
Console.WriteLine($"📂 Files in Avatar_User:");
if (Directory.Exists(avatarFolder))
{
    foreach (var file in Directory.GetFiles(avatarFolder))
    {
        Console.WriteLine($"   - {Path.GetFileName(file)}");
    }
}
Console.ResetColor();

// 🔹 Log tất cả request qua Gateway (TẮT LOG AVATAR để tránh spam)
app.Use(async (context, next) =>
{
    var path = context.Request.Path.Value ?? "";
    
    // Chỉ log các request KHÔNG PHẢI avatar để tránh spam log
    if (!context.Request.Path.StartsWithSegments("/avatars"))
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine($"[Gateway] [{DateTime.Now:HH:mm:ss}] {context.Request.Method} {path}");
        Console.WriteLine($"[Gateway] Has Authorization Header: {context.Request.Headers.ContainsKey("Authorization")}");
        Console.ResetColor();
    }

    await next();
    
    // Log response
    if (!path.StartsWith("/avatars"))
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine($"[Gateway] Response: {context.Response.StatusCode} for {path}");
        Console.ResetColor();
    }
});

app.UseCors("AllowFrontend");

// ⚙️ Static file middleware - MUST BE BEFORE Ocelot
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(avatarFolder),
    RequestPath = "/avatars",
    OnPrepareResponse = ctx =>
    {
        // Set cache headers
        ctx.Context.Response.Headers["Cache-Control"] = "public,max-age=86400";
    }
});

// ✅ QUAN TRỌNG: Gateway authentication middleware
// Authentication ở Gateway chỉ để validate token cho các protected routes
// Routes không có AuthenticationOptions trong ocelot.json sẽ được Ocelot xử lý
app.UseAuthentication();
app.UseAuthorization();

// ✅ DEBUG: Log sau authentication/authorization để xem request có bị chặn không
app.Use(async (context, next) =>
{
    var path = context.Request.Path.Value ?? "";
    
    // Chỉ log auth routes để debug
    if (path.StartsWith("/api-edu/auth"))
    {
        var isAuthenticated = context.User?.Identity?.IsAuthenticated ?? false;
        
        Console.ForegroundColor = ConsoleColor.Magenta;
        Console.WriteLine($"[Gateway After Auth] Path: {path}");
        Console.WriteLine($"[Gateway After Auth] IsAuthenticated: {isAuthenticated}");
        Console.WriteLine($"[Gateway After Auth] User: {context.User?.Identity?.Name ?? "null"}");
        Console.ResetColor();
    }
    
    await next();
});

// ============================================================
// 🧩 8️⃣ Cuối cùng: Ocelot Middleware
// ============================================================
await app.UseOcelot();

// ============================================================
// ✅ 9️⃣ Run
// ============================================================
Console.ForegroundColor = ConsoleColor.Green;
Console.WriteLine("🚀 Gateway started at https://localhost:7033");
Console.ResetColor();

app.Run();