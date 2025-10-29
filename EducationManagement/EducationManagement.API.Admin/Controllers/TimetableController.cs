using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using EducationManagement.BLL.Services;

namespace EducationManagement.API.Admin.Controllers
{
    [ApiController]
    [Route("api-edu/timetable")]
    public class TimetableController : ControllerBase
    {
        private readonly TimetableService _timetableService;

        public TimetableController(TimetableService timetableService)
        {
            _timetableService = timetableService;
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
    }
}


