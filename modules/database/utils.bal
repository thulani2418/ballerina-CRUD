import ballerina/sql;

# Build SQL UPDATE query with dynamic columns.
#
# + mainQuery - Main query to start with
# + filters - Key-value update clauses
# + return - Combined sql:ParameterizedQuery
isolated function buildSqlUpdateQuery(sql:ParameterizedQuery mainQuery, sql:ParameterizedQuery[] filters)
    returns sql:ParameterizedQuery {

    boolean isFirstUpdate = true;
    sql:ParameterizedQuery updatedQuery = ``;

    foreach sql:ParameterizedQuery filter in filters {
        if isFirstUpdate {
            updatedQuery = sql:queryConcat(mainQuery, filter);
            isFirstUpdate = false;
        } else {
            updatedQuery = sql:queryConcat(updatedQuery, `,`  , filter);
        }
    }

    return updatedQuery;
}

# Build SQL SELECT query with dynamic WHERE filters.
#
# + mainQuery - Base SELECT query
# + filters - List of filter conditions
# + return - Final sql:ParameterizedQuery
isolated function buildSqlSelectQuery(sql:ParameterizedQuery mainQuery, sql:ParameterizedQuery[] filters)
    returns sql:ParameterizedQuery {

    boolean isFirstFilter = true;
    sql:ParameterizedQuery updatedQuery = mainQuery;

    foreach sql:ParameterizedQuery filter in filters {
        if isFirstFilter {
            updatedQuery = sql:queryConcat(mainQuery,  `WHERE` , filter);
            isFirstFilter = false;
        } else {
            updatedQuery = sql:queryConcat(updatedQuery,  `AND` , filter);
        }
    }

    return updatedQuery;
}