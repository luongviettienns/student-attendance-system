using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using BanMayTinh_NguoiDung.Code;

namespace BanMayTinh_NguoiDung.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TimetableController : ControllerBase
{
    private readonly IEducationDb _db;
    public TimetableController(IEducationDb db) { _db = db; }

    [HttpGet("my")]
    [Authorize(Roles = "Student,Lecturer")]
    public async Task<IActionResult> My()
    {
        var userName = User.FindFirstValue(ClaimTypes.Name) ?? string.Empty;
        using var conn = _db.CreateConnection();
        // ví dụ: trả lịch của lớp class-001 (mẫu)
        var data = await conn.QueryAsync("SELECT TOP 10 * FROM dbo.schedules WHERE is_active = 1 ORDER BY start_time DESC");
        return Ok(data);
    }
}

