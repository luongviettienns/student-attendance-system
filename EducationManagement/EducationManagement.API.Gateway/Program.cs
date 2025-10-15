using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.FileProviders;
using Ocelot.DependencyInjection;
using Ocelot.Middleware;
using System.Text;

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
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:SecretKey"])
            )
        };

        // 🧠 Log chi tiết lỗi JWT để debug
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                Console.WriteLine($"❌ JWT Authentication Failed: {context.Exception.Message}");
                return Task.CompletedTask;
            },
            OnTokenValidated = context =>
            {
                Console.WriteLine($"✅ Token Valid: {context.Principal.Identity?.Name}");
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();

// ============================================================
// 🧩 3️⃣ Cấu hình CORS (FE gọi Gateway trực tiếp)
// ============================================================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy
            .WithOrigins(
                "http://127.0.0.1:5500",
                "http://localhost:5500"
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

// 🔹 Ghi log tất cả request qua gateway
app.Use(async (context, next) =>
{
    Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {context.Request.Method} {context.Request.Path}");
    await next();
});

// 🔹 Cho phép FE truy cập
app.UseCors("AllowFrontend");

// 🔹 JWT + Authorization
app.UseAuthentication();
app.UseAuthorization();

// 🔹 Static Files – phục vụ ảnh avatar trực tiếp
var avatarFolder = @"C:\Users\TK\Desktop\student-attendance-system\EducationManagement\Avatar_User";
if (!Directory.Exists(avatarFolder))
    Directory.CreateDirectory(avatarFolder);

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(avatarFolder),
    RequestPath = "/avatars"
});

Console.WriteLine($"🖼️  Static avatars served from: {avatarFolder}");

// 🔹 Cuối cùng: Ocelot (luôn cuối pipeline)
await app.UseOcelot();

// ============================================================
// ✅ 7️⃣ Run
// ============================================================
Console.WriteLine("🚀 Gateway started at https://localhost:7033");
app.Run();
