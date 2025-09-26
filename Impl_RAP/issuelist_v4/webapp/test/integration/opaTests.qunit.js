sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'issuelistv4/test/integration/FirstJourney',
		'issuelistv4/test/integration/pages/IssueList',
		'issuelistv4/test/integration/pages/IssueObjectPage'
    ],
    function(JourneyRunner, opaJourney, IssueList, IssueObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('issuelistv4') + '/index.html'
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