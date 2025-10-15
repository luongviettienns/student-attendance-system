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
        public DbSet<Permission> Permissions { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }

        // ==============================
        // 🔹 Cấu hình mối quan hệ
        // ==============================
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ===== USERS =====
            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("users");
                entity.HasKey(u => u.UserId);

                entity.HasOne(u => u.Role)
                      .WithMany(r => r.Users)
                      .HasForeignKey(u => u.RoleId)
                      .OnDelete(DeleteBehavior.Restrict);
            });

            // ===== ROLES =====
            modelBuilder.Entity<Role>(entity =>
            {
                entity.ToTable("roles");
                entity.HasKey(r => r.RoleId);
            });

            // ===== PERMISSIONS =====
            modelBuilder.Entity<Permission>(entity =>
            {
                entity.ToTable("permissions");
                entity.HasKey(p => p.PermissionId);
            });

            // ===== ROLE_PERMISSIONS =====
            modelBuilder.Entity<RolePermission>(entity =>
            {
                entity.ToTable("RolePermissions");

                // Khóa chính riêng biệt
                entity.HasKey(rp => rp.RolePermissionId);

                // Quan hệ Role → RolePermissions
                entity.HasOne(rp => rp.Role)
                      .WithMany()
                      .HasForeignKey(rp => rp.RoleId)
                      .OnDelete(DeleteBehavior.Cascade);

                // Quan hệ Permission → RolePermissions
                entity.HasOne(rp => rp.Permission)
                      .WithMany()
                      .HasForeignKey(rp => rp.PermissionId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // ===== SEED DỮ LIỆU ROLE CƠ BẢN =====
            modelBuilder.Entity<Role>().HasData(
                new Role
                {
                    RoleId = "role-001",
                    RoleName = "Admin",
                    Description = "Quản trị hệ thống",
                    CreatedAt = DateTime.Now,
                    CreatedBy = "system",
                    IsActive = true
                },
                new Role
                {
                    RoleId = "role-002",
                    RoleName = "Lecturer",
                    Description = "Giảng viên",
                    CreatedAt = DateTime.Now,
                    CreatedBy = "system",
                    IsActive = true
                },
                new Role
                {
                    RoleId = "role-003",
                    RoleName = "Student",
                    Description = "Sinh viên",
                    CreatedAt = DateTime.Now,
                    CreatedBy = "system",
                    IsActive = true
                },
                new Role
                {
                    RoleId = "role-004",
                    RoleName = "Advisor",
                    Description = "Cố vấn học tập",
                    CreatedAt = DateTime.Now,
                    CreatedBy = "system",
                    IsActive = true
                }
            );
        }
    }
}
