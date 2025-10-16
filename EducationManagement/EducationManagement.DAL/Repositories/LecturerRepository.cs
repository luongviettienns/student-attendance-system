using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace EducationManagement.DAL.Repositories
{
    public class LecturerRepository
    {
        private readonly AppDbContext _context;

        public LecturerRepository(AppDbContext context)
        {
            _context = context;
        }

        // ============================================================
        // 🔹 Lấy danh sách giảng viên (chỉ các bản ghi đang hoạt động)
        // ============================================================
        public async Task<List<Lecturer>> GetAllAsync()
        {
            return await _context.Lecturers
                .Where(x => x.IsActive)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();
        }

        // ============================================================
        // 🔹 Lấy giảng viên theo ID
        // ============================================================
        public async Task<Lecturer?> GetByIdAsync(string id)
        {
            return await _context.Lecturers
                .FirstOrDefaultAsync(x => x.LecturerId == id && x.IsActive);
        }

        // ============================================================
        // 🔹 Lấy giảng viên theo UserId (dùng khi login hoặc xem profile)
        // ============================================================
        public async Task<Lecturer?> GetByUserIdAsync(string userId)
        {
            return await _context.Lecturers
                .FirstOrDefaultAsync(x => x.UserId == userId && x.IsActive);
        }

        // ============================================================
        // 🔹 Thêm mới giảng viên
        // ============================================================
        public async Task AddAsync(Lecturer entity)
        {
            entity.LecturerId = Guid.NewGuid().ToString();
            entity.CreatedAt = DateTime.Now;
            entity.IsActive = true;

            _context.Lecturers.Add(entity);
            await _context.SaveChangesAsync();
        }

        // ============================================================
        // 🔹 Cập nhật giảng viên
        // ============================================================
        public async Task UpdateAsync(Lecturer entity)
        {
            var existing = await _context.Lecturers.FindAsync(entity.LecturerId);
            if (existing == null)
                throw new Exception("Không tìm thấy giảng viên để cập nhật.");

            // Giữ nguyên CreatedAt/CreatedBy
            entity.CreatedAt = existing.CreatedAt;
            entity.CreatedBy = existing.CreatedBy;

            entity.UpdatedAt = DateTime.Now;
            _context.Entry(existing).CurrentValues.SetValues(entity);
            await _context.SaveChangesAsync();
        }

        // ============================================================
        // 🔹 Xóa mềm giảng viên
        // ============================================================
        public async Task DeleteAsync(string id)
        {
            var item = await _context.Lecturers.FindAsync(id);
            if (item == null)
                throw new Exception("Không tìm thấy giảng viên để xóa.");

            item.IsActive = false;
            item.DeletedAt = DateTime.Now;
            _context.Lecturers.Update(item);
            await _context.SaveChangesAsync();
        }
    }
}
