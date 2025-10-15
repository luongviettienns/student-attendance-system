using EducationManagement.Common.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Data;

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
        // 🔹 CẤU HÌNH MỐI QUAN HỆ & TÊN BẢNG
        // ==========================================================
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ===== USERS =====
            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("Users"); // ✅ đúng với DB
                entity.HasKey(u => u.UserId);

                entity.HasOne(u => u.Role)
                      .WithMany(r => r.Users)
                      .HasForeignKey(u => u.RoleId)
                      .OnDelete(DeleteBehavior.Restrict);
            });

            // ===== ROLES =====
            modelBuilder.Entity<Role>(entity =>
            {
                entity.ToTable("Roles"); // ✅ đúng với DB
                entity.HasKey(r => r.RoleId);
            });

            // ===== PERMISSIONS =====
            modelBuilder.Entity<Permission>(entity =>
            {
                entity.ToTable("Permissions"); // ✅ đúng với DB
                entity.HasKey(p => p.PermissionId);
            });

            // ===== ROLE_PERMISSIONS =====
            modelBuilder.Entity<RolePermission>(entity =>
            {
                entity.ToTable("RolePermissions"); // ✅ FIXED: đúng với DB thật
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

            // ===== REFRESH TOKENS =====
            // ===== REFRESH TOKENS =====
            modelBuilder.Entity<RefreshToken>(entity =>
            {
                entity.ToTable("RefreshTokens");      // ✅ Map đúng bảng
                entity.HasKey(r => r.Id);             // ✅ Khóa chính đúng tên cột DB
                entity.Property(r => r.Token)
                      .IsRequired()
                      .HasMaxLength(4000);

                entity.Property(r => r.UserId)
                      .IsRequired()
                      .HasMaxLength(50);

                entity.Property(r => r.CreatedAt)
                      .HasColumnType("datetime2");

                entity.Property(r => r.ExpiresAt)
                      .HasColumnType("datetime2");

                entity.Property(r => r.RevokedAt)
                      .HasColumnType("datetime2");
            });


            // ===== DANH MỤC ĐÀO TẠO =====
            modelBuilder.Entity<AcademicYear>().ToTable("Academic_Years");
            modelBuilder.Entity<Faculty>().ToTable("Faculties");
            modelBuilder.Entity<Lecturer>().ToTable("Lecturers");
            modelBuilder.Entity<Major>().ToTable("Majors");
            modelBuilder.Entity<Subject>().ToTable("Subjects");
            modelBuilder.Entity<Department>().ToTable("Departments");

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
        public async Task ExecuteAddStudentAsync(SqlCommand cmd)
        {
            // Lấy chuỗi kết nối từ DbContext
            var connection = Database.GetDbConnection();

            // Gán connection cho command
            cmd.Connection = (SqlConnection)connection;
            cmd.CommandType = CommandType.StoredProcedure;

            if (connection.State != ConnectionState.Open)
                await connection.OpenAsync();

            await cmd.ExecuteNonQueryAsync();
        }
    }
}
