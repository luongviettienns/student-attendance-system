using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BanMayTinh_Admin.Code;

namespace BanMayTinh_Admin.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = "AdminOnly")]
public class SchedulesController : ControllerBase
{
    private readonly IEducationDb _db;
    public SchedulesController(IEducationDb db) { _db = db; }

    [HttpGet("by-class/{classId}")]
    public async Task<IActionResult> ByClass(string classId)
    {
        using var conn = _db.CreateConnection();
        var data = await conn.QueryAsync("SELECT * FROM dbo.schedules WHERE class_id = @classId AND is_active = 1 ORDER BY start_time", new { classId });
        return Ok(data);
    }
}

