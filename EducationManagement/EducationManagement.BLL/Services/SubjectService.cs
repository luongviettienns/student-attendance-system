using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;

namespace EducationManagement.BLL.Services
{
    public class SubjectService
    {
        private readonly SubjectRepository _repo;
        private readonly DepartmentRepository _depRepo;

        public SubjectService(SubjectRepository repo, DepartmentRepository depRepo)
        {
            _repo = repo;
            _depRepo = depRepo;
        }

        public Task<List<Subject>> GetAllAsync() => _repo.GetAllAsync();
        public Task<Subject?> GetByIdAsync(string id) => _repo.GetByIdAsync(id);
        public Task<List<Subject>> GetByDepartmentAsync(string departmentId) => _repo.GetByDepartmentAsync(departmentId);

        public async Task AddAsync(Subject model)
        {
            // 🔹 Kiểm tra trùng mã môn học
            if (await _repo.ExistsCodeAsync(model.SubjectCode))
                throw new Exception($"Mã môn học '{model.SubjectCode}' đã tồn tại.");

            // 🔹 Kiểm tra bộ môn có tồn tại không
            var dep = await _depRepo.GetByIdAsync(model.DepartmentId);
            if (dep == null)
                throw new Exception("Bộ môn không tồn tại.");

            model.SubjectId = Guid.NewGuid().ToString();
            model.CreatedAt = DateTime.Now;
            await _repo.AddAsync(model);
        }

        public async Task UpdateAsync(Subject model)
        {
            model.UpdatedAt = DateTime.Now;
            await _repo.UpdateAsync(model);
        }

        public Task DeleteAsync(string id) => _repo.DeleteAsync(id);
    }
}
