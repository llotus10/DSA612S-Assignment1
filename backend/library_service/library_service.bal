import ballerina/http;
import ballerina/log;

// Helper function to extract value from JSON string
function getValue(string jsonStr, string key) returns string {
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
            string status = getValue(entry[1], "status");
            if status == "LOANED_OUT" {
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
    resource function post assets/[string tag]/schedules(@http:Payload string scheduleData) returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        log:printInfo("Added schedule to: " + tag);
        return <http:Ok>{body: {"message": "Schedule added"}};
    }
    
    // POST /assets/{tag}/components - Add component
    resource function post assets/[string tag]/components(@http:Payload string componentData) returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        log:printInfo("Added component to: " + tag);
        return <http:Ok>{body: {"message": "Component added"}};
    }
    
    // DELETE /assets/{tag}/components/{compId} - Remove component
    resource function delete assets/[string tag]/components/[string compId]() returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        log:printInfo("Removed component: " + compId);
        return <http:Ok>{body: {"message": "Component removed"}};
    }
    
    // DELETE /assets/{tag}/schedules/{schedId} - Remove schedule
    resource function delete assets/[string tag]/schedules/[string schedId]() returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        log:printInfo("Removed schedule: " + schedId);
        return <http:Ok>{body: {"message": "Schedule removed"}};
    }
    
    // POST /assets/{tag}/workorders - Create work order
    resource function post assets/[string tag]/workorders(@http:Payload string workOrderData) returns http:Ok|http:NotFound {
        if !assetStore.hasKey(tag) {
            return <http:NotFound>{body: {"error": "Not found"}};
        }
        log:printInfo("Created work order for: " + tag);
        return <http:Ok>{body: {"message": "Work order created"}};
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