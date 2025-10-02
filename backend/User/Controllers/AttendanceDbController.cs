using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BanMayTinh_NguoiDung.Code;

namespace BanMayTinh_NguoiDung.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AttendanceDbController : ControllerBase
{
    private readonly IEducationDb _db;
    public AttendanceDbController(IEducationDb db) { _db = db; }

    [HttpPost("take")] 
    [Authorize(Roles = "Lecturer")]
    public async Task<IActionResult> Take([FromBody] IEnumerable<dynamic> records)
    {
        using var conn = _db.CreateConnection();
        // mẫu: chỉ trả về số lượng, tích hợp SP/INSERT sau
        return Ok(new { saved = records.Count() });
    }
}

