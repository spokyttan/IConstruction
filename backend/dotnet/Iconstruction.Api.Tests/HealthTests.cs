using System.Net;
using System.Threading.Tasks;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace Iconstruction.Api.Tests;

public class HealthTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public HealthTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            // No DB calls in tests we run: hit only endpoints that don't require DB
            // Override environment if needed
            // builder.UseEnvironment("Development");
        });
    }

    [Fact]
    public async Task Root_redirects_to_swagger()
    {
        var client = _factory.CreateClient(new WebApplicationFactoryClientOptions { AllowAutoRedirect = false });
        var res = await client.GetAsync("/");
        res.StatusCode.Should().Be(HttpStatusCode.Redirect);
        res.Headers.Location!.ToString().Should().Contain("/swagger");
    }

    [Fact]
    public async Task Health_ok_returns_true()
    {
        var client = _factory.CreateClient();
        var res = await client.GetAsync("/health");
        res.EnsureSuccessStatusCode();
        var json = await res.Content.ReadAsStringAsync();
        json.Should().Contain("\"ok\":true");
    }
}
