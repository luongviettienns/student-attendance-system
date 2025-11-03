using System;
using System.ComponentModel.DataAnnotations;

namespace EducationManagement.Common.DTOs.Attendance
{
    public class AttendanceCreateDto
    {
        [Required(ErrorMessage = "Enrollment ID is required")]
        [StringLength(50, ErrorMessage = "Enrollment ID cannot exceed 50 characters")]
        public string EnrollmentId { get; set; } = string.Empty;

        [Required(ErrorMessage = "Class ID is required")]
        [StringLength(50, ErrorMessage = "Class ID cannot exceed 50 characters")]
        public string ClassId { get; set; } = string.Empty;

        [Required(ErrorMessage = "Attendance date is required")]
        public DateTime AttendanceDate { get; set; } = DateTime.Now;

        [Required(ErrorMessage = "Status is required")]
        [StringLength(20, ErrorMessage = "Status cannot exceed 20 characters")]
        public string Status { get; set; } = "PRESENT"; // PRESENT, ABSENT, LATE, EXCUSED

        [StringLength(500, ErrorMessage = "Notes cannot exceed 500 characters")]
        public string? Note { get; set; }

        [StringLength(50, ErrorMessage = "Schedule ID cannot exceed 50 characters")]
        public string? ScheduleId { get; set; }

        [Required(ErrorMessage = "Created by is required")]
        [StringLength(50, ErrorMessage = "Created by cannot exceed 50 characters")]
        public string CreatedBy { get; set; } = string.Empty;
    }
}
