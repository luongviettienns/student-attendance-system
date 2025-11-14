using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using EducationManagement.BLL.Services;
using System.Text;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Route("api-edu/timetable")]
    public class TimetableController : ControllerBase
    {
        private readonly TimetableService _timetableService;
        private readonly TimetableExportService _exportService;

        public TimetableController(TimetableService timetableService, TimetableExportService exportService)
        {
            _timetableService = timetableService;
            _exportService = exportService;
        }

        // GET: /api-edu/timetable/student?studentId=...&year=2025&week=12
        [HttpGet("student")]
        [Authorize]
        public async Task<IActionResult> GetStudent([FromQuery] string studentId, [FromQuery] int year, [FromQuery] int week)
        {
            if (string.IsNullOrWhiteSpace(studentId)) return BadRequest(new { message = "studentId required" });
            var data = await _timetableService.GetStudentTimetableByWeekAsync(studentId, year, week);
            return Ok(new { data });
        }

        // GET: /api-edu/timetable/lecturer?lecturerId=...&year=2025&week=12
        [HttpGet("lecturer")]
        [Authorize]
        public async Task<IActionResult> GetLecturer([FromQuery] string lecturerId, [FromQuery] int year, [FromQuery] int week)
        {
            if (string.IsNullOrWhiteSpace(lecturerId)) return BadRequest(new { message = "lecturerId required" });
            var data = await _timetableService.GetLecturerTimetableByWeekAsync(lecturerId, year, week);
            return Ok(new { data });
        }

        // GET: /api-edu/timetable/sessions?year=2025&week=12
        [HttpGet("sessions")]
        [Authorize]
        public async Task<IActionResult> GetAllSessions([FromQuery] int year, [FromQuery] int week)
        {
            var data = await _timetableService.GetAllSessionsByWeekAsync(year, week);
            return Ok(new { data });
        }

        // GET: /api-edu/timetable/sessions/class?classId=...&week=12
        [HttpGet("sessions/class")]
        [Authorize]
        public async Task<IActionResult> GetSessionsByClass([FromQuery] string classId, [FromQuery] int week)
        {
            if (string.IsNullOrWhiteSpace(classId))
                return BadRequest(new { message = "classId required" });
            
            var data = await _timetableService.GetSessionsByClassAndWeekAsync(classId, week);
            return Ok(new { data });
        }

        // DELETE: /api-edu/timetable/session/{id}
        [HttpDelete("session/{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteSession(string id)
        {
            var ok = await _timetableService.DeleteSessionAsync(id, User.Identity?.Name ?? "System");
            if (!ok) return NotFound(new { message = "sessionId không tồn tại" });
            return Ok(new { sessionId = id, deleted = true });
        }

        // GET: /api-edu/rooms?search=&isActive=true
        [HttpGet("/api-edu/rooms")]
        [Authorize]
        public async Task<IActionResult> GetRooms([FromQuery] string? search, [FromQuery] bool? isActive)
        {
            var data = await _timetableService.GetRoomsAsync(search, isActive);
            return Ok(new { data });
        }

        // POST: /api-edu/timetable/conflicts
        [HttpPost("conflicts")]
        [Authorize]
        public async Task<IActionResult> CheckConflicts([FromBody] TimetableConflictCheckInput input)
        {
            var conflicts = await _timetableService.CheckConflictsAsync(input);
            return Ok(new { data = conflicts });
        }

        // POST: /api-edu/timetable/session
        [HttpPost("session")]
        [Authorize]
        public async Task<IActionResult> CreateSession([FromBody] TimetableCreateInput input)
        {
            try
            {
                var (has, detail) = await _timetableService.ValidateBeforeSaveAsync(input);
                if (has)
                    return StatusCode(StatusCodes.Status409Conflict, new { message = "Conflicts detected", data = detail });

                var id = await _timetableService.CreateSessionAsync(input);
                return Ok(new { sessionId = id });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // PUT: /api-edu/timetable/session/{id}
        [HttpPut("session/{id}")]
        [Authorize]
        public async Task<IActionResult> UpdateSession(string id, [FromBody] TimetableUpdateInput input)
        {
            var check = new TimetableConflictCheckInput
            {
                SessionId = id,
                ClassId = string.Empty,
                SubjectId = string.Empty,
                LecturerId = input.LecturerId,
                RoomId = input.RoomId,
                SchoolYearId = null,
                WeekNo = input.WeekNo,
                Weekday = input.Weekday,
                StartTime = input.StartTime,
                EndTime = input.EndTime
            };
            var (has, detail) = await _timetableService.ValidateBeforeSaveAsync(check);
            if (has)
                return StatusCode(StatusCodes.Status409Conflict, new { message = "Conflicts detected", data = detail });
            try
            {
                await _timetableService.UpdateSessionAsync(id, input);
                return Ok(new { sessionId = id });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ============================================
        // NEW FEATURES: Advanced Timetable Operations
        // ============================================

        // POST: /api-edu/timetable/sessions/bulk
        [HttpPost("sessions/bulk")]
        [Authorize]
        public async Task<IActionResult> BulkCreateSessions([FromBody] BulkCreateSessionsInput input)
        {
            try
            {
                input.Actor = User.Identity?.Name ?? "System";
                var result = await _timetableService.BulkCreateSessionsAsync(input);
                return Ok(new { data = result });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // POST: /api-edu/timetable/sessions/copy
        [HttpPost("sessions/copy")]
        [Authorize]
        public async Task<IActionResult> CopySessions([FromBody] CopySessionsInput input)
        {
            try
            {
                input.Actor = User.Identity?.Name ?? "System";
                var result = await _timetableService.CopySessionsAsync(input);
                return Ok(new { data = result });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // POST: /api-edu/timetable/conflicts/suggestions
        [HttpPost("conflicts/suggestions")]
        [Authorize]
        public async Task<IActionResult> GetConflictSuggestions([FromBody] TimetableConflictCheckInput input)
        {
            var suggestions = await _timetableService.GetConflictSuggestionsAsync(input);
            return Ok(new { data = suggestions });
        }

        // GET: /api-edu/timetable/semester?schoolYearId=...&semester=1&classId=...
        [HttpGet("semester")]
        [Authorize]
        public async Task<IActionResult> GetSessionsBySemester(
            [FromQuery] string schoolYearId, 
            [FromQuery] int semester,
            [FromQuery] string? classId = null)
        {
            if (string.IsNullOrWhiteSpace(schoolYearId))
                return BadRequest(new { message = "schoolYearId required" });
            
            var data = await _timetableService.GetSessionsBySemesterAsync(schoolYearId, semester, classId);
            return Ok(new { data });
        }

        // POST: /api-edu/timetable/session/recurrence
        [HttpPost("session/recurrence")]
        [Authorize]
        public async Task<IActionResult> CreateSessionWithRecurrence(
            [FromBody] TimetableCreateWithRecurrenceInput input)
        {
            try
            {
                input.Actor = User.Identity?.Name ?? "System";
                var result = await _timetableService.CreateSessionWithRecurrenceAsync(
                    input, 
                    input.StartDate, 
                    input.EndDate);
                return Ok(new { data = result });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // ============================================
        // EXPORT ENDPOINTS
        // ============================================

        // GET: /api-edu/timetable/export/student?studentId=...&year=2025&week=12&format=csv
        [HttpGet("export/student")]
        [Authorize]
        public async Task<IActionResult> ExportStudentTimetable(
            [FromQuery] string studentId,
            [FromQuery] int year,
            [FromQuery] int week,
            [FromQuery] string format = "csv")
        {
            if (string.IsNullOrWhiteSpace(studentId))
                return BadRequest(new { message = "studentId required" });

            try
            {
                if (format.ToLower() == "excel" || format.ToLower() == "xls")
                {
                    var content = await _exportService.ExportStudentTimetableToExcelAsync(studentId, year, week);
                    var bytes = Encoding.UTF8.GetBytes(content);
                    return File(bytes, "application/vnd.ms-excel", $"ThoiKhoaBieu_SV_Tuan{week}_{year}.xls");
                }
                else
                {
                    var content = await _exportService.ExportStudentTimetableToCsvAsync(studentId, year, week);
                    var bytes = Encoding.UTF8.GetBytes(content);
                    return File(bytes, "text/csv; charset=utf-8", $"ThoiKhoaBieu_SV_Tuan{week}_{year}.csv");
                }
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // GET: /api-edu/timetable/export/lecturer?lecturerId=...&year=2025&week=12&format=csv
        [HttpGet("export/lecturer")]
        [Authorize]
        public async Task<IActionResult> ExportLecturerTimetable(
            [FromQuery] string lecturerId,
            [FromQuery] int year,
            [FromQuery] int week,
            [FromQuery] string format = "csv")
        {
            if (string.IsNullOrWhiteSpace(lecturerId))
                return BadRequest(new { message = "lecturerId required" });

            try
            {
                var content = await _exportService.ExportLecturerTimetableToCsvAsync(lecturerId, year, week);
                var bytes = Encoding.UTF8.GetBytes(content);
                return File(bytes, "text/csv; charset=utf-8", $"ThoiKhoaBieu_GV_Tuan{week}_{year}.csv");
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        // GET: /api-edu/timetable/export/semester?schoolYearId=...&semester=1&classId=...&format=csv
        [HttpGet("export/semester")]
        [Authorize]
        public async Task<IActionResult> ExportSemesterTimetable(
            [FromQuery] string schoolYearId,
            [FromQuery] int semester,
            [FromQuery] string? classId = null,
            [FromQuery] string format = "csv")
        {
            if (string.IsNullOrWhiteSpace(schoolYearId))
                return BadRequest(new { message = "schoolYearId required" });

            try
            {
                var content = await _exportService.ExportSemesterTimetableToCsvAsync(schoolYearId, semester, classId);
                var bytes = Encoding.UTF8.GetBytes(content);
                var filename = classId != null 
                    ? $"ThoiKhoaBieu_HK{semester}_{schoolYearId}_Lop{classId}.csv"
                    : $"ThoiKhoaBieu_HK{semester}_{schoolYearId}.csv";
                return File(bytes, "text/csv; charset=utf-8", filename);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}


