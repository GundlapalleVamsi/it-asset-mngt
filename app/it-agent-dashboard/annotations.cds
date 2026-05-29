using MyService2 as ticket from '../../srv/service';

annotate ticket.ServiceRequests with @(UI.SelectionPresentationVariant: {
    SelectionVariant   : {SelectOptions: []},
    PresentationVariant: {
        SortOrder     : [{
            $Type     : 'Common.SortOrderType',
            Property  : createdAt,
            Descending: false
        }],
        Visualizations: ['@UI.LineItem']
    }
});

annotate ticket.ServiceRequests with @(
    UI.HeaderInfo                                 : {
        TypeName      : 'Service Request',
        TypeNamePlural: 'Service Requests',
        Title         : {
            $Type: 'UI.DataField',
            Value: TicketNumber
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: Title
        },
        TypeImageUrl  : 'sap-icon://laptop'
    },

    UI.HeaderFacets                               : [
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#SLAStatus',
            ID    : 'SLAStatusFacet'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#PriorityKPI',
            ID    : 'PriorityFacet'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#EscalationKPI',
            ID    : 'EscalationFacet'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#CustomerRating',
            ID    : 'RatingFacet'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#TicketStatus',
            ID    : 'TicketStatus'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Target: '@UI.DataPoint#Category',
            ID    : 'Category'
        }

    ],

    UI.DataPoint #SLAStatus                       : {
        Title       : 'SLA Status',
        Value       : SLABreached,
        // Red tile if breached, green if within SLA
        Criticality : (SLABreached = true ? 1 : 3)
    },

    UI.DataPoint #PriorityKPI                     : {
        Title       : 'Priority',
        Value       : Priority,
        Criticality : (Priority = 'CRITICAL' ? 1 : Priority = 'HIGH' ? 2 : Priority = 'MEDIUM' ? 3 : Priority = 'LOW' ? 5 : 0)
    },

    UI.DataPoint #EscalationKPI                   : {
        Title       : 'Escalation Level',
        Value       : EscalationLevel,
        // Escalated tickets show warning colour
        Criticality : (EscalationLevel > 0 ? 2 : 5)
    },

    UI.DataPoint #CustomerRating                  : {
        Title        : 'Customer Rating',
        Value        : CustomerRating,
        TargetValue  : 5,
        Visualization: #Rating
    },
    UI.DataPoint #TicketStatus                    : {
        Value       : Status,
        Title       : 'Current Status',
        Criticality : (Status = 'RESOLVED' ? 3 : Status = 'CLOSED' ? 3 : Status = 'CANCELLED' ? 0 : Status = 'ESCALATED' ? 1 : Status = 'ON_HOLD' ? 1 : Status = 'OPEN' ? 2 : Status = 'IN_PROGRESS' ? 2 : Status = 'PENDING' ? 2 : 0)
    },
    UI.DataPoint #Category                        : {
        Value: Category,
        Title: 'Category'
    },

    UI.LineItem                                   : [

        {
            $Type            : 'UI.DataField',
            Value            : TicketNumber,
            Label            : 'Ticket No',
            ![@UI.Importance]: #High
        },
        {
            $Type            : 'UI.DataField',
            Value            : Title,
            Label            : 'Title',
            ![@UI.Importance]: #High
        },
        {
            $Type            : 'UI.DataField',
            Value            : RequestType,
            Label            : 'Type',
            ![@UI.Importance]: #Medium
        },
        {
            $Type            : 'UI.DataField',
            Value            : Category,
            Label            : 'Category',
            ![@UI.Importance]: #Low
        },

        {
            $Type            : 'UI.DataField',
            Value            : Priority,
            Label            : 'Priority',
            Criticality      : (Priority = 'CRITICAL' ? 1 : Priority = 'HIGH' ? 2 : Priority = 'MEDIUM' ? 3 : Priority = 'LOW' ? 5 : 0),
            ![@UI.Importance]: #High
        },

        {
            $Type            : 'UI.DataField',
            Value            : Status,
            Label            : 'Status',
            Criticality      : (Status = 'ESCALATED' ? 1 : Status = 'OPEN' ? 2 : Status = 'IN_PROGRESS' ? 3 : Status = 'RESOLVED' ? 5 : Status = 'CLOSED' ? 5 : 0),
            ![@UI.Importance]: #High
        },

        {
            $Type            : 'UI.DataField',
            Value            : SLADeadline,
            Label            : 'SLA Deadline',
            ![@UI.Importance]: #High
        },
        {
            $Type            : 'UI.DataField',
            Value            : SLABreached,
            Label            : 'SLA Breached',
            Criticality      : (SLABreached = true ? 1 : 3),
            ![@UI.Importance]: #High
        },
        {
            $Type            : 'UI.DataField',
            Value            : ResponseDue,
            Label            : 'Response Due',
            ![@UI.Importance]: #Medium
        },

        {
            $Type            : 'UI.DataField',
            Value            : AssignedTeam,
            Label            : 'Assigned Team',
            ![@UI.Importance]: #Medium
        },

        {
            $Type            : 'UI.DataField',
            Value            : EscalationLevel,
            Label            : 'Escalation',
            Criticality      : (EscalationLevel > 0 ? 2 : 5),
            ![@UI.Importance]: #Low
        },

        {
            $Type : 'UI.DataFieldForAction',
            Action: 'MyService2.assignTicket',
            Label : 'Assign'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'MyService2.resolveTicket',
            Label : 'Resolve'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'MyService2.escalateTicket',
            Label : 'Escalate'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'MyService2.closeTicket',
            Label : 'Close'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'MyService2.getBreachedSLAs',
            Label : 'Check SLABreached'
        },
    ],

    UI.SelectionFields                            : [
        Status,
        Priority,
        SLABreached,
        RequestType,
        Category,
    ],
    UI.PresentationVariant                        : {
        SortOrder     : [
            {
                $Type     : 'Common.SortOrderType',
                Property  : SLABreached,
                Descending: true
            },
            {
                $Type     : 'Common.SortOrderType',
                Property  : Priority,
                Descending: false
            },
            {
                $Type     : 'Common.SortOrderType',
                Property  : SLADeadline,
                Descending: false
            }
        ],
        Visualizations: ['@UI.LineItem']
    },
    UI.SelectionPresentationVariant #AgentWorklist: {
        Text               : 'Agent Worklist — Breached First',
        SelectionVariant   : {SelectOptions: [{
            PropertyName: Status,
            Ranges      : [
                {
                    $Type : 'UI.SelectionRangeType',
                    Sign  : #I,
                    Option: #EQ,
                    Low   : 'OPEN'
                },
                {
                    $Type : 'UI.SelectionRangeType',
                    Sign  : #I,
                    Option: #EQ,
                    Low   : 'IN_PROGRESS'
                },
                {
                    $Type : 'UI.SelectionRangeType',
                    Sign  : #I,
                    Option: #EQ,
                    Low   : 'ESCALATED'
                }
            ]
        }]},
        PresentationVariant: {
            SortOrder     : [
                {
                    $Type     : 'Common.SortOrderType',
                    Property  : SLABreached,
                    Descending: true
                },
                {
                    $Type     : 'Common.SortOrderType',
                    Property  : SLADeadline,
                    Descending: false
                }
            ],
            Visualizations: ['@UI.LineItem']
        }
    },

    UI.FieldGroup #RaiseTicket                    : {
        Label: 'Request Details',
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
                Value: SubCategory,
                Label: 'Sub Category'
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
            {
                $Type: 'UI.DataField',
                Value: Urgency,
                Label: 'Urgency'
            },
            {
                $Type: 'UI.DataField',
                Value: SourceChannel,
                Label: 'Source Channel'
            },
            {
                $Type: 'UI.DataField',
                Value: IsVIPUser,
                Label: 'VIP User'
            }
        ]
    },

    UI.FieldGroup #AssignmentDetails              : {
        Label: 'Assignment & Agent',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: AssignedTeam,
                Label: 'Assigned Team'
            },
            {
                $Type : 'UI.DataFieldForAction',
                Action: 'MyService2.assignTicket',
                Label : 'Re-assign Agent'
            },
            {
                $Type : 'UI.DataFieldForAction',
                Action: 'MyService2.escalateTicket',
                Label : 'Escalate Ticket'
            },
            {
                $Type: 'UI.DataField',
                Value: EscalationLevel,
                Label: 'Escalation Level'
            },
            {
                $Type: 'UI.DataField',
                Value: EscalatedAt,
                Label: 'Escalated At'
            }
        ]
    },

    UI.FieldGroup #StatusSLA                      : {
        Label: 'SLA & Response Tracking',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: Status,
                Label: 'Status'
            },
            {
                $Type: 'UI.DataField',
                Value: SLADeadline,
                Label: 'SLA Deadline'
            },
            {
                $Type: 'UI.DataField',
                Value: ResponseDue,
                Label: 'Response Due'
            },
            {
                $Type: 'UI.DataField',
                Value: FirstResponseAt,
                Label: 'First Response At'
            },
            {
                $Type       : 'UI.DataField',
                Value       : SLABreached,
                Label       : 'SLA Breached',
                Criticality : (SLABreached = true ? 1 : 3)
            }
        ]
    },

    UI.FieldGroup #Resolution                     : {
        Label: 'Resolution Details',
        Data : [
            {
                $Type : 'UI.DataFieldForAction',
                Action: 'MyService2.resolveTicket',
                Label : 'Mark as Resolved'
            },
            {
                $Type : 'UI.DataFieldForAction',
                Action: 'MyService2.closeTicket',
                Label : 'Close Ticket'
            },
            {
                $Type: 'UI.DataField',
                Value: ResolvedAt,
                Label: 'Resolved At'
            },
            {
                $Type: 'UI.DataField',
                Value: ResolutionSummary,
                Label: 'Resolution Summary'
            },
            {
                $Type: 'UI.DataField',
                Value: RootCause,
                Label: 'Root Cause'
            },
            {
                $Type: 'UI.DataField',
                Value: WorkaroundProvided,
                Label: 'Workaround Provided'
            }
        ]
    },

    UI.FieldGroup #CustomerFeedback               : {
        Label: 'Customer Satisfaction',
        Data : [
            {
                $Type : 'UI.DataFieldForAnnotation',
                Target: '@UI.DataPoint#CustomerRating',
                Label : 'Rating'
            },
            {
                $Type: 'UI.DataField',
                Value: CustomerFeedback,
                Label: 'Customer Feedback'
            }
        ]
    },

    UI.FieldGroup #AuditInfo                      : {
        Label: 'Audit Information',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: createdAt,
                Label: 'Created At'
            },
            {
                $Type: 'UI.DataField',
                Value: createdBy,
                Label: 'Created By'
            },
            {
                $Type: 'UI.DataField',
                Value: modifiedAt,
                Label: 'Last Modified'
            },
            {
                $Type: 'UI.DataField',
                Value: modifiedBy,
                Label: 'Modified By'
            },
            {
                $Type: 'UI.DataField',
                Value: ReopenedCount,
                Label: 'Reopened Count'
            }
        ]
    },
    UI.Facets                                     : [

        {
            $Type : 'UI.CollectionFacet',
            Label : 'Request Details',
            ID    : 'RequestTab',
            Facets: [{
                $Type : 'UI.ReferenceFacet',
                Label : 'Ticket Information',
                Target: '@UI.FieldGroup#RaiseTicket',
                ID    : 'TicketInfoSection'
            }]
        },

        {
            $Type : 'UI.CollectionFacet',
            Label : 'Assignment & SLA',
            ID    : 'AssignmentTab',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Agent Assignment',
                    Target: '@UI.FieldGroup#AssignmentDetails',
                    ID    : 'AssignmentSection'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'SLA Tracking',
                    Target: '@UI.FieldGroup#StatusSLA',
                    ID    : 'SLASection'
                }
            ]
        },

        {
            $Type : 'UI.CollectionFacet',
            Label : 'Resolution',
            ID    : 'ResolutionTab',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Resolution Details',
                    Target: '@UI.FieldGroup#Resolution',
                    ID    : 'ResolutionSection'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Customer Feedback',
                    Target: '@UI.FieldGroup#CustomerFeedback',
                    ID    : 'FeedbackSection'
                }
            ]
        },

        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Comments & Activity Log',
            Target: 'Comments/@UI.LineItem',
            ID    : 'CommentsTab'
        },

        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Audit Info',
            Target: '@UI.FieldGroup#AuditInfo',
            ID    : 'AuditTab'
        }
    ]
);

annotate ticket.ServiceRequests with {
    TicketNumber       @readonly           @title: 'Ticket Number';
    Status             @readonly           @title: 'Status';
    SLADeadline        @readonly           @title: 'SLA Deadline';
    ResponseDue        @readonly           @title: 'Response Due';
    AssignedTeam       @readonly           @title: 'Assigned Team';
    SLABreached        @readonly           @title: 'SLA Breached';
    ResolvedAt         @readonly           @title: 'Resolved At';
    EscalationLevel    @readonly           @title: 'Escalation Level';
    EscalatedAt        @readonly           @title: 'Escalated At';
    FirstResponseAt    @readonly           @title: 'First Response At';
    ReopenedCount      @readonly           @title: 'Reopened Count';
    ResolutionSummary  @readonly           @title: 'Resolution Summary'  @UI.MultiLineText;
    RootCause          @readonly           @title: 'Root Cause'          @UI.MultiLineText;

    RequestType        @mandatory          @title: 'Request Type';
    Title              @mandatory          @title: 'Title';
    Description        @mandatory          @title: 'Description'         @UI.MultiLineText;
    Priority           @mandatory          @title: 'Priority';
    Category           @title: 'Category';
    SubCategory        @title: 'Sub Category';
    Impact             @title: 'Impact';
    Urgency            @title: 'Urgency';
    SourceChannel      @title: 'Source Channel';
    IsVIPUser          @title: 'VIP User';

    CustomerRating     @title: 'Rating (1–5)';
    CustomerFeedback   @title: 'Feedback'  @UI.MultiLineText;
};


annotate ticket.ServiceRequests with {

    Status       @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'StatusVH',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: Status,
                ValueListProperty: 'Status'
            }]
        }
    );

    Priority     @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'PriorityVH',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: Priority,
                ValueListProperty: 'Priority'
            }]
        }
    );

    RequestType  @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'RequestTypeVH',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: RequestType,
                ValueListProperty: 'RequestType'
            }]
        }
    );

    Category     @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'CategoryVH',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: Category,
                ValueListProperty: 'Category'
            }]
        }
    );

    SubCategory  @(
        Common.ValueListWithFixedValues: false,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'SubCategoryVH',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterFilterOnly',
                    ValueListProperty: 'Category'
                },
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: SubCategory,
                    ValueListProperty: 'SubCategory'
                }
            ]
        }
    );

    AssignedTeam @(
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'TeamsVH',
            Parameters    : [{
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: AssignedTeam,
                ValueListProperty: 'TeamName'
            }]
        }
    );
};


annotate ticket.ServiceRequests actions {

    assignTicket(agentID     @(
        title                          : 'Select Agent',
        Common.ValueListWithFixedValues: false,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Employees',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: agentID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'FullName'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Department'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'Designation'
                }
            ]
        }
    )
    );

    resolveTicket(resolution @(
        title              : 'Resolution Summary',
        UI.MultiLineText   : true,
        Common.FieldControl: #Mandatory
    )
    );

    escalateTicket(reason    @(
        title              : 'Escalation Reason',
        UI.MultiLineText   : true,
        Common.FieldControl: #Mandatory
    )
    );
};

annotate ticket.Comments with @(

    UI.HeaderInfo                  : {
        TypeName      : 'Comment',
        TypeNamePlural: 'Comments',
        Title         : {
            $Type: 'UI.DataField',
            Value: ID
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: CommentType
        }
    },
    UI.QuickViewFacets             : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Posted By Info',
        Target: '@UI.FieldGroup#QuickViewComment'
    }],
    UI.FieldGroup #QuickViewComment: {Data: [
        {
            $Type: 'UI.DataField',
            Value: createdBy,
            Label: 'Posted By'
        },
        {
            $Type: 'UI.DataField',
            Value: createdAt,
            Label: 'Posted At'
        },
        {
            $Type: 'UI.DataField',
            Value: CommentType,
            Label: 'Comment Type'
        },
        {
            $Type: 'UI.DataField',
            Value: IsInternal,
            Label: 'Internal Only'
        }
    ]},

    UI.LineItem                    : [
        {
            $Type            : 'UI.DataField',
            Value            : CommentText,
            Label            : 'Comment',
            ![@UI.Importance]: #High
        },
        {
            $Type            : 'UI.DataField',
            Value            : CommentType,
            Label            : 'Type',
            ![@UI.Importance]: #High
        },
        {
            $Type            : 'UI.DataField',
            Value            : IsInternal,
            Label            : 'Internal Only',
            ![@UI.Importance]: #Medium
        },
        {
            $Type            : 'UI.DataField',
            Value            : AttachmentURL,
            Label            : 'Attachment',
            ![@UI.Importance]: #Low
        },
        {
            $Type            : 'UI.DataField',
            Value            : createdBy,
            Label            : 'Posted By',
            ![@UI.Importance]: #High
        },
        {
            $Type            : 'UI.DataField',
            Value            : createdAt,
            Label            : 'Posted At',
            ![@UI.Importance]: #High
        }
    ],

    UI.FieldGroup #CommentForm     : {
        Label: 'Add Comment',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: CommentText,
                Label: 'Comment'
            },
            {
                $Type: 'UI.DataField',
                Value: CommentType,
                Label: 'Comment Type'
            },
            {
                $Type: 'UI.DataField',
                Value: IsInternal,
                Label: 'Internal Only'
            },
            {
                $Type: 'UI.DataField',
                Value: AttachmentURL,
                Label: 'Attachment URL'
            }
        ]
    },

    UI.Facets                      : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Comment Details',
        Target: '@UI.FieldGroup#CommentForm'
    }]
);

annotate ticket.Comments with {
    CommentText   @mandatory  @title: 'Comment'  @UI.MultiLineText;
    CommentType   @title: 'Comment Type';
    IsInternal    @title: 'Internal Only';
    AttachmentURL @title: 'Attachment URL';
};

annotate ticket.Employees with @(

    UI.HeaderInfo     : {
        TypeName      : 'Employee',
        TypeNamePlural: 'Employees',
        Title         : {
            $Type: 'UI.DataField',
            Value: FullName
        }
    },

    UI.LineItem       : [
        {
            $Type: 'UI.DataField',
            Value: FullName,
            Label: 'Full Name'
        },
        {
            $Type: 'UI.DataField',
            Value: Department,
            Label: 'Department'
        },
        {
            $Type: 'UI.DataField',
            Value: Designation,
            Label: 'Designation'
        },
        {
            $Type: 'UI.DataField',
            Value: Email,
            Label: 'Email'
        },
        {
            $Type: 'UI.DataField',
            Value: Location,
            Label: 'Location'
        }
    ],

    UI.SelectionFields: [
        Department,
        Designation
    ]
);

annotate ticket.Employees with {
    FullName    @title: 'Full Name';
    Department  @title: 'Department';
    Designation @title: 'Designation';
    Email       @title: 'Email';
};
