using Ocelot.DependencyInjection;
using Ocelot.Middleware;

var builder = WebApplication.CreateBuilder(args);

// ---------------------- Services ----------------------

builder.Configuration.AddJsonFile("ocelot.json", optional: false, reloadOnChange: true);

builder.Services.AddOcelot(builder.Configuration);

// ✅ Bật CORS AllowAll cho Gateway
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// ---------------------- App Pipeline ----------------------

// ❌ Không cần HTTPS redirect cho Gateway
//// app.UseHttpsRedirection();

app.UseCors("AllowAll");

// Swagger của Gateway thường không cần, vì FE test trực tiếp Auth/User API
// Nếu muốn thì có thể tích hợp swagger for Ocelot (advanced)

await app.UseOcelot();

app.Run();
