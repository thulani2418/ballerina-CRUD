// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import sample_app.authorization;
import sample_app.database;
import sample_app.entity;

import ballerina/cache;
import ballerina/http;
import ballerina/log;

final cache:Cache cache = new ({
    capacity: 2000,
    defaultMaxAge: 1800.0,
    cleanupInterval: 900.0
});

@display {
    label: "Sample Application",
    id: "domain/sample-application"
}

service class ErrorInterceptor {
    *http:ResponseErrorInterceptor;

    remote function interceptResponseError(error err, http:RequestContext ctx) returns http:BadRequest|error {

        // Handle data-binding errors.
        if err is http:PayloadBindingError {
            string customError = string `Payload binding failed!`;
            log:printError(customError, err);
            return {
                body: {
                    message: customError
                }
            };
        }
        return err;
    }
}

service http:InterceptableService / on new http:Listener(9090) {

    # Request interceptor.
    #
    # + return - authorization:JwtInterceptor, ErrorInterceptor
    public function createInterceptors() returns http:Interceptor[] =>
        [new authorization:JwtInterceptor(), new ErrorInterceptor()];

    # Fetch user information of the logged in users.
    #
    # + ctx - Request object
    # + return - User info object|Error
    resource function get user\-info(http:RequestContext ctx) returns UserInfoResponse|http:InternalServerError {

        // User information header.
        authorization:CustomJwtPayload|error userInfo = ctx.getWithType(authorization:HEADER_USER_INFO);
        if userInfo is error {
            return <http:InternalServerError>{
                body: {
                    message: "User information header not found!"
                }
            };
        }

        // Check cache for logged in user.
        if cache.hasKey(userInfo.email) {
            UserInfoResponse|error cachedUserInfo = cache.get(userInfo.email).ensureType();
            if cachedUserInfo is UserInfoResponse {
                return cachedUserInfo;
            }
        }

        // Fetch the user information from the entity service.
        entity:Employee|error loggedInUser = entity:fetchEmployeesBasicInfo(userInfo.email);
        if loggedInUser is error {
            string customError = string `Error occurred while retrieving user data: ${userInfo.email}!`;
            log:printError(customError, loggedInUser);
            return <http:InternalServerError>{
                body: {
                    message: customError
                }
            };
        }

        // Fetch the user's privileges based on the roles.
        int[] privileges = [];
        if authorization:checkPermissions([authorization:authorizedRoles.employeeRole], userInfo.groups) {
            privileges.push(authorization:EMPLOYEE_ROLE_PRIVILEGE);
        }
        if authorization:checkPermissions([authorization:authorizedRoles.headPeopleOperationsRole], userInfo.groups) {
            privileges.push(authorization:HEAD_PEOPLE_OPERATIONS_PRIVILEGE);
        }

        UserInfoResponse userInfoResponse = {...loggedInUser, privileges};

        error? cacheError = cache.put(userInfo.email, userInfoResponse);
        if cacheError is error {
            log:printError("An error occurred while writing user info to the cache", cacheError);
        }
        return userInfoResponse;
    }

    # Fetch all samples from the database.
    #
    # + name - Name to filter
    # + 'limit - Limit of the data
    # + offset - Offset of the data
    # + return - All samples|Error
    isolated resource function get collections(http:RequestContext ctx, string? name, int? 'limit, int? offset)
        returns SampleCollection|http:Forbidden|http:BadRequest|http:InternalServerError {

        // "requestedBy" is the email of the user access this resource.
        // interceptor set this value after validating the jwt.
        authorization:CustomJwtPayload|error userInfo = ctx.getWithType(authorization:HEADER_USER_INFO);
        if userInfo is error {
            return <http:BadRequest>{
                body: {
                    message: "User information header not found!"
                }
            };
        }

        // [Start] Custom Resource level authorization.
        if !authorization:checkPermissions([authorization:authorizedRoles.employeeRole],
                userInfo.groups) {

            return <http:Forbidden>{
                body: {
                    message: "Insufficient privileges!"
                }
            };
        }
        // [End] Custom Resource level authorization.

        database:SampleCollection[]|error collections = database:fetchSampleCollections(name, 'limit, offset);
        if collections is error {
            string customError = string `Error occurred while retrieving the sample collections!`;
            log:printError(customError, collections);
            return <http:InternalServerError>{
                body: {
                    message: customError
                }
            };
        }

        return {
            count: collections.length(),
            collections: collections
        };
    }

    # Insert collections.
    #
    # + collection - New collection
    # + return - Created|Forbidden|BadRequest|Error
    resource function post collections(http:RequestContext ctx, database:AddSampleCollection collection)
        returns http:Created|http:Forbidden|http:BadRequest|http:InternalServerError {

        // "requestedBy" is the email of the user access this resource.
        // interceptor set this value after validating the jwt.
        authorization:CustomJwtPayload|error userInfo = ctx.getWithType(authorization:HEADER_USER_INFO);
        if userInfo is error {
            return <http:BadRequest>{
                body: {
                    message: "User information header not found!"
                }
            };
        }

        // [Start] Custom Resource level authorization.
        if !authorization:checkPermissions([authorization:authorizedRoles.headPeopleOperationsRole],
                userInfo.groups) {

            return <http:Forbidden>{
                body: {
                    message: "Insufficient privileges!"
                }
            };
        }
        // [End] Custom Resource level authorization.

        // Insert collection.
        int|error collectionId = database:addSampleCollection(collection, userInfo.email);
        if collectionId is error {
            string customError = string `Error occurred while adding sample collection!`;
            log:printError(customError, collectionId);
            return <http:InternalServerError>{
                body: {
                    message: customError
                }
            };
        }

        database:SampleCollection|error? addedSampleCollection = database:fetchSampleCollection(collectionId);

        // Handle : database read error.
        if addedSampleCollection is error {
            string customError = string `Error occurred while retrieving the added sample collection!`;
            log:printError(customError, addedSampleCollection);
            return <http:InternalServerError>{
                body: {
                    message: customError
                }
            };
        }

        // Handle : no record error.
        if addedSampleCollection is null {
            string customError = string `Added sample collection is no longer available to access!`;
            log:printError(customError);
            return <http:InternalServerError>{
                body: {
                    message: customError
                }
            };
        }

        return <http:Created>{
            body: addedSampleCollection
        };
    }
}
