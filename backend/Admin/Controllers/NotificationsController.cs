using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BanMayTinh_Admin.Code;

namespace BanMayTinh_Admin.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = "AdminOnly")]
public class NotificationsController : ControllerBase
{
    private readonly IEducationDb _db;
    public NotificationsController(IEducationDb db) { _db = db; }

    [HttpGet("by-user/{userId}")]
    public async Task<IActionResult> ByUser(string userId)
    {
        using var conn = _db.CreateConnection();
        var data = await conn.QueryAsync("SELECT * FROM dbo.notifications WHERE recipient_id = @userId ORDER BY created_at DESC", new { userId });
        return Ok(data);
    }
}

