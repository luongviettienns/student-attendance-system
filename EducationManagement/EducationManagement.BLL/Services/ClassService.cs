using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EducationManagement.BLL.Services
{
    public class ClassService
    {
        private readonly ClassRepository _classRepository;

        public ClassService(ClassRepository classRepository)
        {
            _classRepository = classRepository;
        }

        /// <summary>
        /// Lấy tất cả classes
        /// </summary>
        public async Task<List<Class>> GetAllClassesAsync()
        {
            return await _classRepository.GetAllAsync();
        }

        /// <summary>
        /// Lấy class theo ID
        /// </summary>
        public async Task<Class?> GetClassByIdAsync(string classId)
        {
            if (string.IsNullOrWhiteSpace(classId))
                throw new ArgumentException("Class ID không được để trống");

            return await _classRepository.GetByIdAsync(classId);
        }

        /// <summary>
        /// Tạo class mới
        /// </summary>
        public async Task<string> CreateClassAsync(string classId, string classCode, string className,
            string subjectId, string lecturerId, string semester, string academicYearId,
            int maxStudents, string createdBy)
        {
            if (string.IsNullOrWhiteSpace(classCode))
                throw new ArgumentException("Mã lớp không được để trống");

            if (string.IsNullOrWhiteSpace(className))
                throw new ArgumentException("Tên lớp không được để trống");

            if (string.IsNullOrWhiteSpace(subjectId))
                throw new ArgumentException("Subject ID không được để trống");

            if (string.IsNullOrWhiteSpace(lecturerId))
                throw new ArgumentException("Lecturer ID không được để trống");

            if (maxStudents <= 0)
                throw new ArgumentException("Sĩ số tối đa phải lớn hơn 0");

            return await _classRepository.CreateAsync(classId, classCode, className,
                subjectId, lecturerId, semester, academicYearId, maxStudents, createdBy);
        }

        /// <summary>
        /// Cập nhật class
        /// </summary>
        public async Task UpdateClassAsync(string classId, string classCode, string className,
            string subjectId, string lecturerId, string semester, string academicYearId,
            int maxStudents, string updatedBy)
        {
            if (string.IsNullOrWhiteSpace(classId))
                throw new ArgumentException("Class ID không được để trống");

            if (string.IsNullOrWhiteSpace(classCode))
                throw new ArgumentException("Mã lớp không được để trống");

            if (string.IsNullOrWhiteSpace(className))
                throw new ArgumentException("Tên lớp không được để trống");

            if (maxStudents <= 0)
                throw new ArgumentException("Sĩ số tối đa phải lớn hơn 0");

            await _classRepository.UpdateAsync(classId, classCode, className,
                subjectId, lecturerId, semester, academicYearId, maxStudents, updatedBy);
        }

        /// <summary>
        /// Xóa class (soft delete)
        /// </summary>
        public async Task DeleteClassAsync(string classId, string deletedBy)
        {
            if (string.IsNullOrWhiteSpace(classId))
                throw new ArgumentException("Class ID không được để trống");

            await _classRepository.DeleteAsync(classId, deletedBy);
        }

        /// <summary>
        /// Lấy classes theo lecturer ID
        /// </summary>
        public async Task<List<Class>> GetClassesByLecturerAsync(string lecturerId)
        {
            if (string.IsNullOrWhiteSpace(lecturerId))
                throw new ArgumentException("Lecturer ID không được để trống");

            return await _classRepository.GetByLecturerIdAsync(lecturerId);
        }

        /// <summary>
        /// Lấy classes theo student ID
        /// </summary>
        public async Task<List<Class>> GetClassesByStudentAsync(string studentId)
        {
            if (string.IsNullOrWhiteSpace(studentId))
                throw new ArgumentException("Student ID không được để trống");

            return await _classRepository.GetByStudentIdAsync(studentId);
        }
    }
}

