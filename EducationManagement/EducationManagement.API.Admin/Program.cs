using EducationManagement.DAL;
using EducationManagement.BLL.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.FileProviders;
using System.Text;
using System.IO;

var builder = WebApplication.CreateBuilder(args);

// ======================================================
// 🧩 1️⃣ Add Controllers & Swagger
// ======================================================
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ======================================================
// 🧩 2️⃣ DbContext Configuration
// ======================================================
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection")
    )
);

// ======================================================
// 🧩 3️⃣ Register BLL Services (Dependency Injection)
// ======================================================
builder.Services.AddScoped<IRefreshTokenStore, InMemoryRefreshTokenStore>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<JwtService>();

// ======================================================
// 🧩 4️⃣ CORS Configuration
// ======================================================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(
            "http://127.0.0.1:5500",
            "http://localhost:5500"
        )
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials();
    });
});

// ======================================================
// 🧩 5️⃣ JWT Authentication Configuration
// ======================================================
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
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
    });

builder.Services.AddAuthorization();

// ======================================================
// 🧩 6️⃣ Build app
// ======================================================
var app = builder.Build();

// ======================================================
// 🧩 7️⃣ Swagger (chỉ bật khi Development)
// ======================================================
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ======================================================
// 🧩 8️⃣ Serve Static Files (Ảnh avatar)
// ======================================================
var avatarRootPath = Path.Combine(
    @"C:\Users\TK\Desktop\student-attendance-system\EducationManagement",
    "Avatar_User"
);

// 🔹 Tạo thư mục nếu chưa tồn tại
if (!Directory.Exists(avatarRootPath))
    Directory.CreateDirectory(avatarRootPath);

// ⚙️ Đăng ký middleware phục vụ ảnh tĩnh (đặt TRƯỚC UseRouting / UseCors / Auth)
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(avatarRootPath),
    RequestPath = "/avatars"
});

Console.WriteLine($"🖼️ Avatar static files served from: {avatarRootPath}");

// ======================================================
// 🧩 9️⃣ Middleware Pipeline
// ======================================================

// ⚙️ HTTPS (tuỳ bạn có dùng hay không)
app.UseHttpsRedirection();

app.UseRouting();          // 👈 Thêm dòng này trước các middleware khác
app.UseCors("AllowFrontend");
app.UseAuthentication();
app.UseAuthorization();

// ======================================================
// 🧩 🔟 Map Controllers
// ======================================================
app.MapControllers();

// ======================================================
// 🧩 11️⃣ Run
// ======================================================
Console.WriteLine("🚀 EducationManagement.API.Admin started successfully!");
app.Run();
