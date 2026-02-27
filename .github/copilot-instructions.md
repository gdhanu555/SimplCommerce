# SimplCommerce – Copilot Instructions

## Build & Run

```bash
# Build entire solution
dotnet build

# Run the application
cd src/SimplCommerce.WebHost && dotnet run

# Run all tests (Linux/Mac)
./run-tests.sh

# Run all tests (Windows)
./run-tests.ps1

# Run a single test project
dotnet test test/SimplCommerce.Module.Inventory.Tests

# EF migrations (run from WebHost)
cd src/SimplCommerce.WebHost
dotnet ef migrations add <MigrationName>
dotnet ef database update
```

Default admin credentials: `admin@simplcommerce.com` / `1qazZAQ!` at `/Admin`.

## Architecture: Modulith

The app is a single-deployment ASP.NET Core application composed of independent modules, each a Razor Class Library (RCL). Modules are **not** microservices — they share one process, one `DbContext`, and one database.

### Module discovery

Modules are declared in `src/SimplCommerce.WebHost/modules.json`. On startup, `ServiceCollectionExtensions.AddModules` reads this file and loads each module assembly. Bundled modules (all current ones, `isBundledWithHost: true`) are loaded via `Assembly.Load`. External/plugin modules are loaded from their `bin/` folder via `AssemblyLoadContext`.

### Module lifecycle

Each module implements `IModuleInitializer` (in `SimplCommerce.Infrastructure`):

```csharp
public void ConfigureServices(IServiceCollection services) { ... }
public void Configure(IApplicationBuilder app, IWebHostEnvironment env) { ... }
```

The host calls these for every loaded module during `Startup`.

### Adding a new module

1. Create a Razor Class Library in `src/Modules/SimplCommerce.Module.<Name>/`
2. Add a `ProjectReference` to `SimplCommerce.Infrastructure`
3. Add a `ProjectReference` in `SimplCommerce.WebHost.csproj`
4. Create `module.json` with `id`, `name`, `isBundledWithHost`, `version`
5. Register in `src/SimplCommerce.WebHost/modules.json`
6. Implement `ModuleInitializer : IModuleInitializer`
7. Create `Areas/<Name>/Controllers/`, `Areas/<Name>/Views/`, etc.

## Data Layer

### Single DbContext

`SimplCommerce.Module.Core.Data.SimplDbContext` is the only `DbContext`. It lives in the Core module and is registered by the host.

### Entity auto-discovery

Any class that inherits `EntityBase` (or `EntityBaseWithTypedId<TId>`) is automatically discovered and registered as an EF entity during `OnModelCreating` — no explicit `DbSet<T>` needed.

### Table naming convention

Tables are named `{Module}_{Entity}` automatically by `RegisterConvention`, which derives the prefix from `entity.ClrType.Namespace.Split('.')[2]` (the module name segment). Example: `SimplCommerce.Module.Catalog.Models.Product` → `Catalog_Product`.

Override this (e.g., for Identity tables) by calling `.ToTable("Core_User")` in an `ICustomModelBuilder`.

### Custom EF mappings

To configure relationships, composite keys, or seed data for your module, implement `ICustomModelBuilder`:

```csharp
public class MyCustomModelBuilder : ICustomModelBuilder
{
    public void Build(ModelBuilder modelBuilder) { ... }
}
```

The `SimplDbContext` auto-discovers all `ICustomModelBuilder` implementations across all module assemblies.

### Repository pattern

- `IRepository<T>` — for entities with `long` PK
- `IRepositoryWithTypedId<T, TId>` — for other key types

Both are registered as transient services. The default `DeleteBehavior` for all foreign keys is `Restrict` (set globally in `RegisterConvention`).

## Module Structure Conventions

```
Areas/<ModuleName>/
  Controllers/       # MVC + API controllers
  Views/             # Razor views
  Components/        # ViewComponents
Data/                # ICustomModelBuilder implementations
Events/              # MediatR INotificationHandler<T> handlers
Models/              # Domain entities (inherit EntityBase)
Services/            # Business logic
wwwroot/admin/       # Angular 1.x admin UI files
ModuleInitializer.cs
module.json
```

### API controllers

Use `[Area("ModuleName")]`, `[Route("api/...")]`, and `[Authorize(Roles = "admin")]` (or `"admin, vendor"` where appropriate):

```csharp
[Area("Catalog")]
[Authorize(Roles = "admin, vendor")]
[Route("api/products")]
public class ProductApiController : Controller { ... }
```

## Admin UI (Angular 1.x)

The admin SPA uses Angular 1.6.3 with UI-Router. Each module contributes an Angular module:

1. Create `wwwroot/admin/<modulename>.module.js` defining `angular.module('simplAdmin.<name>', [])` with `$stateProvider` routes.
2. Reference templates via `_content/<ModuleId>/admin/...` (RCL static asset path).
3. Register the Angular module name in `ModuleInitializer.ConfigureServices`:
   ```csharp
   GlobalConfiguration.RegisterAngularModule("simplAdmin.<name>");
   ```

## Events (MediatR)

Domain events use MediatR. Define a notification class, implement `INotificationHandler<TEvent>`, and register the handler in the module's `ConfigureServices`:

```csharp
services.AddTransient<INotificationHandler<MyEvent>, MyEventHandler>();
```

## Testing Patterns

Tests use **xUnit**, **Moq**, and **MockQueryable.Moq**. Use `MockQueryable.Moq` to mock `IRepository<T>.Query()` with async-compatible queryables:

```csharp
var mockData = new List<Product> { ... }.BuildMock();
_repoMock.Setup(x => x.Query()).Returns(mockData);
```

Test projects live in `test/SimplCommerce.Module.<Name>.Tests/`.
