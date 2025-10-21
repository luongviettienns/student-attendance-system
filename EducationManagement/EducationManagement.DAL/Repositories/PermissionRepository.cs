using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using EducationManagement.Common.Models;

namespace EducationManagement.DAL.Repositories
{
    public class PermissionRepository
    {
        private readonly string _connectionString;

        public PermissionRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new ArgumentNullException("Connection string 'DefaultConnection' not found.");
        }

        // ============================================================
        // 🔹 1️⃣ LẤY TẤT CẢ PERMISSIONS
        // ============================================================
        public async Task<List<Permission>> GetAllAsync()
        {
            var permissions = new List<Permission>();
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetAllPermissions");

            foreach (DataRow row in dt.Rows)
                permissions.Add(MapToPermission(row));

            return permissions;
        }

        // ============================================================
        // 🔹 2️⃣ LẤY PERMISSIONS CỦA MỘT ROLE (theo RoleId)
        // ============================================================
        public async Task<List<Permission>> GetByRoleIdAsync(string roleId)
        {
            var permissions = new List<Permission>();
            var param = new SqlParameter("@RoleId", roleId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetRolePermissions", param);

            foreach (DataRow row in dt.Rows)
                permissions.Add(MapToPermission(row));

            return permissions;
        }

        // ============================================================
        // 🔹 3️⃣ LẤY PERMISSIONS THEO ROLE NAME (cho Menu)
        // ============================================================
        public async Task<List<Permission>> GetByRoleNameAsync(string roleName)
        {
            var permissions = new List<Permission>();
            var param = new SqlParameter("@RoleName", roleName);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetPermissionsByRoleName", param);

            foreach (DataRow row in dt.Rows)
                permissions.Add(MapToPermission(row));

            return permissions;
        }

        // ============================================================
        // 🔹 4️⃣ LẤY DANH SÁCH PERMISSION IDs CỦA ROLE
        // ============================================================
        public async Task<List<string>> GetPermissionIdsByRoleAsync(string roleId)
        {
            var permissionIds = new List<string>();
            var param = new SqlParameter("@RoleId", roleId);
            var dt = await DatabaseHelper.ExecuteQueryAsync(_connectionString, "sp_GetRolePermissions", param);

            // SP này chỉ trả về PermissionId
            foreach (DataRow row in dt.Rows)
            {
                var permId = row["PermissionId"]?.ToString();
                if (!string.IsNullOrEmpty(permId))
                    permissionIds.Add(permId);
            }

            return permissionIds;
        }

        // ============================================================
        // 🔹 5️⃣ XOÁ TẤT CẢ PERMISSIONS CỦA ROLE
        // ============================================================
        public async Task DeleteAllByRoleAsync(string roleId)
        {
            var param = new SqlParameter("@RoleId", roleId);
            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_DeleteAllRolePermissions", param);
        }

        // ============================================================
        // 🔹 6️⃣ THÊM PERMISSION CHO ROLE
        // ============================================================
        public async Task AddRolePermissionAsync(string roleId, string permissionId, string createdBy)
        {
            var parameters = new[]
            {
                new SqlParameter("@RoleId", roleId),
                new SqlParameter("@PermissionId", permissionId),
                new SqlParameter("@CreatedBy", createdBy)
            };

            await DatabaseHelper.ExecuteNonQueryAsync(_connectionString, "sp_AddRolePermission", parameters);
        }

        // ============================================================
        // 🔹 MAP DataRow → Permission MODEL
        // ============================================================
        private static Permission MapToPermission(DataRow row)
        {
            return new Permission
            {
                PermissionId = row["PermissionId"].ToString()!,
                PermissionCode = row["PermissionCode"].ToString()!,
                PermissionName = row["PermissionName"].ToString()!,
                ParentCode = row["ParentCode"]?.ToString(),
                Icon = row["Icon"]?.ToString(),
                Description = row.Table.Columns.Contains("Description") ? row["Description"]?.ToString() : null,
                SortOrder = row.Table.Columns.Contains("SortOrder") && row["SortOrder"] != DBNull.Value
                    ? Convert.ToInt32(row["SortOrder"])
                    : 0,
                IsActive = row.Table.Columns.Contains("IsActive")
                    ? Convert.ToBoolean(row["IsActive"])
                    : true,
                CreatedAt = row.Table.Columns.Contains("CreatedAt") && row["CreatedAt"] != DBNull.Value
                    ? Convert.ToDateTime(row["CreatedAt"])
                    : DateTime.Now,
                CreatedBy = row.Table.Columns.Contains("CreatedBy") ? row["CreatedBy"]?.ToString() : null,
                UpdatedAt = row.Table.Columns.Contains("UpdatedAt") && row["UpdatedAt"] != DBNull.Value
                    ? Convert.ToDateTime(row["UpdatedAt"])
                    : null,
                UpdatedBy = row.Table.Columns.Contains("UpdatedBy") ? row["UpdatedBy"]?.ToString() : null,
                DeletedAt = row.Table.Columns.Contains("DeletedAt") && row["DeletedAt"] != DBNull.Value
                    ? Convert.ToDateTime(row["DeletedAt"])
                    : null
            };
        }
    }
}

