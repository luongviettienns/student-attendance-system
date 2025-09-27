using Ocelot.DependencyInjection;
using Ocelot.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Nạp file ocelot.json
builder.Configuration.AddJsonFile("ocelot.json", optional: false, reloadOnChange: true);

// Đăng ký Ocelot
builder.Services.AddOcelot();

var app = builder.Build();

// Middleware Ocelot
await app.UseOcelot();

app.Run();
