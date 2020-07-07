@isTest
public class TestDataFactory {
    public static List<Case> createCaseWithStatus(Integer noOfCases, String caseStatus) {
        List<Case> caseListToUpdate = new List<Case>();
        Account acc = new Account(Name = 'TestAccount'+System.Now());
        insert acc;
        Contact con = new Contact(LastName = 'TestContact'+System.Now(), AccountId = acc.Id);
        insert con;
        for(Integer i = 0 ; i < noOfCases; i++) {
            Case c = new Case();
            c.Subject = 'TestCase'+i;
            c.Status = caseStatus;
            caseListToUpdate.add(c);
        }
        insert caseListToUpdate;
        return caseListToUpdate;
    }

    public static List<Case> updateCaseStatus(List<Case> caseList, String caseStatus) {
        List<Case> caseListToUpdate = new List<Case>();
        for(Case c : caseList) {
            c.Status = caseStatus;
            caseListToUpdate.add(c);
        }
        update caseListToUpdate;
        return caseListToUpdate;
    }

    public static List<Apex_Callout__c> createIntegrationServiceRecord(List<Case> caseList) {
        List<End_Point__mdt> endpoint = (List<End_Point__mdt>)JSON.deserialize('[{"Module__c":"Test Module","CallOut_Type__c":"REST","URL__c":"https://test1231.com"}]',List<End_Point__mdt>.class);
        List<Apex_Callout__c> integrationRecordList = new List<Apex_Callout__c>();
        Set<Id> caseIdSet = new Set<Id>();
        for(Case c : caseList) {
            c.Status = caseTriggerHandler.CLOSED_CASE;
            caseIdSet.add(c.OwnerId);
        }
        update caseList;
        integrationRecordList = [SELECT Id, Record_Id__c, Integration_Status__c, Record_Modified_By__c, Module__c, Max_Attempts__c, No_Of_Attempts__c FROM Apex_Callout__c WHERE Record_Id__c in :caseIdSet AND Integration_Status__c = :integrationService.INTEGRATION_STATUS_PENDING];
        return integrationRecordList;
    }

}
