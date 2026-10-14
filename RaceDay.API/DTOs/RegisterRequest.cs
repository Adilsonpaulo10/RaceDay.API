using Microsoft.AspNetCore.Mvc;
using RaceDay.API.Data;
using RaceDay.API.DTOs;
using RaceDay.API.Models;
using System.Security.Cryptography;
using System.Text;

namespace RaceDay.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AccountController : ControllerBase
    {
        private readonly RaceDayDbContext _context;

        public AccountController(RaceDayDbContext context)
        {
            _context = context;
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

            return Ok(new
            {
                message = "User registered successfully.",
                userID = user.UserID,
                role = user.Role
            });
        }
    }
}