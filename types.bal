// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.
import sample_app.database;

# Collection type.
public type SampleCollection record {
    # Number of total records
    int count;
    # List of collections
    database:SampleCollection[] collections;
};

# Represents the response structure for retrieving user information.
public type UserInfoResponse record {|
    # Id of the employee
    string employeeId;
    # Email of the employee
    string workEmail;
    # First name of the employee
    string firstName;
    # Last name of the employee
    string lastName;
    # Job role
    string jobRole;
    # Thumbnail of the employee
    string? employeeThumbnail;
    # User Privileges
    int[] privileges;
|};
