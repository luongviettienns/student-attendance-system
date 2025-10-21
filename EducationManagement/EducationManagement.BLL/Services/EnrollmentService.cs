using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EducationManagement.BLL.Services
{
    public class EnrollmentService
    {
        private readonly EnrollmentRepository _enrollmentRepository;

        public EnrollmentService(EnrollmentRepository enrollmentRepository)
        {
            _enrollmentRepository = enrollmentRepository;
        }

        public async Task<List<Enrollment>> GetAllEnrollmentsAsync()
        {
            return await _enrollmentRepository.GetAllAsync();
        }

        public async Task<Enrollment?> GetEnrollmentByIdAsync(string enrollmentId)
        {
            if (string.IsNullOrWhiteSpace(enrollmentId))
                throw new ArgumentException("Enrollment ID không được để trống");

            return await _enrollmentRepository.GetByIdAsync(enrollmentId);
        }

        public async Task<List<Enrollment>> GetEnrollmentsByStudentAsync(string studentId)
        {
            if (string.IsNullOrWhiteSpace(studentId))
                throw new ArgumentException("Student ID không được để trống");

            return await _enrollmentRepository.GetByStudentIdAsync(studentId);
        }

        public async Task<List<Enrollment>> GetEnrollmentsByClassAsync(string classId)
        {
            if (string.IsNullOrWhiteSpace(classId))
                throw new ArgumentException("Class ID không được để trống");

            return await _enrollmentRepository.GetByClassIdAsync(classId);
        }
    }
}

