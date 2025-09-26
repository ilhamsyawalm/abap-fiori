sap.ui.define(['sap/fe/test/ListReport'], function(ListReport) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ListReport(
        {
            appId: 'issuelistv4',
            componentId: 'IssueList',
            contextPath: '/Issue'
        },
        CustomPageDefinitions
    );
});