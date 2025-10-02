using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using BanMayTinh_NguoiDung.Code;

namespace BanMayTinh_NguoiDung.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MyNotificationsController : ControllerBase
{
    private readonly IEducationDb _db;
    public MyNotificationsController(IEducationDb db) { _db = db; }

    [HttpGet]
    [Authorize(Roles = "Student,Teacher,Admin")]
    public async Task<IActionResult> Get()
    {
        var userName = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;
        using var conn = _db.CreateConnection();
        var data = await conn.QueryAsync("SELECT TOP 20 * FROM dbo.notifications ORDER BY created_at DESC");
        return Ok(data);
    }
}

