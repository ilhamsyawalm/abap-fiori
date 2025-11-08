sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'issuelist.issuelist',
            componentId: 'IssueObjectPage',
            contextPath: '/Issue'
        },
        CustomPageDefinitions
    );
});