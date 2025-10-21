using Microsoft.AspNetCore.Mvc;
using EducationManagement.DAL.Repositories;
using Microsoft.AspNetCore.Authorization;

namespace EducationManagement.API.Admin.Controllers
{
    /// <summary>
    /// Controller quản lý mối quan hệ giảng viên - môn học (qua classes)
    /// </summary>
    [ApiController]
    [Authorize]
    [Route("api-edu/admin/lecturersubject")]
    public class LecturerSubjectController : ControllerBase
    {
        private readonly ClassRepository _classRepository;
        private readonly LecturerRepository _lecturerRepository;
        private readonly SubjectRepository _subjectRepository;

        public LecturerSubjectController(
            ClassRepository classRepository,
            LecturerRepository lecturerRepository,
            SubjectRepository subjectRepository)
        {
            _classRepository = classRepository;
            _lecturerRepository = lecturerRepository;
            _subjectRepository = subjectRepository;
        }

        // ============================================================
        // 🔹 GET: Lấy danh sách môn học mà giảng viên đang dạy
        // ============================================================
        [HttpGet("lecturer/{lecturerId}")]
        public async Task<IActionResult> GetSubjectsByLecturer(string lecturerId)
        {
            try
            {
                var classes = await _classRepository.GetAllAsync();
                var lecturerClasses = classes.FindAll(c => c.LecturerId == lecturerId);
                
                // Get unique subjects
                var subjectIds = lecturerClasses.Select(c => c.SubjectId).Distinct().ToList();
                var allSubjects = await _subjectRepository.GetAllAsync();
                var subjects = allSubjects.FindAll(s => subjectIds.Contains(s.SubjectId));

                var result = subjects.Select(s => new
                {
                    s.SubjectId,
                    s.SubjectCode,
                    s.SubjectName,
                    s.Credits,
                    ClassCount = lecturerClasses.Count(c => c.SubjectId == s.SubjectId)
                });

                return Ok(new { data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 GET: Lấy danh sách giảng viên đang dạy một môn học
        // ============================================================
        [HttpGet("subject/{subjectId}")]
        public async Task<IActionResult> GetLecturersBySubject(string subjectId)
        {
            try
            {
                var classes = await _classRepository.GetAllAsync();
                var subjectClasses = classes.FindAll(c => c.SubjectId == subjectId);
                
                // Get unique lecturers
                var lecturerIds = subjectClasses.Select(c => c.LecturerId).Distinct().ToList();
                var allLecturers = await _lecturerRepository.GetAllAsync();
                var lecturers = allLecturers.FindAll(l => lecturerIds.Contains(l.LecturerId));

                var result = lecturers.Select(l => new
                {
                    l.LecturerId,
                    l.UserId,
                    l.FullName,
                    l.Email,
                    l.DepartmentName,
                    l.AcademicTitle,
                    l.Degree,
                    ClassCount = subjectClasses.Count(c => c.LecturerId == l.LecturerId)
                });

                return Ok(new { data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================================
        // 🔹 GET: Lấy giảng viên khả dụng cho môn học (trong cùng department)
        // ============================================================
        [HttpGet("available/{subjectId}")]
        public async Task<IActionResult> GetAvailableLecturersForSubject(string subjectId)
        {
            try
            {
                // Get subject to find its department
                var subject = await _subjectRepository.GetByIdAsync(subjectId);
                if (subject == null)
                    return NotFound(new { message = "Không tìm thấy môn học" });

                // Get all lecturers in the same department
                var allLecturers = await _lecturerRepository.GetAllAsync();
                var availableLecturers = allLecturers.FindAll(l => 
                    l.DepartmentId == subject.DepartmentId && l.IsActive);

                var result = availableLecturers.Select(l => new
                {
                    l.LecturerId,
                    l.UserId,
                    l.FullName,
                    l.Email,
                    l.DepartmentName,
                    l.AcademicTitle,
                    l.Degree,
                    l.Specialization,
                    l.Position
                });

                return Ok(new { data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }
}

