using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;

namespace EducationManagement.BLL.Services
{
    public class MajorService
    {
        private readonly MajorRepository _repo;
        private readonly FacultyRepository _facultyRepo;

        public MajorService(MajorRepository repo, FacultyRepository facultyRepo)
        {
            _repo = repo;
            _facultyRepo = facultyRepo;
        }

        public async Task<List<Major>> GetAllAsync() => await _repo.GetAllAsync();

        public async Task<Major?> GetByIdAsync(string id) => await _repo.GetByIdAsync(id);

        public async Task<List<Major>> GetByFacultyAsync(string facultyId)
        {
            return await _repo.GetByFacultyAsync(facultyId);
        }

        public async Task AddAsync(Major major)
        {
            // ✅ Ràng buộc nghiệp vụ: Faculty phải tồn tại
            var faculty = await _facultyRepo.GetByIdAsync(major.FacultyId);
            if (faculty == null)
                throw new Exception("Khoa không tồn tại!");

            major.MajorId = Guid.NewGuid().ToString();
            major.CreatedAt = DateTime.Now;

            await _repo.AddAsync(major);
        }

        public async Task UpdateAsync(Major major)
        {
            major.UpdatedAt = DateTime.Now;
            await _repo.UpdateAsync(major);
        }

        public async Task DeleteAsync(string id)
        {
            await _repo.DeleteAsync(id);
        }
    }
}
