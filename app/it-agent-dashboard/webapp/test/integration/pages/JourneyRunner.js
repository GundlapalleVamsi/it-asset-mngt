sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"itagentdashboard/test/integration/pages/ServiceRequestsList",
	"itagentdashboard/test/integration/pages/ServiceRequestsObjectPage"
], function (JourneyRunner, ServiceRequestsList, ServiceRequestsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('itagentdashboard') + '/test/flp.html#app-preview',
        pages: {
			onTheServiceRequestsList: ServiceRequestsList,
			onTheServiceRequestsObjectPage: ServiceRequestsObjectPage
        },
        async: true
    });

    return runner;
});

