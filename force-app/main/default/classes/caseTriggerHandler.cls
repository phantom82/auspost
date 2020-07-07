public with sharing class caseTriggerHandler {
    public static final String CLOSED_CASE = 'Closed';
    public static final String AUSPOST_HEROKU_SERVICE = 'Auspost_Heroku_Service';

    public static void handleCaseAfterUpdate(Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        Map<Id, Case> selectedCaseMap = new Map<Id, Case>();
        for(Case c : newMap.Values()) {
            if(c.Status == CLOSED_CASE && oldMap.get(c.Id).Status <> CLOSED_CASE) {
                if(selectedCaseMap.get(c.Id) == null) {
                    selectedCaseMap.put(c.Id, new Case());
                }
                selectedCaseMap.put(c.Id, c);
            }
        }
        //callouts prep.
        if(selectedCaseMap.size() > 0) {
            List<Apex_Callout__c> calloutList = new List<Apex_Callout__c>();
            calloutList = createIntegrationRecords(selectedCaseMap);
        }
    }

    //creates/ updates records for integration object
    //keeps track of the integration status
    public static List<Apex_Callout__c> createIntegrationRecords(Map<Id, Case> caseMap) {
        End_Point__mdt endPoint = [SELECT URL__c, DeveloperName, Module__c, Max_Attempts__c, Callout_Type__c FROM End_Point__mdt WHERE DeveloperName = :AUSPOST_HEROKU_SERVICE];
        return apexCalloutTriggerHandler.createRecords(caseMap.Values(), endPoint);
    }
}
