using System.Data;
using System.Data.SqlClient;

namespace BanMayTinh_Admin.Code;

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

