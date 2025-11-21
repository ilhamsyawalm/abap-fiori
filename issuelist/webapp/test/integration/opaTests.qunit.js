sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'sharingknownledge/issuelist/test/integration/FirstJourney',
		'sharingknownledge/issuelist/test/integration/pages/IssueList',
		'sharingknownledge/issuelist/test/integration/pages/IssueObjectPage'
    ],
    function(JourneyRunner, opaJourney, IssueList, IssueObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('sharingknownledge/issuelist') + '/index.html'
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