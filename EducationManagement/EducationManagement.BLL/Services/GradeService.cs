using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EducationManagement.BLL.Services
{
    public class GradeService
    {
        private readonly GradeRepository _gradeRepository;

        public GradeService(GradeRepository gradeRepository)
        {
            _gradeRepository = gradeRepository;
        }

        public async Task<List<Grade>> GetAllGradesAsync()
        {
            return await _gradeRepository.GetAllAsync();
        }

        public async Task<Grade?> GetGradeByIdAsync(string gradeId)
        {
            if (string.IsNullOrWhiteSpace(gradeId))
                throw new ArgumentException("Grade ID không được để trống");

            return await _gradeRepository.GetByIdAsync(gradeId);
        }

        public async Task<string> CreateGradeAsync(string gradeId, string studentId, string classId,
            string gradeType, decimal score, decimal maxScore, decimal weight, string? notes,
            string? gradedBy, string createdBy)
        {
            if (string.IsNullOrWhiteSpace(studentId))
                throw new ArgumentException("Student ID không được để trống");

            if (string.IsNullOrWhiteSpace(classId))
                throw new ArgumentException("Class ID không được để trống");

            if (string.IsNullOrWhiteSpace(gradeType))
                throw new ArgumentException("Grade type không được để trống");

            if (score < 0 || score > maxScore)
                throw new ArgumentException($"Điểm phải nằm trong khoảng 0 đến {maxScore}");

            return await _gradeRepository.CreateAsync(gradeId, studentId, classId,
                gradeType, score, maxScore, weight, notes, gradedBy, createdBy);
        }

        public async Task UpdateGradeAsync(string gradeId, string gradeType, decimal score,
            decimal maxScore, decimal weight, string? notes, string updatedBy)
        {
            if (string.IsNullOrWhiteSpace(gradeId))
                throw new ArgumentException("Grade ID không được để trống");

            if (score < 0 || score > maxScore)
                throw new ArgumentException($"Điểm phải nằm trong khoảng 0 đến {maxScore}");

            await _gradeRepository.UpdateAsync(gradeId, gradeType, score, maxScore, weight, notes, updatedBy);
        }

        public async Task DeleteGradeAsync(string gradeId, string deletedBy)
        {
            if (string.IsNullOrWhiteSpace(gradeId))
                throw new ArgumentException("Grade ID không được để trống");

            await _gradeRepository.DeleteAsync(gradeId, deletedBy);
        }

        public async Task<List<Grade>> GetGradesByStudentAsync(string studentId)
        {
            if (string.IsNullOrWhiteSpace(studentId))
                throw new ArgumentException("Student ID không được để trống");

            return await _gradeRepository.GetByStudentIdAsync(studentId);
        }

        public async Task<List<Grade>> GetGradesByClassAsync(string classId)
        {
            if (string.IsNullOrWhiteSpace(classId))
                throw new ArgumentException("Class ID không được để trống");

            return await _gradeRepository.GetByClassIdAsync(classId);
        }
    }
}

