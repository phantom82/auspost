@isTest
private class caseIntegrationServiceBatch_Tests {
    @TestSetup
    static void makeData(){
        List<Case> caseList = TestDataFactory.createCaseWithStatus(50, 'New');
        caseList = TestDataFactory.updateCaseStatus(caseList, caseTriggerHandler.CLOSED_CASE);
        system.debug('integration records size'+[Select id from Apex_Callout__c].size());
    }
    
    @IsTest
    static void test(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new integrationServiceHttpCalloutMock()); 
            caseIntegrationServiceBatch iService = new caseIntegrationServiceBatch();
            Database.executeBatch(iService, 50);
        Test.stopTest();
    }
}
