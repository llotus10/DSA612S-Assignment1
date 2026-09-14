import ballerina/grpc;
import ballerina/io;


// =========================================================
// TEMPORARY IN-MEMORY DATABASE
// =========================================================

PropertyResponse[] properties = [];

User[] users = [];

BookingResponse[] bookings = [];

// Temporary booking cart. Entries remain here until ConfirmBooking succeeds.
BookingResponse[] bookingCart = [];

int nextPropertyId = 1;

int nextBookingId = 1;

int nextCartId = 1;


// =========================================================
// USER MODEL
// =========================================================

type User record {
    string user_id;
    string name;
    string password;
    string role;
    string region;
};


// =========================================================
// INITIALIZE ADMIN
// =========================================================

function initializeAdmin() {

    User admin = {
        user_id: "Admin",
        name: "System Administrator",
        password: "Admin123",
        role: "admin",
        region: "Khomas"
    };

    users.push(admin);

    io:println("========================================");
    io:println("Rental Accommodation Backend");
    io:println("========================================");
    io:println("Admin account initialized.");
    io:println("Admin User ID: Admin");
    io:println("Admin Password: Admin123");
    io:println("gRPC server: localhost:9090");
    io:println("========================================");
}


// =========================================================
// GRPC LISTENER
// =========================================================

listener grpc:Listener ep = new (9090);


// =========================================================
// GRPC SERVICE
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

        foreach int index in 0 ..< properties.length() {

            if properties[index].property_id == value.property_id {

                if properties[index].host_id != value.host_id {

                    return error("Host ID does not match.");
                }


                if properties[index].region != value.region {

                    return error("Region does not match.");
                }


                _ = properties.remove(index);


                return {
                    properties: properties
                };
            }
        }


        return error(
            "Property not found: " + value.property_id
        );
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


    // =====================================================
    // BOOK PROPERTY - ADD TO TEMPORARY BOOKING CART
    // =====================================================

    remote function BookProperty(BookPropertyRequest value)
        returns BookPropertyResponse|error {

        // A booking request must represent at least one night.
        int nights = check calculateNights(value.check_in, value.check_out);

        if nights <= 0 {
            return {
                success: false,
                message: "Check-out date must be after check-in date.",
                property_id: value.property_id,
                user_id: value.user_id,
                check_in: value.check_in,
                check_out: value.check_out
            };
        }

        lock {
            foreach PropertyResponse property in properties {
                if property.property_id == value.property_id {
                    if property.status != "available" {
                        return {
                            success: false,
                            message: "Property is not available.",
                            property_id: value.property_id,
                            user_id: value.user_id,
                            check_in: value.check_in,
                            check_out: value.check_out
                        };
                    }

                    // Do not create a permanent booking here. The request is
                    // placed in the guest's temporary booking cart instead.
                    foreach BookingResponse cartItem in bookingCart {
                        if cartItem.property_id == value.property_id &&
                            cartItem.user_id == value.user_id {
                            if datesOverlap(
                                cartItem.check_in, cartItem.check_out,
                                value.check_in, value.check_out
                            ) {
                                return {
                                    success: false,
                                    message: "The guest already has an overlapping request for this property.",
                                    property_id: value.property_id,
                                    user_id: value.user_id,
                                    check_in: value.check_in,
                                    check_out: value.check_out
                                };
                            }
                        }
                    }

                    // Confirmed bookings are also checked at cart time to give
                    // immediate feedback. ConfirmBooking repeats this check.
                    foreach BookingResponse booking in bookings {
                        if booking.property_id == value.property_id &&
                            booking.status == "confirmed" &&
                            datesOverlap(
                                booking.check_in, booking.check_out,
                                value.check_in, value.check_out
                            ) {
                            return {
                                success: false,
                                message: "Property is already booked for the requested dates.",
                                property_id: value.property_id,
                                user_id: value.user_id,
                                check_in: value.check_in,
                                check_out: value.check_out
                            };
                        }
                    }

                    string userName = "";
                    foreach User user in users {
                        if user.user_id == value.user_id {
                            userName = user.name;
                        }
                    }

                    BookingResponse cartItem = {
                        booking_id: "CART-" + nextCartId.toString(),
                        property_id: value.property_id,
                        property_name: property.property_name,
                        user_id: value.user_id,
                        user_name: userName,
                        check_in: value.check_in,
                        check_out: value.check_out,
                        status: "pending",
                        total_price: property.price_per_night * <float>nights
                    };

                    bookingCart.push(cartItem);
                    nextCartId += 1;

                    return {
                        success: true,
                        message: "Booking request added to the temporary booking cart.",
                        property_id: value.property_id,
                        user_id: value.user_id,
                        check_in: value.check_in,
                        check_out: value.check_out
                    };
                }
            }
        }

        return {
            success: false,
            message: "Property not found.",
            property_id: value.property_id,
            user_id: value.user_id,
            check_in: value.check_in,
            check_out: value.check_out
        };
    }


    // =====================================================
    // CONFIRM BOOKING
    // =====================================================

    remote function ConfirmBooking(ConfirmBookingRequest value)
        returns ConfirmBookingResponse|error {

        int nights = check calculateNights(value.check_in, value.check_out);

        if nights <= 0 {
            return {
                success: false,
                message: "Check-out date must be after check-in date.",
                property_id: value.property_id,
                user_id: value.user_id,
                check_in: value.check_in,
                check_out: value.check_out,
                nights: 0,
                total_price: 0.0
            };
        }

        lock {
            int cartIndex = -1;
            BookingResponse? cartItem = ();

            foreach int index in 0 ..< bookingCart.length() {
                if bookingCart[index].property_id == value.property_id &&
                    bookingCart[index].user_id == value.user_id &&
                    bookingCart[index].check_in == value.check_in &&
                    bookingCart[index].check_out == value.check_out {
                    cartIndex = index;
                    cartItem = bookingCart[index];
                    break;
                }
            }

            if cartIndex < 0 || cartItem is () {
                return {
                    success: false,
                    message: "Booking request not found in the temporary booking cart.",
                    property_id: value.property_id,
                    user_id: value.user_id,
                    check_in: value.check_in,
                    check_out: value.check_out,
                    nights: 0,
                    total_price: 0.0
                };
            }

            foreach PropertyResponse property in properties {
                if property.property_id == value.property_id {
                    if property.status != "available" {
                        return {
                            success: false,
                            message: "Property is no longer available.",
                            property_id: value.property_id,
                            user_id: value.user_id,
                            check_in: value.check_in,
                            check_out: value.check_out,
                            nights: 0,
                            total_price: 0.0
                        };
                    }

                    // Final availability check immediately before committing.
                    foreach BookingResponse booking in bookings {
                        if booking.property_id == value.property_id &&
                            booking.status == "confirmed" &&
                            datesOverlap(
                                booking.check_in, booking.check_out,
                                value.check_in, value.check_out
                            ) {
                            return {
                                success: false,
                                message: "Property is no longer available for the requested dates.",
                                property_id: value.property_id,
                                user_id: value.user_id,
                                check_in: value.check_in,
                                check_out: value.check_out,
                                nights: 0,
                                total_price: 0.0
                            };
                        }
                    }

                    float totalPrice = property.price_per_night * <float>nights;
                    string bookingId = "BOOK-" + nextBookingId.toString();
                    nextBookingId += 1;

                    BookingResponse confirmedBooking = {
                        booking_id: bookingId,
                        property_id: value.property_id,
                        property_name: property.property_name,
                        user_id: value.user_id,
                        user_name: cartItem.user_name,
                        check_in: value.check_in,
                        check_out: value.check_out,
                        status: "confirmed",
                        total_price: totalPrice
                    };

                    bookings.push(confirmedBooking);
                    _ = bookingCart.remove(cartIndex);

                    return {
                        success: true,
                        message: "Booking confirmed successfully.",
                        property_id: value.property_id,
                        user_id: value.user_id,
                        check_in: value.check_in,
                        check_out: value.check_out,
                        nights: nights,
                        total_price: totalPrice
                    };
                }
            }
        }

        return {
            success: false,
            message: "Property not found.",
            property_id: value.property_id,
            user_id: value.user_id,
            check_in: value.check_in,
            check_out: value.check_out,
            nights: 0,
            total_price: 0.0
        };
    }

    // =====================================================
    // ADMIN - LIST USERS
    // =====================================================

    remote function ListUsers(AdminRequest value)
        returns UserList|error {

        boolean isAdmin = false;


        foreach User user in users {

            if user.user_id == value.user_id &&
                user.role == "admin" {

                isAdmin = true;
            }
        }


        if !isAdmin {

            return error("Administrator access required.");
        }


        UserResponse[] result = [];


        foreach User user in users {

            result.push({
                user_id: user.user_id,
                name: user.name,
                role: user.role,
                region: user.region
            });
        }


        return {
            users: result
        };
    }


    // =====================================================
    // ADMIN - LIST BOOKINGS
    // =====================================================

    remote function ListBookings(AdminRequest value)
        returns BookingList|error {

        boolean isAdmin = false;


        foreach User user in users {

            if user.user_id == value.user_id &&
                user.role == "admin" {

                isAdmin = true;
            }
        }


        if !isAdmin {

            return error("Administrator access required.");
        }


        return {
            bookings: bookings
        };
    }


    // =====================================================
    // OLD CREATE USERS RPC
    // =====================================================

    remote function CreateUsers(
        stream<UserRequest, grpc:Error?> clientStream
    )
        returns UserCreationResponse|error {

        int usersCreated = 0;


        check clientStream.forEach(
            function(UserRequest user) {

                User newUser = {
                    user_id: user.user_id,
                    name: user.name,
                    password: "",
                    role: "user",
                    region: user.region
                };


                users.push(newUser);

                usersCreated += 1;
            }
        );


        return {
            success: true,
            users_created: usersCreated,
            message: "Users created successfully."
        };
    }
}


// =========================================================
// DATE VALIDATION AND BOOKING HELPERS
// =========================================================

function isLeapYear(int year) returns boolean {
    return (year % 400 == 0) || ((year % 4 == 0) && (year % 100 != 0));
}

function dateToOrdinal(string value) returns int|error {
    if value.length() != 10 || value.substring(4, 5) != "-" ||
        value.substring(7, 8) != "-" {
        return error("Date must use YYYY-MM-DD format.");
    }

    int year = check int:fromString(value.substring(0, 4));
    int month = check int:fromString(value.substring(5, 7));
    int day = check int:fromString(value.substring(8, 10));

    if year < 1 || month < 1 || month > 12 || day < 1 {
        return error("Invalid date.");
    }

    int[] monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int maxDay = monthDays[month - 1];
    if month == 2 && isLeapYear(year) {
        maxDay = 29;
    }

    if day > maxDay {
        return error("Invalid date.");
    }

    int previousYear = year - 1;
    int daysBeforeYear = 365 * previousYear +
        previousYear / 4 - previousYear / 100 + previousYear / 400;

    int daysBeforeMonth = 0;
    foreach int index in 0 ..< month - 1 {
        daysBeforeMonth += monthDays[index];
    }

    if month > 2 && isLeapYear(year) {
        daysBeforeMonth += 1;
    }

    return daysBeforeYear + daysBeforeMonth + day;
}

function calculateNights(string checkIn, string checkOut) returns int|error {
    int startOrdinal = check dateToOrdinal(checkIn);
    int endOrdinal = check dateToOrdinal(checkOut);

    int nights = endOrdinal - startOrdinal;
    if nights <= 0 {
        return error("Check-out date must be after check-in date.");
    }

    return nights;
}

function datesOverlap(
    string existingStart, string existingEnd,
    string requestedStart, string requestedEnd
) returns boolean {
    // ISO YYYY-MM-DD strings have chronological ordering when compared
    // lexicographically. All dates reaching this helper have already
    // passed dateToOrdinal validation.
    // Half-open intervals [check-in, check-out) allow a new guest to
    // check in on the same day another guest checks out.
    return existingStart < requestedEnd &&
        requestedStart < existingEnd;
}


// =========================================================
// APPLICATION STARTUP
// =========================================================

function init() {

    initializeAdmin();
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
