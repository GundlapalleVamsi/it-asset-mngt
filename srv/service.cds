using {it.asset.service.db as db} from '../db/schema';

@impl: 'srv/asset-service.js'
service MyService1 {
    @restrict: [
        {
            grant: 'READ',
            to   : [
                'Asset.Read',
                'Asset.Manage',
                'Admin.All'
            ]
        },
        {
            grant: [
                'CREATE',
                'UPDATE',
                'DELETE'
            ],
            to   : [
                'Asset.Manage',
                'Admin.All'
            ]
        }
    ]
    entity Assets         as projection on db.Assets;

    @readonly
    @restrict: [{
        grant: 'READ',
        to   : [
            'Asset.Read',
            'Asset.Manage',
            'Admin.All'
        ]
    }]
    entity Employees      as
        projection on db.Employees {
            key ID,
                FullName,
                Department,
                Designation,
                Email,
                IsActive
        }

    @requires: [
        'Asset.Manage',
        'Admin.All'
    ]
    action   assignAsset(assetID: UUID, employeeID: UUID) returns String;

    @requires: [
        'Asset.Manage',
        'Admin.All'
    ]
    action   returnAsset(assetID: UUID)                   returns String;

    @requires: [
        'Asset.Read',
        'Asset.Manage',
        'Admin.All'
    ]
    function getAssetsByEmployee(employeeID: UUID)        returns array of Assets;

    @restrict: [
        {
            grant: 'READ',
            to   : ['Ticket.Read'],
            where: 'createdBy = $user'
        },
        {
            grant: 'READ',
            to   : ['Admin.All']
        },
        {
            grant: 'CREATE',
            to   : [
                'Ticket.Write',
                'Admin.All'
            ]
        }
    ]
    @odata.draft.enabled
    entity EmployeePortal as
        projection on db.ServiceRequests {
            *,
            virtual SLACriticality : Integer default 2
        };

    entity PriorityVH     as projection on db.PriorityVH;
    entity RequestTypeVH  as projection on db.RequestTypeVH;
    entity StatusVH       as projection on db.StatusVH;
    entity AssetTypeVH    as projection on db.AssetTypeVH;
    entity AssetStatusVH  as projection on db.AssetStatusVH;
    entity CategoryVH     as projection on db.CategoryVH;


    // In MyService1 — add this below the existing Assets entity
@readonly
@cds.redirection.target
entity AssetsVH as projection on db.Assets {
    key ID,
        AssetTag,
        AssetName,
        AssetType,
        Brand,
        Model,
        Status,
        CurrentLocation
};
}





@impl: 'srv/ticket-service.js'
service MyService2 {

    @Analytics.AggregatedProperty #totalTickets    : {
        Name                : 'totalTickets',
        AggregationMethod   : 'sum',
        AggregatableProperty: 'TotalTickets',
        ![@Common.Label]    : 'Total Tickets'
    }

    @Analytics.AggregatedProperty #breachedTickets : {
        Name                : 'breachedTickets',
        AggregationMethod   : 'sum',
        AggregatableProperty: 'BreachedTickets',
        ![@Common.Label]    : 'Breached Tickets'
    }

    @Analytics.AggregatedProperty #openTickets     : {
        Name                : 'openTickets',
        AggregationMethod   : 'sum',
        AggregatableProperty: 'OpenTickets',
        ![@Common.Label]    : 'Open Tickets'
    }

    @Analytics.AggregatedProperty #escalatedTickets: {
        Name                : 'escalatedTickets',
        AggregationMethod   : 'sum',
        AggregatableProperty: 'EscalatedTickets',
        ![@Common.Label]    : 'Escalated Tickets'
    }

    @Analytics.AggregatedProperty #criticalTickets : {
        Name                : 'criticalTickets',
        AggregationMethod   : 'sum',
        AggregatableProperty: 'CriticalTickets',
        ![@Common.Label]    : 'Critical Tickets'
    }

    @Aggregation.ApplySupported                    : {
        Transformations       : [
            'aggregate',
            'groupby',
            'filter',
            'orderby',
            'top',
            'skip',
            'search'
        ],
        Rollup                : #None,
        PropertyRestrictions  : true,
        GroupableProperties   : [
            Priority,
            Status,
            RequestType,
            Category
        ],
        AggregatableProperties: [
            {Property: TotalTickets},
            {Property: BreachedTickets},
            {Property: OpenTickets},
            {Property: EscalatedTickets},
            {Property: CriticalTickets}
        ]
    }

    entity TicketAnalytics as
        projection on db.TicketAnalytics {
            key Priority,
            key Status,
            key RequestType,
            key Category,

                @Aggregation.default: #COUNT
                TotalTickets,

                @Aggregation.default: #SUM
                BreachedTickets,

                @Aggregation.default: #SUM
                OpenTickets,

                @Aggregation.default: #SUM
                EscalatedTickets,

                @Aggregation.default: #SUM
                CriticalTickets
        };

    @restrict: [
        {
            grant: 'READ',
            to   : [
                'Ticket.Manage',
                'Admin.All'
            ]
        },
        {
            grant: 'CREATE',
            to   : [
                'Ticket.Write',
                'Admin.All'
            ]
        },
        {
            grant: [
                'UPDATE',
                'DELETE'
            ],
            to   : [
                'Ticket.Manage',
                'Admin.All'
            ]
        }
    ]
    @cds.redirection.target
    entity ServiceRequests as projection on db.ServiceRequests
        actions {
            @requires: [
                'Ticket.Manage',
                'Admin.All'
            ]
            action   assignTicket(agentID: UUID, agentName: String) returns String;

            @requires: [
                'Ticket.Manage',
                'Admin.All'
            ]
            action   resolveTicket(resolution: String)              returns String;

            @restrict: [
                'Ticket.Manage',
                'Admin.All'
            ]
            action   escalateTicket(reason: String)                 returns String;

            @requires: [
                'Ticket.Write',
                'Ticket.Manage',
                'Admin.All'
            ]
            action   closeTicket(feedback: String)                  returns String;

            @requires: [
                'Ticket.Manage',
                'Admin.All'
            ]
            function getBreachedSLAs()                              returns array of ServiceRequests;
        }

    @restrict: [
        {
            grant: 'READ',
            to   : [
                'Ticket.Write'
            ],
            where: 'createdBy = $user'
        },
        {
            grant: 'READ',
            to   : [
                'Ticket.Manage',
                'Admin.All'
            ]
        },
        {
            grant: 'CREATE',
            to   : [
                'Ticket.Write',
                'Ticket.Manage',
                'Admin.All'
            ]
        },
        {
            grant: [
                'UPDATE',
                'DELETE'
            ],
            to   : [
                'Ticket.Manage',
                'Admin.All'
            ]
        }
    ]
    entity Comments        as projection on db.Comments;

    @restrict: [
        {
            grant: 'READ',
            to   : [
                'Ticket.Manage',
                'Admin.All'
            ]
        },
        {
            grant: [
                'CREATE',
                'UPDATE',
                'DELETE'
            ],
            to   : [
                'Ticket.Manage',
                'Admin.All'
            ]
        }
    ]
    entity SLAConfig       as projection on db.SLAConfig;

    entity PriorityVH      as projection on db.PriorityVH;
    entity RequestTypeVH   as projection on db.RequestTypeVH;
    entity StatusVH        as projection on db.StatusVH;
    entity AssetTypeVH     as projection on db.AssetTypeVH;
    entity AssetStatusVH   as projection on db.AssetStatusVH;
    entity CategoryVH      as projection on db.CategoryVH;

    @readonly
    @requires: [
        'Ticket.Manage',
        'Admin.All'
    ]
    @cds.redirection.target
    entity Employees       as
        projection on db.Employees {
            key ID,
                FullName,
                Department,
                Designation,
                Email,
                IsActive
        };



          @requires: [
        'Ticket.Manage',
        'Admin.All'
    ]
    action checkSLABreaches() returns {
        message : String;
        count   : Integer;
    };
}
