using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BanMayTinh_Admin.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class AdminCoursesController : ControllerBase
{
    [HttpGet]
    public IActionResult Get() => Ok(new[] { new { Code = "INT101", Name = "Intro Programming" } });
}

