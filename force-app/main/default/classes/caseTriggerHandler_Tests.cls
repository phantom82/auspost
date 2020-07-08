@isTest
private class caseTriggerHandler_Tests {
    @TestSetup
    static void makeData(){
        List<Case> caseList = TestDataFactory.createCaseWithStatus(100, 'New');
    }
    
    @IsTest
    static void test(){
        List<Case> caseList = new List<Case>();
        Test.startTest();
            for(Case c : [Select Id, Status from Case]) {
                c.Status = caseTriggerHandler.CLOSED_CASE;
                caseList.add(c);
            }
            update caseList;
        Test.stopTest();

        System.assertEquals(100, [SELECT count(Id) FROM Apex_Callout__c].size());
    }
}
