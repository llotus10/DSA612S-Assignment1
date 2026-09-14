import ballerina/grpc;
import ballerina/io;

// =========================================================
// TEMPORARY IN-MEMORY STORAGE
// =========================================================

PropertyResponse[] properties = [];

int nextPropertyId = 1;

// =========================================================
// USER STORAGE
// =========================================================

type User record {
    string user_id;
    string name;
    string password;
    string role;
    string region;
};

User[] users = [];

// =========================================================
// DEVELOPMENT ADMIN
// =========================================================

function initializeAdmin() {

    foreach User user in users {

        if user.user_id == "Admin" {
            return;
        }
    }

    users.push({
        user_id: "Admin",
        name: "System Administrator",
        password: "Admin123",
        role: "admin",
        region: "Khomas"
    });
}

// =========================================================
// GRPC LISTENER
// =========================================================

listener grpc:Listener ep = new (9090);

// =========================================================
// SERVICE
// =========================================================

@grpc:Descriptor {
    value: RENTAL_ACCOMMODATION_DESC
}
service "RentalAccommodationService" on ep {

    // =====================================================
    // REGISTER USER
    // =====================================================

    remote function RegisterUser(RegisterUserRequest value)
    returns RegisterUserResponse|error {

        foreach User user in users {

            if user.user_id == value.user_id {

                return {
                    success: false,
                    message: "User already exists.",
                    user_id: value.user_id,
                    role: ""
                };
            }
        }

        if value.user_id == "" ||
            value.name == "" ||
            value.password == "" {

            return {
                success: false,
                message: "User ID, name and password are required.",
                user_id: value.user_id,
                role: ""
            };
        }

        User newUser = {
            user_id: value.user_id,
            name: value.name,
            password: value.password,
            role: "user",
            region: value.region
        };

        users.push(newUser);

        return {
            success: true,
            message: "User registered successfully.",
            user_id: newUser.user_id,
            role: newUser.role
        };
    }


    // =====================================================
    // LOGIN
    // =====================================================

    remote function LoginUser(LoginUserRequest value)
    returns LoginUserResponse|error {

        foreach User user in users {

            if user.user_id == value.user_id {

                if user.password != value.password {

                    return {
                        success: false,
                        message: "Invalid password.",
                        user_id: "",
                        name: "",
                        role: "",
                        region: ""
                    };
                }

                return {
                    success: true,
                    message: "Login successful.",
                    user_id: user.user_id,
                    name: user.name,
                    role: user.role,
                    region: user.region
                };
            }
        }

        return {
            success: false,
            message: "User not found.",
            user_id: "",
            name: "",
            role: "",
            region: ""
        };
    }


    // =====================================================
    // ADD PROPERTY
    // =====================================================

    remote function AddProperty(PropertyRequest value)
    returns PropertyResponse|error {

        string propertyId =
            "PROP-" + nextPropertyId.toString();

        nextPropertyId += 1;

        PropertyResponse property = {
            property_id: propertyId,
            property_name: value.property_name,
            location: value.location,
            property_type: value.property_type,
            price_per_night: value.price_per_night,
            status: value.status,
            host_id: value.host_id,
            region: value.region
        };

        properties.push(property);

        return property;
    }


    // =====================================================
    // UPDATE PROPERTY
    // =====================================================

    remote function UpdateProperty(UpdatePropertyRequest value)
    returns PropertyResponse|error {

        foreach int index in 0 ..< properties.length() {

            if properties[index].property_id == value.property_id {

                PropertyResponse updatedProperty = {
                    property_id: properties[index].property_id,
                    property_name: value.property_name,
                    location: value.location,
                    property_type: value.property_type,
                    price_per_night: value.price_per_night,
                    status: value.status,
                    host_id: properties[index].host_id,
                    region: properties[index].region
                };

                properties[index] = updatedProperty;

                return updatedProperty;
            }
        }

        return error(
            "Property not found: " + value.property_id
        );
    }


    // =====================================================
    // REMOVE PROPERTY
    // =====================================================

    remote function RemoveProperty(RemovePropertyRequest value)
    returns PropertyList|error {

        PropertyResponse[] remainingProperties = [];

        boolean found = false;

        foreach PropertyResponse property in properties {

            if property.property_id == value.property_id {

                found = true;

                if property.host_id != value.host_id {
                    return error("Host ID does not match.");
                }

                if property.region != value.region {
                    return error("Region does not match.");
                }

            } else {

                remainingProperties.push(property);
            }
        }

        if !found {
            return error(
                "Property not found: " + value.property_id
            );
        }

        properties = remainingProperties;

        return {
            properties: properties
        };
    }


    // =====================================================
    // SEARCH PROPERTY
    // =====================================================

    remote function SearchProperty(SearchPropertyRequest value)
    returns PropertySearchResponse|error {

        foreach PropertyResponse property in properties {

            if property.property_id == value.property_id {

                if property.status == "available" {

                    return {
                        available: true,
                        message: "Property is available.",
                        property: property
                    };
                }

                return {
                    available: false,
                    message: "Property exists but is not available.",
                    property: property
                };
            }
        }

        PropertyResponse emptyProperty = {
            property_id: "",
            property_name: "",
            location: "",
            property_type: "",
            price_per_night: 0.0,
            status: "",
            host_id: "",
            region: ""
        };

        return {
            available: false,
            message: "Property not found.",
            property: emptyProperty
        };
    }


    // =====================================================
    // BOOK PROPERTY
    // =====================================================

    remote function BookProperty(BookPropertyRequest value)
    returns BookPropertyResponse|error {

        foreach int index in 0 ..< properties.length() {

            if properties[index].property_id == value.property_id {

                if properties[index].status != "available" {

                    return {
                        success: false,
                        message: "Property is not available for booking.",
                        property_id: value.property_id,
                        check_in: value.check_in,
                        check_out: value.check_out
                    };
                }

                properties[index].status = "booked";

                return {
                    success: true,
                    message: "Property booked successfully.",
                    property_id: value.property_id,
                    check_in: value.check_in,
                    check_out: value.check_out
                };
            }
        }

        return {
            success: false,
            message: "Property not found.",
            property_id: value.property_id,
            check_in: value.check_in,
            check_out: value.check_out
        };
    }


    // =====================================================
    // CONFIRM BOOKING
    // =====================================================

    remote function ConfirmBooking(ConfirmBookingRequest value)
    returns ConfirmBookingResponse|error {

        foreach PropertyResponse property in properties {

            if property.property_id == value.property_id {

                if property.status != "booked" {

                    return {
                        success: false,
                        message: "Property has not been booked.",
                        property_id: value.property_id,
                        check_in: value.check_in,
                        check_out: value.check_out,
                        nights: 0,
                        total_price: 0.0
                    };
                }

                return {
                    success: true,
                    message: "Booking confirmed successfully.",
                    property_id: value.property_id,
                    check_in: value.check_in,
                    check_out: value.check_out,
                    nights: 1,
                    total_price: property.price_per_night
                };
            }
        }

        return {
            success: false,
            message: "Property not found.",
            property_id: value.property_id,
            check_in: value.check_in,
            check_out: value.check_out,
            nights: 0,
            total_price: 0.0
        };
    }


    // =====================================================
    // CREATE USERS
    // =====================================================

    remote function CreateUsers(
        stream<UserRequest, grpc:Error?> clientStream
    )
    returns UserCreationResponse|error {

        int usersCreated = 0;

        check clientStream.forEach(function(UserRequest user) {

            User newUser = {
                user_id: user.user_id,
                name: user.name,
                password: "",
                role: "user",
                region: user.region
            };

            users.push(newUser);

            usersCreated += 1;
        });

        return {
            success: true,
            users_created: usersCreated,
            message: "Users created successfully."
        };
    }


    // =====================================================
    // LIST AVAILABLE PROPERTIES
    // =====================================================

    remote function ListAvailableProperties(PropertyFilter value)
    returns stream<PropertyResponse, error?>|error {

        PropertyResponse[] availableProperties = [];

        foreach PropertyResponse property in properties {

            if property.status == "available" {

                boolean locationMatches =
                    value.location == "" ||
                    property.location == value.location;

                boolean minPriceMatches =
                    value.min_price == 0.0 ||
                    property.price_per_night >= value.min_price;

                boolean maxPriceMatches =
                    value.max_price == 0.0 ||
                    property.price_per_night <= value.max_price;

                if locationMatches &&
                    minPriceMatches &&
                    maxPriceMatches {

                    availableProperties.push(property);
                }
            }
        }

        return availableProperties.toStream();
    }
}


// =========================================================
// APPLICATION STARTUP
// =========================================================

public function main() {

    initializeAdmin();

    io:println("========================================");
    io:println("Rental Accommodation Backend");
    io:println("========================================");
    io:println("Admin account initialized.");
    io:println("Admin User ID: Admin");
    io:println("Admin Password: Admin123");
    io:println("gRPC server: localhost:9090");
    io:println("========================================");
}