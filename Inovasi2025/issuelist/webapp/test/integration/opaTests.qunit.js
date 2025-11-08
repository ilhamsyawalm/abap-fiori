sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'issuelist/issuelist/test/integration/FirstJourney',
		'issuelist/issuelist/test/integration/pages/IssueList',
		'issuelist/issuelist/test/integration/pages/IssueObjectPage'
    ],
    function(JourneyRunner, opaJourney, IssueList, IssueObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('issuelist/issuelist') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheIssueList: IssueList,
					onTheIssueObjectPage: IssueObjectPage
                }
            },
            opaJourney.run
        );
    }
);