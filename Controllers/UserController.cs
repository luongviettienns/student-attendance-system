using Microsoft.AspNetCore.Mvc;
using SimpleUserAPI.Models;
using System.Collections.Concurrent;

namespace SimpleUserAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserController : ControllerBase
    {
        // In-memory storage for demo purposes
        private static readonly ConcurrentDictionary<int, User> _users = new();
        private static int _nextId = 1;

        public UserController()
        {
            // Add some sample data
            if (_users.IsEmpty)
            {
                _users.TryAdd(_nextId, new User
                {
                    user_id = _nextId++,
                    user_name = "admin",
                    password = "admin123",
                    full_name = "Administrator",
                    email = "admin@example.com",
                    phone = "0123456789",
                    role = "Admin"
                });

                _users.TryAdd(_nextId, new User
                {
                    user_id = _nextId++,
                    user_name = "user1",
                    password = "user123",
                    full_name = "Nguyễn Văn A",
                    email = "user1@example.com",
                    phone = "0987654321",
                    role = "User"
                });
            }
        }

        /// <summary>
        /// Lấy danh sách tất cả users
        /// </summary>
        [HttpGet]
        public ActionResult<IEnumerable<User>> GetAllUsers()
        {
            return Ok(_users.Values);
        }

        /// <summary>
        /// Lấy user theo ID
        /// </summary>
        [HttpGet("{id}")]
        public ActionResult<User> GetUserById(int id)
        {
            if (_users.TryGetValue(id, out var user))
            {
                return Ok(user);
            }
            return NotFound($"Không tìm thấy user với ID: {id}");
        }

        /// <summary>
        /// Tạo user mới
        /// </summary>
        [HttpPost]
        public ActionResult<User> CreateUser([FromBody] User user)
        {
            if (user == null)
            {
                return BadRequest("Dữ liệu user không hợp lệ");
            }

            // Check if username already exists
            if (_users.Values.Any(u => u.user_name == user.user_name))
            {
                return BadRequest("Tên đăng nhập đã tồn tại");
            }

            user.user_id = _nextId++;
            user.created_at = DateTime.UtcNow;
            _users.TryAdd(user.user_id, user);

            return CreatedAtAction(nameof(GetUserById), new { id = user.user_id }, user);
        }

        /// <summary>
        /// Cập nhật user
        /// </summary>
        [HttpPut("{id}")]
        public ActionResult<User> UpdateUser(int id, [FromBody] User user)
        {
            if (user == null)
            {
                return BadRequest("Dữ liệu user không hợp lệ");
            }

            if (!_users.TryGetValue(id, out var existingUser))
            {
                return NotFound($"Không tìm thấy user với ID: {id}");
            }

            // Check if username already exists (excluding current user)
            if (_users.Values.Any(u => u.user_name == user.user_name && u.user_id != id))
            {
                return BadRequest("Tên đăng nhập đã tồn tại");
            }

            user.user_id = id;
            user.created_at = existingUser.created_at;
            user.updated_at = DateTime.UtcNow;
            _users.TryUpdate(id, user, existingUser);

            return Ok(user);
        }

        /// <summary>
        /// Xóa user
        /// </summary>
        [HttpDelete("{id}")]
        public ActionResult DeleteUser(int id)
        {
            if (_users.TryRemove(id, out var user))
            {
                return Ok($"Đã xóa user: {user.full_name}");
            }
            return NotFound($"Không tìm thấy user với ID: {id}");
        }

        /// <summary>
        /// Tìm kiếm user theo tên
        /// </summary>
        [HttpGet("search")]
        public ActionResult<IEnumerable<User>> SearchUsers([FromQuery] string name)
        {
            if (string.IsNullOrEmpty(name))
            {
                return Ok(_users.Values);
            }

            var results = _users.Values.Where(u => 
                u.full_name.Contains(name, StringComparison.OrdinalIgnoreCase) ||
                u.user_name.Contains(name, StringComparison.OrdinalIgnoreCase)
            );

            return Ok(results);
        }
    }
}


