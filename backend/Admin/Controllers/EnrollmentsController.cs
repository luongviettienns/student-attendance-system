using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BanMayTinh_Admin.Code;

namespace BanMayTinh_Admin.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = "AdminOnly")]
public class EnrollmentsController : ControllerBase
{
    private readonly IEducationDb _db;
    public EnrollmentsController(IEducationDb db) { _db = db; }

    [HttpGet("by-class/{classId}")]
    public async Task<IActionResult> ByClass(string classId)
    {
        using var conn = _db.CreateConnection();
        var data = await conn.QueryAsync("SELECT e.enrollment_id, e.student_id, s.full_name FROM dbo.enrollments e JOIN dbo.students s ON s.student_id = e.student_id WHERE e.class_id = @classId AND e.is_active = 1", new { classId });
        return Ok(data);
    }
}

