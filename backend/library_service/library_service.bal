import ballerina/http;
import ballerina/log;
import ballerina/time;

// So what this getvalue function does is it takes a JSON string and a key, and it returns the value associated with that key in the JSON string. It does this by searching for the key in the JSON string and then extracting the value that follows it. If the key is not found, it returns an empty string. This function is used throughout the service to extract values from JSON strings representing assets.
function getValue(string jsonStr, string key) returns string {
    //whats happening here is we`re creating a variabe called search and its a string `
    string search = "\"" + key + "\":\"";
    int searchLen = search.length();
    int jsonLen = jsonStr.length();
    int startPos = -1;
    int i = 0;
    while i < jsonLen - searchLen + 1 {
        string sub = jsonStr.substring(i, i + searchLen);
        if sub == search {
            startPos = i + searchLen;
            break;
        }
        i = i + 1;
    }
    if startPos == -1 {
        return "";
    }
    int endPos = -1;
    int j = startPos;
    while j < jsonLen {
        string ch = jsonStr.substring(j, j + 1);
        if ch == "\"" {
            endPos = j;
            break;
        }
        j = j + 1;
    }
    if endPos == -1 {
        return "";
    }
    return jsonStr.substring(startPos, endPos);
}

function isPastDate(string date) returns boolean {
    time:Utc|time:Error dueDate = time:utcFromString(date + "T00:00:00Z");
    if dueDate is time:Utc {
        return dueDate < time:utcNow();
    }
    return false;
}

service /api/library on new http:Listener(9090) {
    
    function init() {
        initSampleData();
        log:printInfo("Library System started on port 9090");
    }
    
    // GET /assets - Return all assets as JSON string
    resource function get assets() returns string {
        string result = "[";
        int count = 0;
        foreach var entry in assetStore.entries() {
            if count > 0 {
                result = result + ",";
            }
            result = result + entry[1];
            count = count + 1;
        }
        result = result + "]";
        return result;
    }
    
    // POST /assets - Create asset
    resource function post assets(@http:Payload string assetData) returns http:Created|http:Conflict|http:BadRequest {
        string tag = getValue(assetData, "assetTag");
        if tag == "" {
            return <http:BadRequest>{body: {"error": "Invalid asset tag"}};
        }
        if assetStore.hasKey(tag) {
            return <http:Conflict>{body: {"error": "Asset already exists"}};
        }
        assetStore[tag] = assetData;
        log:printInfo("Created: " + tag);
        return <http:Created>{body: {"message": "Created", "assetTag": tag}};
    }
    
    // GET /assets/{tag} - Get asset by tag
    resource function get assets/[string tag]() returns string|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string? result = assetStore[tag];
        if result is string {
            return result;
        }
        return <http:NotFound>{body: {"error": "Not found"}};
    }
    
    // PUT /assets/{tag} - Update asset
    resource function put assets/[string tag](@http:Payload string assetData) returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        assetStore[tag] = assetData;
        log:printInfo("Updated: " + tag);
        return <http:Ok>{body: {"message": "Updated"}};
    }
    
    // DELETE /assets/{tag} - Delete asset
    resource function delete assets/[string tag]() returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        _ = assetStore.remove(tag);
        log:printInfo("Deleted: " + tag);
        return <http:Ok>{body: {"message": "Deleted"}};
    }
    
    // GET /assets/institution/{inst} - Get by institution
    resource function get assets/institution/[string inst]() returns string {
        string result = "[";
        int count = 0;
        foreach var entry in assetStore.entries() {
            string institution = getValue(entry[1], "institution");
            if institution == inst {
                if count > 0 {
                    result = result + ",";
                }
                result = result + entry[1];
                count = count + 1;
            }
        }
        result = result + "]";
        return result;
    }
    
    // GET /assets/institution/{inst}/site/{site} - Get by institution and site
    resource function get assets/institution/[string inst]/site/[string site]() returns string {
        string result = "[";
        int count = 0;
        foreach var entry in assetStore.entries() {
            string institution = getValue(entry[1], "institution");
            string siteVal = getValue(entry[1], "site");
            if institution == inst && siteVal == site {
                if count > 0 {
                    result = result + ",";
                }
                result = result + entry[1];
                count = count + 1;
            }
        }
        result = result + "]";
        return result;
    }
    
    // GET /assets/maintenance/overdue - Get overdue
    resource function get assets/maintenance/overdue() returns string {
        string result = "[";
        int count = 0;
        foreach var entry in assetStore.entries() {
            boolean overdue = false;
            string[]? schedules = scheduleStore[entry[0]];
            if schedules is string[] {
                foreach string schedule in schedules {
                    string scheduleType = getValue(schedule, "type").toUpperAscii();
                    string dueDate = getValue(schedule, "dueDate");
                    if scheduleType == "MAINTENANCE" && isPastDate(dueDate) {
                        overdue = true;
                        break;
                    }
                }
            }
            if overdue {
                if count > 0 {
                    result = result + ",";
                }
                result = result + entry[1];
                count = count + 1;
            }
        }
        result = result + "]";
        return result;
    }
    
    // POST /assets/{tag}/schedules - Add schedule
    resource function post assets/[string tag]/schedules(@http:Payload json scheduleData) returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string scheduleJson = scheduleData.toJsonString();
        if !scheduleStore.hasKey(tag) {
            scheduleStore[tag] = [];
        }
        string[] schedules = [];
        string[]? storedSchedules = scheduleStore[tag];
        if storedSchedules is string[] {
            schedules = storedSchedules;
        }
        schedules.push(scheduleJson);
        scheduleStore[tag] = schedules;
        log:printInfo("Added schedule to: " + tag);
        return <http:Ok>{body: {"message": "Schedule added"}};
    }

    // GET /assets/{tag}/schedules - Get schedules for an asset
    resource function get assets/[string tag]/schedules() returns string|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string result = "[";
        string[]? schedules = scheduleStore[tag];
        if schedules is string[] {
            foreach string schedule in schedules {
                if result != "[" {
                    result = result + ",";
                }
                result = result + schedule;
            }
        }
        return result + "]";
    }
    
    // POST /assets/{tag}/components - Add component
    resource function post assets/[string tag]/components(@http:Payload json componentData) returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string[] components = [];
        string[]? storedComponents = componentStore[tag];
        if storedComponents is string[] {
            components = storedComponents;
        }
        components.push(componentData.toJsonString());
        componentStore[tag] = components;
        log:printInfo("Added component to: " + tag);
        return <http:Ok>{body: {"message": "Component added"}};
    }

    // GET /assets/{tag}/components - Get components for an asset
    resource function get assets/[string tag]/components() returns string|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string result = "[";
        string[]? components = componentStore[tag];
        if components is string[] {
            foreach string component in components {
                if result != "[" {
                    result = result + ",";
                }
                result = result + component;
            }
        }
        return result + "]";
    }
    
    // DELETE /assets/{tag}/components/{compId} - Remove component
    resource function delete assets/[string tag]/components/[string compId]() returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string[]? components = componentStore[tag];
        if components is string[] {
            string[] remaining = [];
            boolean removed = false;
            foreach string component in components {
                if getValue(component, "compId") == compId {
                    removed = true;
                } else {
                    remaining.push(component);
                }
            }
            if !removed {
                return <http:NotFound>{body: {"error": "Component not found"}};
            }
            componentStore[tag] = remaining;
        } else {
            return <http:NotFound>{body: {"error": "Component not found"}};
        }
        log:printInfo("Removed component: " + compId);
        return <http:Ok>{body: {"message": "Component removed"}};
    }
    
    // DELETE /assets/{tag}/schedules/{schedId} - Remove schedule
    resource function delete assets/[string tag]/schedules/[string schedId]() returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string[]? schedules = scheduleStore[tag];
        if schedules is string[] {
            string[] remaining = [];
            boolean removed = false;
            foreach string schedule in schedules {
                if getValue(schedule, "scheduleId") == schedId {
                    removed = true;
                } else {
                    remaining.push(schedule);
                }
            }
            if !removed {
                return <http:NotFound>{body: {"error": "Schedule not found"}};
            }
            scheduleStore[tag] = remaining;
        } else {
            return <http:NotFound>{body: {"error": "Schedule not found"}};
        }
        log:printInfo("Removed schedule: " + schedId);
        return <http:Ok>{body: {"message": "Schedule removed"}};
    }
    
    // POST /assets/{tag}/workorders - Create work order
    resource function post assets/[string tag]/workorders(@http:Payload json workOrderData) returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string[] workOrders = [];
        string[]? storedWorkOrders = workOrderStore[tag];
        if storedWorkOrders is string[] {
            workOrders = storedWorkOrders;
        }
        workOrders.push(workOrderData.toJsonString());
        workOrderStore[tag] = workOrders;
        log:printInfo("Created work order for: " + tag);
        return <http:Ok>{body: {"message": "Work order created"}};
    }

    // GET /assets/{tag}/workorders - Get work orders for an asset
    resource function get assets/[string tag]/workorders() returns string|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string result = "[";
        string[]? workOrders = workOrderStore[tag];
        if workOrders is string[] {
            foreach string workOrder in workOrders {
                if result != "[" {
                    result = result + ",";
                }
                result = result + workOrder;
            }
        }
        return result + "]";
    }

    // PATCH /assets/{tag}/workorders/{orderId} - Update a work order
    resource function patch assets/[string tag]/workorders/[string orderId](@http:Payload json workOrderData) returns http:Ok|http:NotFound|http:BadRequest {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string updatedWorkOrder = workOrderData.toJsonString();
        string status = getValue(updatedWorkOrder, "status").toUpperAscii();
        if status != "OPEN" && status != "IN_PROGRESS" && status != "CLOSED" {
            return <http:BadRequest>{body: {"error": "Invalid work order status"}};
        }
        string[]? workOrders = workOrderStore[tag];
        if workOrders is string[] {
            string[] updatedWorkOrders = [];
            boolean updated = false;
            foreach string workOrder in workOrders {
                if getValue(workOrder, "orderId") == orderId {
                    updatedWorkOrders.push(updatedWorkOrder);
                    updated = true;
                } else {
                    updatedWorkOrders.push(workOrder);
                }
            }
            if !updated {
                return <http:NotFound>{body: {"error": "Work order not found"}};
            }
            workOrderStore[tag] = updatedWorkOrders;
            log:printInfo("Updated work order: " + orderId);
            return <http:Ok>{body: {"message": "Work order updated"}};
        }
        return <http:NotFound>{body: {"error": "Work order not found"}};
    }
    
    // PATCH /assets/{tag}/status - Update status
    resource function patch assets/[string tag]/status(@http:Payload string statusData) returns http:Ok|http:NotFound|http:BadRequest {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        string newStatus = getValue(statusData, "newStatus");
        if newStatus == "" {
            return <http:BadRequest>{body: {"error": "Invalid status"}};
        }
        newStatus = newStatus.toUpperAscii();
        
        string? currentJson = assetStore[tag];
        if currentJson is string {
            string tagVal = getValue(currentJson, "assetTag");
            string name = getValue(currentJson, "name");
            string desc = getValue(currentJson, "description");
            string inst = getValue(currentJson, "institution");
            string site = getValue(currentJson, "site");
            string date = getValue(currentJson, "dateAcquired");
            
            string updatedJson = "{\"assetTag\":\"" + tagVal + "\",\"name\":\"" + name + "\",\"description\":\"" + desc + "\",\"institution\":\"" + inst + "\",\"site\":\"" + site + "\",\"status\":\"" + newStatus + "\",\"dateAcquired\":\"" + date + "\"}";
            
            assetStore[tag] = updatedJson;
            log:printInfo("Updated status for: " + tag);
            return <http:Ok>{body: {"message": "Status updated"}};
        }
        return <http:NotFound>{body: {"error": "Not found"}};
    }
    
    // GET /institutions - Get all institutions
    resource function get institutions() returns string {
        string result = "[";
        int count = 0;
        string[] seen = [];
        foreach var entry in assetStore.entries() {
            string inst = getValue(entry[1], "institution");
            if inst == "" {
                continue;
            }
            boolean found = false;
            int idx = 0;
            while idx < seen.length() {
                if seen[idx] == inst {
                    found = true;
                    break;
                }
                idx = idx + 1;
            }
            if !found {
                if count > 0 {
                    result = result + ",";
                }
                result = result + "\"" + inst + "\"";
                seen.push(inst);
                count = count + 1;
            }
        }
        result = result + "]";
        return result;
    }
}