@isTest
private class integrationServiceBatch_Tests {
    @TestSetup
    static void makeData(){
        List<Case> caseList = TestDataFactory.createCaseWithStatus(100, 'New');
        List<Apex_Callout__c> calloutList = TestDataFactory.createIntegrationServiceRecord(caseList);
    }
    
    @IsTest
    static void test(){
        Test.startTest();
            integrationServiceBatch iService = new integrationServiceBatch();
            Database.executeBatch(iService, 5);
        Test.stopTest();
    }
}
