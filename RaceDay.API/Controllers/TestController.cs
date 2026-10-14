using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RaceDay.API.Data;

namespace RaceDay.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class TestController : ControllerBase
    {
        private readonly RaceDayDbContext _context;

        public TestController(RaceDayDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> TestDatabaseConnection()
        {
            try
            {
                bool connected = await _context.Database.CanConnectAsync();

                if (connected)
                {
                    return Ok(new
                    {
                        message = "Successfully connected to the RaceDay database."
                    });
                }

                return StatusCode(500, new
                {
                    message = "Could not connect to the RaceDay database."
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    message = "Database connection failed.",
                    error = ex.Message
                });
            }
        }
    }
}