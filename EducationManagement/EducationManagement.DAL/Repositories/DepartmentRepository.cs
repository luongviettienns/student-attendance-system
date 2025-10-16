using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace EducationManagement.DAL.Repositories
{
    public class DepartmentRepository
    {
        private readonly AppDbContext _context;

        public DepartmentRepository(AppDbContext context)
        {
            _context = context;
        }

        // ==========================================================
        // 🔹 Lấy tất cả bộ môn (còn hoạt động)
        // ==========================================================
        public async Task<List<Department>> GetAllAsync()
        {
            return await _context.Departments
                .Where(x => x.IsActive)
                .OrderBy(x => x.DepartmentName)
                .ToListAsync();
        }

        // ==========================================================
        // 🔹 Lấy bộ môn theo ID
        // ==========================================================
        public async Task<Department?> GetByIdAsync(string id)
        {
            return await _context.Departments
                .FirstOrDefaultAsync(x => x.DepartmentId == id && x.IsActive);
        }

        // ==========================================================
        // 🔹 Thêm mới
        // ==========================================================
        public async Task AddAsync(Department entity)
        {
            entity.CreatedAt = DateTime.Now;
            entity.IsActive = true;
            _context.Departments.Add(entity);
            await _context.SaveChangesAsync();
        }

        // ==========================================================
        // 🔹 Cập nhật
        // ==========================================================
        public async Task UpdateAsync(Department entity)
        {
            entity.UpdatedAt = DateTime.Now;
            _context.Departments.Update(entity);
            await _context.SaveChangesAsync();
        }

        // ==========================================================
        // 🔹 Xoá mềm (soft delete)
        // ==========================================================
        public async Task DeleteAsync(string id)
        {
            var dep = await _context.Departments
                .FirstOrDefaultAsync(x => x.DepartmentId == id);
            if (dep != null)
            {
                dep.IsActive = false;
                dep.DeletedAt = DateTime.Now;
                _context.Departments.Update(dep);
                await _context.SaveChangesAsync();
            }
        }
    }
}
