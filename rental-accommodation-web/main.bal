import ballerina/http;
import ballerina/io;


// =========================================================
// GRPC CLIENT
// =========================================================

final RentalAccommodationServiceClient rentalClient =
    checkpanic new ("http://localhost:9090");


// =========================================================
// HTTP LISTENER
// =========================================================

listener http:Listener webListener = new (8080);


// =========================================================
// API SERVICE
// =========================================================

service /api on webListener {

    // =====================================================
    // REGISTER USER
    // =====================================================

    resource function post register(
        @http:Payload RegisterUserRequest request
    ) returns RegisterUserResponse|error {

        return check rentalClient->RegisterUser(request);
    }


    // =====================================================
    // LOGIN USER
    // =====================================================

    resource function post login(
        @http:Payload LoginUserRequest request
    ) returns LoginUserResponse|error {

        return check rentalClient->LoginUser(request);
    }


    // =====================================================
    // GET AVAILABLE PROPERTIES
    // =====================================================

    resource function get properties()
        returns PropertyResponse[]|error {

        PropertyFilter filter = {
            location: "",
            min_price: 0,
            max_price: 0
        };


        stream<PropertyResponse, error?> result =
            check rentalClient->ListAvailableProperties(filter);


        PropertyResponse[] properties = [];


        check result.forEach(
            function(PropertyResponse property) {

                properties.push(property);
            }
        );


        return properties;
    }


    // =====================================================
    // ADD PROPERTY
    // ADMIN
    // =====================================================

    resource function post addProperty(
        @http:Payload PropertyRequest request
    ) returns PropertyResponse|error {

        return check rentalClient->AddProperty(request);
    }


    // =====================================================
    // UPDATE PROPERTY
    // ADMIN
    // =====================================================

    resource function put property/[string propertyId](
        @http:Payload UpdatePropertyRequest request
    ) returns PropertyResponse|error {

        UpdatePropertyRequest updateRequest = {
            property_id: propertyId,
            property_name: request.property_name,
            location: request.location,
            property_type: request.property_type,
            price_per_night: request.price_per_night,
            status: request.status
        };


        return check rentalClient->UpdateProperty(updateRequest);
    }


    // =====================================================
    // REMOVE PROPERTY
    // ADMIN
    // =====================================================

    resource function delete property/[string propertyId](
        @http:Payload RemovePropertyRequest request
    ) returns PropertyList|error {

        RemovePropertyRequest removeRequest = {
            property_id: propertyId,
            host_id: request.host_id,
            region: request.region
        };


        return check rentalClient->RemoveProperty(removeRequest);
    }


    // =====================================================
    // BOOK PROPERTY
    // USER
    // =====================================================

    resource function post book(
        @http:Payload BookPropertyRequest request
    ) returns BookPropertyResponse|error {

        return check rentalClient->BookProperty(request);
    }


    // =====================================================
    // CONFIRM BOOKING
    // =====================================================

    resource function post confirmBooking(
        @http:Payload ConfirmBookingRequest request
    ) returns ConfirmBookingResponse|error {

        return check rentalClient->ConfirmBooking(request);
    }
}


// =========================================================
// FRONTEND
// =========================================================

service / on webListener {

    // =====================================================
    // INDEX PAGE
    // =====================================================

    resource function get .() returns http:Response {

        string html = checkpanic io:fileReadString(
            "web/index.html"
        );


        http:Response response = new;

        response.statusCode = 200;

        response.setHeader(
            "Content-Type",
            "text/html"
        );

        response.setTextPayload(html);

        return response;
    }


    // =====================================================
    // CSS
    // =====================================================

    resource function get css/[string filename]()
        returns http:Response {

        string css = checkpanic io:fileReadString(
            "web/css/" + filename
        );


        http:Response response = new;

        response.statusCode = 200;

        response.setHeader(
            "Content-Type",
            "text/css"
        );

        response.setTextPayload(css);

        return response;
    }


    // =====================================================
    // JAVASCRIPT
    // =====================================================

    resource function get js/[string filename]()
        returns http:Response {

        string javascript = checkpanic io:fileReadString(
            "web/js/" + filename
        );


        http:Response response = new;

        response.statusCode = 200;

        response.setHeader(
            "Content-Type",
            "application/javascript"
        );

        response.setTextPayload(javascript);

        return response;
    }
}