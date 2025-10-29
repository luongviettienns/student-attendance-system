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
    // Chỉ log các request KHÔNG PHẢI avatar để tránh spam log
    if (!context.Request.Path.StartsWithSegments("/avatars"))
    {
        Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {context.Request.Method} {context.Request.Path}");
    }
    
    await next();
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
        ctx.Context.Response.Headers.Add("Cache-Control", "public,max-age=86400");
    }
});

app.UseAuthentication();
app.UseAuthorization();

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
