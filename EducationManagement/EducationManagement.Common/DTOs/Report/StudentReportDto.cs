namespace EducationManagement.Common.DTOs.Report
{
    public class StudentReportDto
    {
        public decimal CurrentGpa { get; set; }
        public decimal CumulativeGpa { get; set; }
        public int TotalCreditsEarned { get; set; }
        public int TotalCreditsRequired { get; set; }
        public int CreditDebt { get; set; }
        public decimal AttendanceRate { get; set; }
        public List<SemesterSummaryDto> SemesterSummaries { get; set; } = new();
    }

    public class SemesterSummaryDto
    {
        public string SchoolYearName { get; set; } = string.Empty;
        public int Semester { get; set; }
        public decimal SemesterGpa { get; set; }
        public int CreditsEarned { get; set; }
        public decimal AttendanceRate { get; set; }
    }
}
