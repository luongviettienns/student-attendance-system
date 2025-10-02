using System.Data;
using Microsoft.Data.SqlClient;

namespace BanMayTinh_NguoiDung.Code;

public interface IEducationDb
{
    IDbConnection CreateConnection();
}

public class EducationDb : IEducationDb
{
    private readonly IConfiguration _config;
    private readonly string _connStr;
    public EducationDb(IConfiguration config)
    {
        _config = config;
        _connStr = _config.GetConnectionString("EducationManagement") ?? string.Empty;
    }
    public IDbConnection CreateConnection()
    {
        return new SqlConnection(_connStr);
    }
}

