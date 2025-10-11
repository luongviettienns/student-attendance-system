using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EducationManagement.DAL;
using EducationManagement.Common.Models;
using EducationManagement.Common.DTOs.User;
using EducationManagement.Common.Helpers;
using EducationManagement.BLL.Services;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Authorize(Roles = "Admin")]
    [Route("api/admin/users")]
    public class UserAdminController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly AuthService _authService;

        public UserAdminController(AppDbContext context, AuthService authService)
        {
            _context = context;
            _authService = authService;
        }

        #region 🔹 GET: Danh sách + Chi tiết
        /// <summary>
        /// Lấy danh sách người dùng có phân trang, lọc, tìm kiếm
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? roleId = null,
            [FromQuery] bool? isActive = null)
        {
            var query = _context.Users
                .Include(u => u.Role)
                .Where(u => u.DeletedAt == null)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
                query = query.Where(u =>
                    u.Username.Contains(search) ||
                    u.FullName.Contains(search) ||
                    u.Email.Contains(search));

            if (!string.IsNullOrWhiteSpace(roleId))
                query = query.Where(u => u.RoleId == roleId);

            if (isActive.HasValue)
                query = query.Where(u => u.IsActive == isActive.Value);

            var totalCount = await query.CountAsync();

            var users = await query
                .OrderByDescending(u => u.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(u => new UserListDto
                {
                    UserId = u.UserId,
                    Username = u.Username,
                    FullName = u.FullName,
                    Email = u.Email,
                    Phone = u.Phone,
                    RoleId = u.RoleId,
                    RoleName = u.Role.RoleName,
                    AvatarUrl = FileHelper.BuildFullAvatarUrl(Request.Scheme, Request.Host.ToString(), u.AvatarUrl),
                    IsActive = u.IsActive,
                    LastLoginAt = u.LastLoginAt,
                    CreatedAt = u.CreatedAt,
                    CreatedBy = u.CreatedBy,
                    UpdatedAt = u.UpdatedAt,
                    UpdatedBy = u.UpdatedBy
                })
                .ToListAsync();

            return Ok(new
            {
                data = users,
                pagination = new
                {
                    page,
                    pageSize,
                    totalCount,
                    totalPages = (int)Math.Ceiling((double)totalCount / pageSize)
                }
            });
        }

        /// <summary>
        /// Lấy thông tin chi tiết của 1 người dùng
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == id && u.DeletedAt == null);

            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            var userDto = new UserListDto
            {
                UserId = user.UserId,
                Username = user.Username,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                RoleId = user.RoleId,
                RoleName = user.Role.RoleName,
                AvatarUrl = FileHelper.BuildFullAvatarUrl(Request.Scheme, Request.Host.ToString(), user.AvatarUrl),
                IsActive = user.IsActive,
                LastLoginAt = user.LastLoginAt,
                CreatedAt = user.CreatedAt,
                CreatedBy = user.CreatedBy,
                UpdatedAt = user.UpdatedAt,
                UpdatedBy = user.UpdatedBy
            };

            return Ok(new { data = userDto });
        }
        #endregion

        #region 🔹 POST/PUT/DELETE: CRUD
        /// <summary>
        /// Tạo mới người dùng
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] UserCreateDto request)
        {
            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
                return BadRequest(new { message = "Tên đăng nhập đã tồn tại" });

            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
                return BadRequest(new { message = "Email đã tồn tại" });

            var role = await _context.Roles.FindAsync(request.RoleId);
            if (role == null)
                return BadRequest(new { message = "Role không hợp lệ" });

            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var user = new User
            {
                UserId = Guid.NewGuid().ToString(),
                Username = request.Username,
                PasswordHash = _authService.HashPassword(request.Password),
                FullName = request.FullName,
                Email = request.Email,
                Phone = request.Phone,
                RoleId = request.RoleId,
                IsActive = request.IsActive,
                // ✅ Ảnh mặc định (default.png)
                AvatarUrl = "/uploads/avatars/default.png",
                CreatedAt = DateTime.UtcNow,
                CreatedBy = currentUserId
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Tạo người dùng thành công", userId = user.UserId });
        }

        /// <summary>
        /// Cập nhật thông tin người dùng
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UserUpdateAdminDto request)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.UserId != id))
                return BadRequest(new { message = "Email đã được sử dụng" });

            var role = await _context.Roles.FindAsync(request.RoleId);
            if (role == null)
                return BadRequest(new { message = "Role không hợp lệ" });

            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            user.FullName = request.FullName;
            user.Email = request.Email;
            user.Phone = request.Phone;
            user.RoleId = request.RoleId;
            user.IsActive = request.IsActive;
            user.UpdatedAt = DateTime.UtcNow;
            user.UpdatedBy = currentUserId;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Cập nhật người dùng thành công" });
        }

        /// <summary>
        /// Xoá mềm người dùng (không xoá khỏi DB)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (user.UserId == currentUserId)
                return BadRequest(new { message = "Không thể xoá tài khoản của chính bạn" });

            user.DeletedAt = DateTime.UtcNow;
            user.DeletedBy = currentUserId;
            user.IsActive = false;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xoá người dùng thành công" });
        }
        #endregion

        #region 🔹 PUT: Toggle trạng thái hoạt động
        /// <summary>
        /// Chuyển trạng thái hoạt động (Active/Inactive) cho người dùng
        /// </summary>
        [HttpPut("{id}/toggle-status")]
        public async Task<IActionResult> ToggleStatus(string id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null || user.DeletedAt != null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (user.UserId == currentUserId)
                return BadRequest(new { message = "Không thể vô hiệu hóa tài khoản của chính bạn" });

            user.IsActive = !user.IsActive;
            user.UpdatedAt = DateTime.UtcNow;
            user.UpdatedBy = currentUserId;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = $"Tài khoản {(user.IsActive ? "đã được kích hoạt" : "đã bị vô hiệu hoá")}",
                isActive = user.IsActive
            });
        }
        #endregion
    }
}
