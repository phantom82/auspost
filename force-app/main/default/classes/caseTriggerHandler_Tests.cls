@isTest
private class caseTriggerHandler_Tests {
    @TestSetup
    static void makeData(){
        List<Case> caseList = TestDataFactory.createCaseWithStatus(100, 'New');
        system.debug('caseList.sizes=='+caseList.size());

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
            system.debug('caseList.sizes=='+caseList.size());
        Test.stopTest();

        System.assertEquals(100, [SELECT Id FROM Case].size());
    }
}
