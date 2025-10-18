using Microsoft.AspNetCore.Authentication.JwtBearer;
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

        // 🧠 Ghi log JWT để debug
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"❌ JWT Authentication Failed: {context.Exception.Message}");
                Console.ResetColor();
                return Task.CompletedTask;
            },
            OnTokenValidated = context =>
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"✅ Token Valid: {context.Principal?.Identity?.Name}");
                Console.ResetColor();
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();

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
                "https://localhost:5500"
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

// 🔹 Log tất cả request qua Gateway
app.Use(async (context, next) =>
{
    Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {context.Request.Method} {context.Request.Path}");
    await next();
});

app.UseCors("AllowFrontend");
app.UseAuthentication();
app.UseAuthorization();

// ============================================================
// 🧩 7️⃣ Static Files – phục vụ ảnh avatar
// ============================================================
var projectRoot = Directory.GetParent(Directory.GetCurrentDirectory())?.FullName;
var avatarFolder = Path.Combine(projectRoot!, "Avatar_User");

// ✅ Đảm bảo thư mục tồn tại
if (!Directory.Exists(avatarFolder))
    Directory.CreateDirectory(avatarFolder);

// ✅ Nếu ảnh không tồn tại, trả về default.png
app.Use(async (context, next) =>
{
    if (context.Request.Path.StartsWithSegments("/avatars"))
    {
        var rawPath = context.Request.Path.Value ?? string.Empty;

        var relativePath = rawPath.StartsWith("/avatars/", StringComparison.OrdinalIgnoreCase)
            ? rawPath.Substring("/avatars/".Length)
            : rawPath.StartsWith("/avatars", StringComparison.OrdinalIgnoreCase)
                ? rawPath.Substring("/avatars".Length)
                : rawPath;

        relativePath = relativePath.Replace('/', Path.DirectorySeparatorChar);
        var filePath = Path.Combine(avatarFolder, relativePath);

        if (!File.Exists(filePath))
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"⚠️ File not found: {filePath}, fallback to default.png");
            Console.ResetColor();
            context.Request.Path = "/avatars/default.png";
        }
    }

    await next();
});

// ⚙️ Static file middleware
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(avatarFolder),
    RequestPath = "/avatars"
});

Console.ForegroundColor = ConsoleColor.Cyan;
Console.WriteLine($"🖼️ Static avatars served from: {avatarFolder}");
Console.ResetColor();

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
