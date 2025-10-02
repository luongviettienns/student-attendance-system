using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using System.Text;

namespace BanMayTinh_NguoiDung.Controllers;

public record LoginRequest(string Username, string Role);
public record LoginResponse(string AccessToken, DateTime ExpiresAtUtc);

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IConfiguration _config;
    public AuthController(IConfiguration config) { _config = config; }

    [HttpPost("login")]
    public ActionResult<LoginResponse> Login([FromBody] LoginRequest req)
    {
        var key = _config["Jwt:Key"];
        if (string.IsNullOrWhiteSpace(key)) return Problem("JWT key not configured");

        var claims = new List<Claim>
        {
            new(ClaimTypes.Name, req.Username ?? "user"),
            new(ClaimTypes.Role, string.IsNullOrWhiteSpace(req.Role) ? "Student" : req.Role)
        };

        var signingKey = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(key));
        var creds = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);
        var expires = DateTime.UtcNow.AddHours(3);

        var jwt = new JwtSecurityToken(
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: expires,
            signingCredentials: creds
        );

        var token = new JwtSecurityTokenHandler().WriteToken(jwt);
        return new LoginResponse(token, expires);
    }
}

