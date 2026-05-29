using MyService1 as service from '../../srv/service';

annotate service.EmployeePortal with @(

    UI.DataPoint #SLARemaining : {
        Value      : SLADeadline,
        Title      : 'SLA Deadline',
        Criticality: SLACriticality
    },

    UI.DataPoint #Priority     : {
        Value       : Priority,
        Title       : 'Priority',
        Criticality : (Priority = 'LOW' ? 3 : Priority = 'MEDIUM' ? 2 : Priority = 'HIGH' ? 1 : Priority = 'CRITICAL' ? 1 : 0)
    },

    UI.DataPoint #TicketStatus : {
        Value       : Status,
        Title       : 'Current Status',
        Criticality : (Status = 'RESOLVED' ? 3 : Status = 'CLOSED' ? 3 : Status = 'CANCELLED' ? 0 : Status = 'ESCALATED' ? 1 : Status = 'ON_HOLD' ? 1 : Status = 'OPEN' ? 2 : Status = 'IN_PROGRESS' ? 2 : Status = 'PENDING' ? 2 : 0)
    },

    UI.HeaderFacets            : [
        {
            $Type        : 'UI.ReferenceFacet',
            Target       : '@UI.DataPoint#SLARemaining',
            ![@UI.Hidden]: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'IsActiveEntity'},
                    false
                ]},
                true,
                false
            ]}}
        },
        {
            $Type        : 'UI.ReferenceFacet',
            Target       : '@UI.DataPoint#Priority',
            ![@UI.Hidden]: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'IsActiveEntity'},
                    false
                ]},
                true,
                false
            ]}}
        },
        {
            $Type        : 'UI.ReferenceFacet',
            Target       : '@UI.DataPoint#TicketStatus',
            ![@UI.Hidden]: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'IsActiveEntity'},
                    false
                ]},
                true,
                false
            ]}}
        }
    ]

);

annotate service.EmployeePortal with @(
    UI.SelectionPresentationVariant: {PresentationVariant: {SortOrder: [{
        Property  : createdAt,
        Descending: true
    }]}},

    UI.PresentationVariant         : {SortOrder: [{
        Property  : createdAt,
        Descending: true
    }]}
);

annotate service.EmployeePortal with @(
    UI.HeaderInfo              : {
        TypeName      : 'My Ticket',
        TypeNamePlural: 'My Tickets',
        Title         : {
            $Type: 'UI.DataField',
            Value: TicketNumber
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: Title
        },
        TypeImageUrl  : 'sap-icon://e-learning'
    },

    UI.LineItem                : [
        {
            $Type: 'UI.DataField',
            Label: 'Ticket Number',
            Value: TicketNumber
        },
        {
            $Type: 'UI.DataField',
            Label: 'Title',
            Value: Title
        },
        {
            $Type: 'UI.DataField',
            Label: 'Request Type',
            Value: RequestType
        },
        {
            $Type       : 'UI.DataField',
            Label       : 'Priority',
            Value       : Priority,
            Criticality : (Priority = 'LOW' ? 3 : Priority = 'MEDIUM' ? 2 : Priority = 'HIGH' ? 1 : Priority = 'CRITICAL' ? 1 : 0)
        },
        {
            $Type       : 'UI.DataField',
            Label       : 'Status',
            Value       : Status,
            Criticality : (Status = 'OPEN' ? 2 : Status = 'IN_PROGRESS' ? 2 : Status = 'PENDING' ? 2 : Status = 'ON_HOLD' ? 1 : Status = 'ESCALATED' ? 1 : Status = 'RESOLVED' ? 3 : Status = 'CLOSED' ? 3 : Status = 'CANCELLED' ? 0 : 0)
        },
        {
            $Type: 'UI.DataField',
            Label: 'Created At',
            Value: createdAt
        }
    ],

    UI.SelectionFields         : [
        Priority,
        RequestType,
        Category
    ],

    UI.FieldGroup #RaiseTicket : {
        Label: 'Raise Service Request',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: RequestType,
                Label: 'Request Type'
            },
            {
                $Type: 'UI.DataField',
                Value: Title,
                Label: 'Title'
            },
            {
                $Type: 'UI.DataField',
                Value: Description,
                Label: 'Description'
            },
            {
                $Type: 'UI.DataField',
                Value: Category,
                Label: 'Category'
            },
            {
                $Type: 'UI.DataField',
                Value: Priority,
                Label: 'Priority'
            },
            {
                $Type: 'UI.DataField',
                Value: Impact,
                Label: 'Impact'
            },
            // NEW — lets employee link an asset when raising the ticket
            {
                $Type: 'UI.DataField',
                Value: RelatedAsset_ID,
                Label: 'Related Asset'
            }
        ]
    },

    UI.FieldGroup #TicketStatus: {
        Label: 'Ticket Status',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: Status,
                Label: 'Current Status'
            },
            {
                $Type: 'UI.DataField',
                Value: AssignedTeam,
                Label: 'Assigned Team'
            },
            {
                $Type: 'UI.DataField',
                Value: SLADeadline,
                Label: 'SLA Deadline'
            }
        ]
    },

    UI.FieldGroup #AssetDetails: {
        Label: 'Asset Details',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: RelatedAsset.AssetTag,
                Label: 'Asset Tag'
            },
            {
                $Type: 'UI.DataField',
                Value: RelatedAsset.AssetName,
                Label: 'Asset Name'
            },
            {
                $Type: 'UI.DataField',
                Value: RelatedAsset.AssetType,
                Label: 'Asset Type'
            },
            {
                $Type: 'UI.DataField',
                Value: RelatedAsset.Brand,
                Label: 'Brand'
            },
            {
                $Type: 'UI.DataField',
                Value: RelatedAsset.Model,
                Label: 'Model'
            },
            {
                $Type: 'UI.DataField',
                Value: RelatedAsset.Status,
                Label: 'Asset Status'
            }
        ]
    },

    UI.Facets                  : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Raise Ticket',
            Target: '@UI.FieldGroup#RaiseTicket'
        },
        {
            $Type        : 'UI.ReferenceFacet',
            Label        : 'Ticket Status',
            Target       : '@UI.FieldGroup#TicketStatus',
            ![@UI.Hidden]: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'IsActiveEntity'},
                    false
                ]},
                true,
                false
            ]}}
        },
        {
            $Type        : 'UI.ReferenceFacet',
            Label        : 'Related Asset',
            Target       : '@UI.FieldGroup#AssetDetails',
            ![@UI.Hidden]: {$edmJson: {$If: [
                {$Eq: [
                    {$Path: 'IsActiveEntity'},
                    false
                ]},
                true,
                false
            ]}}
        }
    ]
);

annotate service.EmployeePortal with {

    Priority        @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'PriorityVH',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: Priority,
                ValueListProperty: 'code'
            }]
        }
    );

    RequestType     @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'RequestTypeVH',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: RequestType,
                ValueListProperty: 'code'
            }]
        }
    );

    Status          @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'StatusVH',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterOut',
                LocalDataProperty: Status,
                ValueListProperty: 'code'
            }]
        }
    );

    Category        @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'CategoryVH',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: Category,
                ValueListProperty: 'code'
            }]
        }
    );

    // NEW — value help popup shows AssetTag, AssetName, AssetType when picking an asset
    RelatedAsset_ID @(
        Common.Label                   : 'Related Asset',
        Common.ValueListWithFixedValues: false,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'AssetsVH',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: RelatedAsset_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'AssetTag'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'AssetName'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'AssetType'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Brand'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Model'
                }
            ]
        }
    );
};

annotate service.Assets with @(

    UI.Identification: [
        {
            $Type: 'UI.DataField',
            Label: 'Asset Tag',
            Value: AssetTag
        },
        {
            $Type: 'UI.DataField',
            Label: 'Asset Type',
            Value: AssetType
        },
        {
            $Type: 'UI.DataField',
            Label: 'Asset Name',
            Value: AssetName
        },
        {
            $Type: 'UI.DataField',
            Label: 'Brand',
            Value: Brand
        },

        
        {
            $Type: 'UI.DataField',
            Label: 'Model',
            Value: Model
        },
        {
            $Type: 'UI.DataField',
            Label: 'Status',
            Value: Status
        },
        {
            $Type: 'UI.DataField',
            Label: 'Warranty Expiry',
            Value: WarrantyExpiry
        }
    ]
);

annotate service.Assets with {
    AssetTag       @(Common.Label: 'Asset Tag');
    AssetName      @(Common.Label: 'Asset Name');
    AssetType      @(Common.Label: 'Asset Type');
    Brand          @(Common.Label: 'Brand');
    Model          @(Common.Label: 'Model');
    Status         @(Common.Label: 'Status');
    PurchaseDate   @(Common.Label: 'Purchase Date');
    WarrantyExpiry @(Common.Label: 'Warranty Expiry');
};