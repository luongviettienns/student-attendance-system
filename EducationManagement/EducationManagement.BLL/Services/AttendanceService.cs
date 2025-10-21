using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EducationManagement.BLL.Services
{
    public class AttendanceService
    {
        private readonly AttendanceRepository _attendanceRepository;

        public AttendanceService(AttendanceRepository attendanceRepository)
        {
            _attendanceRepository = attendanceRepository;
        }

        /// <summary>
        /// Lấy tất cả attendance records
        /// </summary>
        public async Task<List<Attendance>> GetAllAttendancesAsync()
        {
            return await _attendanceRepository.GetAllAsync();
        }

        /// <summary>
        /// Lấy attendance theo ID
        /// </summary>
        public async Task<Attendance?> GetAttendanceByIdAsync(string attendanceId)
        {
            if (string.IsNullOrWhiteSpace(attendanceId))
                throw new ArgumentException("Attendance ID không được để trống");

            return await _attendanceRepository.GetByIdAsync(attendanceId);
        }

        /// <summary>
        /// Tạo attendance record mới
        /// </summary>
        public async Task<string> CreateAttendanceAsync(string attendanceId, string studentId, string scheduleId,
            DateTime attendanceDate, string status, string? notes, string? markedBy, string createdBy)
        {
            if (string.IsNullOrWhiteSpace(studentId))
                throw new ArgumentException("Student ID không được để trống");

            if (string.IsNullOrWhiteSpace(scheduleId))
                throw new ArgumentException("Schedule ID không được để trống");

            if (string.IsNullOrWhiteSpace(status))
                throw new ArgumentException("Status không được để trống");

            // Validate status
            var validStatuses = new[] { "Present", "Absent", "Late", "Excused" };
            if (!Array.Exists(validStatuses, s => s.Equals(status, StringComparison.OrdinalIgnoreCase)))
                throw new ArgumentException($"Status phải là một trong: {string.Join(", ", validStatuses)}");

            return await _attendanceRepository.CreateAsync(attendanceId, studentId, scheduleId,
                attendanceDate, status, notes, markedBy, createdBy);
        }

        /// <summary>
        /// Cập nhật attendance
        /// </summary>
        public async Task UpdateAttendanceAsync(string attendanceId, string status, string? notes, string updatedBy)
        {
            if (string.IsNullOrWhiteSpace(attendanceId))
                throw new ArgumentException("Attendance ID không được để trống");

            if (string.IsNullOrWhiteSpace(status))
                throw new ArgumentException("Status không được để trống");

            // Validate status
            var validStatuses = new[] { "Present", "Absent", "Late", "Excused" };
            if (!Array.Exists(validStatuses, s => s.Equals(status, StringComparison.OrdinalIgnoreCase)))
                throw new ArgumentException($"Status phải là một trong: {string.Join(", ", validStatuses)}");

            await _attendanceRepository.UpdateAsync(attendanceId, status, notes, updatedBy);
        }

        /// <summary>
        /// Xóa attendance (soft delete)
        /// </summary>
        public async Task DeleteAttendanceAsync(string attendanceId, string deletedBy)
        {
            if (string.IsNullOrWhiteSpace(attendanceId))
                throw new ArgumentException("Attendance ID không được để trống");

            await _attendanceRepository.DeleteAsync(attendanceId, deletedBy);
        }

        /// <summary>
        /// Lấy attendances theo student ID
        /// </summary>
        public async Task<List<Attendance>> GetAttendancesByStudentAsync(string studentId)
        {
            if (string.IsNullOrWhiteSpace(studentId))
                throw new ArgumentException("Student ID không được để trống");

            return await _attendanceRepository.GetByStudentIdAsync(studentId);
        }

        /// <summary>
        /// Lấy attendances theo schedule ID
        /// </summary>
        public async Task<List<Attendance>> GetAttendancesByScheduleAsync(string scheduleId)
        {
            if (string.IsNullOrWhiteSpace(scheduleId))
                throw new ArgumentException("Schedule ID không được để trống");

            return await _attendanceRepository.GetByScheduleIdAsync(scheduleId);
        }

        /// <summary>
        /// Lấy attendances theo class ID
        /// </summary>
        public async Task<List<Attendance>> GetAttendancesByClassAsync(string classId)
        {
            if (string.IsNullOrWhiteSpace(classId))
                throw new ArgumentException("Class ID không được để trống");

            return await _attendanceRepository.GetByClassIdAsync(classId);
        }
    }
}

