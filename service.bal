// import ballerina/http;

// service / on new http:Listener(8080) {
//     resource function get users() returns string {
//         return "user list";
//     }
// }

import ballerina_CRUD_task.database;

import ballerina/http;
import ballerina/sql;

service / on new http:Listener(8080) {

    // Resource function to get all books.
    resource function get users() returns database:Users[]|http:InternalServerError {
        // Call the getBooks function to fetch data from the database.
        database:Users[]|error response = database:getUsers();

        // If there's an error while fetching, return an internal server error.
        if response is error {
            return <http:InternalServerError>{
                body: "Error while retrieving users"
            };
        }

        // Return the response containing the list of books.
        return response;
    }

        resource function post users(database:UserCreate user) returns http:Created|http:InternalServerError {
        sql:ExecutionResult|sql:Error response = database:insertUser(user);
        if response is error {
            return <http:InternalServerError>{
                body: "Error while inserting user"
            };
        }
        return http:CREATED;
    }

    resource function delete users/[int id]() returns http:NoContent|http:InternalServerError {
     sql:ExecutionResult|sql:Error response = database:deleteUser(id);

     if response is error {
         return <http:InternalServerError>{
             body: "Error while deleting user"
         };
     }

     return http:NO_CONTENT;
}

resource function patch users/[int id](database:UserUpdate user) returns http:NoContent|http:InternalServerError {
    sql:ExecutionResult|sql:Error response = database:updateUser(id, user);

    if response is error {
        return <http:InternalServerError>{
            body: "Error while updating user"
        };
    }

    return http:NO_CONTENT;
}

}

