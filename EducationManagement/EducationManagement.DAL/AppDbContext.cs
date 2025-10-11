using System;
using EducationManagement.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace EducationManagement.DAL
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        // ==============================
        // 🔹 Các DbSet (bảng chính)
        // ==============================
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }

        // 🔹 Thêm mới cho RBAC
        public DbSet<Permission> Permissions { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }

        // ==============================
        // 🔹 Cấu hình mối quan hệ
        // ==============================
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Bảng users
            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("users");
                entity.HasKey(u => u.UserId);

                entity.HasOne(u => u.Role)
                      .WithMany(r => r.Users)
                      .HasForeignKey(u => u.RoleId);
            });

            // Bảng roles
            modelBuilder.Entity<Role>(entity =>
            {
                entity.ToTable("roles");
                entity.HasKey(r => r.RoleId);
            });

            // Bảng permissions
            modelBuilder.Entity<Permission>(entity =>
            {
                entity.ToTable("permissions");
                entity.HasKey(p => p.PermissionId);
            });

            // Bảng role_permissions (many-to-many)
            modelBuilder.Entity<RolePermission>(entity =>
            {
                entity.ToTable("role_permissions");
                entity.HasKey(rp => new { rp.RoleId, rp.PermissionId });

                entity.HasOne(rp => rp.Role)
                      .WithMany()
                      .HasForeignKey(rp => rp.RoleId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(rp => rp.Permission)
                      .WithMany()
                      .HasForeignKey(rp => rp.PermissionId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // 📌 Seed dữ liệu roles cơ bản (nếu cần)
            // 📌 Seed dữ liệu roles mặc định
            modelBuilder.Entity<Role>().HasData(
                new Role { RoleId = "role-001", RoleName = "Admin", Description = "Quản trị hệ thống" },
                new Role { RoleId = "role-002", RoleName = "Lecturer", Description = "Giảng viên" },
                new Role { RoleId = "role-003", RoleName = "Student", Description = "Sinh viên" },
                new Role { RoleId = "role-004", RoleName = "Advisor", Description = "Cố vấn học tập" }
            );

        }
    }
}
