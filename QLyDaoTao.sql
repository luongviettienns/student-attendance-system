
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'QuanLyDaoTaoSinhVien')
BEGIN
    CREATE DATABASE QuanLyDaoTaoSinhVien;
END
GO

USE QuanLyDaoTaoSinhVien;
GO

/* 
   1) BANG VaiTro (Roles)
 */
IF OBJECT_ID('dbo.VaiTro', 'U') IS NOT NULL DROP TABLE dbo.VaiTro;
GO
CREATE TABLE dbo.VaiTro (
    ma_vai_tro     INT IDENTITY(1,1) PRIMARY KEY,
    ten_vai_tro    NVARCHAR(50) NOT NULL UNIQUE,  -- 'Admin','GiangVien','CoVan','SinhVien'
    mo_ta          NVARCHAR(200),
    ngay_tao       DATETIME DEFAULT GETDATE()
);
GO

/* 
   2) BANG NguoiDung (Users)
 */
IF OBJECT_ID('dbo.NguoiDung', 'U') IS NOT NULL DROP TABLE dbo.NguoiDung;
GO
CREATE TABLE dbo.NguoiDung (
    ma_nguoi_dung      INT IDENTITY(1,1) PRIMARY KEY,
    ten_dang_nhap      NVARCHAR(50)  NOT NULL UNIQUE,
    email              NVARCHAR(100) NOT NULL UNIQUE,
    mat_khau_bam       NVARCHAR(255) NOT NULL,      -- hashed password
    ho_ten             NVARCHAR(100) NOT NULL,
    ma_vai_tro         INT NOT NULL,
    dang_hoat_dong     BIT DEFAULT 1,
    lan_dang_nhap_cuoi DATETIME,
    da_xoa             BIT DEFAULT 0,               -- soft delete
    ngay_tao           DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat      DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ND_VaiTro FOREIGN KEY (ma_vai_tro) REFERENCES dbo.VaiTro(ma_vai_tro) ON DELETE NO ACTION
);
GO

/* 
   3) BANG HocKy (Semesters)
 */
IF OBJECT_ID('dbo.HocKy', 'U') IS NOT NULL DROP TABLE dbo.HocKy;
GO
CREATE TABLE dbo.HocKy (
    ma_hoc_ky     INT IDENTITY(1,1) PRIMARY KEY,
    ten_hoc_ky    NVARCHAR(50) NOT NULL,  -- '2025-1'
    nam_hoc       NVARCHAR(9),           -- '2025-2026'
    ngay_bat_dau  DATE NOT NULL,
    ngay_ket_thuc DATE NOT NULL,
    dang_hoat_dong BIT DEFAULT 1,
    da_xoa         BIT DEFAULT 0,
    ngay_tao       DATETIME DEFAULT GETDATE()
);
GO

/*
   4) BANG MonHoc (Subjects)
 */
IF OBJECT_ID('dbo.MonHoc', 'U') IS NOT NULL DROP TABLE dbo.MonHoc;
GO
CREATE TABLE dbo.MonHoc (
    ma_mon_hoc        INT IDENTITY(1,1) PRIMARY KEY,
    ma_so_mon_hoc     NVARCHAR(20) NOT NULL UNIQUE,   -- 'CS101'
    ten_mon_hoc       NVARCHAR(200) NOT NULL,
    so_tin_chi        INT NOT NULL,
    mo_ta             NVARCHAR(MAX),
    ma_giang_vien     INT NULL,                       -- giang vien chinh (tham chieu NguoiDung)
    da_xoa            BIT DEFAULT 0,
    ngay_tao          DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat     DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_MH_GV FOREIGN KEY (ma_giang_vien) REFERENCES dbo.NguoiDung(ma_nguoi_dung) ON DELETE SET NULL
);
GO

/*
   5) BANG LopHoc (Classes)
 */
IF OBJECT_ID('dbo.LopHoc', 'U') IS NOT NULL DROP TABLE dbo.LopHoc;
GO
CREATE TABLE dbo.LopHoc (
    ma_lop_hoc          INT IDENTITY(1,1) PRIMARY KEY,
    ten_lop_hoc         NVARCHAR(50) NOT NULL,   -- 'CS101-A1'
    ma_mon_hoc          INT NOT NULL,
    ma_hoc_ky           INT NOT NULL,
    si_so_toi_da        INT DEFAULT 50,
    ngay_bat_dau        DATE,
    ngay_ket_thuc       DATE,
    da_xoa              BIT DEFAULT 0,
    ngay_tao            DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_LH_MH FOREIGN KEY (ma_mon_hoc) REFERENCES dbo.MonHoc(ma_mon_hoc) ON DELETE CASCADE,
    CONSTRAINT FK_LH_HK FOREIGN KEY (ma_hoc_ky)  REFERENCES dbo.HocKy(ma_hoc_ky)  ON DELETE NO ACTION
);
GO

/* 
   6) BANG DangKyHocPhan (Enrollments)
*/
IF OBJECT_ID('dbo.DangKyHocPhan', 'U') IS NOT NULL DROP TABLE dbo.DangKyHocPhan;
GO
CREATE TABLE dbo.DangKyHocPhan (
    ma_dang_ky     INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien   INT NOT NULL,    -- tham chieu NguoiDung (vai tro SV)
    ma_lop_hoc     INT NOT NULL,
    ngay_dang_ky   DATE DEFAULT GETDATE(),
    trang_thai     NVARCHAR(20) CHECK (trang_thai IN (N'hoat_dong', N'rut', N'hoan_thanh')) DEFAULT N'hoat_dong',
    da_xoa         BIT DEFAULT 0,
    ngay_tao       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_DKHP_SV FOREIGN KEY (ma_sinh_vien) REFERENCES dbo.NguoiDung(ma_nguoi_dung) ON DELETE CASCADE,
    CONSTRAINT FK_DKHP_LH FOREIGN KEY (ma_lop_hoc)   REFERENCES dbo.LopHoc(ma_lop_hoc)      ON DELETE CASCADE,
    CONSTRAINT UQ_DKHP UNIQUE (ma_sinh_vien, ma_lop_hoc)
);
GO

/* 
   7) BANG LichHocThi (Schedules)
 */
IF OBJECT_ID('dbo.LichHocThi', 'U') IS NOT NULL DROP TABLE dbo.LichHocThi;
GO
CREATE TABLE dbo.LichHocThi (
    ma_lich        INT IDENTITY(1,1) PRIMARY KEY,
    ma_lop_hoc     INT NOT NULL,
    loai_lich      NVARCHAR(20) CHECK (loai_lich IN (N'hoc', N'thi')),
    thu            NVARCHAR(10) CHECK (thu IN (N'Thu2',N'Thu3',N'Thu4',N'Thu5',N'Thu6',N'Thu7',N'ChuNhat')),
    gio_bat_dau    TIME NOT NULL,
    gio_ket_thuc   TIME NOT NULL,
    phong          NVARCHAR(20),
    la_online      BIT DEFAULT 0,
    ngay_dien_ra   DATE,              -- cho lich thi
    ghi_chu        NVARCHAR(MAX),
    da_xoa         BIT DEFAULT 0,
    ngay_tao       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_LHT_LH FOREIGN KEY (ma_lop_hoc) REFERENCES dbo.LopHoc(ma_lop_hoc) ON DELETE CASCADE
);
GO

/* 
   8) BANG DiemDanh (Attendances)
 */
IF OBJECT_ID('dbo.DiemDanh', 'U') IS NOT NULL DROP TABLE dbo.DiemDanh;
GO
CREATE TABLE dbo.DiemDanh (
    ma_diem_danh     INT IDENTITY(1,1) PRIMARY KEY,
    ma_dang_ky       INT NOT NULL,
    ma_lich          INT NOT NULL,
    ngay_diem_danh   DATE NOT NULL,
    trang_thai       NVARCHAR(20) CHECK (trang_thai IN (N'co_mat', N'vang_mat', N'tre', N'co_phep')) DEFAULT N'vang_mat',
    thoi_gian_check_in DATETIME,
    ghi_chu          NVARCHAR(MAX),
    da_xoa           BIT DEFAULT 0,
    ngay_tao         DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_DD_DKHP FOREIGN KEY (ma_dang_ky) REFERENCES dbo.DangKyHocPhan(ma_dang_ky) ON DELETE CASCADE,
    CONSTRAINT FK_DD_LHT  FOREIGN KEY (ma_lich)     REFERENCES dbo.LichHocThi(ma_lich)      ON DELETE NO ACTION,
    CONSTRAINT UQ_DD UNIQUE (ma_dang_ky, ma_lich, ngay_diem_danh)
);
GO

/* 
   9) BANG ThanhPhanDiem (GradeComponents)
 */
IF OBJECT_ID('dbo.ThanhPhanDiem', 'U') IS NOT NULL DROP TABLE dbo.ThanhPhanDiem;
GO
CREATE TABLE dbo.ThanhPhanDiem (
    ma_thanh_phan   INT IDENTITY(1,1) PRIMARY KEY,
    ma_mon_hoc      INT NOT NULL,
    ten_thanh_phan  NVARCHAR(50) NOT NULL,     -- 'giua_ky', 'cuoi_ky', 'diem_danh', ...
    he_so           DECIMAL(3,2) NOT NULL,     -- 0.00 - 9.99
    mo_ta           NVARCHAR(MAX),
    cong_thuc_tinh  NVARCHAR(500),
    da_xoa          BIT DEFAULT 0,
    ngay_tao        DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_TPD_MH FOREIGN KEY (ma_mon_hoc) REFERENCES dbo.MonHoc(ma_mon_hoc) ON DELETE CASCADE,
    CONSTRAINT UQ_TPD UNIQUE (ma_mon_hoc, ten_thanh_phan)
);
GO

/* 
   10) BANG Diem (Grades)
 */

CREATE TABLE dbo.Diem (
    ma_diem           INT IDENTITY(1,1) PRIMARY KEY,
    ma_dang_ky        INT NOT NULL,
    ma_thanh_phan     INT NOT NULL,
    diem_so           DECIMAL(5,2) CHECK (diem_so >= 0 AND diem_so <= 10),
    xep_loai          NVARCHAR(5),
    diem_tong         DECIMAL(6,3) NULL,
    ngay_nhap_diem    DATETIME DEFAULT GETDATE(),
    ma_nguoi_nhap     INT NULL,
    da_xoa            BIT DEFAULT 0,
    ngay_tao          DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Diem_DKHP FOREIGN KEY (ma_dang_ky)
        REFERENCES dbo.DangKyHocPhan(ma_dang_ky) ON DELETE CASCADE,   -- GIỮ
    CONSTRAINT FK_Diem_TPD FOREIGN KEY (ma_thanh_phan)
        REFERENCES dbo.ThanhPhanDiem(ma_thanh_phan),                  -- NO ACTION (mặc định)
    CONSTRAINT FK_Diem_ND FOREIGN KEY (ma_nguoi_nhap)
        REFERENCES dbo.NguoiDung(ma_nguoi_dung),                      -- NO ACTION (mặc định) -> Hết lỗi 1785
    CONSTRAINT UQ_Diem UNIQUE (ma_dang_ky, ma_thanh_phan)
);
GO


-- 3) VIEW để luôn xem 'diem_tong' = diem_so * he_so (không cần lưu)
IF OBJECT_ID('dbo.vw_Diem_TinhTong', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Diem_TinhTong;
GO
CREATE VIEW dbo.vw_Diem_TinhTong
AS
SELECT 
    d.ma_diem,
    d.ma_dang_ky,
    d.ma_thanh_phan,
    d.diem_so,
    d.xep_loai,
    -- ưu tiên tính động theo he_so thực tế
    CAST(d.diem_so * tpd.he_so AS DECIMAL(6,3)) AS diem_tong_tinh,
    d.ngay_nhap_diem,
    d.ma_nguoi_nhap,
    d.da_xoa,
    d.ngay_tao
FROM dbo.Diem d
JOIN dbo.ThanhPhanDiem tpd
  ON tpd.ma_thanh_phan = d.ma_thanh_phan;
GO
GO


/*
   11) BANG PhucKhao (Appeals)
 */
CREATE TABLE dbo.PhucKhao (
    ma_phuc_khao   INT IDENTITY(1,1) PRIMARY KEY,
    ma_diem        INT NOT NULL,
    ly_do          NVARCHAR(MAX) NOT NULL,
    trang_thai     NVARCHAR(20)
        CHECK (trang_thai IN (N'gui', N'duyet', N'tu_choi', N'hoan_thanh'))
        DEFAULT N'gui',
    ngay_gui       DATE DEFAULT GETDATE(),
    ma_nguoi_duyet INT NULL,                 -- cố vấn/giảng viên
    ghi_chu_duyet  NVARCHAR(MAX),
    da_xoa         BIT DEFAULT 0,
    ngay_tao       DATETIME DEFAULT GETDATE(),
    -- GIỮ cascade theo điểm (khi xoá điểm thì tự xoá phúc khảo của điểm đó)
    CONSTRAINT FK_PK_Diem FOREIGN KEY (ma_diem)
        REFERENCES dbo.Diem(ma_diem) ON DELETE CASCADE,
    -- BỎ SET NULL để tránh multiple cascade paths
    CONSTRAINT FK_PK_ND FOREIGN KEY (ma_nguoi_duyet)
        REFERENCES dbo.NguoiDung(ma_nguoi_dung)  -- NO ACTION (mặc định)
);
GO


/*
   12) BANG ThongBao (Notifications)
 */
IF OBJECT_ID('dbo.ThongBao', 'U') IS NOT NULL DROP TABLE dbo.ThongBao;
GO
CREATE TABLE dbo.ThongBao (
    ma_thong_bao INT IDENTITY(1,1) PRIMARY KEY,
    ma_nguoi_dung INT NOT NULL,
    tieu_de      NVARCHAR(200) NOT NULL,
    noi_dung     NVARCHAR(MAX) NOT NULL,
    loai         NVARCHAR(50),        -- 'email','in_app','canh_bao_chuyen_can',...
    da_doc       BIT DEFAULT 0,
    da_xoa       BIT DEFAULT 0,
    ngay_tao     DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_TB_ND FOREIGN KEY (ma_nguoi_dung) REFERENCES dbo.NguoiDung(ma_nguoi_dung) ON DELETE CASCADE
);
GO

/* 
   13) BANG NhatKyHeThong (AuditLog)
 */
IF OBJECT_ID('dbo.NhatKyHeThong', 'U') IS NOT NULL DROP TABLE dbo.NhatKyHeThong;
GO
CREATE TABLE dbo.NhatKyHeThong (
    ma_nhat_ky     INT IDENTITY(1,1) PRIMARY KEY,
    ma_nguoi_dung  INT NOT NULL,
    ten_bang       NVARCHAR(50) NOT NULL,     -- vi du: 'Diem'
    hanh_dong      NVARCHAR(20) NOT NULL,     -- 'INSERT','UPDATE','DELETE'
    ma_ban_ghi_cu  NVARCHAR(50),
    ma_ban_ghi_moi NVARCHAR(50),
    chi_tiet_thay_doi NVARCHAR(MAX),          -- mo ta JSON/text
    ip_address     NVARCHAR(45),
    ngay_tao       DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_NK_ND FOREIGN KEY (ma_nguoi_dung) REFERENCES dbo.NguoiDung(ma_nguoi_dung) ON DELETE NO ACTION
);
GO

/*
   14) DU LIEU MAU
 */
INSERT INTO dbo.VaiTro (ten_vai_tro, mo_ta) VALUES
(N'Admin',     N'Quản trị viên hệ thống'),
(N'GiangVien', N'Giảng viên'),
(N'CoVan',     N'Cố vấn học tập'),
(N'SinhVien',  N'Sinh viên');
GO

INSERT INTO dbo.NguoiDung (ten_dang_nhap, email, mat_khau_bam, ho_ten, ma_vai_tro)
VALUES
(N'admin',      N'admin@utehy.edu.vn', N'hashed_password_here', N'Admin User', 1),
(N'sinhvien1',  N'sv1@utehy.edu.vn',   N'hashed_password_here', N'Phàn Văn Khánh', 4);
GO

INSERT INTO dbo.HocKy (ten_hoc_ky, nam_hoc, ngay_bat_dau, ngay_ket_thuc)
VALUES (N'2025-1', N'2025-2026', '2025-09-01', '2026-01-31');
GO

/* 
   15) CHI MUC (INDEX)
*/
CREATE INDEX IX_ND_VaiTro           ON dbo.NguoiDung(ma_vai_tro);
CREATE INDEX IX_DKHP_TrangThai      ON dbo.DangKyHocPhan(trang_thai);
CREATE INDEX IX_DiemDanh_TrangThai  ON dbo.DiemDanh(trang_thai);
CREATE INDEX IX_Diem_DangKy         ON dbo.Diem(ma_dang_ky);
CREATE INDEX IX_NhatKy_ND_HanhDong  ON dbo.NhatKyHeThong(ma_nguoi_dung, hanh_dong);
GO

/* 
   16) TRIGGER AUTO EDIT SUA DIEM (bat buoc)
 */
IF OBJECT_ID('dbo.TR_AuditDiemUpdate', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_AuditDiemUpdate;
GO
CREATE TRIGGER dbo.TR_AuditDiemUpdate
ON dbo.Diem
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.NhatKyHeThong (ma_nguoi_dung, ten_bang, hanh_dong, ma_ban_ghi_cu, ma_ban_ghi_moi, chi_tiet_thay_doi)
    SELECT 
        ISNULL(i.ma_nguoi_nhap, d.ma_nguoi_nhap),
        N'Diem',
        N'UPDATE',
        CAST(d.ma_diem AS NVARCHAR(50)),
        CAST(i.ma_diem AS NVARCHAR(50)),
        N'Thay doi diem tu ' + CAST(d.diem_so AS NVARCHAR(10)) + N' sang ' + CAST(i.diem_so AS NVARCHAR(10))
    FROM inserted i
    JOIN deleted  d ON i.ma_diem = d.ma_diem;
END;
GO

/* 
   17) TRIGGER SOFT-DELETE NguoiDung (thay cho DELETE)
 */
IF OBJECT_ID('dbo.TR_SoftDelete_NguoiDung', 'TR') IS NOT NULL DROP TRIGGER dbo.TR_SoftDelete_NguoiDung;
GO
CREATE TRIGGER dbo.TR_SoftDelete_NguoiDung
ON dbo.NguoiDung
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE nd
    SET nd.da_xoa = 1,
        nd.ngay_cap_nhat = GETDATE()
    FROM dbo.NguoiDung nd
    INNER JOIN deleted d ON nd.ma_nguoi_dung = d.ma_nguoi_dung;
END;
GO
