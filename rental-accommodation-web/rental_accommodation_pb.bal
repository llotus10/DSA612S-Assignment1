import ballerina/grpc;
import ballerina/protobuf;

public const string RENTAL_ACCOMMODATION_DESC = "0A1A72656E74616C5F6163636F6D6D6F646174696F6E2E70726F746F120672656E74616C22E8010A0F50726F70657274795265717565737412230A0D70726F70657274795F6E616D65180120012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18022001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180320012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180420012801520D70726963655065724E6967687412160A06737461747573180520012809520673746174757312170A07686F73745F69641806200128095206686F7374496412160A06726567696F6E1807200128095206726567696F6E228A020A1050726F7065727479526573706F6E7365121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412230A0D70726F70657274795F6E616D65180220012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687412160A06737461747573180620012809520673746174757312170A07686F73745F69641807200128095206686F7374496412160A06726567696F6E1808200128095206726567696F6E22DE010A1555706461746550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412230A0D70726F70657274795F6E616D65180220012809520C70726F70657274794E616D65121A0A086C6F636174696F6E18032001280952086C6F636174696F6E12230A0D70726F70657274795F74797065180420012809520C70726F70657274795479706512260A0F70726963655F7065725F6E69676874180520012801520D70726963655065724E6967687412160A06737461747573180620012809520673746174757322690A1552656D6F766550726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07686F73745F69641802200128095206686F7374496412160A06726567696F6E1803200128095206726567696F6E22480A0C50726F70657274794C69737412380A0A70726F7065727469657318012003280B32182E72656E74616C2E50726F7065727479526573706F6E7365520A70726F7065727469657322660A0E50726F706572747946696C746572121A0A086C6F636174696F6E18012001280952086C6F636174696F6E121B0A096D696E5F707269636518022001280152086D696E5072696365121B0A096D61785F707269636518032001280152086D6178507269636522380A1553656172636850726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F706572747949642286010A1650726F7065727479536561726368526573706F6E7365121C0A09617661696C61626C651801200128085209617661696C61626C6512180A076D65737361676518022001280952076D65737361676512340A0870726F706572747918032001280B32182E72656E74616C2E50726F7065727479526573706F6E7365520870726F706572747922660A0B557365725265717565737412170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6512160A06726567696F6E1804200128095206726567696F6E226F0A14557365724372656174696F6E526573706F6E736512180A077375636365737318012001280852077375636365737312230A0D75736572735F63726561746564180220012805520C75736572734372656174656412180A076D65737361676518032001280952076D65737361676522760A135265676973746572557365725265717565737412170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D65121A0A0870617373776F7264180320012809520870617373776F726412160A06726567696F6E1804200128095206726567696F6E22770A14526567697374657255736572526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512170A07757365725F6964180320012809520675736572496412120A04726F6C651804200128095204726F6C6522470A104C6F67696E557365725265717565737412170A07757365725F69641801200128095206757365724964121A0A0870617373776F7264180220012809520870617373776F726422A0010A114C6F67696E55736572526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512170A07757365725F6964180320012809520675736572496412120A046E616D6518042001280952046E616D6512120A04726F6C651805200128095204726F6C6512160A06726567696F6E1806200128095206726567696F6E22270A0C41646D696E5265717565737412170A07757365725F6964180120012809520675736572496422670A0C55736572526573706F6E736512170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6512160A06726567696F6E1804200128095206726567696F6E22360A08557365724C697374122A0A05757365727318012003280B32142E72656E74616C2E55736572526573706F6E7365520575736572732287010A13426F6F6B50726F706572747952657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07757365725F6964180220012809520675736572496412190A08636865636B5F696E1803200128095207636865636B496E121B0A09636865636B5F6F75741804200128095208636865636B4F757422BC010A14426F6F6B50726F7065727479526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D657373616765121F0A0B70726F70657274795F6964180320012809520A70726F7065727479496412170A07757365725F6964180420012809520675736572496412190A08636865636B5F696E1805200128095207636865636B496E121B0A09636865636B5F6F75741806200128095208636865636B4F75742289010A15436F6E6669726D426F6F6B696E6752657175657374121F0A0B70726F70657274795F6964180120012809520A70726F7065727479496412170A07757365725F6964180220012809520675736572496412190A08636865636B5F696E1803200128095207636865636B496E121B0A09636865636B5F6F75741804200128095208636865636B4F757422F7010A16436F6E6669726D426F6F6B696E67526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D657373616765121F0A0B70726F70657274795F6964180320012809520A70726F7065727479496412170A07757365725F6964180420012809520675736572496412190A08636865636B5F696E1805200128095207636865636B496E121B0A09636865636B5F6F75741806200128095208636865636B4F757412160A066E696768747318072001280552066E6967687473121F0A0B746F74616C5F7072696365180820012801520A746F74616C5072696365229D020A0F426F6F6B696E67526573706F6E7365121D0A0A626F6F6B696E675F69641801200128095209626F6F6B696E674964121F0A0B70726F70657274795F6964180220012809520A70726F7065727479496412230A0D70726F70657274795F6E616D65180320012809520C70726F70657274794E616D6512170A07757365725F69641804200128095206757365724964121B0A09757365725F6E616D651805200128095208757365724E616D6512190A08636865636B5F696E1806200128095207636865636B496E121B0A09636865636B5F6F75741807200128095208636865636B4F757412160A067374617475731808200128095206737461747573121F0A0B746F74616C5F7072696365180920012801520A746F74616C507269636522420A0B426F6F6B696E674C69737412330A08626F6F6B696E677318012003280B32172E72656E74616C2E426F6F6B696E67526573706F6E73655208626F6F6B696E677332ED060A1A52656E74616C4163636F6D6D6F646174696F6E5365727669636512400A0B41646450726F706572747912172E72656E74616C2E50726F7065727479526571756573741A182E72656E74616C2E50726F7065727479526573706F6E736512490A0E55706461746550726F7065727479121D2E72656E74616C2E55706461746550726F7065727479526571756573741A182E72656E74616C2E50726F7065727479526573706F6E736512450A0E52656D6F766550726F7065727479121D2E72656E74616C2E52656D6F766550726F7065727479526571756573741A142E72656E74616C2E50726F70657274794C697374124D0A174C697374417661696C61626C6550726F7065727469657312162E72656E74616C2E50726F706572747946696C7465721A182E72656E74616C2E50726F7065727479526573706F6E73653001124F0A0E53656172636850726F7065727479121D2E72656E74616C2E53656172636850726F7065727479526571756573741A1E2E72656E74616C2E50726F7065727479536561726368526573706F6E736512490A0C526567697374657255736572121B2E72656E74616C2E526567697374657255736572526571756573741A1C2E72656E74616C2E526567697374657255736572526573706F6E736512400A094C6F67696E5573657212182E72656E74616C2E4C6F67696E55736572526571756573741A192E72656E74616C2E4C6F67696E55736572526573706F6E736512420A0B437265617465557365727312132E72656E74616C2E55736572526571756573741A1C2E72656E74616C2E557365724372656174696F6E526573706F6E7365280112490A0C426F6F6B50726F7065727479121B2E72656E74616C2E426F6F6B50726F7065727479526571756573741A1C2E72656E74616C2E426F6F6B50726F7065727479526573706F6E7365124F0A0E436F6E6669726D426F6F6B696E67121D2E72656E74616C2E436F6E6669726D426F6F6B696E67526571756573741A1E2E72656E74616C2E436F6E6669726D426F6F6B696E67526573706F6E736512330A094C697374557365727312142E72656E74616C2E41646D696E526571756573741A102E72656E74616C2E557365724C69737412390A0C4C697374426F6F6B696E677312142E72656E74616C2E41646D696E526571756573741A132E72656E74616C2E426F6F6B696E674C697374620670726F746F33";

public isolated client class RentalAccommodationServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, RENTAL_ACCOMMODATION_DESC);
    }

    isolated remote function AddProperty(PropertyRequest|ContextPropertyRequest req) returns PropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        PropertyRequest message;
        if req is ContextPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/AddProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PropertyResponse>result;
    }

    isolated remote function AddPropertyContext(PropertyRequest|ContextPropertyRequest req) returns ContextPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        PropertyRequest message;
        if req is ContextPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/AddProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PropertyResponse>result, headers: respHeaders};
    }

    isolated remote function UpdateProperty(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns PropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/UpdateProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PropertyResponse>result;
    }

    isolated remote function UpdatePropertyContext(UpdatePropertyRequest|ContextUpdatePropertyRequest req) returns ContextPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdatePropertyRequest message;
        if req is ContextUpdatePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/UpdateProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PropertyResponse>result, headers: respHeaders};
    }

    isolated remote function RemoveProperty(RemovePropertyRequest|ContextRemovePropertyRequest req) returns PropertyList|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/RemoveProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PropertyList>result;
    }

    isolated remote function RemovePropertyContext(RemovePropertyRequest|ContextRemovePropertyRequest req) returns ContextPropertyList|grpc:Error {
        map<string|string[]> headers = {};
        RemovePropertyRequest message;
        if req is ContextRemovePropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/RemoveProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PropertyList>result, headers: respHeaders};
    }

    isolated remote function SearchProperty(SearchPropertyRequest|ContextSearchPropertyRequest req) returns PropertySearchResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/SearchProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <PropertySearchResponse>result;
    }

    isolated remote function SearchPropertyContext(SearchPropertyRequest|ContextSearchPropertyRequest req) returns ContextPropertySearchResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchPropertyRequest message;
        if req is ContextSearchPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/SearchProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <PropertySearchResponse>result, headers: respHeaders};
    }

    isolated remote function RegisterUser(RegisterUserRequest|ContextRegisterUserRequest req) returns RegisterUserResponse|grpc:Error {
        map<string|string[]> headers = {};
        RegisterUserRequest message;
        if req is ContextRegisterUserRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/RegisterUser", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <RegisterUserResponse>result;
    }

    isolated remote function RegisterUserContext(RegisterUserRequest|ContextRegisterUserRequest req) returns ContextRegisterUserResponse|grpc:Error {
        map<string|string[]> headers = {};
        RegisterUserRequest message;
        if req is ContextRegisterUserRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/RegisterUser", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <RegisterUserResponse>result, headers: respHeaders};
    }

    isolated remote function LoginUser(LoginUserRequest|ContextLoginUserRequest req) returns LoginUserResponse|grpc:Error {
        map<string|string[]> headers = {};
        LoginUserRequest message;
        if req is ContextLoginUserRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/LoginUser", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <LoginUserResponse>result;
    }

    isolated remote function LoginUserContext(LoginUserRequest|ContextLoginUserRequest req) returns ContextLoginUserResponse|grpc:Error {
        map<string|string[]> headers = {};
        LoginUserRequest message;
        if req is ContextLoginUserRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/LoginUser", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <LoginUserResponse>result, headers: respHeaders};
    }

    isolated remote function BookProperty(BookPropertyRequest|ContextBookPropertyRequest req) returns BookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/BookProperty", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookPropertyResponse>result;
    }

    isolated remote function BookPropertyContext(BookPropertyRequest|ContextBookPropertyRequest req) returns ContextBookPropertyResponse|grpc:Error {
        map<string|string[]> headers = {};
        BookPropertyRequest message;
        if req is ContextBookPropertyRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/BookProperty", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookPropertyResponse>result, headers: respHeaders};
    }

    isolated remote function ConfirmBooking(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/ConfirmBooking", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ConfirmBookingResponse>result;
    }

    isolated remote function ConfirmBookingContext(ConfirmBookingRequest|ContextConfirmBookingRequest req) returns ContextConfirmBookingResponse|grpc:Error {
        map<string|string[]> headers = {};
        ConfirmBookingRequest message;
        if req is ContextConfirmBookingRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/ConfirmBooking", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ConfirmBookingResponse>result, headers: respHeaders};
    }

    isolated remote function ListUsers(AdminRequest|ContextAdminRequest req) returns UserList|grpc:Error {
        map<string|string[]> headers = {};
        AdminRequest message;
        if req is ContextAdminRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/ListUsers", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UserList>result;
    }

    isolated remote function ListUsersContext(AdminRequest|ContextAdminRequest req) returns ContextUserList|grpc:Error {
        map<string|string[]> headers = {};
        AdminRequest message;
        if req is ContextAdminRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/ListUsers", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UserList>result, headers: respHeaders};
    }

    isolated remote function ListBookings(AdminRequest|ContextAdminRequest req) returns BookingList|grpc:Error {
        map<string|string[]> headers = {};
        AdminRequest message;
        if req is ContextAdminRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/ListBookings", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <BookingList>result;
    }

    isolated remote function ListBookingsContext(AdminRequest|ContextAdminRequest req) returns ContextBookingList|grpc:Error {
        map<string|string[]> headers = {};
        AdminRequest message;
        if req is ContextAdminRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("rental.RentalAccommodationService/ListBookings", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <BookingList>result, headers: respHeaders};
    }

    isolated remote function CreateUsers() returns CreateUsersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("rental.RentalAccommodationService/CreateUsers");
        return new CreateUsersStreamingClient(sClient);
    }

    isolated remote function ListAvailableProperties(PropertyFilter|ContextPropertyFilter req) returns stream<PropertyResponse, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        PropertyFilter message;
        if req is ContextPropertyFilter {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rental.RentalAccommodationService/ListAvailableProperties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        PropertyResponseStream outputStream = new PropertyResponseStream(result);
        return new stream<PropertyResponse, grpc:Error?>(outputStream);
    }

    isolated remote function ListAvailablePropertiesContext(PropertyFilter|ContextPropertyFilter req) returns ContextPropertyResponseStream|grpc:Error {
        map<string|string[]> headers = {};
        PropertyFilter message;
        if req is ContextPropertyFilter {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("rental.RentalAccommodationService/ListAvailableProperties", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        PropertyResponseStream outputStream = new PropertyResponseStream(result);
        return {content: new stream<PropertyResponse, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class CreateUsersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUserRequest(UserRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUserRequest(ContextUserRequest message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveUserCreationResponse() returns UserCreationResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <UserCreationResponse>payload;
        }
    }

    isolated remote function receiveContextUserCreationResponse() returns ContextUserCreationResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <UserCreationResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class PropertyResponseStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|PropertyResponse value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|PropertyResponse value;|} nextRecord = {value: <PropertyResponse>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class RentalAccommodationServiceBookingListCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendBookingList(BookingList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextBookingList(ContextBookingList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalAccommodationServicePropertyListCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendPropertyList(PropertyList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextPropertyList(ContextPropertyList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalAccommodationServiceUserCreationResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUserCreationResponse(UserCreationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUserCreationResponse(ContextUserCreationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalAccommodationServicePropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendPropertyResponse(PropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextPropertyResponse(ContextPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalAccommodationServiceLoginUserResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendLoginUserResponse(LoginUserResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextLoginUserResponse(ContextLoginUserResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalAccommodationServiceBookPropertyResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendBookPropertyResponse(BookPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextBookPropertyResponse(ContextBookPropertyResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalAccommodationServiceConfirmBookingResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendConfirmBookingResponse(ConfirmBookingResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextConfirmBookingResponse(ContextConfirmBookingResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalAccommodationServicePropertySearchResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendPropertySearchResponse(PropertySearchResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextPropertySearchResponse(ContextPropertySearchResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalAccommodationServiceRegisterUserResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendRegisterUserResponse(RegisterUserResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextRegisterUserResponse(ContextRegisterUserResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class RentalAccommodationServiceUserListCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUserList(UserList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUserList(ContextUserList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextPropertyResponseStream record {|
    stream<PropertyResponse, error?> content;
    map<string|string[]> headers;
|};

public type ContextUserRequestStream record {|
    stream<UserRequest, error?> content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyRequest record {|
    BookPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextLoginUserRequest record {|
    LoginUserRequest content;
    map<string|string[]> headers;
|};

public type ContextLoginUserResponse record {|
    LoginUserResponse content;
    map<string|string[]> headers;
|};

public type ContextUpdatePropertyRequest record {|
    UpdatePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextRegisterUserRequest record {|
    RegisterUserRequest content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingRequest record {|
    ConfirmBookingRequest content;
    map<string|string[]> headers;
|};

public type ContextConfirmBookingResponse record {|
    ConfirmBookingResponse content;
    map<string|string[]> headers;
|};

public type ContextPropertyResponse record {|
    PropertyResponse content;
    map<string|string[]> headers;
|};

public type ContextAdminRequest record {|
    AdminRequest content;
    map<string|string[]> headers;
|};

public type ContextPropertyList record {|
    PropertyList content;
    map<string|string[]> headers;
|};

public type ContextUserCreationResponse record {|
    UserCreationResponse content;
    map<string|string[]> headers;
|};

public type ContextRemovePropertyRequest record {|
    RemovePropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextRegisterUserResponse record {|
    RegisterUserResponse content;
    map<string|string[]> headers;
|};

public type ContextPropertyFilter record {|
    PropertyFilter content;
    map<string|string[]> headers;
|};

public type ContextPropertySearchResponse record {|
    PropertySearchResponse content;
    map<string|string[]> headers;
|};

public type ContextSearchPropertyRequest record {|
    SearchPropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextBookingList record {|
    BookingList content;
    map<string|string[]> headers;
|};

public type ContextUserList record {|
    UserList content;
    map<string|string[]> headers;
|};

public type ContextPropertyRequest record {|
    PropertyRequest content;
    map<string|string[]> headers;
|};

public type ContextUserRequest record {|
    UserRequest content;
    map<string|string[]> headers;
|};

public type ContextBookPropertyResponse record {|
    BookPropertyResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type BookPropertyRequest record {|
    string property_id = "";
    string user_id = "";
    string check_in = "";
    string check_out = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type LoginUserRequest record {|
    string user_id = "";
    string password = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type LoginUserResponse record {|
    boolean success = false;
    string message = "";
    string user_id = "";
    string name = "";
    string role = "";
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type UpdatePropertyRequest record {|
    string property_id = "";
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type RegisterUserRequest record {|
    string user_id = "";
    string name = "";
    string password = "";
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type ConfirmBookingRequest record {|
    string property_id = "";
    string user_id = "";
    string check_in = "";
    string check_out = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type ConfirmBookingResponse record {|
    boolean success = false;
    string message = "";
    string property_id = "";
    string user_id = "";
    string check_in = "";
    string check_out = "";
    int nights = 0;
    float total_price = 0.0;
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type PropertyResponse record {|
    string property_id = "";
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
    string host_id = "";
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type AdminRequest record {|
    string user_id = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type UserResponse record {|
    string user_id = "";
    string name = "";
    string role = "";
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type PropertyList record {|
    PropertyResponse[] properties = [];
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type UserCreationResponse record {|
    boolean success = false;
    int users_created = 0;
    string message = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type RemovePropertyRequest record {|
    string property_id = "";
    string host_id = "";
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type RegisterUserResponse record {|
    boolean success = false;
    string message = "";
    string user_id = "";
    string role = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type PropertyFilter record {|
    string location = "";
    float min_price = 0.0;
    float max_price = 0.0;
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type PropertySearchResponse record {|
    boolean available = false;
    string message = "";
    PropertyResponse property = {};
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type BookingResponse record {|
    string booking_id = "";
    string property_id = "";
    string property_name = "";
    string user_id = "";
    string user_name = "";
    string check_in = "";
    string check_out = "";
    string status = "";
    float total_price = 0.0;
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type SearchPropertyRequest record {|
    string property_id = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type BookingList record {|
    BookingResponse[] bookings = [];
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type UserList record {|
    UserResponse[] users = [];
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type PropertyRequest record {|
    string property_name = "";
    string location = "";
    string property_type = "";
    float price_per_night = 0.0;
    string status = "";
    string host_id = "";
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type UserRequest record {|
    string user_id = "";
    string name = "";
    string role = "";
    string region = "";
|};

@protobuf:Descriptor {value: RENTAL_ACCOMMODATION_DESC}
public type BookPropertyResponse record {|
    boolean success = false;
    string message = "";
    string property_id = "";
    string user_id = "";
    string check_in = "";
    string check_out = "";
|};
