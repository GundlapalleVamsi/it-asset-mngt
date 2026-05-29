namespace it.asset.service.db;

using { cuid, managed } from '@sap/cds/common';

entity CategoryVH {
    key code : String(50);
}
entity PriorityVH {
    key code : String(30);
}

entity RequestTypeVH {
    key code : String(50);
}

entity StatusVH {
    key code : String(50);
}

entity AssetTypeVH {
    key code : String(50);
}

entity AssetStatusVH {
    key code : String(50);
}

type AssetType    : String enum {
    LAPTOP;
    DESKTOP;
    MOBILE;
    TABLET;
    MONITOR;
    PRINTER;
    SOFTWARE;
    SERVER;
    NETWORK_DEVICE;
    ACCESSORY;
}

type AssetStatus  : String enum {
    AVAILABLE;
    ASSIGNED;
    UNDER_REPAIR;
    RESERVED;
    RETIRED;
    LOST;
}

type RequestType  : String enum {
    INCIDENT;
    PROBLEM;
    CHANGE_REQUEST;
    SERVICE_REQUEST;
    ACCESS_REQUEST;
}

type Priority     : String enum {
    LOW;
    MEDIUM;
    HIGH;
    CRITICAL;
}

type TicketStatus : String enum {
    OPEN;
    IN_PROGRESS;
    PENDING;
    ON_HOLD;
    ESCALATED;
    RESOLVED;
    CLOSED;
    CANCELLED;
}

type Category : String enum {
    HARDWARE;
    SOFTWARE;
    NETWORK;
    ACCESS;
    SECURITY;
    INFRASTRUCTURE;
    EMAIL;
    PRINTER;
    VPN;
    DATABASE;
}

entity Employees : cuid, managed {
    EmployeeCode    : String(20);
    FirstName       : String(100);
    LastName        : String(100);
    FullName        : String(200);
    Email           : String(150);
    PhoneNumber     : String(20);
    Department      : String(100);
    Designation     : String(100);
    ManagerName     : String(100);
    Location        : String(100);
    WorkMode        : String(30);
    JoiningDate     : Date;
    IsActive        : Boolean;
    Assets          : Association to many Assets
                          on Assets.AssignedTo = $self;
    ReportedTickets : Association to many ServiceRequests
                          on ReportedTickets.Reporter = $self;
    AssignedTickets : Association to many ServiceRequests
                          on AssignedTickets.AssignedTo = $self;
}

entity Assets : cuid, managed {
    AssetTag            : String(50);
    AssetName           : String(150);
    AssetType           : AssetType;
    Category            : Category;
    Brand               : String(100);
    Model               : String(100);
    SerialNumber        : String(100);
    PurchaseDate        : Date;
    PurchasePrice       : Decimal(15, 2);
    VendorName          : String(150);
    InvoiceNumber       : String(100);
    WarrantyExpiry      : Date;
    OperatingSystem     : String(100);
    Processor           : String(100);
    RAMSize             : String(50);
    StorageCapacity     : String(50);
    IPAddress           : String(50);
    MACAddress          : String(50);
    AssignedDate        : Date;
    AssignedTo          : Association to Employees;
    Status              : AssetStatus @readonly;
    CurrentLocation     : String(100);
    LastMaintenanceDate : Date;
    NextMaintenanceDate : Date;
    AntivirusInstalled  : Boolean;
    EncryptionEnabled   : Boolean;
    AssetCondition      : String(50);
    Notes               : String(1000);
}

entity SLAConfig : cuid, managed {
    Priority        : Priority;
    ResponseHours   : Integer;
    ResolutionHours : Integer;
    EscalationHours : Integer;
    EscalationLevel : String(50);
    IsActive        : Boolean;
    Description     : String(255);
}

// @odata.draft.enabled
entity ServiceRequests : cuid, managed {
    TicketNumber       : String(30);
    RequestType        : RequestType;
    Title              : String(200);
    Description        : String(3000);
    Category           : String(100);
    SubCategory        : String(100);
    Priority           : Priority;
    Status             : TicketStatus default 'OPEN';
    Reporter           : Association to Employees;
    AssignedTo         : Association to Employees;
    AssignedTeam       : String(100);
    RelatedAsset       : Association to Assets;
    SLADeadline        : DateTime;
    FirstResponseAt    : DateTime;
    ResponseDue        : DateTime;
    ResolvedAt         : DateTime;
    ClosedAt           : DateTime;
    SLABreached        : Boolean;
    EscalationLevel    : String(50);
    EscalationReason   : String(500);
    EscalatedAt        : DateTime;
    ResolutionSummary  : String(2000);
    RootCause          : String(1000);
    WorkaroundProvided : Boolean;
    CustomerRating     : Integer;
    CustomerFeedback   : String(1000);
    Impact             : String(100);
    Urgency            : String(100);
    ReopenedCount      : Integer;
    IsVIPUser          : Boolean;
    SourceChannel      : String(50);
    Comments           : Composition of many Comments
                             on Comments.ServiceRequest = $self;
}

entity Comments : cuid, managed {
    ServiceRequest : Association to ServiceRequests;
    Author         : Association to Employees;
    CommentText    : String(3000);
    CommentType    : String(50);
    IsInternal     : Boolean;
    AttachmentURL  : String(500);
}

@Analytics.query: true
view TicketAnalytics as
    select from db.ServiceRequests {

        key Priority,
        key Status,
        key RequestType,
        key Category,

        @Aggregation.default: #COUNT
        count(*) as TotalTickets : Integer,

        @Aggregation.default: #SUM
        sum(case when SLABreached = true then 1 else 0 end) as BreachedTickets : Integer,

        @Aggregation.default: #SUM
        sum(case when Status = 'OPEN' then 1 else 0 end) as OpenTickets : Integer,

        @Aggregation.default: #SUM
        sum(case when Status = 'ESCALATED' then 1 else 0 end) as EscalatedTickets : Integer,

        @Aggregation.default: #SUM
        sum(case when Priority = 'CRITICAL' then 1 else 0 end) as CriticalTickets : Integer

    }
    group by
        Priority,
        Status,
        RequestType,
        Category;