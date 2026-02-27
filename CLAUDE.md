# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SimplCommerce is a cross-platform, modular e-commerce system built on .NET 8. It uses a "modulith" architecture - modules are logically separated but deploy as a single application (not microservices). Each module is an ASP.NET Core Razor Class Library that can be developed, tested, and deployed independently.

## Development Commands

### Building and Running
```bash
# Build the entire solution
dotnet build

# Run the application (from WebHost directory)
cd src/SimplCommerce.WebHost
dotnet run

# Entity Framework migrations (Package Manager Console in VS)
Update-Database

# Entity Framework migrations (CLI)
cd src/SimplCommerce.WebHost
dotnet ef migrations add MigrationName
dotnet ef database update
```

### Running Tests
```bash
# Run all tests (Linux/Mac)
./run-tests.sh

# Run all tests (Windows PowerShell)
./run-tests.ps1

# Run single test project
cd test/SimplCommerce.Module.Core.Tests
dotnet test
```

### PostgreSQL Setup (Linux/Mac)
```bash
# Switch from SQL Server to PostgreSQL
sudo ./simpl-build.sh

# After running, import static data manually:
psql -U your_user -d your_database -f src/Database/StaticData_Postgres.sql
```

## High-Level Architecture

### Module System

The core architectural pattern is the modular plugin system:

1. **Module Discovery**: Modules are declared in `src/SimplCommerce.WebHost/modules.json`. Each module has an `id`, `version`, and `isBundledWithHost` flag.

2. **Module Loading** (`ServiceCollectionExtensions.AddModules`):
   - Bundled modules (in the same solution) are loaded via `Assembly.Load`
   - External modules are loaded from their `bin/` folder using `AssemblyLoadContext.Default.LoadFromAssemblyPath`

3. **Module Initialization**: Each module implements `IModuleInitializer` with two methods:
   - `ConfigureServices(IServiceCollection)`: Register DI services
   - `Configure(IApplicationBuilder, IWebHostEnvironment)`: Configure middleware

4. **Module Assembly Registration**: All module assemblies are registered as MVC ApplicationParts, making their Controllers, Views, and Components discoverable.

### Module Structure

Each module follows this convention:
- `Areas/{ModuleName}/Controllers/` - Controllers (use `{ModuleName}ApiController` for API controllers)
- `Areas/{ModuleName}/Views/` - Razor views
- `Areas/{ModuleName}/Components/` - ViewComponents
- `Models/` - Domain entities
- `Data/` - EF Core custom model builders (`ICustomModelBuilder`), repositories
- `Services/` - Business logic services
- `Events/` - MediatR event handlers (notifications)
- `module.json` - Module manifest

### Data Layer Architecture

- **DbContext**: `SimplCommerce.Module.Core.Data.SimplDbContext` - single context for all modules
- **Entity Discovery**: Entities are auto-discovered from all module assemblies (types inheriting from `EntityBase`)
- **Table Naming Convention**: `{ModuleName}_{EntityName}` (e.g., `Catalog_Product`)
- **Custom Mappings**: Each module can implement `ICustomModelBuilder` for fluent API configurations
- **Repository Pattern**: `IRepository<T>` and `IRepositoryWithTypedId<TId>` - registered as transient services

### Key Infrastructure Components

- `GlobalConfiguration` - Singleton holding loaded module info and paths
- `IModuleInitializer` - Contract for module bootstrap
- `ICustomModelBuilder` - Contract for EF Core fluent API configuration
- `SlugRouteValueTransformer` - Dynamic route handling for slugs (categories, products, etc.)

### Dependency Injection Patterns

Services are registered in module initializers:
```csharp
services.AddTransient<IService, ServiceImplementation>();
services.AddTransient<INotificationHandler<Event>, EventHandler>();
```

### Event System

Uses MediatR for domain events:
- Events defined in `Events/` folders (e.g., `ReviewSummaryChanged`)
- Handlers implement `INotificationHandler<TEvent>`
- Handlers registered in module `ConfigureServices` method

### Frontend Architecture

- **Storefront**: ASP.NET Core MVC with Razor views
- **Admin UI**: Angular 1.6.3 (single-page application served from `/Admin`)
- **Routing**: Dynamic slug-based routing via `SlugRouteValueTransformer`
- **Theming**: `ThemeableViewLocationExpander` for theme support

### Testing Structure

Test projects mirror the module structure:
- `test/SimplCommerce.Module.{ModuleName}.Tests/` - Module-specific tests
- Tests use `dotnet test --logger:trx` for TRX output

## Working with Modules

### Creating a New Module

1. Create a new Razor Class Library project in `src/Modules/SimplCommerce.Module.{Name}/`
2. Add `ProjectReference` to `SimplCommerce.Infrastructure`
3. Add `ProjectReference` in `SimplCommerce.WebHost.csproj`
4. Create `module.json` manifest
5. Add entry to `src/SimplCommerce.WebHost/modules.json`
6. Create `ModuleInitializer.cs` implementing `IModuleInitializer`
7. Create `Areas/{ModuleName}/` folder structure
8. Implement `ICustomModelBuilder` if needed for EF Core configuration

### Adding Database Changes

1. For simple entity changes: Just add the entity class inheriting from `EntityBase`
2. For complex configurations: Implement `ICustomModelBuilder` in the module's `Data/` folder
3. Create migration: `cd src/SimplCommerce.WebHost && dotnet ef migrations add Description`
4. Update database: `dotnet ef database update`

## Default Credentials

- Admin URL: `/Admin`
- Email: `admin@simplcommerce.com`
- Password: `1qazZAQ!`
