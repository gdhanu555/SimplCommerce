# SimplCommerce (Lite)

SimplCommerce is a simple, cross-platform modulith ecommerce system built on ASP.NET Core.

## Quickstart (SQLite)

Prereqs:
- .NET SDK 8.x
- EF Core tools (`dotnet tool install --global dotnet-ef`)
- `sqlite3` (for seeding in `simpl-build.sh`)

From the repo root:

```bash
./simpl-build.sh
cd src/SimplCommerce.WebHost

dotnet run
```

Open `http://localhost:5000`.

## Admin Login

- URL: `http://localhost:5000/Admin`
- Email: `admin@simplcommerce.com`
- Password: `1qazZAQ!`

## Alternate Databases

- SQL Server (Visual Studio): see `README.md`
- PostgreSQL / SQLite details: `docs/alternative-databases.md`

## Tests

```bash
./run-tests.sh
```

## Key Links

- Docs: https://docs.simplcommerce.com/
- Roadmap: https://github.com/simplcommerce/SimplCommerce/wiki/Roadmap
- Demo: http://demo.simplcommerce.com (admin: http://demo.simplcommerce.com/admin)

## License

Apache 2.0. See `License.txt`.

