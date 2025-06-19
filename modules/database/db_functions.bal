import ballerina/sql;
import ballerina/io;

// Define the function to fetch books from the database.
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

public isolated function insertUser(UserCreate payload) returns sql:ExecutionResult|sql:Error {
    return dbClient->execute(insertUserQuery(payload));
}

public isolated function deleteUser(int userId) returns sql:ExecutionResult|sql:Error {
    return dbClient->execute(deleteUserQuery(userId));
}

public isolated function updateUser(int userId, UserUpdate payload) returns sql:ExecutionResult|sql:Error {
    return dbClient->execute(updateUserQuery(userId, payload));
}


public isolated function searchUserByName(string name) returns Users[]|sql:Error {
    stream<Users, sql:Error?> resultStream = dbClient->query(searchUserByNameQuery(name));

    if resultStream is stream<Users> {
        return from Users user in resultStream
            select user;
    }

    return error("Error searching users by name");
}


public isolated function getUserById(int userId) returns Users|error {
    stream<Users, sql:Error?> resultStream = dbClient->query(getUserByIdQuery(userId));

    check from Users user in resultStream
        do {
            return user;
        };

    return error("User not found for ID: " + userId.toString());
}

