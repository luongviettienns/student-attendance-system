using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BanMayTinh_Admin.Code;

namespace BanMayTinh_Admin.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = "LecturerOnly")]
public class GradesController : ControllerBase
{
    private readonly IEducationDb _db;
    public GradesController(IEducationDb db) { _db = db; }

    [HttpGet("by-class/{classId}")]
    public async Task<IActionResult> ByClass(string classId)
    {
        using var conn = _db.CreateConnection();
        var data = await conn.QueryAsync("SELECT * FROM dbo.grades WHERE class_id = @classId", new { classId });
        return Ok(data);
    }
}

