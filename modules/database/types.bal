import ballerina/sql;

type DatabaseConfig record {|
    # User of the database
    string user;
    # Password of the database
    string password;
    # Name of the database
    string database;
    # Host of the database
    string host;
    # Port
    int port;
|};

// User record type
public type Users record {|
    // User ID
    @sql:Column {name: "id"}
    readonly int id;

    // User name
    @sql:Column {name: "name"}
    string name;

    // User email
    @sql:Column {name: "email"}
    string email;

    // User age
    @sql:Column {name: "age"}
    string age;

    // // User account creation time
    // @sql:Column {name: "created_at"}
    // readonly string createdAt;

    // // User account last updated time
    // @sql:Column {name: "updated_at"}
    // readonly string updatedAt;
|};

public type UserCreate record {|
    string name;
    string email;
    string age;
|};

public type UserUpdate record {|
    string? name = ();
    string? email = ();
    string? age = ();
|};




