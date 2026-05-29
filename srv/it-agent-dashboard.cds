using MyService2  as SalesService from '../srv/service';


annotate SalesService.TicketAnalytics:Priority with @(
  Common.Label                   : 'Priority',
  Common.ValueListWithFixedValues: true,
  Common.ValueList               : {
    $Type         : 'Common.ValueListType',
    CollectionPath: 'PriorityVH',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterOut',
        LocalDataProperty: Priority,
        ValueListProperty: 'Priority'
      }
    ]
  }
);
annotate SalesService.TicketAnalytics:Status with @(
  Common.Label                   : 'Status',
  Common.ValueListWithFixedValues: true,
  Common.ValueList               : {
    $Type         : 'Common.ValueListType',
    CollectionPath: 'StatusVH',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterOut',
        LocalDataProperty: Status,
        ValueListProperty: 'Status'
      }
    ]
  }
);
 
annotate SalesService.TicketAnalytics:RequestType with @(
  Common.Label                   : 'Request Type',
  Common.ValueListWithFixedValues: true,
  Common.ValueList               : {
    $Type         : 'Common.ValueListType',
    CollectionPath: 'RequestTypeVH',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterOut',
        LocalDataProperty: RequestType,
        ValueListProperty: 'RequestType'
      }
    ]
  }
);
 
annotate SalesService.TicketAnalytics:Category with @(
  Common.Label                   : 'Category',
  Common.ValueListWithFixedValues: true,
  Common.ValueList               : {
    $Type         : 'Common.ValueListType',
    CollectionPath: 'CategoryVH',
    Parameters    : [
      {
        $Type            : 'Common.ValueListParameterOut',
        LocalDataProperty: Category,
        ValueListProperty: 'Category'
      }
    ]
  }
);
 
annotate SalesService.TicketAnalytics:TotalTickets with @(
  Common.Label: 'Total Tickets'
);
 
annotate SalesService.TicketAnalytics:BreachedTickets with @(
  Common.Label: 'SLA Breached'
);
 
annotate SalesService.TicketAnalytics:OpenTickets with @(
  Common.Label: 'Open Tickets'
);
 
annotate SalesService.TicketAnalytics:EscalatedTickets with @(
  Common.Label: 'Escalated Tickets'
);
 
annotate SalesService.TicketAnalytics:CriticalTickets with @(
  Common.Label: 'Critical Tickets'
);
 
// ─────────────────────────────────────────
// MAIN ENTITY ANNOTATIONS
// ─────────────────────────────────────────
 
annotate SalesService.TicketAnalytics with @(
 
  // ── FILTER BAR ───────────────────────────
  UI.SelectionFields: [
    Priority,
    Status,
    RequestType,
    Category
  ],
 
  // ── CHART ────────────────────────────────
  UI.Chart: {
    $Type           : 'UI.ChartDefinitionType',
    Title           : 'Tickets by Priority',
    ChartType       : #Bar,
    Dimensions      : [ Priority ],
    DynamicMeasures : [
      '@Analytics.AggregatedProperty#totalTickets',
      '@Analytics.AggregatedProperty#breachedTickets',
      '@Analytics.AggregatedProperty#criticalTickets'
    ]
  },
 
  // ── LINE ITEM (Table) ─────────────────────
  UI.LineItem: [
    {
      $Type            : 'UI.DataField',
      Value            : Priority,
      Label            : 'Priority',
      ![@UI.Importance]: #High
    },
    {
      $Type            : 'UI.DataField',
      Value            : Status,
      Label            : 'Status',
      ![@UI.Importance]: #High
    },
    {
      $Type            : 'UI.DataField',
      Value            : RequestType,
      Label            : 'Request Type',
      ![@UI.Importance]: #High
    },
    {
      $Type            : 'UI.DataField',
      Value            : Category,
      Label            : 'Category',
      ![@UI.Importance]: #Medium
    },
    {
      $Type            : 'UI.DataField',
      Value            : TotalTickets,
      Label            : 'Total Tickets',
      ![@UI.Importance]: #High
    },
    {
      $Type            : 'UI.DataField',
      Value            : BreachedTickets,
      Label            : 'SLA Breached',
      ![@UI.Importance]: #High
    },
    {
      $Type            : 'UI.DataField',
      Value            : OpenTickets,
      Label            : 'Open Tickets',
      ![@UI.Importance]: #Medium
    },
    {
      $Type            : 'UI.DataField',
      Value            : EscalatedTickets,
      Label            : 'Escalated',
      ![@UI.Importance]: #Medium
    },
    {
      $Type            : 'UI.DataField',
      Value            : CriticalTickets,
      Label            : 'Critical',
      ![@UI.Importance]: #Medium
    }
  ],
 
  // ── HEADER INFO ───────────────────────────
  UI.HeaderInfo: {
    $Type         : 'UI.HeaderInfoType',
    TypeName      : 'Ticket',
    TypeNamePlural: 'Tickets',
    Title         : {
      $Type: 'UI.DataField',
      Value: Priority
    },
    Description   : {
      $Type: 'UI.DataField',
      Value: Status
    }
  },
 
  // ── FACETS ────────────────────────────────
  UI.Facets: [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'ClassificationFacet',
      Label : 'Classification',
      Target: '@UI.FieldGroup#Classification'
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'VolumeFacet',
      Label : 'Ticket Volumes',
      Target: '@UI.FieldGroup#Volumes'
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'SLAFacet',
      Label : 'SLA & Escalation',
      Target: '@UI.FieldGroup#SLA'
    }
  ],
 
  // ── FIELD GROUPS ──────────────────────────
  UI.FieldGroup #Classification: {
    $Type: 'UI.FieldGroupType',
    Label: 'Classification',
    Data : [
      { $Type: 'UI.DataField', Value: Priority,    Label: 'Priority'      },
      { $Type: 'UI.DataField', Value: Status,      Label: 'Status'        },
      { $Type: 'UI.DataField', Value: RequestType, Label: 'Request Type'  },
      { $Type: 'UI.DataField', Value: Category,    Label: 'Category'      }
    ]
  },
 
  UI.FieldGroup #Volumes: {
    $Type: 'UI.FieldGroupType',
    Label: 'Ticket Volumes',
    Data : [
      { $Type: 'UI.DataField', Value: TotalTickets,    Label: 'Total Tickets' },
      { $Type: 'UI.DataField', Value: OpenTickets,     Label: 'Open Tickets'  },
      { $Type: 'UI.DataField', Value: CriticalTickets, Label: 'Critical'      }
    ]
  },
 
  UI.FieldGroup #SLA: {
    $Type: 'UI.FieldGroupType',
    Label: 'SLA & Escalation',
    Data : [
      { $Type: 'UI.DataField', Value: BreachedTickets,   Label: 'SLA Breached' },
      { $Type: 'UI.DataField', Value: EscalatedTickets,  Label: 'Escalated'    }
    ]
  },
 
  UI.PresentationVariant: {
    $Type          : 'UI.PresentationVariantType',
    Visualizations : ['@UI.Chart', '@UI.LineItem'],
    SortOrder      : [{
      Property  : TotalTickets,
      Descending: true
    }]
  }
 
);