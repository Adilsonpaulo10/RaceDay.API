
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace RaceDay.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Organiser")]
    public class OrganiserTestController : ControllerBase
    {
        [HttpGet]
        public IActionResult TestOrganiserAccess()
        {
            return Ok(new
            {
                message = "Access granted. You are an Organiser."
            });
        }
    }
}
