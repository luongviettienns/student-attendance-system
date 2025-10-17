using EducationManagement.DAL;
using EducationManagement.DAL.Repositories;
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
// 🧩 3️⃣ Register BLL Services & Repositories (Dependency Injection)
// ======================================================

// 🔐 Auth & JWT
builder.Services.AddScoped<IRefreshTokenStore, InMemoryRefreshTokenStore>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<JwtService>();

// 📘 Danh mục học vụ
builder.Services.AddScoped<AcademicYearRepository>();
builder.Services.AddScoped<AcademicYearService>();

builder.Services.AddScoped<FacultyRepository>();
builder.Services.AddScoped<FacultyService>();

builder.Services.AddScoped<MajorRepository>();
builder.Services.AddScoped<MajorService>();

// 🧑‍🏫 Giảng viên & Bộ môn
builder.Services.AddScoped<DepartmentRepository>();
builder.Services.AddScoped<LecturerRepository>();
builder.Services.AddScoped<LecturerService>();

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
        options.RequireHttpsMetadata = false; // Cho phép test local
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
            ),

            // Token hết hạn đúng giờ, không cộng thêm 5 phút mặc định
            ClockSkew = TimeSpan.Zero
        };

        // 🔹 Ghi log khi JWT gặp lỗi hoặc xác thực thành công
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = context =>
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"❌ JWT Auth failed: {context.Exception.Message}");
                Console.ResetColor();
                return Task.CompletedTask;
            },
            OnTokenValidated = context =>
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"✅ Token hợp lệ cho user: {context.Principal?.Identity?.Name}");
                Console.ResetColor();
                return Task.CompletedTask;
            },
            OnChallenge = context =>
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine($"⚠️ JWT challenge: {context.ErrorDescription}");
                Console.ResetColor();
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();

// ======================================================
// 🧩 6️⃣ Build app
// ======================================================
var app = builder.Build();

// ======================================================
// 🧩 7️⃣ Swagger (bật khi Development)
// ======================================================
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// ======================================================
// 🧩 8️⃣ Serve Static Files (Ảnh avatar - dùng đường dẫn tương đối)
// ======================================================

// 📁 Tạo đường dẫn tương đối tới thư mục Avatar_User (ở cùng cấp solution)
var avatarRootPath = Path.Combine(
    Directory.GetParent(Directory.GetCurrentDirectory())!.FullName,
    "Avatar_User"
);

// 🔹 Tạo thư mục nếu chưa tồn tại
if (!Directory.Exists(avatarRootPath))
    Directory.CreateDirectory(avatarRootPath);

// ⚙️ Đăng ký middleware phục vụ ảnh tĩnh
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(avatarRootPath),
    RequestPath = "/avatars" // Truy cập qua: https://localhost:7299/avatars/ten-file.jpg
});

Console.WriteLine($"🖼️ Avatar static files served from: {avatarRootPath}");

// ======================================================
// 🧩 9️⃣ Middleware Pipeline
// ======================================================
app.UseHttpsRedirection();

app.UseRouting();
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
