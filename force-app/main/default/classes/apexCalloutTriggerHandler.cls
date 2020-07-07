public with sharing class apexCalloutTriggerHandler {
    //creates record(s) for Integration based on 
    //1. list of cases
    //2. end point configuration provided
    public static List<Apex_Callout__c> createRecords(List<Case> caseList, End_Point__mdt endpoint) {
        if(caseList.isEmpty() || endpoint.URL__c == null || endpoint.URL__c == '') {
            return null;
        }

        List<Apex_Callout__c> calloutList = new List<Apex_Callout__c>();
        for(Case c : caseList) {
            Apex_Callout__c callout = new Apex_Callout__c(
                Integration_Status__c   = integrationService.INTEGRATION_STATUS_PENDING,
                Module__c               = endpoint.Module__c,
                Callout_Type__c         = endpoint.Callout_Type__c,
                Record_Id__c            = c.Id,
                End_Point_URL__c        = endpoint.URL__c,
                Record_Modified_By__c   = c.OwnerId,
                Max_Attempts__c         = endpoint.Max_Attempts__c
            );
            calloutList.add(callout);
        }
        try{
            Database.insert(calloutList, false);
        }catch(DMLException e) {
            System.debug(e);
            //log error
            return null;
        }
        return calloutList;
    }
}
