using EducationManagement.DAL;
using EducationManagement.BLL.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.FileProviders;
using System.Text;


var builder = WebApplication.CreateBuilder(args);

// ======================================================
// 🧩 1. Add Controllers & Swagger
// ======================================================
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ======================================================
// 🧩 2. DbContext Configuration
// ======================================================
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection")
    )
);

// ======================================================
// 🧩 3. Register BLL Services (Dependency Injection)
// ======================================================
builder.Services.AddScoped<IRefreshTokenStore, InMemoryRefreshTokenStore>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<JwtService>();

// ======================================================
// 🧩 4. CORS Configuration
// ======================================================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(
            "http://127.0.0.1:5500",   // FE chạy local
            "http://localhost:5500"    // fallback cho trường hợp khác
        )
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials();
    });
});

// ======================================================
// 🧩 5. JWT Authentication Configuration
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
// 🧩 6. Build & Configure Middleware Pipeline
// ======================================================
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ======================================================
// 🧩 7. Serve Static Files (Ảnh lưu ngoài wwwroot)
// ======================================================
var customAvatarPath = @"C:\Users\TK\Desktop\student-attendance-system\EducationManagement\Avatar_User";

if (Directory.Exists(customAvatarPath))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(customAvatarPath),
        RequestPath = "/uploads/avatars"
    });
}

// ======================================================
// 🧩 8. Enable CORS + Authentication
// ======================================================

// ⚠️ Nếu bạn cần chạy HTTPS thật có thể bật dòng dưới
// app.UseHttpsRedirection();

app.UseCors("AllowFrontend");

app.UseAuthentication();
app.UseAuthorization();

// ======================================================
// 🧩 9. Map Controllers
// ======================================================
app.MapControllers();

// ======================================================
// 🧩 10. Run
// ======================================================
app.Run();
