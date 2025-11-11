using EducationManagement.Common.DTOs.Student;
using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EducationManagement.BLL.Services
{
    public class StudentService
    {
        private readonly StudentRepository _studentRepository;
        private readonly CachingService? _cache;

        public StudentService(StudentRepository studentRepository, CachingService? cache = null)
        {
            _studentRepository = studentRepository;
            _cache = cache;
        }

        /// <summary>
        /// Thêm sinh viên mới
        /// </summary>
        public async Task AddStudentAsync(StudentCreateDto model)
        {
            if (string.IsNullOrWhiteSpace(model.StudentCode))
                throw new ArgumentException("Mã sinh viên không được để trống");

            if (string.IsNullOrWhiteSpace(model.FullName))
                throw new ArgumentException("Họ tên không được để trống");

            await _studentRepository.AddAsync(model);
        }

        /// <summary>
        /// Cập nhật thông tin sinh viên
        /// </summary>
        public async Task UpdateStudentAsync(UpdateStudentFullDto model)
        {
            if (string.IsNullOrWhiteSpace(model.StudentId))
                throw new ArgumentException("Student ID không được để trống");

            await _studentRepository.UpdateAsync(model);
            
            // Invalidate cache after update
            if (_cache != null)
            {
                await _cache.RemoveAsync(string.Format(CacheKeys.StudentById, model.StudentId));
            }
        }

        /// <summary>
        /// Xóa sinh viên (soft delete)
        /// </summary>
        public async Task DeleteStudentAsync(string studentId, string deletedBy)
        {
            if (string.IsNullOrWhiteSpace(studentId))
                throw new ArgumentException("Student ID không được để trống");

            await _studentRepository.DeleteAsync(studentId, deletedBy);
        }

        /// <summary>
        /// Lấy danh sách sinh viên với phân trang và lọc
        /// </summary>
        public async Task<(List<Student> Students, int TotalCount)> GetAllStudentsAsync(
            int page = 1,
            int pageSize = 10,
            string? search = null,
            string? facultyId = null,
            string? majorId = null,
            string? academicYearId = null)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;
            if (pageSize > 100) pageSize = 100; // Giới hạn max pageSize

            return await _studentRepository.GetAllAsync(page, pageSize, search, facultyId, majorId, academicYearId);
        }

        /// <summary>
        /// Lấy sinh viên theo ID
        /// </summary>
        public async Task<Student?> GetStudentByIdAsync(string studentId)
        {
            if (string.IsNullOrWhiteSpace(studentId))
                throw new ArgumentException("Student ID không được để trống");

            if (_cache != null)
            {
                var cacheKey = string.Format(CacheKeys.StudentById, studentId);
                return await _cache.GetOrSetAsync(
                    cacheKey,
                    async () => await _studentRepository.GetByIdAsync(studentId),
                    CacheKeys.StudentExpiration
                );
            }
            return await _studentRepository.GetByIdAsync(studentId);
        }

        /// <summary>
        /// Lấy sinh viên theo User ID
        /// </summary>
        public async Task<Student?> GetStudentByUserIdAsync(string userId)
        {
            if (string.IsNullOrWhiteSpace(userId))
                throw new ArgumentException("User ID không được để trống");

            if (_cache != null)
            {
                var cacheKey = string.Format(CacheKeys.StudentByUserId, userId);
                return await _cache.GetOrSetAsync(
                    cacheKey,
                    async () => await _studentRepository.GetByUserIdAsync(userId),
                    CacheKeys.StudentExpiration
                );
            }
            return await _studentRepository.GetByUserIdAsync(userId);
        }
    }
}

