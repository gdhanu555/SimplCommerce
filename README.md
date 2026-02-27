# A simple, cross platform, modulith ecommerce system built on .NET Core

## High level architecture
 
![SimpleCommerce - Modulith architecture](https://raw.githubusercontent.com/simplcommerce/SimplCommerce/master/modular-architecture.png)


<!-- ## Online demo (Azure Website)
- Store front: http://demo.simplcommerce.com
- Administration: http://demo.simplcommerce.com/admin Email: admin@simplcommerce.com Password: 1qazZAQ! -->

<!-- ## Docker -->

<!-- For testing purpose only `docker run -p 5000:80 simplcommerce/ci-build` -->

<!-- Continuous deployment: https://ci.simplcommerce.com -->

## Visual Studio 2022 and SQLite

#### Prerequisites

- SQLite
- Visual Studio 2022 and .NET 8

#### Steps to run

<!-- - Update the connection string: Open appsettings.json in src/SimplCommerce.WebHost. 
  The default is configured for a local SQL Server
    ```json
    {
      "DefaultConnection": "Server=.;Database=SimplCommerce;Trusted_Connection=True;TrustServerCertificate=true"
    }
    ```
  If you are using Visual Studio LocalDB, change it to
    ```json
    {
      "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=SimplCommerce;Trusted_Connection=True;TrustServerCertificate=true;MultipleActiveResultSets=true"
    }
    ```
- Ensure you have a database named `SimplCommerce` created in your SQL instance, or change the `Database` name in the connection string to match your environment. -->
- Build the whole solution.
- In Solution Explorer, make sure that SimplCommerce.WebHost is selected as the Startup Project
- Open the Package Manager Console Window and make sure that SimplCommerce.WebHost is selected as the Default project. Then type "Update-Database" then press "Enter". This action will create the database schema.
- In Visual Studio, press "Control + F5".
- The back-office can be accessed via /Admin using the following built-in account: admin@simplcommerce.com, 1qazZAQ!

## Mac/Linux with PostgreSQL

#### Prerequisite

- SQLite
- [.NET Core SDK 8.0](https://www.microsoft.com/net/download/all)
- Entity Framework Core Tools (`dotnet tool install --global dotnet-ef`)

#### Steps to run

- Update the connection string in appsettings.json in SimplCommerce.WebHost.
- Run the simpl-build.sh file by issuing the following command: "sudo ./simpl-build.sh". For ubuntu 18: "sudo bash simpl-build.sh"
- In the terminal, navigate to "src/SimplCommerce.WebHost" and type "dotnet run" and then hit "Enter".
- Open http://localhost:49206 in the browser. The back-office can be accessed via /Admin using the following built-in account: admin@simplcommerce.com, 1qazZAQ!

## Technologies and frameworks used:

- ASP.NET Core
- Entity Framework Core
- ASP.NET Identity Core
- Angular 1.6.3
- MediatR 7.0.0 for domain event
- SQLite

