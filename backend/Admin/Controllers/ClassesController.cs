using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BanMayTinh_Admin.Code;

namespace BanMayTinh_Admin.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = "AdminOnly")]
public class ClassesController : ControllerBase
{
    private readonly IEducationDb _db;
    public ClassesController(IEducationDb db) { _db = db; }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        using var conn = _db.CreateConnection();
        var data = await conn.QueryAsync("SELECT class_id, class_code, class_name, subject_id, lecturer_id, semester, academic_year_id, max_students FROM dbo.classes WHERE is_active = 1");
        return Ok(data);
    }
}

