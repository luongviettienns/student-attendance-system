using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace EducationManagement.DAL.Repositories
{
    public class SubjectRepository
    {
        private readonly AppDbContext _context;

        public SubjectRepository(AppDbContext context)
        {
            _context = context;
        }

        // ==========================================================
        // 🔹 LẤY DANH SÁCH MÔN HỌC (ACTIVE)
        // ==========================================================
        public async Task<List<Subject>> GetAllAsync()
        {
            return await _context.Subjects
                .Where(x => x.IsActive)
                .OrderBy(x => x.SubjectCode)
                .ToListAsync();
        }

        // ==========================================================
        // 🔹 LẤY MÔN HỌC THEO ID
        // ==========================================================
        public async Task<Subject?> GetByIdAsync(string id)
        {
            return await _context.Subjects
                .FirstOrDefaultAsync(x => x.SubjectId == id && x.IsActive);
        }

        // ==========================================================
        // 🔹 LẤY DANH SÁCH THEO KHOA (DepartmentId)
        // ==========================================================
        public async Task<List<Subject>> GetByDepartmentAsync(string departmentId)
        {
            return await _context.Subjects
                .Where(x => x.DepartmentId == departmentId && x.IsActive)
                .OrderBy(x => x.SubjectCode)
                .ToListAsync();
        }

        // ==========================================================
        // 🔹 THÊM MỚI
        // ==========================================================
        public async Task AddAsync(Subject entity)
        {
            entity.CreatedAt = DateTime.Now;
            entity.IsActive = true;
            _context.Subjects.Add(entity);
            await _context.SaveChangesAsync();
        }

        // ==========================================================
        // 🔹 CẬP NHẬT
        // ==========================================================
        public async Task UpdateAsync(Subject entity)
        {
            entity.UpdatedAt = DateTime.Now;
            _context.Subjects.Update(entity);
            await _context.SaveChangesAsync();
        }

        // ==========================================================
        // 🔹 XOÁ MỀM (SOFT DELETE)
        // ==========================================================
        public async Task DeleteAsync(string id)
        {
            var item = await _context.Subjects.FirstOrDefaultAsync(x => x.SubjectId == id);
            if (item != null)
            {
                item.IsActive = false;
                item.DeletedAt = DateTime.Now;
                _context.Subjects.Update(item);
                await _context.SaveChangesAsync();
            }
        }

        // ==========================================================
        // 🔹 KIỂM TRA MÃ MÔN HỌC ĐÃ TỒN TẠI CHƯA
        // ==========================================================
        public async Task<bool> ExistsCodeAsync(string code)
        {
            return await _context.Subjects
                .AnyAsync(x => x.SubjectCode == code && x.IsActive);
        }
    }
}
