using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace EducationManagement.DAL.Repositories
{
    public class MajorRepository
    {
        private readonly AppDbContext _context;

        public MajorRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Major>> GetAllAsync()
        {
            return await _context.Majors
                .Where(x => x.IsActive)
                .OrderBy(x => x.MajorName)
                .ToListAsync();
        }

        public async Task<Major?> GetByIdAsync(string id)
        {
            return await _context.Majors.FindAsync(id);
        }

        public async Task AddAsync(Major major)
        {
            _context.Majors.Add(major);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Major major)
        {
            _context.Majors.Update(major);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(string id)
        {
            var m = await _context.Majors.FindAsync(id);
            if (m != null)
            {
                m.IsActive = false;
                m.DeletedAt = DateTime.Now;
                _context.Majors.Update(m);
                await _context.SaveChangesAsync();
            }
        }

        // 🔹 Lấy danh sách ngành theo khoa
        public async Task<List<Major>> GetByFacultyAsync(string facultyId)
        {
            return await _context.Majors
                .Where(x => x.FacultyId == facultyId && x.IsActive)
                .OrderBy(x => x.MajorName)
                .ToListAsync();
        }
    }
}
