using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace EducationManagement.DAL.Repositories
{
    public class FacultyRepository
    {
        private readonly AppDbContext _context;
        public FacultyRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Faculty>> GetAllAsync()
        {
            return await _context.Faculties
                .Where(x => x.IsActive)
                .OrderBy(x => x.FacultyName)
                .ToListAsync();
        }

        public async Task<Faculty?> GetByIdAsync(string id)
        {
            return await _context.Faculties.FindAsync(id);
        }

        public async Task AddAsync(Faculty faculty)
        {
            _context.Faculties.Add(faculty);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Faculty faculty)
        {
            _context.Faculties.Update(faculty);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(string id)
        {
            var f = await _context.Faculties.FindAsync(id);
            if (f != null)
            {
                f.IsActive = false;
                f.DeletedAt = DateTime.Now;
                _context.Faculties.Update(f);
                await _context.SaveChangesAsync();
            }
        }
    }
}
