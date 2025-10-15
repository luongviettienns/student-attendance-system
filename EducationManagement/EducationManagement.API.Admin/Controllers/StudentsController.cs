using Azure.Core;
using EducationManagement.Common.DTOs.Student;
using EducationManagement.DAL;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;

namespace EducationManagement.API.Auth.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/studemt")]
    public class StudentsController : Controller
    {
        private readonly IWebHostEnvironment _env;
        private readonly AppDbContext _context;
        StudentCreateDTO model = new StudentCreateDTO();

        public StudentsController(AppDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        [HttpPost("addstudent")]
        public async Task<IActionResult> AddStudent([FromBody] StudentCreateDTO model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                using var cmd = new SqlCommand("sp_AddStudentFull");
                cmd.Parameters.AddWithValue("@Username", model.Username);
                cmd.Parameters.AddWithValue("@PasswordHash", model.PasswordHash);
                cmd.Parameters.AddWithValue("@Email", model.Email);
                cmd.Parameters.AddWithValue("@Phone", model.Phone);
                cmd.Parameters.AddWithValue("@FullName", model.FullName);
                cmd.Parameters.AddWithValue("@Gender", model.Gender);
                cmd.Parameters.AddWithValue("@Dob", model.Dob);
                cmd.Parameters.AddWithValue("@FacultyId", model.FacultyId);
                cmd.Parameters.AddWithValue("@MajorId", model.MajorId);
                cmd.Parameters.AddWithValue("@AcademicYearId", model.AcademicYearId);
                cmd.Parameters.AddWithValue("@CohortYear", model.CohortYear);
                cmd.Parameters.AddWithValue("@Nationality", (object?)model.Nationality ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Ethnicity", (object?)model.Ethnicity ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Religion", (object?)model.Religion ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Hometown", (object?)model.Hometown ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@CurrentAddress", (object?)model.CurrentAddress ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@FatherName", (object?)model.FatherName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@FatherPhone", (object?)model.FatherPhone ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@FatherJob", (object?)model.FatherJob ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@MotherName", (object?)model.MotherName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@MotherPhone", (object?)model.MotherPhone ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@MotherJob", (object?)model.MotherJob ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@CreatedBy", model.CreatedBy);

                await _context.ExecuteAddStudentAsync(cmd);

                return Ok(new { success = true, message = "Thêm sinh viên thành công!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Lỗi hệ thống: " + ex.Message });
            }
        }
        [HttpPut("update")]
        public async Task<IActionResult> UpdateStudentFull([FromBody] UpdateStudentFullDto request)
        {
            try
            {
                using var cmd = new SqlCommand("dbo.sp_UpdateStudentFull");
                {
                    cmd.Parameters.AddWithValue("@StudentId", request.StudentId);
                    cmd.Parameters.AddWithValue("@FullName", request.FullName);
                    cmd.Parameters.AddWithValue("@Gender", request.Gender);
                    cmd.Parameters.AddWithValue("@Dob", request.Dob);
                    cmd.Parameters.AddWithValue("@Email", request.Email);
                    cmd.Parameters.AddWithValue("@Phone", request.Phone);
                    cmd.Parameters.AddWithValue("@FacultyId", (object?)request.FacultyId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@MajorId", (object?)request.MajorId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@AcademicYearId", (object?)request.AcademicYearId ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@CohortYear", (object?)request.CohortYear ?? DBNull.Value);

                    cmd.Parameters.AddWithValue("@Nationality", (object?)request.Nationality ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Ethnicity", (object?)request.Ethnicity ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Religion", (object?)request.Religion ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Hometown", (object?)request.Hometown ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@CurrentAddress", (object?)request.CurrentAddress ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@BankNo", (object?)request.BankNo ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@BankName", (object?)request.BankName ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@InsuranceNo", (object?)request.InsuranceNo ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@IssuePlace", (object?)request.IssuePlace ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@IssueDate", (object?)request.IssueDate ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@Facebook", (object?)request.Facebook ?? DBNull.Value);

                    cmd.Parameters.AddWithValue("@FamilyFullName", (object?)request.FamilyFullName ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@RelationType", (object?)request.RelationType ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@BirthYear", (object?)request.BirthYear ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@PhoneFamily", (object?)request.PhoneFamily ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@JobFamily", (object?)request.JobFamily ?? DBNull.Value);

                    cmd.Parameters.AddWithValue("@UpdatedBy", request.UpdatedBy);
                    await _context.ExecuteAddStudentAsync(cmd);

                }

                return Ok(new { message = "Cập nhật sinh viên (sp_UpdateStudentFull) thành công!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }

        // ============================================
        // DELETE: api/student/delete
        // ============================================
        [HttpDelete("delete")]
        public async Task<IActionResult> DeleteStudentFull([FromBody] DeleteStudentFullDto dto)
        {
            try
            {
                using var cmd = new SqlCommand("dbo.sp_DeleteStudentFull");
                {
                    cmd.Parameters.AddWithValue("@StudentId", dto.StudentId);
                    cmd.Parameters.AddWithValue("@DeletedBy", dto.DeletedBy);

                    await _context.ExecuteAddStudentAsync(cmd);
                }

                return Ok(new { message = "Xóa sinh viên (sp_DeleteStudentFull) thành công!" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
            }
        }
    }
}
