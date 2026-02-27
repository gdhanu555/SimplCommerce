# Running SimplCommerce Without MSSQL

The project defaults to SQL Server. Two alternatives are supported out of the box.

---

## Option 1: PostgreSQL (recommended for production-like setup)

### Prerequisites

```bash
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo -u postgres psql -c "CREATE USER simpluser WITH PASSWORD 'yourpassword';"
sudo -u postgres psql -c "CREATE DATABASE simplcommerce OWNER simpluser;"
```

### Switch the codebase

Run the included script from the repo root — it swaps the EF Core package, updates `UseSqlServer` calls, and recreates migrations:

```bash
sudo ./simpl-build.sh
```

### Update the connection string

Edit `src/SimplCommerce.WebHost/appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "User ID=simpluser;Password=yourpassword;Host=localhost;Port=5432;Database=simplcommerce;Pooling=true;"
}
```

### Seed static data

```bash
psql -U simpluser -d simplcommerce -f src/Database/StaticData_Postgres.sql
```

### Run

```bash
cd src/SimplCommerce.WebHost && dotnet run
```

---

## Option 2: SQLite (easiest for local development — no DB server needed)

### Step 1 — Swap the NuGet package

In `src/SimplCommerce.WebHost/SimplCommerce.WebHost.csproj`, replace:

```diff
- <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
+ <PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" Version="8.0.0" />
```

### Step 2 — Replace `UseSqlServer` with `UseSqlite`

In **`src/SimplCommerce.WebHost/Program.cs`**:

```diff
- options.UseSqlServer(connectionString);
+ options.UseSqlite(connectionString);
```

In **`src/SimplCommerce.WebHost/Extensions/ServiceCollectionExtensions.cs`**:

```diff
- .UseSqlServer(...)
+ .UseSqlite(...)
```

### Step 3 — Update the connection string

In `src/SimplCommerce.WebHost/appsettings.json`:

```diff
- "DefaultConnection": "Server=.;Database=SimplCommerce;Trusted_Connection=True;TrustServerCertificate=true;MultipleActiveResultSets=true"
+ "DefaultConnection": "Data Source=simplcommerce.db"
```

### Step 4 — Recreate migrations and run

```bash
rm src/SimplCommerce.WebHost/Migrations/*
dotnet restore && dotnet build

cd src/SimplCommerce.WebHost
dotnet ef migrations add initialSchema
dotnet ef database update
dotnet run
```

The SQLite database file `simplcommerce.db` will be created automatically in the `SimplCommerce.WebHost` directory.

---

## Comparison

| | PostgreSQL | SQLite |
|---|---|---|
| Setup effort | Medium (needs DB server) | None |
| Best for | Staging / production-like | Quick local dev |
| Script provided | `simpl-build.sh` | Manual steps above |
| Static data import | Required (SQL script) | Not needed (seeded via migrations) |
