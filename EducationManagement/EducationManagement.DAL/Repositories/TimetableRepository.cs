using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Data.Common;

namespace EducationManagement.DAL.Repositories
{
    public class TimetableRepository
    {
        private readonly string _connectionString;

        public TimetableRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        public async Task<DataTable> GetStudentTimetableByWeekAsync(string studentId, int year, int weekNo)
        {
            var parameters = new[]
            {
                new SqlParameter("@StudentId", studentId),
                new SqlParameter("@Year", year),
                new SqlParameter("@WeekNo", weekNo)
            };
            return await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetStudentTimetableByWeek", parameters);
        }

        public async Task<DataTable> GetLecturerTimetableByWeekAsync(string lecturerId, int year, int weekNo)
        {
            var parameters = new[]
            {
                new SqlParameter("@LecturerId", lecturerId),
                new SqlParameter("@Year", year),
                new SqlParameter("@WeekNo", weekNo)
            };
            return await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetLecturerTimetableByWeek", parameters);
        }

        public async Task<DataSet> CheckConflictsAsync(
            string? sessionId,
            string classId,
            string subjectId,
            string? lecturerId,
            string? roomId,
            string? schoolYearId,
            int? weekNo,
            int weekday,
            TimeSpan startTime,
            TimeSpan endTime)
        {
            var parameters = new[]
            {
                new SqlParameter("@SessionId", (object?)sessionId ?? DBNull.Value),
                new SqlParameter("@ClassId", classId),
                new SqlParameter("@SubjectId", subjectId),
                new SqlParameter("@LecturerId", (object?)lecturerId ?? DBNull.Value),
                new SqlParameter("@RoomId", (object?)roomId ?? DBNull.Value),
                new SqlParameter("@SchoolYearId", (object?)schoolYearId ?? DBNull.Value),
                new SqlParameter("@WeekNo", (object?)weekNo ?? DBNull.Value),
                new SqlParameter("@Weekday", weekday),
                new SqlParameter("@StartTime", startTime),
                new SqlParameter("@EndTime", endTime)
            };
            return await DatabaseHelper.ExecuteQueryMultipleAsync(_connectionString, "sp_CheckTimetableConflicts", parameters);
        }

        public async Task<int> InsertSessionAsync(
            string sessionId,
            string classId,
            string subjectId,
            string? lecturerId,
            string? roomId,
            string? schoolYearId,
            int? weekNo,
            int weekday,
            TimeSpan startTime,
            TimeSpan endTime,
            int? periodFrom,
            int? periodTo,
            string? recurrence,
            string? status,
            string? createdBy)
        {
            using var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            var cmd = conn.CreateCommand();
            cmd.CommandText = @"INSERT INTO dbo.timetable_sessions
                (session_id, class_id, subject_id, lecturer_id, room_id, school_year_id, week_no, weekday,
                 start_time, end_time, period_from, period_to, recurrence, status, created_at, created_by)
                VALUES (@id, @class, @subj, @lect, @room, @sy, @week, @wday, @st, @et, @pf, @pt, @rec, @status, GETDATE(), @cb)";
            cmd.Parameters.AddWithValue("@id", sessionId);
            cmd.Parameters.AddWithValue("@class", classId);
            cmd.Parameters.AddWithValue("@subj", subjectId);
            cmd.Parameters.AddWithValue("@lect", (object?)lecturerId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@room", (object?)roomId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@sy", (object?)schoolYearId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@week", (object?)weekNo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@wday", weekday);
            cmd.Parameters.AddWithValue("@st", startTime);
            cmd.Parameters.AddWithValue("@et", endTime);
            cmd.Parameters.AddWithValue("@pf", (object?)periodFrom ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@pt", (object?)periodTo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@rec", (object?)recurrence ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@status", (object?)status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@cb", (object?)createdBy ?? "System");
            return await cmd.ExecuteNonQueryAsync();
        }

        public async Task<int> UpdateSessionAsync(
            string sessionId,
            string? lecturerId,
            string? roomId,
            int? weekNo,
            int weekday,
            TimeSpan startTime,
            TimeSpan endTime,
            int? periodFrom,
            int? periodTo,
            string? recurrence,
            string? status,
            string? updatedBy)
        {
            using var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            var cmd = conn.CreateCommand();
            cmd.CommandText = @"UPDATE dbo.timetable_sessions
                SET lecturer_id=@lect, room_id=@room, week_no=@week, weekday=@wday,
                    start_time=@st, end_time=@et, period_from=@pf, period_to=@pt,
                    recurrence=@rec, status=@status, updated_at=GETDATE(), updated_by=@ub
                WHERE session_id=@id";
            cmd.Parameters.AddWithValue("@id", sessionId);
            cmd.Parameters.AddWithValue("@lect", (object?)lecturerId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@room", (object?)roomId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@week", (object?)weekNo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@wday", weekday);
            cmd.Parameters.AddWithValue("@st", startTime);
            cmd.Parameters.AddWithValue("@et", endTime);
            cmd.Parameters.AddWithValue("@pf", (object?)periodFrom ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@pt", (object?)periodTo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@rec", (object?)recurrence ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@status", (object?)status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ub", (object?)updatedBy ?? "System");
            return await cmd.ExecuteNonQueryAsync();
        }

        // FK existence helpers
        public async Task<bool> ExistsClassAsync(string classId)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand("SELECT 1 FROM dbo.classes WHERE class_id=@id", conn);
            cmd.Parameters.AddWithValue("@id", classId);
            await conn.OpenAsync();
            var o = await cmd.ExecuteScalarAsync();
            return o != null;
        }

        public async Task<bool> ExistsSubjectAsync(string subjectId)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand("SELECT 1 FROM dbo.subjects WHERE subject_id=@id", conn);
            cmd.Parameters.AddWithValue("@id", subjectId);
            await conn.OpenAsync();
            var o = await cmd.ExecuteScalarAsync();
            return o != null;
        }

        public async Task<bool> ExistsLecturerAsync(string lecturerId)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand("SELECT 1 FROM dbo.lecturers WHERE lecturer_id=@id", conn);
            cmd.Parameters.AddWithValue("@id", lecturerId);
            await conn.OpenAsync();
            var o = await cmd.ExecuteScalarAsync();
            return o != null;
        }

        public async Task<bool> ExistsRoomAsync(string roomId)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand("SELECT 1 FROM dbo.rooms WHERE room_id=@id", conn);
            cmd.Parameters.AddWithValue("@id", roomId);
            await conn.OpenAsync();
            var o = await cmd.ExecuteScalarAsync();
            return o != null;
        }

        public async Task<bool> ExistsSchoolYearAsync(string schoolYearId)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand("SELECT 1 FROM dbo.school_years WHERE school_year_id=@id", conn);
            cmd.Parameters.AddWithValue("@id", schoolYearId);
            await conn.OpenAsync();
            var o = await cmd.ExecuteScalarAsync();
            return o != null;
        }

        public async Task<bool> ExistsSessionAsync(string sessionId)
        {
            using var conn = new SqlConnection(_connectionString);
            using var cmd = new SqlCommand("SELECT 1 FROM dbo.timetable_sessions WHERE session_id=@id AND deleted_at IS NULL", conn);
            cmd.Parameters.AddWithValue("@id", sessionId);
            await conn.OpenAsync();
            var o = await cmd.ExecuteScalarAsync();
            return o != null;
        }

        public async Task<int> SoftDeleteSessionAsync(string sessionId, string? actor)
        {
            using var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            var cmd = conn.CreateCommand();
            cmd.CommandText = @"UPDATE dbo.timetable_sessions
                SET deleted_at = GETDATE(), deleted_by = @db
                WHERE session_id = @id AND deleted_at IS NULL";
            cmd.Parameters.AddWithValue("@id", sessionId);
            cmd.Parameters.AddWithValue("@db", (object?)actor ?? "System");
            return await cmd.ExecuteNonQueryAsync();
        }

        public async Task<DataTable> GetRoomsAsync(string? search = null, bool? isActive = true)
        {
            using var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT room_id, room_code, building, capacity, is_active
                                FROM dbo.rooms
                                WHERE (@act IS NULL OR is_active=@act)
                                  AND (@s IS NULL OR room_code LIKE '%'+@s+'%' OR building LIKE '%'+@s+'%')
                                ORDER BY room_code";
            cmd.Parameters.AddWithValue("@act", (object?)isActive ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@s", (object?)search ?? DBNull.Value);
            var dt = new DataTable();
            using var da = new SqlDataAdapter((SqlCommand)cmd);
            da.Fill(dt);
            return dt;
        }

        public async Task<DataTable> GetAllSessionsByWeekAsync(int year, int weekNo)
        {
            using var conn = new SqlConnection(_connectionString);
            await conn.OpenAsync();
            var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT 
                ts.session_id, ts.class_id, ts.subject_id, ts.lecturer_id, ts.room_id, ts.school_year_id,
                ts.week_no, ts.weekday, ts.start_time, ts.end_time, ts.period_from, ts.period_to,
                ts.recurrence, ts.status, ts.notes,
                c.class_code, c.class_name,
                s.subject_code, s.subject_name,
                l.full_name AS lecturer_name,
                r.room_code, r.building,
                sy.year_code AS school_year_code
            FROM dbo.timetable_sessions ts
            INNER JOIN dbo.classes c ON ts.class_id = c.class_id
            INNER JOIN dbo.subjects s ON ts.subject_id = s.subject_id
            LEFT JOIN dbo.lecturers l ON ts.lecturer_id = l.lecturer_id
            LEFT JOIN dbo.rooms r ON ts.room_id = r.room_id
            LEFT JOIN dbo.school_years sy ON ts.school_year_id = sy.school_year_id
            WHERE ts.week_no = @weekNo
              AND ts.deleted_at IS NULL
              AND c.deleted_at IS NULL
            ORDER BY ts.weekday, ts.start_time";
            cmd.Parameters.AddWithValue("@weekNo", weekNo);
            var dt = new DataTable();
            using var da = new SqlDataAdapter((SqlCommand)cmd);
            da.Fill(dt);
            return dt;
        }
    }
}


