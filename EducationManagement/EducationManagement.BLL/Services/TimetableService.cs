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
                    Recurrence = r.Table.Columns.Contains("recurrence") ? r["recurrence"]?.ToString() : null,
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
            }, updateMode: true);
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

        // ============================================
        // NEW FEATURES: Bulk operations & Advanced
        // ============================================

        /// <summary>
        /// Bulk create sessions for multiple weeks
        /// </summary>
        public async Task<BulkCreateSessionsResult> BulkCreateSessionsAsync(BulkCreateSessionsInput input)
        {
            var result = new BulkCreateSessionsResult
            {
                TotalRequested = 0,
                Created = 0,
                Skipped = 0,
                Errors = new List<string>()
            };

            // Validate input
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

            // Calculate weeks based on semester or week range
            var weeks = await CalculateWeeksAsync(input);
            result.TotalRequested = weeks.Count;

            foreach (var weekNo in weeks)
            {
                try
                {
                    var checkInput = new TimetableConflictCheckInput
                    {
                        ClassId = input.ClassId,
                        SubjectId = input.SubjectId,
                        LecturerId = input.LecturerId,
                        RoomId = input.RoomId,
                        SchoolYearId = input.SchoolYearId,
                        WeekNo = weekNo,
                        Weekday = input.Weekday,
                        StartTime = input.StartTime,
                        EndTime = input.EndTime
                    };

                    var (hasConflict, _) = await ValidateBeforeSaveAsync(checkInput);
                    if (hasConflict && input.SkipConflicts)
                    {
                        result.Skipped++;
                        continue;
                    }
                    if (hasConflict)
                    {
                        result.Errors.Add($"Week {weekNo}: Conflicts detected");
                        continue;
                    }

                    var createInput = new TimetableCreateInput
                    {
                        ClassId = input.ClassId,
                        SubjectId = input.SubjectId,
                        LecturerId = input.LecturerId,
                        RoomId = input.RoomId,
                        SchoolYearId = input.SchoolYearId,
                        WeekNo = weekNo,
                        Weekday = input.Weekday,
                        StartTime = input.StartTime,
                        EndTime = input.EndTime,
                        PeriodFrom = input.PeriodFrom,
                        PeriodTo = input.PeriodTo,
                        Recurrence = input.Recurrence ?? "weekly",
                        Status = input.Status ?? "active",
                        Actor = input.Actor
                    };

                    await CreateSessionAsync(createInput);
                    result.Created++;
                }
                catch (Exception ex)
                {
                    result.Errors.Add($"Week {weekNo}: {ex.Message}");
                }
            }

            return result;
        }

        /// <summary>
        /// Copy sessions from one school year/semester to another
        /// </summary>
        public async Task<CopySessionsResult> CopySessionsAsync(CopySessionsInput input)
        {
            var result = new CopySessionsResult
            {
                TotalFound = 0,
                Copied = 0,
                Skipped = 0,
                Errors = new List<string>()
            };

            // Get source sessions
            var sourceSessionsDt = await _repo.GetSessionsBySemesterAsync(
                input.SourceSchoolYearId,
                input.SourceSemester,
                input.SourceClassId);
            var sourceSessions = MapSessions(sourceSessionsDt);

            result.TotalFound = sourceSessions.Count;

            foreach (var session in sourceSessions)
            {
                try
                {
                    // Check if target class exists
                    if (!string.IsNullOrEmpty(input.TargetClassId) &&
                        !await _repo.ExistsClassAsync(input.TargetClassId))
                    {
                        result.Errors.Add($"Session {session.SessionId}: Target class not found");
                        result.Skipped++;
                        continue;
                    }

                    var classId = input.TargetClassId ?? session.ClassId;
                    var checkInput = new TimetableConflictCheckInput
                    {
                        ClassId = classId,
                        SubjectId = session.SubjectId,
                        LecturerId = input.TargetLecturerId ?? session.LecturerId,
                        RoomId = input.TargetRoomId ?? session.RoomId,
                        SchoolYearId = input.TargetSchoolYearId,
                        WeekNo = session.WeekNo,
                        Weekday = session.Weekday,
                        StartTime = session.StartTime,
                        EndTime = session.EndTime
                    };

                    var (hasConflict, _) = await ValidateBeforeSaveAsync(checkInput);
                    if (hasConflict && input.SkipConflicts)
                    {
                        result.Skipped++;
                        continue;
                    }
                    if (hasConflict)
                    {
                        result.Errors.Add($"Session {session.SessionId}: Conflicts detected");
                        result.Skipped++;
                        continue;
                    }

                    var createInput = new TimetableCreateInput
                    {
                        ClassId = classId,
                        SubjectId = session.SubjectId,
                        LecturerId = input.TargetLecturerId ?? session.LecturerId,
                        RoomId = input.TargetRoomId ?? session.RoomId,
                        SchoolYearId = input.TargetSchoolYearId,
                        WeekNo = session.WeekNo,
                        Weekday = session.Weekday,
                        StartTime = session.StartTime,
                        EndTime = session.EndTime,
                        PeriodFrom = session.PeriodFrom != null ? int.Parse(session.PeriodFrom) : null,
                        PeriodTo = session.PeriodTo != null ? int.Parse(session.PeriodTo) : null,
                        Recurrence = session.Recurrence ?? "weekly",
                        Status = input.TargetStatus ?? "planned",
                        Actor = input.Actor
                    };

                    await CreateSessionAsync(createInput);
                    result.Copied++;
                }
                catch (Exception ex)
                {
                    result.Errors.Add($"Session {session.SessionId}: {ex.Message}");
                    result.Skipped++;
                }
            }

            return result;
        }

        /// <summary>
        /// Get conflict resolution suggestions
        /// </summary>
        public async Task<ConflictSuggestions> GetConflictSuggestionsAsync(TimetableConflictCheckInput input)
        {
            var suggestions = new ConflictSuggestions
            {
                AlternativeRooms = new List<RoomDto>(),
                AlternativeTimes = new List<TimeSlotSuggestion>(),
                AlternativeLecturers = new List<LecturerSuggestion>()
            };

            // Get available rooms for the same time slot
            var allRooms = await GetRoomsAsync(null, true);
            foreach (var room in allRooms)
            {
                if (room.RoomId == input.RoomId) continue;

                var roomCheck = new TimetableConflictCheckInput
                {
                    SessionId = input.SessionId,
                    ClassId = input.ClassId,
                    SubjectId = input.SubjectId,
                    LecturerId = input.LecturerId,
                    RoomId = room.RoomId,
                    SchoolYearId = input.SchoolYearId,
                    WeekNo = input.WeekNo,
                    Weekday = input.Weekday,
                    StartTime = input.StartTime,
                    EndTime = input.EndTime
                };

                var (hasConflict, conflicts) = await ValidateBeforeSaveAsync(roomCheck);
                if (!hasConflict || (!conflicts.RoomConflicts.Any() && !conflicts.IsOverCapacity))
                {
                    suggestions.AlternativeRooms.Add(room);
                }
            }

            // Suggest alternative time slots (same day, different hours)
            var timeSlots = GenerateTimeSlotSuggestions(input);
            foreach (var slot in timeSlots)
            {
                var timeCheck = new TimetableConflictCheckInput
                {
                    SessionId = input.SessionId,
                    ClassId = input.ClassId,
                    SubjectId = input.SubjectId,
                    LecturerId = input.LecturerId,
                    RoomId = input.RoomId,
                    SchoolYearId = input.SchoolYearId,
                    WeekNo = input.WeekNo,
                    Weekday = input.Weekday,
                    StartTime = slot.StartTime,
                    EndTime = slot.EndTime
                };

                var (hasConflict, _) = await ValidateBeforeSaveAsync(timeCheck);
                if (!hasConflict)
                {
                    suggestions.AlternativeTimes.Add(slot);
                }
            }

            return suggestions;
        }

        /// <summary>
        /// Get sessions by semester
        /// </summary>
        public async Task<List<TimetableSessionDto>> GetSessionsBySemesterAsync(
            string schoolYearId,
            int semester,
            string? classId = null)
        {
            var dt = await _repo.GetSessionsBySemesterAsync(schoolYearId, semester, classId);
            return MapSessions(dt);
        }

        /// <summary>
        /// Create session with recurrence pattern
        /// </summary>
        public async Task<RecurrenceCreateResult> CreateSessionWithRecurrenceAsync(
            TimetableCreateInput input,
            DateTime? startDate = null,
            DateTime? endDate = null)
        {
            var result = new RecurrenceCreateResult
            {
                Created = 0,
                Skipped = 0,
                SessionIds = new List<string>(),
                Errors = new List<string>()
            };

            // If no recurrence or "once", create single session
            if (string.IsNullOrEmpty(input.Recurrence) || input.Recurrence == "once")
            {
                try
                {
                    var (hasConflict, _) = await ValidateBeforeSaveAsync(input);
                    if (hasConflict)
                    {
                        result.Errors.Add("Conflicts detected");
                        return result;
                    }
                    var id = await CreateSessionAsync(input);
                    result.Created = 1;
                    result.SessionIds.Add(id);
                    return result;
                }
                catch (Exception ex)
                {
                    result.Errors.Add(ex.Message);
                    return result;
                }
            }

            // For recurrence patterns, need date range
            if (!startDate.HasValue || !endDate.HasValue)
            {
                result.Errors.Add("startDate and endDate required for recurrence patterns");
                return result;
            }

            var sessionIds = await ApplyRecurrencePatternAsync(input, startDate.Value, endDate.Value);
            result.Created = sessionIds.Count;
            result.SessionIds = sessionIds;

            return result;
        }

        // Helper methods
        private async Task<List<int>> CalculateWeeksAsync(BulkCreateSessionsInput input)
        {
            if (input == null)
                throw new ArgumentNullException(nameof(input));

            var weeks = new List<int>();

            // Priority 1: Specific week numbers
            if (input.WeekNumbers != null && input.WeekNumbers.Any())
            {
                return input.WeekNumbers.Where(w => w > 0).OrderBy(w => w).Distinct().ToList();
            }

            // Priority 2: Calculate from semester
            if (input.Semester.HasValue && !string.IsNullOrEmpty(input.SchoolYearId))
            {
                var semesterWeeks = await _repo.GetSemesterWeeksAsync(input.SchoolYearId, input.Semester.Value);
                if (semesterWeeks == null || !semesterWeeks.Any())
                    throw new InvalidOperationException($"Không tìm thấy tuần học cho học kỳ {input.Semester.Value} của năm học {input.SchoolYearId}");
                return semesterWeeks;
            }

            // Priority 3: Week range
            if (input.WeekFrom.HasValue && input.WeekTo.HasValue)
            {
                if (input.WeekFrom.Value < 1 || input.WeekTo.Value < 1)
                    throw new ArgumentException("Số tuần phải lớn hơn 0", nameof(input));
                
                if (input.WeekFrom.Value > input.WeekTo.Value)
                    throw new ArgumentException("WeekFrom phải nhỏ hơn hoặc bằng WeekTo", nameof(input));

                for (int i = input.WeekFrom.Value; i <= input.WeekTo.Value; i++)
                {
                    weeks.Add(i);
                }
                return weeks;
            }

            // No valid input provided
            throw new ArgumentException("Phải cung cấp WeekNumbers, (Semester + SchoolYearId), hoặc (WeekFrom + WeekTo)", nameof(input));
        }

        /// <summary>
        /// Apply recurrence pattern to generate sessions
        /// </summary>
        public async Task<List<string>> ApplyRecurrencePatternAsync(TimetableCreateInput input, DateTime startDate, DateTime endDate)
        {
            var createdSessionIds = new List<string>();

            if (string.IsNullOrEmpty(input.Recurrence) || input.Recurrence == "once")
            {
                // Single session - no recurrence
                var id = await CreateSessionAsync(input);
                createdSessionIds.Add(id);
                return createdSessionIds;
            }

            var currentDate = startDate;
            var weekday = input.Weekday; // 1=Sunday, 2=Monday, ..., 7=Saturday

            while (currentDate <= endDate)
            {
                // Check if current date matches the weekday
                var currentWeekday = (int)currentDate.DayOfWeek;
                if (currentWeekday == 0) currentWeekday = 7; // Sunday = 7

                if (currentWeekday == weekday)
                {
                    // Calculate week number for this date
                    var weekNo = GetWeekNumber(currentDate);

                    // Check if we should create session based on recurrence pattern
                    bool shouldCreate = input.Recurrence switch
                    {
                        "weekly" => true, // Every week
                        "bi-weekly" => ShouldCreateBiWeekly(currentDate, startDate), // Every 2 weeks
                        "monthly" => ShouldCreateMonthly(currentDate, startDate), // Same day of month
                        _ => true
                    };

                    if (shouldCreate)
                    {
                        var sessionInput = new TimetableCreateInput
                        {
                            ClassId = input.ClassId,
                            SubjectId = input.SubjectId,
                            LecturerId = input.LecturerId,
                            RoomId = input.RoomId,
                            SchoolYearId = input.SchoolYearId,
                            WeekNo = weekNo,
                            Weekday = weekday,
                            StartTime = input.StartTime,
                            EndTime = input.EndTime,
                            PeriodFrom = input.PeriodFrom,
                            PeriodTo = input.PeriodTo,
                            Recurrence = input.Recurrence,
                            Status = input.Status,
                            Actor = input.Actor
                        };

                        // Check conflicts before creating
                        var checkInput = new TimetableConflictCheckInput
                        {
                            ClassId = sessionInput.ClassId,
                            SubjectId = sessionInput.SubjectId,
                            LecturerId = sessionInput.LecturerId,
                            RoomId = sessionInput.RoomId,
                            SchoolYearId = sessionInput.SchoolYearId,
                            WeekNo = weekNo,
                            Weekday = weekday,
                            StartTime = sessionInput.StartTime,
                            EndTime = sessionInput.EndTime
                        };

                        var (hasConflict, _) = await ValidateBeforeSaveAsync(checkInput);
                        if (!hasConflict)
                        {
                            var id = await CreateSessionAsync(sessionInput);
                            createdSessionIds.Add(id);
                        }
                    }
                }

                currentDate = currentDate.AddDays(1);
            }

            return createdSessionIds;
        }

        private bool ShouldCreateBiWeekly(DateTime currentDate, DateTime startDate)
        {
            var daysDiff = (currentDate - startDate).Days;
            return daysDiff % 14 == 0; // Every 14 days
        }

        private bool ShouldCreateMonthly(DateTime currentDate, DateTime startDate)
        {
            return currentDate.Day == startDate.Day; // Same day of month
        }

        /// <summary>
        /// Calculate week number based on custom logic: Week 12 starts from 3/11/2025 (Monday)
        /// This ensures consistency with frontend calculation
        /// </summary>
        private int GetWeekNumber(DateTime date)
        {
            // Custom week calculation: Week 12 starts on 3/11/2025 (Monday)
            var week12StartDate = new DateTime(2025, 11, 3); // November 3, 2025 (Monday)
            
            // Calculate week 1 start date (11 weeks before week 12)
            var week1StartDate = week12StartDate.AddDays(-(12 - 1) * 7);
            
            // Calculate which week the given date falls into
            var daysDiff = (date.Date - week1StartDate.Date).TotalDays;
            
            // If date is before week 1, return week 1
            if (daysDiff < 0)
            {
                return 1;
            }
            
            // Calculate week number (1-based)
            var weekNo = (int)Math.Floor(daysDiff / 7) + 1;
            
            // Ensure week number is at least 1
            return Math.Max(1, weekNo);
        }
        
        /// <summary>
        /// Get the start date of a specific week based on custom logic
        /// </summary>
        public DateTime GetWeekStartDate(int year, int weekNo)
        {
            // Week 12 starts on 3/11/2025 (Monday)
            var week12StartDate = new DateTime(2025, 11, 3);
            
            // Calculate week 1 start date
            var week1StartDate = week12StartDate.AddDays(-(12 - 1) * 7);
            
            // Calculate the start date for the requested week
            var weekStartDate = week1StartDate.AddDays((weekNo - 1) * 7);
            
            return weekStartDate;
        }
        
        /// <summary>
        /// Get the date for a specific weekday in a week
        /// </summary>
        public DateTime GetDateForWeekday(int year, int weekNo, int weekday)
        {
            // weekday: 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
            var weekStart = GetWeekStartDate(year, weekNo);
            var dayOffset = weekday - 1; // Monday is 0 days offset, Tuesday is 1, etc.
            return weekStart.AddDays(dayOffset);
        }

        private List<TimeSlotSuggestion> GenerateTimeSlotSuggestions(TimetableConflictCheckInput input)
        {
            var suggestions = new List<TimeSlotSuggestion>();
            var duration = input.EndTime - input.StartTime;

            // Common time slots in Vietnamese universities
            var commonSlots = new[]
            {
                new { Start = TimeSpan.FromHours(7), End = TimeSpan.FromHours(9) },   // 7:00-9:00
                new { Start = TimeSpan.FromHours(9), End = TimeSpan.FromHours(11) },  // 9:00-11:00
                new { Start = TimeSpan.FromHours(13), End = TimeSpan.FromHours(15) },  // 13:00-15:00
new { Start = TimeSpan.FromHours(15), End = TimeSpan.FromHours(17) },  // 15:00-17:00
                new { Start = TimeSpan.FromHours(17), End = TimeSpan.FromHours(19) },  // 17:00-19:00
            };

            foreach (var slot in commonSlots)
            {
                if (slot.Start == input.StartTime && slot.End == input.EndTime) continue;

                suggestions.Add(new TimeSlotSuggestion
                {
                    StartTime = slot.Start,
                    EndTime = slot.End,
                    Weekday = input.Weekday
                });
            }

            return suggestions;
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
        public string? Recurrence { get; set; }
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

    // ============================================
    // NEW DTOs for advanced features
    // ============================================

    public class BulkCreateSessionsInput
    {
        public string ClassId { get; set; } = string.Empty;
        public string SubjectId { get; set; } = string.Empty;
        public string? LecturerId { get; set; }
        public string? RoomId { get; set; }
        public string? SchoolYearId { get; set; }
        public int Weekday { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public int? PeriodFrom { get; set; }
        public int? PeriodTo { get; set; }
        public string? Recurrence { get; set; }
        public string? Status { get; set; }
        public string? Actor { get; set; }

        // Options for bulk creation
        public List<int>? WeekNumbers { get; set; }  // Specific weeks: [1,2,3,5,7]
        public int? WeekFrom { get; set; }           // Range: WeekFrom=1, WeekTo=15
        public int? WeekTo { get; set; }
        public int? Semester { get; set; }           // Auto-calculate weeks for semester
        public bool SkipConflicts { get; set; } = false;  // Skip weeks with conflicts
    }

    public class BulkCreateSessionsResult
    {
        public int TotalRequested { get; set; }
        public int Created { get; set; }
        public int Skipped { get; set; }
        public List<string> Errors { get; set; } = new();
    }

    public class CopySessionsInput
    {
        public string SourceSchoolYearId { get; set; } = string.Empty;
        public int SourceSemester { get; set; }
        public string? SourceClassId { get; set; }  // NULL = all classes
        public string TargetSchoolYearId { get; set; } = string.Empty;
        public string? TargetClassId { get; set; }  // NULL = keep same class
        public string? TargetLecturerId { get; set; }  // NULL = keep same lecturer
        public string? TargetRoomId { get; set; }  // NULL = keep same room
        public string? TargetStatus { get; set; }  // Default: "planned"
        public bool SkipConflicts { get; set; } = false;
        public string? Actor { get; set; }
    }

    public class CopySessionsResult
    {
        public int TotalFound { get; set; }
        public int Copied { get; set; }
        public int Skipped { get; set; }
        public List<string> Errors { get; set; } = new();
    }

    public class ConflictSuggestions
    {
        public List<RoomDto> AlternativeRooms { get; set; } = new();
        public List<TimeSlotSuggestion> AlternativeTimes { get; set; } = new();
        public List<LecturerSuggestion> AlternativeLecturers { get; set; } = new();
    }

    public class TimeSlotSuggestion
    {
        public int Weekday { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
    }

    public class LecturerSuggestion
    {
        public string LecturerId { get; set; } = string.Empty;
        public string LecturerName { get; set; } = string.Empty;
    }

    public class RecurrenceCreateResult
    {
        public int Created { get; set; }
        public int Skipped { get; set; }
        public List<string> SessionIds { get; set; } = new();
        public List<string> Errors { get; set; } = new();
    }

    public class TimetableCreateWithRecurrenceInput : TimetableCreateInput
    {
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
