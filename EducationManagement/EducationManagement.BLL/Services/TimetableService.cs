using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using EducationManagement.DAL.Repositories;

namespace EducationManagement.BLL.Services
{
    public class TimetableService
    {
        private readonly TimetableRepository _repo;

        public TimetableService(TimetableRepository repo)
        {
            _repo = repo;
        }

        public async Task<List<TimetableSessionDto>> GetStudentTimetableByWeekAsync(string studentId, int year, int weekNo)
        {
            var dt = await _repo.GetStudentTimetableByWeekAsync(studentId, year, weekNo);
            return MapSessions(dt);
        }

        public async Task<List<TimetableSessionDto>> GetLecturerTimetableByWeekAsync(string lecturerId, int year, int weekNo)
        {
            var dt = await _repo.GetLecturerTimetableByWeekAsync(lecturerId, year, weekNo);
            return MapSessions(dt);
        }

        public async Task<List<TimetableSessionDto>> GetAllSessionsByWeekAsync(int year, int weekNo)
        {
            var dt = await _repo.GetAllSessionsByWeekAsync(year, weekNo);
            return MapSessions(dt);
        }

        private static List<TimetableSessionDto> MapSessions(DataTable dt)
        {
            var list = new List<TimetableSessionDto>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new TimetableSessionDto
                {
                    SessionId = r["session_id"].ToString()!,
                    WeekNo = r.Table.Columns.Contains("week_no") && r["week_no"] != DBNull.Value ? Convert.ToInt32(r["week_no"]) : (int?)null,
                    Weekday = Convert.ToInt32(r["weekday"]),
                    StartTime = TimeSpan.Parse(r["start_time"].ToString()!),
                    EndTime = TimeSpan.Parse(r["end_time"].ToString()!),
                    PeriodFrom = r["period_from"] == DBNull.Value ? null : Convert.ToInt32(r["period_from"]).ToString(),
                    PeriodTo = r["period_to"] == DBNull.Value ? null : Convert.ToInt32(r["period_to"]).ToString(),
                    Status = r.Table.Columns.Contains("status") ? r["status"]?.ToString() : null,
                    ClassId = r["class_id"].ToString()!,
                    ClassCode = r["class_code"].ToString()!,
                    ClassName = r["class_name"].ToString()!,
                    SubjectId = r["subject_id"].ToString()!,
                    SubjectName = r["subject_name"].ToString()!,
                    LecturerId = r.Table.Columns.Contains("lecturer_id") ? r["lecturer_id"]?.ToString() : null,
                    LecturerName = r.Table.Columns.Contains("lecturer_name") ? r["lecturer_name"]?.ToString() : null,
                    RoomId = r.Table.Columns.Contains("room_id") ? r["room_id"]?.ToString() : null,
                    RoomCode = r.Table.Columns.Contains("room_code") ? r["room_code"]?.ToString() : null,
                    SchoolYearId = r.Table.Columns.Contains("school_year_id") ? r["school_year_id"]?.ToString() : null,
                    SchoolYearCode = r.Table.Columns.Contains("year_code") ? r["year_code"]?.ToString() : null
                });
            }
            return list;
        }

        public async Task<TimetableConflicts> CheckConflictsAsync(TimetableConflictCheckInput input)
        {
            var ds = await _repo.CheckConflictsAsync(
                input.SessionId,
                input.ClassId,
                input.SubjectId,
                input.LecturerId,
                input.RoomId,
                input.SchoolYearId,
                input.WeekNo,
                input.Weekday,
                input.StartTime,
                input.EndTime);

            var result = new TimetableConflicts();
            if (ds.Tables.Count > 0) result.LecturerConflicts = MapConflictRows(ds.Tables[0]);
            if (ds.Tables.Count > 1) result.RoomConflicts = MapConflictRows(ds.Tables[1]);
            if (ds.Tables.Count > 2) result.StudentConflicts = MapStudentConflictRows(ds.Tables[2]);
            if (ds.Tables.Count > 3 && ds.Tables[3].Rows.Count > 0)
            {
                var r = ds.Tables[3].Rows[0];
                result.RoomCapacity = r["room_capacity"] == DBNull.Value ? null : Convert.ToInt32(r["room_capacity"]);
                result.Enrolled = r["enrolled"] == DBNull.Value ? 0 : Convert.ToInt32(r["enrolled"]);
                result.IsOverCapacity = r["is_over_capacity"] != DBNull.Value && Convert.ToInt32(r["is_over_capacity"]) == 1;
            }
            return result;
        }

        public async Task<(bool HasConflict, TimetableConflicts Conflicts)> ValidateBeforeSaveAsync(TimetableConflictCheckInput input)
        {
            var conflicts = await CheckConflictsAsync(input);
            var has = (conflicts.LecturerConflicts.Any() || conflicts.RoomConflicts.Any() || conflicts.StudentConflicts.Any() || conflicts.IsOverCapacity);
            return (has, conflicts);
        }

        public async Task<string> CreateSessionAsync(TimetableCreateInput input)
        {
            var fkErrors = await ValidateForeignKeysAsync(new TimetableForeignKeys
            {
                ClassId = input.ClassId,
                SubjectId = input.SubjectId,
                LecturerId = input.LecturerId,
                RoomId = input.RoomId,
                SchoolYearId = input.SchoolYearId
            });
            if (fkErrors.Any())
                throw new InvalidOperationException(string.Join("; ", fkErrors));

            var id = Guid.NewGuid().ToString("N");
            await _repo.InsertSessionAsync(id, input.ClassId, input.SubjectId, input.LecturerId, input.RoomId,
                input.SchoolYearId, input.WeekNo, input.Weekday, input.StartTime, input.EndTime,
                input.PeriodFrom, input.PeriodTo, input.Recurrence, input.Status, input.Actor);
            return id;
        }

        public async Task UpdateSessionAsync(string sessionId, TimetableUpdateInput input)
        {
            var fkErrors = await ValidateForeignKeysAsync(new TimetableForeignKeys
            {
                LecturerId = input.LecturerId,
                RoomId = input.RoomId
            }, updateMode:true);
            if (fkErrors.Any())
                throw new InvalidOperationException(string.Join("; ", fkErrors));

            await _repo.UpdateSessionAsync(sessionId, input.LecturerId, input.RoomId, input.WeekNo, input.Weekday,
                input.StartTime, input.EndTime, input.PeriodFrom, input.PeriodTo, input.Recurrence, input.Status, input.Actor);
        }

        // NEW: Soft delete session (validate existence)
        public async Task<bool> DeleteSessionAsync(string sessionId, string? actor)
        {
            if (!await _repo.ExistsSessionAsync(sessionId)) return false;
            var n = await _repo.SoftDeleteSessionAsync(sessionId, actor);
            return n > 0;
        }

        private static List<TimetableConflictItem> MapConflictRows(DataTable dt)
        {
            var list = new List<TimetableConflictItem>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new TimetableConflictItem
                {
                    ExistingSessionId = r["existing_session_id"].ToString()!,
                    WeekNo = r.Table.Columns.Contains("week_no") && r["week_no"] != DBNull.Value ? Convert.ToInt32(r["week_no"]) : (int?)null,
                    Weekday = Convert.ToInt32(r["weekday"]),
                    StartTime = TimeSpan.Parse(r["start_time"].ToString()!),
                    EndTime = TimeSpan.Parse(r["end_time"].ToString()!),
                    ClassCode = r.Table.Columns.Contains("class_code") ? r["class_code"]?.ToString() : null,
                    RoomCode = r.Table.Columns.Contains("room_code") ? r["room_code"]?.ToString() : null
                });
            }
            return list;
        }

        private static List<TimetableStudentConflictItem> MapStudentConflictRows(DataTable dt)
        {
            var list = new List<TimetableStudentConflictItem>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new TimetableStudentConflictItem
                {
                    ExistingSessionId = r["existing_session_id"].ToString()!,
                    StudentId = r["student_id"].ToString()!,
                    StudentCode = r["student_code"].ToString()!,
                    StudentName = r["student_name"].ToString()!,
                    WeekNo = r.Table.Columns.Contains("week_no") && r["week_no"] != DBNull.Value ? Convert.ToInt32(r["week_no"]) : (int?)null,
                    Weekday = Convert.ToInt32(r["weekday"]),
                    StartTime = TimeSpan.Parse(r["start_time"].ToString()!),
                    EndTime = TimeSpan.Parse(r["end_time"].ToString()!),
                    ClassCode = r.Table.Columns.Contains("class_code") ? r["class_code"]?.ToString() : null
                });
            }
            return list;
        }

        // NEW: List rooms for FE to pick
        public async Task<List<RoomDto>> GetRoomsAsync(string? search, bool? isActive)
        {
            var dt = await _repo.GetRoomsAsync(search, isActive);
            var list = new List<RoomDto>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new RoomDto
                {
                    RoomId = r["room_id"].ToString()!,
                    RoomCode = r["room_code"].ToString()!,
                    Building = r["building"]?.ToString(),
                    Capacity = r["capacity"] == DBNull.Value ? null : Convert.ToInt32(r["capacity"]),
                    IsActive = Convert.ToBoolean(r["is_active"])
                });
            }
            return list;
        }

        private async Task<List<string>> ValidateForeignKeysAsync(TimetableForeignKeys keys, bool updateMode = false)
        {
            var errors = new List<string>();
            if (!updateMode)
            {
                if (string.IsNullOrWhiteSpace(keys.ClassId) || !await _repo.ExistsClassAsync(keys.ClassId!))
                    errors.Add("classId không tồn tại");
                if (string.IsNullOrWhiteSpace(keys.SubjectId) || !await _repo.ExistsSubjectAsync(keys.SubjectId!))
                    errors.Add("subjectId không tồn tại");
                if (!string.IsNullOrWhiteSpace(keys.SchoolYearId) && !await _repo.ExistsSchoolYearAsync(keys.SchoolYearId!))
                    errors.Add("schoolYearId không tồn tại");
            }
            if (!string.IsNullOrWhiteSpace(keys.LecturerId) && !await _repo.ExistsLecturerAsync(keys.LecturerId!))
                errors.Add("lecturerId không tồn tại");
            if (!string.IsNullOrWhiteSpace(keys.RoomId) && !await _repo.ExistsRoomAsync(keys.RoomId!))
                errors.Add("roomId không tồn tại");
            return errors;
        }
    }

    public class TimetableSessionDto
    {
        public string SessionId { get; set; } = string.Empty;
        public int? WeekNo { get; set; }
        public int Weekday { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public string? PeriodFrom { get; set; }
        public string? PeriodTo { get; set; }
        public string? Status { get; set; }
        public string ClassId { get; set; } = string.Empty;
        public string ClassCode { get; set; } = string.Empty;
        public string ClassName { get; set; } = string.Empty;
        public string SubjectId { get; set; } = string.Empty;
        public string SubjectName { get; set; } = string.Empty;
        public string? LecturerId { get; set; }
        public string? LecturerName { get; set; }
        public string? RoomId { get; set; }
        public string? RoomCode { get; set; }
        public string? SchoolYearId { get; set; }
        public string? SchoolYearCode { get; set; }
    }

    public class TimetableConflictCheckInput
    {
        public string? SessionId { get; set; }
        public string ClassId { get; set; } = string.Empty;
        public string SubjectId { get; set; } = string.Empty;
        public string? LecturerId { get; set; }
        public string? RoomId { get; set; }
        public string? SchoolYearId { get; set; }
        public int? WeekNo { get; set; }
        public int Weekday { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
    }

    public class TimetableCreateInput : TimetableConflictCheckInput
    {
        public int? PeriodFrom { get; set; }
        public int? PeriodTo { get; set; }
        public string? Recurrence { get; set; }
        public string? Status { get; set; }
        public string? Actor { get; set; }
    }

    public class TimetableUpdateInput
    {
        public string? LecturerId { get; set; }
        public string? RoomId { get; set; }
        public int? WeekNo { get; set; }
        public int Weekday { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public int? PeriodFrom { get; set; }
        public int? PeriodTo { get; set; }
        public string? Recurrence { get; set; }
        public string? Status { get; set; }
        public string? Actor { get; set; }
    }

    public class TimetableConflicts
    {
        public List<TimetableConflictItem> LecturerConflicts { get; set; } = new();
        public List<TimetableConflictItem> RoomConflicts { get; set; } = new();
        public List<TimetableStudentConflictItem> StudentConflicts { get; set; } = new();
        public int? RoomCapacity { get; set; }
        public int Enrolled { get; set; }
        public bool IsOverCapacity { get; set; }
    }

    public class TimetableConflictItem
    {
        public string ExistingSessionId { get; set; } = string.Empty;
        public int? WeekNo { get; set; }
        public int Weekday { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public string? ClassCode { get; set; }
        public string? RoomCode { get; set; }
    }

    public class TimetableStudentConflictItem : TimetableConflictItem
    {
        public string StudentId { get; set; } = string.Empty;
        public string StudentCode { get; set; } = string.Empty;
        public string StudentName { get; set; } = string.Empty;
    }

    public class TimetableForeignKeys
    {
        public string? ClassId { get; set; }
        public string? SubjectId { get; set; }
        public string? LecturerId { get; set; }
        public string? RoomId { get; set; }
        public string? SchoolYearId { get; set; }
    }

    // NEW: Room DTO for rooms list endpoint
    public class RoomDto
    {
        public string RoomId { get; set; } = string.Empty;
        public string RoomCode { get; set; } = string.Empty;
        public string? Building { get; set; }
        public int? Capacity { get; set; }
        public bool IsActive { get; set; }
    }
}


