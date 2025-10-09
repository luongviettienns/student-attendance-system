using EducationManagement.DAL;
using EducationManagement.BLL.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// ---------------------- Services ----------------------

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// BLL Services
builder.Services.AddScoped<IRefreshTokenStore, InMemoryRefreshTokenStore>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<JwtService>();

// ✅ CORS cho FE (127.0.0.1:5500)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://127.0.0.1:5500") // FE origin
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// ✅ JWT Authentication
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
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:SecretKey"])),
            ClockSkew = TimeSpan.Zero // tránh delay mặc định 5 phút
        };
    });

builder.Services.AddAuthorization();

// ---------------------- App Pipeline ----------------------

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ❌ Không redirect sang HTTPS (dev dùng http qua Gateway 5090)
//// app.UseHttpsRedirection();

app.UseStaticFiles();

// ✅ Bật CORS trước Authentication
app.UseCors("AllowFrontend");

app.UseAuthentication();
app.UseAuthorization();

// 🔹 Audit Middleware (nếu có)
app.UseMiddleware<EducationManagement.API.Auth.Middleware.AuditMiddleware>();

app.MapControllers();

app.Run();
