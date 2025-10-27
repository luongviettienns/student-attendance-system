using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Route("api-edu/auth/debug")]
    public class DebugAuthController : ControllerBase
    {
        // WARNING: Debug-only helpers. Keep only for local troubleshooting.

        [HttpGet("hash")]
        [AllowAnonymous]
        public IActionResult Hash([FromQuery] string pwd)
        {
            if (string.IsNullOrWhiteSpace(pwd)) return BadRequest(new { message = "pwd required" });
            var h = BCrypt.Net.BCrypt.HashPassword(pwd, workFactor: 10);
            return Ok(new { hash = h });
        }

        [HttpGet("verify")]
        [AllowAnonymous]
        public IActionResult Verify([FromQuery] string pwd, [FromQuery] string hash)
        {
            if (string.IsNullOrWhiteSpace(pwd) || string.IsNullOrWhiteSpace(hash))
                return BadRequest(new { message = "pwd and hash required" });
            var ok = BCrypt.Net.BCrypt.Verify(pwd, hash);
            return Ok(new { valid = ok });
        }
    }
}


