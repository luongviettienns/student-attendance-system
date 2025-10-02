using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BanMayTinh_NguoiDung.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AttendanceController : ControllerBase
{
    [HttpPost("take")]
    [Authorize(Roles = "Teacher")]
    public IActionResult Take([FromBody] Dictionary<string, string> statuses)
    {
        return Ok(new { saved = statuses.Count });
    }

    [HttpGet("my")]
    [Authorize(Roles = "Student,Teacher")]
    public IActionResult My()
    {
        return Ok(new[] { new { Date = DateTime.UtcNow.Date, Status = "Present" } });
    }
}

