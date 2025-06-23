import ballerina/sql;

// Returns a query to select all users from the Users table.
isolated function getUsersQuery() returns sql:ParameterizedQuery => `
    SELECT 
        id,
        name,
        email,
        age
    FROM 
        Users;
`;

// Returns a query to insert a new user into the Users table.
// Accepts a UserCreate payload for the new user's data.
isolated function insertUserQuery(UserCreate payload) returns sql:ParameterizedQuery => `
    INSERT INTO Users
        (
            name,
            email,
            age
        )
    VALUES
        (
            ${payload.name},
            ${payload.email},
            ${payload.age}
        )
`;

// Returns a query to delete a user by their ID from the Users table.
isolated function deleteUserQuery(int userId) returns sql:ParameterizedQuery => `
    DELETE FROM Users WHERE id = ${userId}
`;

// Returns a query to update a user's details by their ID.
// Accepts a UserUpdate payload for the fields to update.
isolated function updateUserQuery(int userId, UserUpdate payload) returns sql:ParameterizedQuery => `
    UPDATE Users
        SET 
            name = COALESCE(${payload.name}, name),
            email = COALESCE(${payload.email}, email),
            age = COALESCE(${payload.age}, age)
        WHERE id = ${userId}
`;

// Returns a query to search for users by name (case-insensitive, partial match).
isolated function searchUserByNameQuery(string name) returns sql:ParameterizedQuery => `
    SELECT 
        id,
        name,
        email,
        age
    FROM 
        Users
    WHERE
        name LIKE ${"%" + name + "%"}
`;

// Returns a query to select a single user by their ID.
isolated function getUserByIdQuery(int userId) returns sql:ParameterizedQuery => `
    SELECT 
        id,
        name,
        email,
        age
    FROM 
        Users
    WHERE
        id = ${userId}
`;

