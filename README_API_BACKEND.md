# 📘 Hướng Dẫn Hoạt Động API Backend
## Hệ Thống Quản Lý Điểm Danh Sinh Viên

---

## 🎯 Tổng Quan Kiến Trúc

Hệ thống Backend được xây dựng theo mô hình **3-Layer Architecture** (Kiến trúc 3 lớp):

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT (Frontend)                        │
│              (Angular, HTML, CSS, JavaScript)               │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTP Request (GET/POST/PUT/DELETE)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              🔵 LAYER 1: API / CONTROLLER                   │
│        EducationManagement.API.Admin/Controllers/           │
│                                                             │
│  ✓ Nhận HTTP Request từ Client                             │
│  ✓ Validate dữ liệu đầu vào (ModelState)                   │
│  ✓ Gọi Service Layer để xử lý nghiệp vụ                    │
│  ✓ Trả về HTTP Response (JSON)                             │
└──────────────────────────┬──────────────────────────────────┘
                           │ Call Service Method
                           ▼
┌─────────────────────────────────────────────────────────────┐
│          🟢 LAYER 2: BUSINESS LOGIC / SERVICE               │
│            EducationManagement.BLL/Services/                │
│                                                             │
│  ✓ Xử lý logic nghiệp vụ (Business Rules)                  │
│  ✓ Validation dữ liệu chi tiết                             │
│  ✓ Xử lý các quy tắc phức tạp                              │
│  ✓ Gọi Repository Layer để truy xuất dữ liệu               │
└──────────────────────────┬──────────────────────────────────┘
                           │ Call Repository Method
                           ▼
┌─────────────────────────────────────────────────────────────┐
│           🟠 LAYER 3: DATA ACCESS / REPOSITORY              │
│           EducationManagement.DAL/Repositories/             │
│                                                             │
│  ✓ Tương tác trực tiếp với Database                        │
│  ✓ Thực thi Stored Procedures                              │
│  ✓ Mapping dữ liệu từ Database sang Model                  │
│  ✓ Sử dụng DatabaseHelper để kết nối SQL Server            │
└──────────────────────────┬──────────────────────────────────┘
                           │ Execute Stored Procedure
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              🔧 DATABASE HELPER UTILITY                     │
│             EducationManagement.DAL/DatabaseHelper          │
│                                                             │
│  ✓ ExecuteQueryAsync()        - Truy vấn SELECT            │
│  ✓ ExecuteNonQueryAsync()     - INSERT/UPDATE/DELETE       │
│  ✓ ExecuteScalarAsync()       - Trả về giá trị đơn         │
│  ✓ ExecuteQueryMultipleAsync()- Nhiều result sets          │
└──────────────────────────┬──────────────────────────────────┘
                           │ ADO.NET Connection
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                 🗄️ SQL SERVER DATABASE                      │
│                   (Stored Procedures)                       │
│                                                             │
│  ✓ sp_GetAllStudents                                        │
│  ✓ sp_GetStudentById                                        │
│  ✓ sp_AddStudentFull                                        │
│  ✓ sp_UpdateStudentFull                                     │
│  ✓ sp_DeleteStudentFull                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Luồng Hoạt Động Chi Tiết

### 📌 **VÍ DỤ: Lấy Danh Sách Sinh Viên**

#### **1️⃣ BƯỚC 1: Client Gửi HTTP Request**

Frontend gửi HTTP GET request:

```http
GET http://localhost:5227/api-edu/students?page=1&pageSize=10&search=Nguyen
Authorization: Bearer <JWT_TOKEN>
```

---

#### **2️⃣ BƯỚC 2: Controller Nhận Request**

📁 File: `EducationManagement.API.Admin/Controllers/StudentsController.cs`

```csharp
[Authorize]
[ApiController]
[Route("api-edu/students")]
public class StudentsController : ControllerBase
{
    private readonly StudentService _studentService;

    public StudentsController(StudentService studentService)
    {
        _studentService = studentService; // ✅ Dependency Injection
    }

    [HttpGet]
    public async Task<IActionResult> GetAllStudents(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? search = null,
        [FromQuery] string? facultyId = null,
        [FromQuery] string? majorId = null,
        [FromQuery] string? academicYearId = null)
    {
        try
        {
            // ✅ Gọi Service Layer
            var (students, totalCount) = await _studentService.GetAllStudentsAsync(
                page, pageSize, search, facultyId, majorId, academicYearId);

            // ✅ Trả về Response JSON
            return Ok(new
            {
                data = students,
                pagination = new
                {
                    page,
                    pageSize,
                    totalCount,
                    totalPages = (int)Math.Ceiling((double)totalCount / pageSize)
                }
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi hệ thống", error = ex.Message });
        }
    }
}
```

**Nhiệm vụ của Controller:**
- ✅ Nhận request từ Frontend
- ✅ Parse query parameters (`page`, `pageSize`, `search`, ...)
- ✅ Kiểm tra JWT Authentication (`[Authorize]`)
- ✅ Gọi `_studentService.GetAllStudentsAsync()`
- ✅ Trả về JSON response với status code (200 OK / 500 Error)

---

#### **3️⃣ BƯỚC 3: Service Layer Xử Lý Business Logic**

📁 File: `EducationManagement.BLL/Services/StudentService.cs`

```csharp
public class StudentService
{
    private readonly StudentRepository _studentRepository;

    public StudentService(StudentRepository studentRepository)
    {
        _studentRepository = studentRepository; // ✅ Dependency Injection
    }

    public async Task<(List<Student> Students, int TotalCount)> GetAllStudentsAsync(
        int page = 1,
        int pageSize = 10,
        string? search = null,
        string? facultyId = null,
        string? majorId = null,
        string? academicYearId = null)
    {
        // ✅ Validation nghiệp vụ
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        if (pageSize > 100) pageSize = 100; // Giới hạn max pageSize

        // ✅ Gọi Repository Layer
        return await _studentRepository.GetAllAsync(
            page, pageSize, search, facultyId, majorId, academicYearId);
    }
}
```

**Nhiệm vụ của Service:**
- ✅ Validate dữ liệu đầu vào (page >= 1, pageSize <= 100)
- ✅ Xử lý các quy tắc nghiệp vụ phức tạp
- ✅ Gọi `_studentRepository.GetAllAsync()`
- ✅ Có thể kết hợp nhiều Repository nếu cần

---

#### **4️⃣ BƯỚC 4: Repository Tương Tác Database**

📁 File: `EducationManagement.DAL/Repositories/StudentRepository.cs`

```csharp
public class StudentRepository
{
    private readonly string _connectionString;

    public StudentRepository(IConfiguration configuration)
    {
        // ✅ Lấy connection string từ appsettings.json
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new ArgumentNullException("Connection string not found.");
    }

    public async Task<(List<Student> Students, int TotalCount)> GetAllAsync(
        int page = 1,
        int pageSize = 10,
        string? search = null,
        string? facultyId = null,
        string? majorId = null,
        string? academicYearId = null)
    {
        var students = new List<Student>();
        int totalCount = 0;

        // ✅ Chuẩn bị parameters cho Stored Procedure
        var parameters = new[]
        {
            new SqlParameter("@Page", page),
            new SqlParameter("@PageSize", pageSize),
            new SqlParameter("@Search", (object?)search ?? DBNull.Value),
            new SqlParameter("@FacultyId", (object?)facultyId ?? DBNull.Value),
            new SqlParameter("@MajorId", (object?)majorId ?? DBNull.Value),
            new SqlParameter("@AcademicYearId", (object?)academicYearId ?? DBNull.Value)
        };

        // ✅ Gọi DatabaseHelper để thực thi Stored Procedure
        var ds = await DatabaseHelper.ExecuteQueryMultipleAsync(
            _connectionString, "sp_GetAllStudents", parameters);

        // ✅ Lấy TotalCount từ result set đầu tiên
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            totalCount = Convert.ToInt32(ds.Tables[0].Rows[0]["TotalCount"]);

        // ✅ Lấy danh sách sinh viên từ result set thứ hai
        if (ds.Tables.Count > 1)
        {
            foreach (DataRow row in ds.Tables[1].Rows)
                students.Add(MapToStudent(row)); // ✅ Map DataRow → Student Object
        }

        return (students, totalCount);
    }

    // ✅ Mapping dữ liệu từ Database sang Model
    private static Student MapToStudent(DataRow row)
    {
        return new Student
        {
            StudentId = row["student_id"].ToString()!,
            UserId = row["user_id"].ToString()!,
            StudentCode = row["student_code"].ToString()!,
            FullName = row["full_name"].ToString()!,
            Gender = row["gender"]?.ToString(),
            Dob = row["dob"] != DBNull.Value ? Convert.ToDateTime(row["dob"]) : null,
            Email = row["email"]?.ToString(),
            Phone = row["phone"]?.ToString(),
            FacultyName = row["faculty_name"]?.ToString(),
            MajorName = row["major_name"]?.ToString(),
            // ... các trường khác
        };
    }
}
```

**Nhiệm vụ của Repository:**
- ✅ Tạo `SqlParameter[]` từ input
- ✅ Gọi `DatabaseHelper.ExecuteQueryMultipleAsync()`
- ✅ Nhận `DataSet` với nhiều result sets
- ✅ Parse `TotalCount` từ Table[0]
- ✅ Parse danh sách sinh viên từ Table[1]
- ✅ Map `DataRow` → `Student` object

---

#### **5️⃣ BƯỚC 5: DatabaseHelper Thực Thi Stored Procedure**

📁 File: `EducationManagement.DAL/DatabaseHelper.cs`

```csharp
public static class DatabaseHelper
{
    public static async Task<DataSet> ExecuteQueryMultipleAsync(
        string connectionString,
        string storedProc,
        params SqlParameter[] parameters)
    {
        var ds = new DataSet();

        try
        {
            // ✅ Tạo kết nối SQL Server
            using var conn = new SqlConnection(connectionString);
            using var cmd = new SqlCommand(storedProc, conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            // ✅ Thêm parameters
            if (parameters?.Length > 0)
                cmd.Parameters.AddRange(PrepareParameters(parameters));

            // ✅ Mở kết nối
            await conn.OpenAsync();

            // ✅ Thực thi Stored Procedure
            using var reader = await cmd.ExecuteReaderAsync();
            
            // ✅ Đọc multiple result sets
            int tableIndex = 0;
            do
            {
                var dt = new DataTable($"Table{tableIndex}");
                
                // Load schema
                for (int i = 0; i < reader.FieldCount; i++)
                {
                    dt.Columns.Add(reader.GetName(i), reader.GetFieldType(i));
                }
                
                // Load rows
                while (await reader.ReadAsync())
                {
                    var row = dt.NewRow();
                    for (int i = 0; i < reader.FieldCount; i++)
                    {
                        row[i] = reader.IsDBNull(i) ? DBNull.Value : reader.GetValue(i);
                    }
                    dt.Rows.Add(row);
                }
                
                ds.Tables.Add(dt);
                tableIndex++;
            } while (await reader.NextResultAsync());
        }
        catch (Exception ex)
        {
            throw new Exception($"Lỗi khi thực thi SP [{storedProc}]: {ex.Message}", ex);
        }

        return ds;
    }
}
```

**Nhiệm vụ của DatabaseHelper:**
- ✅ Tạo `SqlConnection` và `SqlCommand`
- ✅ Set `CommandType = StoredProcedure`
- ✅ Thêm parameters vào command
- ✅ Thực thi `ExecuteReaderAsync()`
- ✅ Đọc multiple result sets vào `DataSet`
- ✅ Xử lý lỗi và throw exception nếu có

---

#### **6️⃣ BƯỚC 6: SQL Server Thực Thi Stored Procedure**

📁 File: `02_StoredProcedures.sql`

```sql
CREATE PROCEDURE sp_GetAllStudents
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL,
    @FacultyId NVARCHAR(50) = NULL,
    @MajorId NVARCHAR(50) = NULL,
    @AcademicYearId NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Page - 1) * @PageSize;

    -- ✅ Result Set 1: TotalCount
    SELECT COUNT(*) AS TotalCount
    FROM Students s
    LEFT JOIN Users u ON s.user_id = u.user_id
    LEFT JOIN Faculties f ON s.faculty_id = f.faculty_id
    LEFT JOIN Majors m ON s.major_id = m.major_id
    LEFT JOIN AcademicYears ay ON s.academic_year_id = ay.academic_year_id
    WHERE s.deleted_at IS NULL
      AND (@Search IS NULL OR u.full_name LIKE '%' + @Search + '%' OR s.student_code LIKE '%' + @Search + '%')
      AND (@FacultyId IS NULL OR s.faculty_id = @FacultyId)
      AND (@MajorId IS NULL OR s.major_id = @MajorId)
      AND (@AcademicYearId IS NULL OR s.academic_year_id = @AcademicYearId);

    -- ✅ Result Set 2: Danh sách sinh viên (phân trang)
    SELECT 
        s.student_id,
        s.user_id,
        s.student_code,
        u.full_name,
        u.gender,
        u.dob,
        u.email,
        u.phone,
        f.faculty_name,
        m.major_name,
        ay.year_code,
        s.cohort_year,
        s.is_active,
        s.created_at,
        s.updated_at
    FROM Students s
    LEFT JOIN Users u ON s.user_id = u.user_id
    LEFT JOIN Faculties f ON s.faculty_id = f.faculty_id
    LEFT JOIN Majors m ON s.major_id = m.major_id
    LEFT JOIN AcademicYears ay ON s.academic_year_id = ay.academic_year_id
    WHERE s.deleted_at IS NULL
      AND (@Search IS NULL OR u.full_name LIKE '%' + @Search + '%' OR s.student_code LIKE '%' + @Search + '%')
      AND (@FacultyId IS NULL OR s.faculty_id = @FacultyId)
      AND (@MajorId IS NULL OR s.major_id = @MajorId)
      AND (@AcademicYearId IS NULL OR s.academic_year_id = @AcademicYearId)
    ORDER BY s.created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
```

**Stored Procedure trả về 2 result sets:**
1. **Result Set 1:** Tổng số bản ghi (`TotalCount`)
2. **Result Set 2:** Danh sách sinh viên (đã phân trang)

---

## 📊 Tóm Tắt Luồng Dữ Liệu

| **Bước** | **Lớp / File** | **Nhiệm Vụ** | **Input** | **Output** |
|---------|---------------|-------------|----------|-----------|
| 1 | **Controller** <br/> `StudentsController.cs` | Nhận HTTP Request | Query Params | Gọi Service |
| 2 | **Service** <br/> `StudentService.cs` | Business Logic & Validation | Parameters | Gọi Repository |
| 3 | **Repository** <br/> `StudentRepository.cs` | Tạo SQL Parameters | Data Objects | Gọi DatabaseHelper |
| 4 | **DatabaseHelper** <br/> `DatabaseHelper.cs` | Thực thi Stored Procedure | SP Name + Params | DataSet |
| 5 | **Repository** <br/> `StudentRepository.cs` | Map DataRow → Model | DataSet | List\<Student\> |
| 6 | **Service** <br/> `StudentService.cs` | Trả về kết quả | Repository Response | Tuple\<List, int\> |
| 7 | **Controller** <br/> `StudentsController.cs` | Trả về HTTP Response | Service Response | JSON |

---

## 🛠️ Các Phương Thức DatabaseHelper

| **Phương Thức** | **Mục Đích** | **Khi Nào Dùng** |
|----------------|-------------|-----------------|
| `ExecuteQueryAsync()` | Truy vấn SELECT (1 result set) | Lấy 1 bảng dữ liệu |
| `ExecuteQueryMultipleAsync()` | Truy vấn SELECT (nhiều result sets) | Lấy nhiều bảng (TotalCount + Data) |
| `ExecuteNonQueryAsync()` | INSERT / UPDATE / DELETE | Thêm, sửa, xóa dữ liệu |
| `ExecuteScalarAsync()` | Trả về 1 giá trị đơn | Đếm số bản ghi, lấy ID |
| `ExecuteReaderAsync<T>()` | Map dữ liệu sang custom object | Mapping tùy chỉnh |

---

## 🔧 Dependency Injection (DI)

Hệ thống sử dụng **Scrutor** để tự động đăng ký tất cả Services và Repositories:

📁 File: `Program.cs`

```csharp
// ✅ Auto-register tất cả Services + Repositories
builder.Services.Scan(scan => scan
    .FromAssemblies(
        Assembly.Load("EducationManagement.BLL"),
        Assembly.Load("EducationManagement.DAL")
    )
    .AddClasses(classes => classes.InNamespaces(
        "EducationManagement.BLL.Services",
        "EducationManagement.DAL.Repositories"
    ))
    .AsSelfWithInterfaces()
    .WithScopedLifetime()
);
```

**Cách hoạt động:**
- ✅ Tự động tìm tất cả class trong namespace `Services` và `Repositories`
- ✅ Đăng ký với `Scoped Lifetime` (mỗi request có 1 instance riêng)
- ✅ Controller nhận Service qua Constructor Injection
- ✅ Service nhận Repository qua Constructor Injection

---

## 📝 Ví Dụ Các Loại Request

### **1️⃣ Lấy Danh Sách (GET - Query)**

**Request:**
```http
GET /api-edu/students?page=1&pageSize=10&search=Nguyen
```

**Luồng:**
```
Controller.GetAllStudents()
  → Service.GetAllStudentsAsync()
    → Repository.GetAllAsync()
      → DatabaseHelper.ExecuteQueryMultipleAsync()
        → sp_GetAllStudents
          → Return DataSet (TotalCount + Data)
```

---

### **2️⃣ Lấy Theo ID (GET - Route Param)**

**Request:**
```http
GET /api-edu/students/ST001
```

**Luồng:**
```
Controller.GetStudentById("ST001")
  → Service.GetStudentByIdAsync("ST001")
    → Repository.GetByIdAsync("ST001")
      → DatabaseHelper.ExecuteQueryAsync()
        → sp_GetStudentById (@StudentId = 'ST001')
          → Return DataTable (1 row)
```

---

### **3️⃣ Thêm Mới (POST - Body)**

**Request:**
```http
POST /api-edu/students/addstudent
Content-Type: application/json

{
  "userId": "U001",
  "studentCode": "ST001",
  "fullName": "Nguyen Van A",
  "email": "a@example.com",
  ...
}
```

**Luồng:**
```
Controller.AddStudent(StudentCreateDto)
  → Service.AddStudentAsync(StudentCreateDto)
    → Repository.AddAsync(StudentCreateDto)
      → DatabaseHelper.ExecuteNonQueryAsync()
        → sp_AddStudentFull (@UserId, @StudentCode, ...)
          → INSERT vào Database
```

---

### **4️⃣ Cập Nhật (PUT - Body)**

**Request:**
```http
PUT /api-edu/students/update
Content-Type: application/json

{
  "studentId": "ST001",
  "fullName": "Nguyen Van B",
  ...
}
```

**Luồng:**
```
Controller.UpdateStudentFull(UpdateStudentFullDto)
  → Service.UpdateStudentAsync(UpdateStudentFullDto)
    → Repository.UpdateAsync(UpdateStudentFullDto)
      → DatabaseHelper.ExecuteNonQueryAsync()
        → sp_UpdateStudentFull (@StudentId, @FullName, ...)
          → UPDATE Database
```

---

### **5️⃣ Xóa (DELETE - Body)**

**Request:**
```http
DELETE /api-edu/students/delete
Content-Type: application/json

{
  "studentId": "ST001",
  "deletedBy": "admin"
}
```

**Luồng:**
```
Controller.DeleteStudentFull(DeleteStudentFullDto)
  → Service.DeleteStudentAsync(studentId, deletedBy)
    → Repository.DeleteAsync(studentId, deletedBy)
      → DatabaseHelper.ExecuteNonQueryAsync()
        → sp_DeleteStudentFull (@StudentId, @DeletedBy)
          → UPDATE deleted_at = GETDATE() (Soft Delete)
```

---

## 🔐 Authentication & Authorization

Hệ thống sử dụng **JWT Bearer Token** để xác thực:

```csharp
[Authorize] // ✅ Yêu cầu token hợp lệ
[ApiController]
[Route("api-edu/students")]
public class StudentsController : ControllerBase
{
    // ...
}
```

**Middleware Pipeline:**
```
Request → CORS → UseAuthentication() → UseAuthorization() → Controller
```

**Cấu hình JWT:**
```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSection["Issuer"],
            ValidAudience = jwtSection["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
        };
    });
```

---

## 📂 Cấu Trúc Thư Mục Backend

```
EducationManagement/
│
├── EducationManagement.API.Admin/          # 🔵 API Layer
│   ├── Controllers/                        # HTTP Endpoints
│   │   ├── StudentsController.cs
│   │   ├── LecturerController.cs
│   │   ├── AttendanceController.cs
│   │   └── ...
│   ├── Program.cs                          # Startup + DI Configuration
│   └── appsettings.json                    # Connection String + JWT Config
│
├── EducationManagement.BLL/                # 🟢 Business Logic Layer
│   └── Services/
│       ├── StudentService.cs
│       ├── LecturerService.cs
│       ├── AttendanceService.cs
│       ├── AuthService.cs
│       ├── JwtService.cs
│       └── ...
│
├── EducationManagement.DAL/                # 🟠 Data Access Layer
│   ├── DatabaseHelper.cs                   # SQL Execution Utility
│   └── Repositories/
│       ├── StudentRepository.cs
│       ├── LecturerRepository.cs
│       ├── AttendanceRepository.cs
│       └── ...
│
├── EducationManagement.Common/             # 📦 Shared Models & DTOs
│   ├── Models/                             # Database Entities
│   │   ├── Student.cs
│   │   ├── Lecturer.cs
│   │   └── ...
│   └── DTOs/                               # Data Transfer Objects
│       ├── StudentCreateDto.cs
│       ├── UpdateStudentFullDto.cs
│       └── ...
│
└── EducationManagement.API.Gateway/        # 🌐 API Gateway (Ocelot)
    ├── ocelot.json                         # Routing Configuration
    └── Program.cs
```

---

## 🚀 Quy Trình Deploy

### **1. Build Project**
```bash
cd EducationManagement/EducationManagement.API.Admin
dotnet build
```

### **2. Run Migration (Stored Procedures)**
```sql
-- Chạy tuần tự các file:
01_CreateTables.sql
02_StoredProcedures.sql
03_Triggers.sql
04_SeedData.sql
```

### **3. Update Connection String**
📁 File: `appsettings.json`
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=EducationDB;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

### **4. Run Application**
```bash
dotnet run
```

**Output:**
```
✅ EducationManagement.API.Admin started at http://localhost:5227
```

---

## ⚙️ Cấu Hình CORS

Backend cho phép Frontend từ nhiều port:

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy
            .WithOrigins(
                "http://localhost:5500",   // Live Server
                "http://127.0.0.1:5500",
                "http://localhost:8080",   // Python/Node Server
                "https://localhost:7033"   // Gateway
            )
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});
```

---

## 🎓 Lợi Ích Của Kiến Trúc 3 Lớp

| **Lợi Ích** | **Giải Thích** |
|------------|---------------|
| ✅ **Separation of Concerns** | Mỗi lớp có trách nhiệm riêng biệt |
| ✅ **Dễ Bảo Trì** | Thay đổi logic nghiệp vụ không ảnh hưởng Database |
| ✅ **Dễ Test** | Mock Service/Repository để unit test |
| ✅ **Tái Sử Dụng** | Service có thể dùng cho nhiều Controller |
| ✅ **Bảo Mật** | Controller không truy cập trực tiếp Database |
| ✅ **Scalability** | Dễ dàng thêm tính năng mới |

---

## 📞 Liên Hệ & Hỗ Trợ

- **Tài liệu đầy đủ:** Xem file `Đặc tả hệ thống Quản lý điểm danh sinh viên.docx`
- **Database Schema:** Xem file `01_CreateTables.sql`
- **Stored Procedures:** Xem file `02_StoredProcedures.sql`

---

**🎉 Chúc bạn phát triển thành công!**

