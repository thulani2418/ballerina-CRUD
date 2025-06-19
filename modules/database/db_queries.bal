import ballerina/sql;

isolated function getUsersQuery() returns sql:ParameterizedQuery => `
    SELECT 
        id,
        name,
        email,
        age,
    FROM 
        Users;
`;

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

isolated function deleteUserQuery(int userId) returns sql:ParameterizedQuery => `
    DELETE FROM Users WHERE id = ${userId}
`;

isolated function updateUserQuery(int userId, UserUpdate payload) returns sql:ParameterizedQuery => `
    UPDATE Users
        SET 
            name = COALESCE(${payload.name}, name),
            email = COALESCE(${payload.email}, email),
            age = COALESCE(${payload.age}, age)
        WHERE id = ${userId}
`;


isolated function searchUserByNameQuery(string name) returns sql:ParameterizedQuery => `
    SELECT 
        id,
        name,
        email,
        address
    FROM 
        user
    WHERE
        name LIKE ${"%"+name+"%"}
`;

isolated function getUserByIdQuery(int id) returns sql:ParameterizedQuery => `
    SELECT 
        id,
        name,
        email,
        address
    FROM 
        user
    WHERE
        id = ${id}
`;
