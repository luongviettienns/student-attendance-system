using Ocelot.DependencyInjection;
using Ocelot.Middleware;

var builder = WebApplication.CreateBuilder(args);

// ============================================================
// 🧩 1. Load cấu hình Ocelot
// ============================================================
builder.Configuration.AddJsonFile("ocelot.json", optional: false, reloadOnChange: true);

// ============================================================
// 🧩 2. Đăng ký dịch vụ Ocelot
// ============================================================
builder.Services.AddOcelot(builder.Configuration);

// ============================================================
// 🧩 3. Cấu hình CORS cho phép FE gọi Gateway
// ============================================================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// ============================================================
// 🧩 4. Tạo app
// ============================================================
var app = builder.Build();

// ============================================================
// 🚀 5. Cấu hình Middleware pipeline
// ============================================================

// ✅ Bật CORS cho tất cả request
app.UseCors("AllowAll");

// ✅ HTTPS redirection chỉ dùng khi cần (nếu không chạy song song IIS Express thì có thể bật)
app.UseHttpsRedirection();

// ✅ Logging mặc định (giúp debug Gateway dễ hơn)
app.Use(async (context, next) =>
{
    Console.WriteLine($"[{DateTime.Now:HH:mm:ss}] {context.Request.Method} {context.Request.Path}");
    await next.Invoke();
});

// ✅ Middleware chính của Ocelot (phải luôn đặt cuối cùng)
await app.UseOcelot();

// ============================================================
// ✅ 6. Chạy ứng dụng
// ============================================================
app.Run();
