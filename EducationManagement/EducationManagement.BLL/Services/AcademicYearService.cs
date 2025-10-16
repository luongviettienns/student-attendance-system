using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;

namespace EducationManagement.BLL.Services
{
    public class AcademicYearService
    {
        private readonly AcademicYearRepository _repo;

        public AcademicYearService(AcademicYearRepository repo)
        {
            _repo = repo;
        }

        public Task<List<AcademicYear>> GetAllAsync() => _repo.GetAllAsync();
        public Task<AcademicYear?> GetByIdAsync(string id) => _repo.GetByIdAsync(id);

        public async Task AddAsync(AcademicYear entity)
        {
            // ✅ Không cho trùng mã niên khóa
            if (await _repo.ExistsCodeAsync(entity.YearCode))
                throw new Exception($"Mã niên khóa '{entity.YearCode}' đã tồn tại!");

            entity.AcademicYearId = Guid.NewGuid().ToString();
            entity.CreatedAt = DateTime.Now;

            await _repo.AddAsync(entity);
        }

        public async Task UpdateAsync(AcademicYear entity)
        {
            entity.UpdatedAt = DateTime.Now;
            await _repo.UpdateAsync(entity);
        }

        public Task DeleteAsync(string id) => _repo.DeleteAsync(id);
    }
}
