using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;

namespace EducationManagement.BLL.Services
{
    public class FacultyService
    {
        private readonly FacultyRepository _repo;

        public FacultyService(FacultyRepository repo)
        {
            _repo = repo;
        }

        public Task<List<Faculty>> GetAllAsync() => _repo.GetAllAsync();
        public Task<Faculty?> GetByIdAsync(string id) => _repo.GetByIdAsync(id);
        public Task AddAsync(Faculty f) => _repo.AddAsync(f);
        public Task UpdateAsync(Faculty f) => _repo.UpdateAsync(f);
        public Task DeleteAsync(string id) => _repo.DeleteAsync(id);
    }
}
