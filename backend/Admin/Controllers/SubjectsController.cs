using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BanMayTinh_Admin.Code;

namespace BanMayTinh_Admin.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = "AdminOnly")]
public class SubjectsController : ControllerBase
{
    private readonly IEducationDb _db;
    public SubjectsController(IEducationDb db) { _db = db; }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        using var conn = _db.CreateConnection();
        var data = await conn.QueryAsync("SELECT subject_id, subject_code, subject_name, credits FROM dbo.subjects WHERE is_active = 1");
        return Ok(data);
    }
}

