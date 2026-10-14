using Microsoft.EntityFrameworkCore;
using RaceDay.API.Models;

namespace RaceDay.API.Data
{
    public class RaceDayDbContext : DbContext
    {
        public RaceDayDbContext(DbContextOptions<RaceDayDbContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; }

        public DbSet<Event> Events { get; set; }

        public DbSet<Category> Categories { get; set; }

        public DbSet<Enrolment> Enrolments { get; set; }

        public DbSet<Result> Results { get; set; }

        public DbSet<Route> Routes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>()
                .ToTable("User");

            modelBuilder.Entity<Event>()
                .ToTable("Event");

            modelBuilder.Entity<Category>()
                .ToTable("Category");

            modelBuilder.Entity<Enrolment>()
                .ToTable("Enrolment");

            modelBuilder.Entity<Result>()
                .ToTable("Result");

            modelBuilder.Entity<Route>()
                .ToTable("Route");
        }
    }
} 