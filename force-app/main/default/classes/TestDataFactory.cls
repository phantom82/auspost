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
        List<End_Point__mdt> endpoint = [SELECT Module__c, CallOut_Type__c, URL__c, Max_Attempts__c FROM End_Point__mdt];
        List<Apex_Callout__c> integrationRecordList = apexCalloutTriggerHandler.createRecords(caseList, endpoint[0]);
        return integrationRecordList;
    }
}
