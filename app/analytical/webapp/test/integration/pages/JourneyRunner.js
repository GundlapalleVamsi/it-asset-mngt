sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"analytical/test/integration/pages/TicketAnalyticsList",
	"analytical/test/integration/pages/TicketAnalyticsObjectPage"
], function (JourneyRunner, TicketAnalyticsList, TicketAnalyticsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('analytical') + '/test/flp.html#app-preview',
        pages: {
			onTheTicketAnalyticsList: TicketAnalyticsList,
			onTheTicketAnalyticsObjectPage: TicketAnalyticsObjectPage
        },
        async: true
    });

    return runner;
});

