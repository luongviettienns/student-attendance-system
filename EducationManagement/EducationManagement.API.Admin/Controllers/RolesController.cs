using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EducationManagement.DAL;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/admin/roles")]
    public class RolesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RolesController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetRoles()
        {
            var roles = await _context.Roles
                .Where(r => r.DeletedAt == null && r.IsActive)
                .Select(r => new
                {
                    r.RoleId,
                    r.RoleName,
                    r.Description
                })
                .ToListAsync();

            return Ok(roles);
        }
    }
}


