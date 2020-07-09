/*
Batch class that iterates through all Apex Callout records that are:
1. Status = Pending (not integrated)

Apex Callout records status stays in Pending unless Max Attempts have been exceeded. 
Max Attempts is defined as Meta data, but could be overridden for a certain Apex Callout record.
The batch class is meant to run overnight.

Batch chains up if there are any Pending records remaining untill all the Completed or Failed.
*/
global class caseIntegrationServiceBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // This is the object for which we required data.
        Map<String, Schema.SObjectField> fieldMap = Apex_Callout__c.sObjectType.getDescribe().fields.getMap();
        // Get all of the fields on the object
        Set<String> fieldNamesSet = fieldMap.keySet();
        List<String> fieldNamesList = new List<String>(fieldNamesSet);

        return Database.getQueryLocator(
            'SELECT ' + string.join(fieldNamesList, ',') + ' FROM Apex_Callout__c' +
            ' WHERE Integration_Status__c =\''+  caseIntegrationService.INTEGRATION_STATUS_PENDING + '\''+
            ' AND IsDeleted = false ' +
            ' ORDER BY CreatedDate ASC'
        );
    }

    global void execute(Database.BatchableContext bc, List<Apex_Callout__c> scope) {
        //caseIntegrationService.callout(scope);
        List<Case> caseListToUpdate = new List<Case>();
        List<Apex_Callout__c> calloutListToUpdate = new List<Apex_Callout__c>();
        Http h = new Http();
        Map<String, String> parametersMap = new Map<String, String>();
        for(Apex_Callout__c callout : scope) {
            try {
                parametersMap = caseIntegrationService.setHTTPCalloutParameters(callout);
                HTTPRequest request = caseIntegrationService.createHTTPRequest(parametersMap.get('method'), parametersMap.get('timeOut'), parametersMap.get('endPoint'), parametersMap.get('header'), parametersMap.get('body'));
                HttpResponse response = caseIntegrationService.sendHTTPRequest(h, request);

                Apex_Callout__c responseMessage = new Apex_Callout__c(Id = callout.Id, No_Of_Attempts__c = 0);
                responseMessage.No_Of_Attempts__c = callout.No_Of_Attempts__c + 1;
                
                List<String> sList = (response.getBody()).split(',');
                List<String> sList2 = sList[1].split(':');
                //key could have error or secret
                String key = sList2[1].replaceAll('[^a-zA-Z0-9\\s+]', '');
                if(response.getStatusCode() == caseIntegrationService.INTEGRATION_SERVICE_HTTP_SUCCESS) {
                    //update case with secret key
                    Case c = new Case(Id = callout.Record_Id__c);
                    c.Integrated_Secret_Key__c = key;
                    caseListToUpdate.add(c);
                    responseMessage.Integration_Status__c = caseIntegrationService.INTEGRATION_STATUS_COMPLETED;
                }else {
                    responseMessage.Error_Message__c = key;
                    if(responseMessage.No_Of_Attempts__c >= callout.Max_Attempts__c) {
                        responseMessage.Integration_Status__c = caseIntegrationService.INTEGRATION_STATUS_FAILED;
                    }else {
                        responseMessage.Integration_Status__c = caseIntegrationService.INTEGRATION_STATUS_PENDING;
                    }
                } 
                calloutListToUpdate.add(responseMessage);
            }catch(CalloutException e) {
                system.debug(e);
                //log error
                //Utils.logError(e);
                return;
            }
        }
        update caseListToUpdate;
        update calloutListToUpdate;
    }

    global void finish(Database.BatchableContext bc) {
        List<Apex_Callout__c> pendingCalloutList = new List<Apex_Callout__c>();
        pendingCalloutList =  [SELECT Id, Integration_Status__c FROM Apex_Callout__c WHERE Integration_Status__c = :caseIntegrationService.INTEGRATION_STATUS_PENDING];
        if(Test.isRunningTest()) {
            return;
        }
        if(pendingCalloutList.size() > 0) {
            caseIntegrationServiceBatch b = new caseIntegrationServiceBatch();
            database.executebatch(b, 1);
        }
        //Email..
    }
}
