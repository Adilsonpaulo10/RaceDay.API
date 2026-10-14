[HttpPost("login")]
public IActionResult Login(LoginRequest request)
{
    // Find the user by email
    var user = _context.Users
        .FirstOrDefault(u => u.Email == request.Email);

    if (user == null)
    {
        return Unauthorized(new
        {
            message = "Invalid email or password."
        });
    }

    // Hash the password entered during login
    using SHA256 sha256 = SHA256.Create();

    byte[] passwordBytes =
        Encoding.UTF8.GetBytes(request.Password);

    byte[] hashBytes =
        sha256.ComputeHash(passwordBytes);

    string passwordHash =
        Convert.ToHexString(hashBytes);

    // Compare the password hash
    if (user.PasswordHash != passwordHash)
    {
        return Unauthorized(new
        {
            message = "Invalid email or password."
        });
    }

    return Ok(new
    {
        message = "Login successful.",
        userID = user.UserID,
        firstName = user.FirstName,
        lastName = user.LastName,
        email = user.Email,
        role = user.Role
    });
}