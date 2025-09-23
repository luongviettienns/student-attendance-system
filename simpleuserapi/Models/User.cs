using System.ComponentModel.DataAnnotations;

namespace SimpleUserAPI.Models
{
    public class User
    {
        public int user_id { get; set; }
        
        [Required]
        public string user_name { get; set; } = string.Empty;
        
        [Required]
        public string password { get; set; } = string.Empty;
        
        [Required]
        public string full_name { get; set; } = string.Empty;
        
        [EmailAddress]
        public string email { get; set; } = string.Empty;
        
        public string phone { get; set; } = string.Empty;
        
        [Required]
        public string role { get; set; } = "User";
        
        public DateTime created_at { get; set; } = DateTime.UtcNow;
        
        public DateTime? updated_at { get; set; }
    }
}


