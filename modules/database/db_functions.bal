import ballerina/sql;
import ballerina/io;


// Retrieves all users from the database.
// Returns an array of Users or an error if the query fails.
public function getUsers() returns Users[]|error {
    Users[] users = [];
    stream<Users, error?> resultStream = dbClient->query(`SELECT * FROM users`);
    io:println("Query executed, checking results..."); 
    check from Users user in resultStream
        do {
            io:println("Found user: ", user); 
            users.push(user);
        };
    return users;
}

// Inserts a new user into the database.
// Accepts a UserCreate payload and returns the execution result or an error.
public isolated function insertUser(UserCreate payload) returns sql:ExecutionResult|sql:Error {
    return dbClient->execute(insertUserQuery(payload));
}

// Deletes a user from the database by user ID.
// Returns the execution result or an error.
public isolated function deleteUser(int userId) returns sql:ExecutionResult|sql:Error {
    return dbClient->execute(deleteUserQuery(userId));
}

// Updates an existing user in the database by user ID.
// Accepts a UserUpdate payload and returns the execution result or an error.
public isolated function updateUser(int userId, UserUpdate payload) returns sql:ExecutionResult|sql:Error {
    return dbClient->execute(updateUserQuery(userId, payload));
}

// Searches for users by name (case-insensitive).
// Returns an array of Users matching the name or an error.
public isolated function searchUserByName(string name) returns Users[]|sql:Error {
    stream<Users, sql:Error?> resultStream = dbClient->query(searchUserByNameQuery(name));

    if resultStream is stream<Users> {
        return from Users user in resultStream
            select user;
    }

    return error("Error searching users by name");
}

// Retrieves a single user by user ID.
// Returns the User record if found, or an error if not found.
public isolated function getUserById(int userId) returns Users|error {
    stream<Users, sql:Error?> resultStream = dbClient->query(getUserByIdQuery(userId));

    check from Users user in resultStream
        do {
            return user;
        };

    return error("User not found for ID: " + userId.toString());
}

