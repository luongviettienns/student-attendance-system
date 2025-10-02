using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using BanMayTinh_NguoiDung.Code;

namespace BanMayTinh_NguoiDung.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MyGradesController : ControllerBase
{
    private readonly IEducationDb _db;
    public MyGradesController(IEducationDb db) { _db = db; }

    [HttpGet]
    [Authorize(Roles = "Student")]
    public async Task<IActionResult> Get()
    {
        var userName = User.FindFirstValue(ClaimTypes.Name) ?? string.Empty;
        using var conn = _db.CreateConnection();
        var data = await conn.QueryAsync("SELECT TOP 20 * FROM dbo.grades ORDER BY created_at DESC");
        return Ok(data);
    }
}

