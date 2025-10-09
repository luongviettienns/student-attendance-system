using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EducationManagement.DAL;
using EducationManagement.Common.DTOs.Student;
using EducationManagement.Common.Models;
using EducationManagement.BLL.Services;
using System.Security.Claims;
using StudentModel = EducationManagement.Common.Models.Student;

namespace EducationManagement.API.Student.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class StudentController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly AuthService _authService;

        public StudentController(AppDbContext context, AuthService authService)
        {
            _context = context;
            _authService = authService;
        }

        /// <summary>
        /// Lấy danh sách sinh viên với phân trang và tìm kiếm
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllStudents(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            [FromQuery] string? search = null,
            [FromQuery] string? facultyId = null,
            [FromQuery] string? majorId = null,
            [FromQuery] bool? isActive = null)
        {
            var query = _context.Students
                .Where(s => s.DeletedAt == null)
                .AsQueryable();

            // Tìm kiếm theo tên, mã sinh viên, email
            if (!string.IsNullOrEmpty(search))
            {
                query = query.Where(s =>
                    s.FullName.Contains(search) ||
                    s.StudentCode.Contains(search) ||
                    (s.Email != null && s.Email.Contains(search)));
            }

            // Lọc theo khoa
            if (!string.IsNullOrEmpty(facultyId))
            {
                query = query.Where(s => s.FacultyId == facultyId);
            }

            // Lọc theo ngành
            if (!string.IsNullOrEmpty(majorId))
            {
                query = query.Where(s => s.MajorId == majorId);
            }

            // Lọc theo trạng thái
            if (isActive.HasValue)
            {
                query = query.Where(s => s.IsActive == isActive.Value);
            }

            var totalCount = await query.CountAsync();

            var students = await query
                .OrderByDescending(s => s.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(s => new StudentListDto
                {
                    StudentId = s.StudentId,
                    StudentCode = s.StudentCode,
                    FullName = s.FullName,
                    Gender = s.Gender,
                    Dob = s.Dob,
                    Email = s.Email,
                    Phone = s.Phone,
                    FacultyId = s.FacultyId,
                    MajorId = s.MajorId,
                    AcademicYearId = s.AcademicYearId,
                    CohortYear = s.CohortYear,
                    IsActive = s.IsActive,
                    CreatedAt = s.CreatedAt,
                    CreatedBy = s.CreatedBy,
                    UpdatedAt = s.UpdatedAt,
                    UpdatedBy = s.UpdatedBy
                })
                .ToListAsync();

            return Ok(new
            {
                students,
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
        /// Lấy thông tin chi tiết sinh viên theo ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetStudentById(string id)
        {
            var student = await _context.Students
                .Include(s => s.StudentProfiles)
                .Include(s => s.StudentFamilies)
                .FirstOrDefaultAsync(s => s.StudentId == id && s.DeletedAt == null);

            if (student == null)
                return NotFound(new { message = "Không tìm thấy sinh viên" });

            var studentDto = new StudentDetailDto
            {
                StudentId = student.StudentId,
                UserId = student.UserId,
                StudentCode = student.StudentCode,
                FullName = student.FullName,
                Gender = student.Gender,
                Dob = student.Dob,
                Email = student.Email,
                Phone = student.Phone,
                FacultyId = student.FacultyId,
                MajorId = student.MajorId,
                AcademicYearId = student.AcademicYearId,
                CohortYear = student.CohortYear,
                IsActive = student.IsActive,
                CreatedAt = student.CreatedAt,
                CreatedBy = student.CreatedBy,
                UpdatedAt = student.UpdatedAt,
                UpdatedBy = student.UpdatedBy,
                Profile = student.StudentProfiles?.FirstOrDefault() != null ? new StudentProfileDto
                {
                    StudentId = student.StudentProfiles.First().StudentId,
                    Nationality = student.StudentProfiles.First().Nationality,
                    Ethnicity = student.StudentProfiles.First().Ethnicity,
                    Religion = student.StudentProfiles.First().Religion,
                    Hometown = student.StudentProfiles.First().Hometown,
                    CurrentAddress = student.StudentProfiles.First().CurrentAddress,
                    BankNo = student.StudentProfiles.First().BankNo,
                    BankName = student.StudentProfiles.First().BankName,
                    InsuranceNo = student.StudentProfiles.First().InsuranceNo,
                    IssuePlace = student.StudentProfiles.First().IssuePlace,
                    IssueDate = student.StudentProfiles.First().IssueDate,
                    Facebook = student.StudentProfiles.First().Facebook,
                    CreatedAt = student.StudentProfiles.First().CreatedAt,
                    CreatedBy = student.StudentProfiles.First().CreatedBy,
                    UpdatedAt = student.StudentProfiles.First().UpdatedAt,
                    UpdatedBy = student.StudentProfiles.First().UpdatedBy
                } : null,
                Family = student.StudentFamilies?.Select(f => new StudentFamilyDto
                {
                    StudentFamilyId = f.StudentFamilyId,
                    StudentId = f.StudentId,
                    RelationType = f.RelationType,
                    FullName = f.FullName,
                    BirthYear = f.BirthYear,
                    Phone = f.Phone,
                    Nationality = f.Nationality,
                    Ethnicity = f.Ethnicity,
                    Religion = f.Religion,
                    PermanentAddress = f.PermanentAddress,
                    Job = f.Job,
                    CreatedAt = f.CreatedAt,
                    CreatedBy = f.CreatedBy,
                    UpdatedAt = f.UpdatedAt,
                    UpdatedBy = f.UpdatedBy
                }).ToList()
            };

            return Ok(studentDto);
        }

        /// <summary>
        /// Lấy thông tin sinh viên theo mã sinh viên
        /// </summary>
        [HttpGet("by-code/{studentCode}")]
        public async Task<IActionResult> GetStudentByCode(string studentCode)
        {
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.StudentCode == studentCode && s.DeletedAt == null);

            if (student == null)
                return NotFound(new { message = "Không tìm thấy sinh viên với mã này" });

            var studentDto = new StudentListDto
            {
                StudentId = student.StudentId,
                StudentCode = student.StudentCode,
                FullName = student.FullName,
                Gender = student.Gender,
                Dob = student.Dob,
                Email = student.Email,
                Phone = student.Phone,
                FacultyId = student.FacultyId,
                MajorId = student.MajorId,
                AcademicYearId = student.AcademicYearId,
                CohortYear = student.CohortYear,
                IsActive = student.IsActive,
                CreatedAt = student.CreatedAt,
                CreatedBy = student.CreatedBy,
                UpdatedAt = student.UpdatedAt,
                UpdatedBy = student.UpdatedBy
            };

            return Ok(studentDto);
        }

        /// <summary>
        /// Tạo sinh viên mới
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateStudent([FromBody] StudentCreateDto createDto)
        {
            try
            {
                // Kiểm tra mã sinh viên đã tồn tại chưa
                var existingStudent = await _context.Students
                    .FirstOrDefaultAsync(s => s.StudentCode == createDto.StudentCode);
                
                if (existingStudent != null)
                {
                    return BadRequest(new { message = "Mã sinh viên đã tồn tại" });
                }

                // Kiểm tra username đã tồn tại chưa
                var existingUser = await _context.Users
                    .FirstOrDefaultAsync(u => u.Username == createDto.Username);
                
                if (existingUser != null)
                {
                    return BadRequest(new { message = "Tên đăng nhập đã tồn tại" });
                }

                // Tạo User trước
                var userId = Guid.NewGuid().ToString();
                var user = new User
                {
                    UserId = userId,
                    Username = createDto.Username,
                    PasswordHash = _authService.HashPassword(createDto.Password),
                    Email = createDto.Email,
                    Phone = createDto.Phone,
                    FullName = createDto.FullName,
                    RoleId = "role-003", // Student role
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    CreatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system"
                };

                _context.Users.Add(user);

                // Tạo Student
                var studentId = Guid.NewGuid().ToString();
                var student = new StudentModel
                {
                    StudentId = studentId,
                    UserId = userId,
                    StudentCode = createDto.StudentCode,
                    FullName = createDto.FullName,
                    Gender = createDto.Gender,
                    Dob = createDto.Dob,
                    Email = createDto.Email,
                    Phone = createDto.Phone,
                    FacultyId = createDto.FacultyId,
                    MajorId = createDto.MajorId,
                    AcademicYearId = createDto.AcademicYearId,
                    CohortYear = createDto.CohortYear,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    CreatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "system"
                };

                _context.Students.Add(student);

                await _context.SaveChangesAsync();

                return CreatedAtAction(nameof(GetStudentById), new { id = studentId }, new { 
                    message = "Tạo sinh viên thành công",
                    studentId = studentId,
                    studentCode = student.StudentCode
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi tạo sinh viên", error = ex.Message });
            }
        }

        /// <summary>
        /// Thêm dữ liệu mẫu để test
        /// </summary>
        [HttpPost("seed-data")]
        public async Task<IActionResult> SeedSampleData()
        {
            try
            {
                var sampleStudents = new[]
                {
                    new { Username = "sv2024002", StudentCode = "SV2024002", FullName = "Trần Thị B", Gender = "Nữ", Dob = new DateTime(2004, 3, 15), Email = "sv2024002@edu.com", Phone = "0912345679", FacultyId = "fac-001", MajorId = "maj-001", AcademicYearId = "year-001", CohortYear = "2024" },
                    new { Username = "sv2024003", StudentCode = "SV2024003", FullName = "Lê Văn C", Gender = "Nam", Dob = new DateTime(2004, 7, 22), Email = "sv2024003@edu.com", Phone = "0912345680", FacultyId = "fac-001", MajorId = "maj-001", AcademicYearId = "year-001", CohortYear = "2024" },
                    new { Username = "sv2024004", StudentCode = "SV2024004", FullName = "Phạm Thị D", Gender = "Nữ", Dob = new DateTime(2004, 11, 8), Email = "sv2024004@edu.com", Phone = "0912345681", FacultyId = "fac-002", MajorId = "maj-002", AcademicYearId = "year-001", CohortYear = "2024" },
                    new { Username = "sv2024005", StudentCode = "SV2024005", FullName = "Hoàng Văn E", Gender = "Nam", Dob = new DateTime(2004, 1, 30), Email = "sv2024005@edu.com", Phone = "0912345682", FacultyId = "fac-001", MajorId = "maj-001", AcademicYearId = "year-001", CohortYear = "2024" },
                    new { Username = "sv2024006", StudentCode = "SV2024006", FullName = "Vũ Thị F", Gender = "Nữ", Dob = new DateTime(2004, 9, 14), Email = "sv2024006@edu.com", Phone = "0912345683", FacultyId = "fac-002", MajorId = "maj-002", AcademicYearId = "year-001", CohortYear = "2024" }
                };

                var createdCount = 0;
                foreach (var sample in sampleStudents)
                {
                    // Kiểm tra đã tồn tại chưa
                    var existingStudent = await _context.Students
                        .FirstOrDefaultAsync(s => s.StudentCode == sample.StudentCode);
                    
                    if (existingStudent != null) continue;

                    // Tạo User
                    var userId = Guid.NewGuid().ToString();
                    var user = new User
                    {
                        UserId = userId,
                        Username = sample.Username,
                        PasswordHash = _authService.HashPassword("admin123"), // Mật khẩu mặc định
                        Email = sample.Email,
                        Phone = sample.Phone,
                        FullName = sample.FullName,
                        RoleId = "role-003",
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = "system"
                    };

                    _context.Users.Add(user);

                    // Tạo Student
                    var studentId = Guid.NewGuid().ToString();
                    var student = new StudentModel
                    {
                        StudentId = studentId,
                        UserId = userId,
                        StudentCode = sample.StudentCode,
                        FullName = sample.FullName,
                        Gender = sample.Gender,
                        Dob = sample.Dob,
                        Email = sample.Email,
                        Phone = sample.Phone,
                        FacultyId = sample.FacultyId,
                        MajorId = sample.MajorId,
                        AcademicYearId = sample.AcademicYearId,
                        CohortYear = sample.CohortYear,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = "system"
                    };

                    _context.Students.Add(student);
                    createdCount++;
                }

                await _context.SaveChangesAsync();

                return Ok(new { 
                    message = $"Đã tạo thành công {createdCount} sinh viên mẫu",
                    createdCount = createdCount
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi khi tạo dữ liệu mẫu", error = ex.Message });
            }
        }
    }
}




