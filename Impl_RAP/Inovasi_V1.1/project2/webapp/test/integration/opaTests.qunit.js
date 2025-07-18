sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'project2/test/integration/FirstJourney',
		'project2/test/integration/pages/IssueList',
		'project2/test/integration/pages/IssueObjectPage'
    ],
    function(JourneyRunner, opaJourney, IssueList, IssueObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('project2') + '/index.html'
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