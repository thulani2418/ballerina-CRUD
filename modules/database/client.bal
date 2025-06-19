import ballerinax/mysql;
import ballerinax/mysql.driver as _;

# Database Client Configuration.
configurable DatabaseConfig dbConfig = ?;

final mysql:Client dbClient = check new (
    user = dbConfig.user,
    password = dbConfig.password,
    database = dbConfig.database,
    host = dbConfig.host,
    port = dbConfig.port
);