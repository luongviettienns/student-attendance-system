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

        // ==========================================================
        // 🔹 HỆ THỐNG NGƯỜI DÙNG & PHÂN QUYỀN
        // ==========================================================
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<Permission> Permissions { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }

        // ==========================================================
        // 🔹 DANH MỤC QUẢN LÝ ĐÀO TẠO
        // ==========================================================
        public DbSet<AcademicYear> AcademicYears { get; set; }
        public DbSet<Faculty> Faculties { get; set; }
        public DbSet<Lecturer> Lecturers { get; set; }
        public DbSet<Major> Majors { get; set; }
        public DbSet<Subject> Subjects { get; set; }
        public DbSet<Department> Departments { get; set; }

        // ==========================================================
        // 🔹 CẤU HÌNH MỐI QUAN HỆ
        // ==========================================================
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
                entity.ToTable("role_permissions");
                entity.HasKey(rp => rp.RolePermissionId);

                entity.HasOne(rp => rp.Role)
                      .WithMany()
                      .HasForeignKey(rp => rp.RoleId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(rp => rp.Permission)
                      .WithMany()
                      .HasForeignKey(rp => rp.PermissionId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // ======================================================
            // 🔹 SEED DỮ LIỆU ROLE CƠ BẢN
            // ======================================================
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
