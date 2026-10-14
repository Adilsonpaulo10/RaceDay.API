using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using RaceDay.API.Data;
using RaceDay.API.DTOs;
using RaceDay.API.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace RaceDay.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AccountController : ControllerBase
    {
        private readonly RaceDayDbContext _context;
        private readonly IConfiguration _configuration;

        public AccountController(
    RaceDayDbContext context,
    IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public IActionResult Register(RegisterRequest request)
        {
            // Check if the email already exists
            if (_context.Users.Any(u => u.Email == request.Email))
            {
                return BadRequest(new
                {
                    message = "Email is already registered."
                });
            }

            // Check that the role is valid
            if (request.Role != "Participant" &&
                request.Role != "Organiser")
            {
                return BadRequest(new
                {
                    message = "Role must be Participant or Organiser."
                });
            }

            // Hash the password
            using SHA256 sha256 = SHA256.Create();

            byte[] passwordBytes =
                Encoding.UTF8.GetBytes(request.Password);

            byte[] hashBytes =
                sha256.ComputeHash(passwordBytes);

            string passwordHash =
                Convert.ToHexString(hashBytes);

            // Create the user
            var user = new User
            {
                FirstName = request.FirstName,
                LastName = request.LastName,
                Email = request.Email,
                PasswordHash = passwordHash,
                Role = request.Role
            };

            // Add user to database
            _context.Users.Add(user);
            _context.SaveChanges();

            // Create claims for the logged-in user
            var claims = new[]
            {
    new Claim(ClaimTypes.NameIdentifier, user.UserID.ToString()),
    new Claim(ClaimTypes.Name, user.Email),
    new Claim(ClaimTypes.Role, user.Role)
};

            // Get JWT settings
            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!)
            );

            var credentials = new SigningCredentials(
                key,
                SecurityAlgorithms.HmacSha256
            );

            // Create the token
            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddHours(2),
                signingCredentials: credentials
            );

            // Convert token to a string
            var tokenString = new JwtSecurityTokenHandler()
                .WriteToken(token);

            return Ok(new
            {
                message = "Login successful.",
                token = tokenString,
                userID = user.UserID,
                firstName = user.FirstName,
                lastName = user.LastName,
                email = user.Email,
                role = user.Role
            });
        }
    }
}