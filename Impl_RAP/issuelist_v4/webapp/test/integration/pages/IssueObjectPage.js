sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'issuelistv4',
            componentId: 'IssueObjectPage',
            contextPath: '/Issue'
        },
        CustomPageDefinitions
    );
});