using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace EducationManagement.DAL.Repositories
{
    public class AcademicYearRepository
    {
        private readonly AppDbContext _context;

        public AcademicYearRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<AcademicYear>> GetAllAsync()
        {
            return await _context.AcademicYears
                .Where(x => x.IsActive)
                .OrderByDescending(x => x.YearCode)
                .ToListAsync();
        }

        public async Task<AcademicYear?> GetByIdAsync(string id)
        {
            return await _context.AcademicYears.FindAsync(id);
        }

        public async Task AddAsync(AcademicYear entity)
        {
            _context.AcademicYears.Add(entity);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(AcademicYear entity)
        {
            _context.AcademicYears.Update(entity);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(string id)
        {
            var item = await _context.AcademicYears.FindAsync(id);
            if (item != null)
            {
                item.IsActive = false;
                item.DeletedAt = DateTime.Now;
                _context.AcademicYears.Update(item);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<bool> ExistsCodeAsync(string yearCode)
        {
            return await _context.AcademicYears
                .AnyAsync(x => x.YearCode == yearCode && x.IsActive);
        }
    }
}
