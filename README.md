# Ballerina CRUD API

A simple CRUD (Create, Read, Update, Delete) REST API built with Ballerina for managing user data.

## Prerequisites

- Ballerina 2201.12.6 or higher
- MySQL database
- MySQL Connector/J driver

## Project Structure

```
ballerina-CRUD/
├── service.bal              # Main service file with HTTP endpoints
├── types.bal               # Common type definitions
├── Config.toml             # Database configuration
├── modules/
│   └── database/          # Database related modules
│       ├── client.bal     # Database client configuration
│       ├── types.bal      # Database types
│       ├── db_queries.bal # SQL queries
│       └── db_functions.bal # Database operations
```

## Setup

1. Create a MySQL database named `UserDB`

2. Configure your database connection in `Config.toml`:
```toml
[ballerina_CRUD_task.database.dbConfig]
user="your_username"
password="your_password"
host="localhost"
port=3306
database="UserDB"
```

## API Endpoints

- **GET /users** - Get all users
- **POST /users** - Create a new user
- **PATCH /users/{id}** - Update user by ID
- **DELETE /users/{id}** - Delete user by ID

## Running the Project

1. Install dependencies:
```bash
bal build
```

2. Run the service:
```bash
bal run
```

The service will start on port 8080.

## API Request Examples

### Create User
```bash
curl -X POST http://localhost:8080/users \
-H "Content-Type: application/json" \
-d '{"name": "John Doe", "email": "john@example.com", "age": "30"}'
```

### Get All Users
```bash
curl http://localhost:8080/users
```

### Update User
```bash
curl -X PATCH http://localhost:8080/users/1 \
-H "Content-Type: application/json" \
-d '{"name": "Updated Name"}'
```

### Delete User
```bash
curl -X DELETE http://localhost:8080/users/1
```
