sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"employeeportal/test/integration/pages/EmployeePortalList",
	"employeeportal/test/integration/pages/EmployeePortalObjectPage"
], function (JourneyRunner, EmployeePortalList, EmployeePortalObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('employeeportal') + '/test/flp.html#app-preview',
        pages: {
			onTheEmployeePortalList: EmployeePortalList,
			onTheEmployeePortalObjectPage: EmployeePortalObjectPage
        },
        async: true
    });

    return runner;
});

