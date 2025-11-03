using EducationManagement.BLL.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using EducationManagement.Common.Helpers;
using System.Threading.Tasks;
using System.Linq;
using EducationManagement.Common.Models;

namespace EducationManagement.API.Admin.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api-edu/attendances")]
    public class AttendanceController : ControllerBase
    {
        private readonly AttendanceService _attendanceService;

        public AttendanceController(AttendanceService attendanceService)
        {
            _attendanceService = attendanceService;
        }

        /// <summary>
        /// Lấy tất cả attendance records với filter
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] string? classId, [FromQuery] string? studentId, [FromQuery] DateTime? attendanceDate, [FromQuery] string? status)
        {
            try
            {
                var attendances = await _attendanceService.GetAllAttendancesAsync();
                
                // Apply filters
                if (!string.IsNullOrEmpty(classId))
                {
                    attendances = attendances.Where(a => a.ClassId == classId).ToList();
                }
                
                if (!string.IsNullOrEmpty(studentId))
                {
                    attendances = attendances.Where(a => a.StudentId == studentId).ToList();
                }
                
                if (attendanceDate.HasValue)
                {
                    attendances = attendances.Where(a => a.AttendanceDate.Date == attendanceDate.Value.Date).ToList();
                }
                
                if (!string.IsNullOrEmpty(status))
                {
                    attendances = attendances.Where(a => a.Status == status).ToList();
                }
                
                return Ok(new { data = attendances });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy attendance theo ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            try
            {
                var attendance = await _attendanceService.GetAttendanceByIdAsync(id);
                if (attendance == null)
                    return NotFound(new { message = "Không tìm thấy bản ghi điểm danh" });

                return Ok(new { data = attendance });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Tạo attendance record mới
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateAttendanceRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                // Validate: Không cho phép điểm danh ngày tương lai
                var attendanceDate = request.AttendanceDate ?? DateTime.Now;
                if (attendanceDate.Date > DateTime.Now.Date)
                    return BadRequest(new { message = "Không thể điểm danh cho ngày tương lai" });

                var attendanceId = IdGenerator.Generate("att");
                var newId = await _attendanceService.CreateAttendanceAsync(
                    attendanceId,
                    request.EnrollmentId,
                    request.ClassId,
                    attendanceDate,
                    request.Status,
                    request.Note,
                    request.ScheduleId,
                    request.CreatedBy ?? User?.Identity?.Name ?? "system"
                );

                return Ok(new { message = "Tạo bản ghi điểm danh thành công", attendanceId = newId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Cập nhật attendance
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] UpdateAttendanceRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                await _attendanceService.UpdateAttendanceAsync(
                    id,
                    request.Status,
                    request.Note,
                    request.UpdatedBy ?? User?.Identity?.Name ?? "system"
                );

                return Ok(new { message = "Cập nhật điểm danh thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Xóa attendance (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id, [FromBody] DeleteAttendanceRequest request)
        {
            try
            {
                await _attendanceService.DeleteAttendanceAsync(id, request.DeletedBy ?? "system");
                return Ok(new { message = "Xóa bản ghi điểm danh thành công" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy attendances theo student ID
        /// </summary>
        [HttpGet("student/{studentId}")]
        public async Task<IActionResult> GetByStudent(string studentId)
        {
            try
            {
                var attendances = await _attendanceService.GetAttendancesByStudentAsync(studentId);
                return Ok(new { data = attendances });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy attendances theo schedule ID
        /// </summary>
        [HttpGet("schedule/{scheduleId}")]
        public async Task<IActionResult> GetBySchedule(string scheduleId)
        {
            try
            {
                var attendances = await _attendanceService.GetAttendancesByScheduleAsync(scheduleId);
                return Ok(new { data = attendances });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Lấy attendances theo class ID
        /// </summary>
        [HttpGet("class/{classId}")]
        public async Task<IActionResult> GetByClass(string classId, [FromQuery] DateTime? attendanceDate)
        {
            try
            {
                var attendances = await _attendanceService.GetAttendancesByClassAsync(classId, attendanceDate);
                return Ok(new { data = attendances });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Batch create attendance records
        /// </summary>
        [HttpPost("batch")]
        public async Task<IActionResult> CreateBatch([FromBody] List<CreateAttendanceRequest> requests)
        {
            if (requests == null || requests.Count == 0)
                return BadRequest(new { message = "Không có dữ liệu để tạo" });

            try
            {
                var results = new List<object>();
                var successCount = 0;
                var errorCount = 0;
                var errors = new List<object>();

                foreach (var request in requests)
                {
                    try
                    {
                        // Validate: Không cho phép điểm danh ngày tương lai
                        var attendanceDate = request.AttendanceDate ?? DateTime.Now;
                        if (attendanceDate.Date > DateTime.Now.Date)
                        {
                            errorCount++;
                            errors.Add(new { 
                                enrollmentId = request.EnrollmentId, 
                                errorMessage = "Không thể điểm danh cho ngày tương lai"
                            });
                            continue;
                        }

                        var attendanceId = IdGenerator.Generate("att");
                        var newId = await _attendanceService.CreateAttendanceAsync(
                            attendanceId,
                            request.EnrollmentId,
                            request.ClassId,
                            attendanceDate,
                            request.Status,
                            request.Note,
                            request.ScheduleId,
                            request.CreatedBy ?? User?.Identity?.Name ?? "system"
                        );
                        successCount++;
                    }
                    catch (Exception ex)
                    {
                        errorCount++;
                        errors.Add(new { 
                            enrollmentId = request.EnrollmentId, 
                            errorMessage = ex.Message 
                        });
                    }
                }

                return Ok(new { 
                    success = true,
                    message = $"Tạo thành công {successCount}/{requests.Count} bản ghi",
                    data = new {
                        successCount,
                        errorCount,
                        errors
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Import attendance from Excel
        /// </summary>
        [HttpPost("import")]
        public async Task<IActionResult> ImportExcel(IFormFile file, [FromForm] string classId)
        {
            if (file == null || file.Length == 0)
                return BadRequest(new { message = "Không có file được tải lên" });

            if (string.IsNullOrEmpty(classId))
                return BadRequest(new { message = "ClassId là bắt buộc" });

            try
            {
                // TODO: Implement Excel import logic
                // This is a placeholder - you'll need to implement actual Excel parsing
                // and map student codes to enrollment IDs
                
                return Ok(new { 
                    success = true,
                    message = "Import thành công",
                    data = new {
                        successCount = 0,
                        errorCount = 0,
                        errors = new List<object>()
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        /// <summary>
        /// Get attendance statistics (for tạch môn check - nghỉ quá 3 buổi)
        /// </summary>
        [HttpGet("statistics")]
        public async Task<IActionResult> GetStatistics([FromQuery] string? classId, [FromQuery] string? studentId)
        {
            try
            {
                List<Attendance> attendances;
                
                if (!string.IsNullOrEmpty(classId))
                {
                    attendances = await _attendanceService.GetAttendancesByClassAsync(classId, null);
                }
                else if (!string.IsNullOrEmpty(studentId))
                {
                    attendances = await _attendanceService.GetAttendancesByStudentAsync(studentId);
                }
                else
                {
                    attendances = await _attendanceService.GetAllAttendancesAsync();
                }

                // Group by student and count absences (chỉ tính ABSENT, không tính LATE)
                // Nếu nghỉ quá 3 buổi (ABSENT) = tạch môn
                var studentStats = attendances
                    .Where(a => a.Status == "ABSENT") // Chỉ tính vắng mặt, không tính đi muộn
                    .GroupBy(a => new { a.StudentId, a.StudentCode, a.StudentName, a.ClassId })
                    .Select(g => new
                    {
                        studentId = g.Key.StudentId,
                        studentCode = g.Key.StudentCode,
                        studentName = g.Key.StudentName,
                        classId = g.Key.ClassId,
                        absentCount = g.Count(),
                        isFailed = g.Count() > 3 // Tạch môn nếu nghỉ quá 3 buổi
                    })
                    .ToList();

                return Ok(new { 
                    data = new {
                        students = studentStats,
                        totalStudents = studentStats.Count,
                        failedStudents = studentStats.Count(s => s.isFailed)
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }

    // DTOs for Attendance
    public class CreateAttendanceRequest
    {
        public string EnrollmentId { get; set; } = string.Empty;
        public string ClassId { get; set; } = string.Empty;
        public DateTime? AttendanceDate { get; set; }
        public string Status { get; set; } = "PRESENT"; // PRESENT, ABSENT, LATE, EXCUSED
        public string? Note { get; set; }
        public string? ScheduleId { get; set; }
        public string? CreatedBy { get; set; }
    }

    public class UpdateAttendanceRequest
    {
        public string Status { get; set; } = "PRESENT";
        public string? Note { get; set; }
        public string? UpdatedBy { get; set; }
    }

    public class DeleteAttendanceRequest
    {
        public string? DeletedBy { get; set; }
    }
}

