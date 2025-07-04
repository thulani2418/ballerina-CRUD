// import ballerina/http;

// service / on new http:Listener(8080) {
//     resource function get users() returns string {
//         return "user list";
//     }
// }

import ballerina_CRUD_task.database;

import ballerina/http;
import ballerina/sql;

service / on new http:Listener(8085) {

    // GET /users
    resource function get users() returns database:Users[]|http:InternalServerError {
        // Call the getUsers function to fetch data from the database.
        database:Users[]|error response = database:getUsers();

        // If there's an error while fetching, return an internal server error.
        if response is error {
            return <http:InternalServerError>{
                body: "Error while retrieving users"
            };
        }

        // Return the response containing the list of users.
        return response;
    }

    // POST /users
    // Returns: 201 Created on success, or 500 Internal Server Error.
        resource function post users(database:UserCreate user) returns http:Created|http:InternalServerError {
        sql:ExecutionResult|sql:Error response = database:insertUser(user);
        if response is error {
            return <http:InternalServerError>{
                body: "Error while inserting user"
            };
        }
        return http:CREATED;
    }

    // DELETE /users/{id}
    // Returns: 204 No Content on success, or 500 Internal Server Error.
    resource function delete users/[int id]() returns http:NoContent|http:InternalServerError {
     sql:ExecutionResult|sql:Error response = database:deleteUser(id);

     if response is error {
         return <http:InternalServerError>{
             body: "Error while deleting user"
         };
     }

     return http:NO_CONTENT;
}


// PATCH /users/{id}
// Returns: 204 No Content on success, or 500 Internal Server Error.
resource function patch users/[int id](database:UserUpdate user) returns http:NoContent|http:InternalServerError {
    sql:ExecutionResult|sql:Error response = database:updateUser(id, user);

    if response is error {
        return <http:InternalServerError>{
            body: "Error while updating user"
        };
    }

    return http:NO_CONTENT;
}

// GET /users/search?name={name} 
// Returns: Array of users or 500 Internal Server Error.
resource function get users/search(@http:Query string name) returns database:Users[]|http:InternalServerError {
    database:Users[]|error response = database:searchUserByName(name);

    if response is error {
        return <http:InternalServerError>{
            body: "Error while searching user by name"
        };
    }

    return response;
}


    // GET /users/{id}  
    // Returns: User record, 404 Not Found, or 500 Internal Server Error.
resource function get users/[int id]() returns database:Users|http:InternalServerError|http:NotFound {
    database:Users|error response = database:getUserById(id);

    if response is error {
        if response.message() == "User not found for ID: " + id.toString() {
            return <http:NotFound>{ body: response.message() };
        }
        return <http:InternalServerError>{
            body: "Error while retrieving user"
        };
    }

    return response;
}


}

