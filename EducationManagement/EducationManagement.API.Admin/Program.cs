using System.Reflection;
using System.Text;
using EducationManagement.DAL;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scrutor;

var builder = WebApplication.CreateBuilder(args);

// ============================================================
// 🔹 1️⃣ Kết nối Database (DAL)
// ============================================================
builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
});

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
                "http://localhost:7034"    // Gateway (HTTP fallback)
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
// 🔹 6️⃣ Middleware pipeline
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
