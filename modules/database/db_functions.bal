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

public function getUserById(int id) returns Users|error {
    stream<Users, error?> resultStream = dbClient->query(`SELECT * FROM users WHERE id = ${id}`);
    record {|Users value;|}? result = check resultStream.next();
    
    if result is () {
        return error("User not found");
    }
    
    return result.value;
}
