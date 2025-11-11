using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EducationManagement.Common.Models;
using EducationManagement.DAL.Repositories;
using Microsoft.Extensions.Caching.Memory;

namespace EducationManagement.BLL.Services
{
    public class FacultyService
    {
        private readonly FacultyRepository _repo;
        private readonly IMemoryCache _memoryCache;
        private readonly CachingService _distributedCache;
        private const string CacheKeyPrefix = "faculty:";
        private static readonly TimeSpan CacheExpiration = TimeSpan.FromHours(6); // Faculties rarely change

        public FacultyService(FacultyRepository repo, IMemoryCache memoryCache, CachingService distributedCache)
        {
            _repo = repo;
            _memoryCache = memoryCache;
            _distributedCache = distributedCache;
        }

        public async Task<List<Faculty>> GetAllAsync()
        {
            const string cacheKey = CacheKeys.AllFaculties;
            
            // Try memory cache first (fastest)
            if (_memoryCache.TryGetValue(cacheKey, out List<Faculty>? cachedFaculties))
            {
                return cachedFaculties ?? new List<Faculty>();
            }

            // Try distributed cache
            var faculties = await _distributedCache.GetOrSetAsync(
                cacheKey,
                async () => await _repo.GetAllAsync(),
                CacheKeys.FacultyExpiration
            );

            if (faculties != null)
            {
                // Store in memory cache for quick access
                _memoryCache.Set(cacheKey, faculties, new MemoryCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1), // Shorter TTL for memory cache
                    Size = 1 // Size limit for memory cache
                });
            }

            return faculties ?? new List<Faculty>();
        }
        
        public Task<(List<Faculty> items, int totalCount)> GetAllPagedAsync(
            int page = 1, int pageSize = 10, string? search = null) 
            => _repo.GetAllPagedAsync(page, pageSize, search);
        
        public async Task<Faculty?> GetByIdAsync(string id)
        {
            var cacheKey = string.Format(CacheKeys.FacultyById, id);
            
            // Try memory cache first
            if (_memoryCache.TryGetValue(cacheKey, out Faculty? cachedFaculty))
            {
                return cachedFaculty;
            }

            // Try distributed cache
            var faculty = await _distributedCache.GetOrSetAsync(
                cacheKey,
                async () => await _repo.GetByIdAsync(id),
                CacheKeys.FacultyExpiration
            );

            if (faculty != null)
            {
                // Store in memory cache
                _memoryCache.Set(cacheKey, faculty, new MemoryCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(1),
                    Size = 1
                });
            }

            return faculty;
        }

        public async Task AddAsync(Faculty f)
        {
            await _repo.AddAsync(f);
            // Invalidate caches
            await InvalidateCacheAsync();
        }

        public async Task UpdateAsync(Faculty f)
        {
            await _repo.UpdateAsync(f);
            // Invalidate caches
            await InvalidateCacheAsync(f.FacultyId);
        }

        public async Task DeleteAsync(string id)
        {
            await _repo.DeleteAsync(id);
            // Invalidate caches
            await InvalidateCacheAsync(id);
        }

        private async Task InvalidateCacheAsync(string? facultyId = null)
        {
            // Remove from memory cache
            _memoryCache.Remove(CacheKeys.AllFaculties);
            if (!string.IsNullOrEmpty(facultyId))
            {
                _memoryCache.Remove(string.Format(CacheKeys.FacultyById, facultyId));
            }

            // Remove from distributed cache
            await _distributedCache.RemoveAsync(CacheKeys.AllFaculties);
            if (!string.IsNullOrEmpty(facultyId))
            {
                await _distributedCache.RemoveAsync(string.Format(CacheKeys.FacultyById, facultyId));
            }
        }
    }
}
