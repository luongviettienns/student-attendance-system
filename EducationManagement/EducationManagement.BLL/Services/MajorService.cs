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
        private readonly CachingService? _cache;

        public MajorService(MajorRepository repo, FacultyRepository facultyRepo, CachingService? cache = null)
        {
            _repo = repo;
            _facultyRepo = facultyRepo;
            _cache = cache;
        }

        public async Task<List<Major>> GetAllAsync()
        {
            if (_cache != null)
            {
                return await _cache.GetOrSetAsync(
                    CacheKeys.AllMajors,
                    async () => await _repo.GetAllAsync(),
                    CacheKeys.MajorExpiration
                ) ?? new List<Major>();
            }
            return await _repo.GetAllAsync();
        }
        
        public Task<(List<Major> items, int totalCount)> GetAllPagedAsync(
            int page = 1, int pageSize = 10, string? search = null) 
            => _repo.GetAllPagedAsync(page, pageSize, search);

        public async Task<Major?> GetByIdAsync(string id) => await _repo.GetByIdAsync(id);

        public async Task<List<Major>> GetByFacultyAsync(string facultyId)
        {
            if (_cache != null)
            {
                var cacheKey = string.Format(CacheKeys.MajorsByFaculty, facultyId);
                return await _cache.GetOrSetAsync(
                    cacheKey,
                    async () => await _repo.GetByFacultyAsync(facultyId),
                    CacheKeys.MajorExpiration
                ) ?? new List<Major>();
            }
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
