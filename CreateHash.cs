using BCrypt.Net;

class Program
{
    static void Main()
    {
        string password = "Admin@123";
        string hash = BCrypt.HashPassword(password, workFactor: 10);
        
        Console.WriteLine($"Password: {password}");
        Console.WriteLine($"Hash: {hash}");
        Console.WriteLine($"\nVerify test: {BCrypt.Verify(password, hash)}");
        
        Console.WriteLine($"\n--- SQL Update Statement ---");
        Console.WriteLine($"UPDATE users SET password_hash = '{hash}' WHERE username = 'admin';");
    }
}

