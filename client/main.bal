import ballerina/http;
import ballerina/io;

final http:Client apiClient = check new ("http://localhost:9091/api/library");

public function main() returns error? {
    io:println("=================================================");
    io:println("  Ministry Library Resource Management Client");
    io:println("=================================================");

    boolean running = true;
    while running {
        io:println("\nPlease choose an operation:");
        io:println("1. Global View (View All Assets Across Ministry)");
        io:println("2. Campus View (Filter by Institution & Site)");
        io:println("3. Loan an Asset");
        io:println("4. Return an Asset");
        io:println("5. Book a Space (Lab or Meeting Room)");
        io:println("6. Overdue Maintenance Dashboard");
        io:println("7. Schedule Manager (Add Maintenance Schedule)");
        io:println("0. Exit");

        string choice = io:readln("Enter choice (0-7): ");

        if choice == "1" {
            check viewAllAssets();
        } else if choice == "2" {
            check filterByCampus();
        } else if choice == "3" {
            check loanAsset();
        } else if choice == "4" {
            check returnAsset();
        } else if choice == "5" {
            check bookSpace();
        } else if choice == "6" {
            check viewOverdue();
        } else if choice == "7" {
            check addSchedule();
        } else if choice == "0" {
            io:println("Exiting client. Goodbye!");
            running = false;
        } else {
            io:println("Invalid choice. Please select 0-7.");
        }
    }
}

// 1. Global View
function viewAllAssets() returns error? {
    io:println("\n--- All Assets Across Ministry ---");
    http:Response res = check apiClient->get("/assets");
    json data = check res.getJsonPayload();
    printAssetList(data);
}

// 2. Campus View
function filterByCampus() returns error? {
    string inst = io:readln("Enter Institution name: ");
    if inst == "" {
        io:println("Institution cannot be empty.");
        return;
    }
    string site = io:readln("Enter Site/Campus (leave blank for all sites): ");
    string path = "/assets/institution/" + inst;
    if site != "" {
        path = path + "/site/" + site;
    }
    http:Response res = check apiClient->get(path);
    json data = check res.getJsonPayload();
    printAssetList(data);
}

// 3. Loaning
function loanAsset() returns error? {
    string tag = io:readln("Enter Asset Tag to loan (e.g. UNAM-LIB-LAP-002): ");
    http:Response res = check apiClient->patch("/assets/" + tag + "/loan", ());
    if res.statusCode == 200 {
        io:println("SUCCESS: Asset '" + tag + "' is now LOANED OUT.");
    } else {
        json body = check res.getJsonPayload();
        io:println("FAILED: " + body.toJsonString());
    }
}

// 4. Return
function returnAsset() returns error? {
    string tag = io:readln("Enter Asset Tag to return: ");
    http:Response res = check apiClient->patch("/assets/" + tag + "/release", ());
    if res.statusCode == 200 {
        io:println("SUCCESS: Asset '" + tag + "' has been RETURNED (now AVAILABLE).");
    } else {
        json body = check res.getJsonPayload();
        io:println("FAILED: " + body.toJsonString());
    }
}

// 5. Booking
function bookSpace() returns error? {
    string tag = io:readln("Enter Room/Lab Tag (e.g. IIT-LIB-ROOM-003): ");
    string bookId = io:readln("Enter Booking ID (e.g. BOOK-001): ");
    string bookDate = io:readln("Enter Booking Date (YYYY-MM-DD): ");
    string desc = io:readln("Enter Description: ");

    json payload = {
        "bookingId": bookId,
        "type": "BOOKING",
        "bookingDate": bookDate,
        "description": desc
    };

    http:Response res = check apiClient->post("/assets/" + tag + "/bookings", payload);
    if res.statusCode == 200 {
        io:println("SUCCESS: Space '" + tag + "' booked for " + bookDate);
    } else {
        json body = check res.getJsonPayload();
        io:println("FAILED: " + body.toJsonString());
    }
}

// 6. Overdue Dashboard
function viewOverdue() returns error? {
    io:println("\n--- Overdue Maintenance Dashboard ---");
    http:Response res = check apiClient->get("/assets/maintenance/overdue");
    json data = check res.getJsonPayload();
    printAssetList(data);
}

// 7. Schedule Manager
function addSchedule() returns error? {
    string tag = io:readln("Enter Asset Tag: ");
    string schedId = io:readln("Enter Schedule ID (e.g. SCH-101): ");
    string dueDate = io:readln("Enter Due Date (YYYY-MM-DD): ");
    string desc = io:readln("Enter Description: ");

    json payload = {
        "scheduleId": schedId,
        "type": "MAINTENANCE",
        "dueDate": dueDate,
        "description": desc
    };

    http:Response res = check apiClient->post("/assets/" + tag + "/schedules", payload);
    if res.statusCode == 200 {
        io:println("SUCCESS: Maintenance schedule added to '" + tag + "'");
    } else {
        json body = check res.getJsonPayload();
        io:println("FAILED: " + body.toJsonString());
    }
}

// Helper to format and print asset list
function printAssetList(json data) {
    if data is json[] {
        if data.length() == 0 {
            io:println("No assets found.");
            return;
        }
        foreach json item in data {
            if item is map<json> {
                io:println("-------------------------------------------------");
                io:println("Tag:         " + (item["assetTag"] ?: "").toString());
                io:println("Name:        " + (item["name"] ?: "").toString());
                io:println("Institution: " + (item["institution"] ?: "").toString());
                io:println("Site:        " + (item["site"] ?: "").toString());
                io:println("Status:      " + (item["status"] ?: "").toString());
            }
        }
        io:println("-------------------------------------------------");
        io:println("Total count: " + data.length().toString());
    } else {
        io:println(data.toJsonString());
    }
}
