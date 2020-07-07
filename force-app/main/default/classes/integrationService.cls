public without sharing class integrationService {
    public static final String INTEGRATION_STATUS_PENDING = 'Pending';
    public static final String INTEGRATION_STATUS_COMPLETED = 'Completed';
    public static final String INTEGRATION_STATUS_FAILED = 'Failed';
    public static final Integer INTEGRATION_SERVICE_HTTP_SUCCESS = 200;

    public integrationService() {}

    /*public static void callout(List<Apex_Callout__c> calloutList) {
        List<Case> caseListToUpdate = new List<Case>();
        List<Apex_Callout__c> calloutListToUpdate = new List<Apex_Callout__c>();
        for(Apex_Callout__c callout : calloutList) {
            Http h = new Http();        
            HttpRequest request = new HttpRequest();
            request.setEndpoint(callout.End_Point_URL__c);
            request.setMethod('POST');
            request.setTimeout(120000);
            //set header
            request.setHeader('Content-Type','multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW');
            
            //set payload
            String body = '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"id\"\r\n\r\n'+callout.Record_Id__c;
            body = body + '\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"agentid\"\r\n\r\n'+callout.Record_Modified_By__c;
            body = body + '\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--';
            request.setbody(body);

            try {
                // callout to service
                HttpResponse response = h.send(request);
                List<String> sList = (response.getBody()).split(',');
                List<String> sList2 = sList[1].split(':');

                Apex_Callout__c responseMessage = new Apex_Callout__c(Id = callout.Id, No_Of_Attempts__c = 0);
                responseMessage.No_Of_Attempts__c = callout.No_Of_Attempts__c + 1; 
                if(response.getStatusCode() == integrationService.INTEGRATION_SERVICE_HTTP_SUCCESS) {
                    String secretkey = sList2[1].remove('"');
                    secretkey = secretkey.remove('}');

                    //update case with secret key
                    Case c = new Case(Id = callout.Record_Id__c);
                    c.Integrated_Secret_Key__c = secretkey;
                    caseListToUpdate.add(c);
                    responseMessage.Integration_Status__c = integrationService.INTEGRATION_STATUS_COMPLETED;
                }else {
                    String message = sList2[1].remove('"');
                    message = message.remove('}');
                    responseMessage.Error_Message__c = message;
                    if(responseMessage.No_Of_Attempts__c >= callout.Max_Attempts__c) {
                        responseMessage.Integration_Status__c = integrationService.INTEGRATION_STATUS_FAILED;
                    }else {
                        responseMessage.Integration_Status__c = integrationService.INTEGRATION_STATUS_PENDING;
                    }
                } 
                calloutListToUpdate.add(responseMessage);
            }
            catch(CalloutException e) {
                system.debug(e);
                //log error
                //Utils.logError(e);
                return;
            }
        }
        update caseListToUpdate;
        update calloutListToUpdate;
    }
    */
    public static HTTPRequest createHTTPRequest(String method, String timeOut, String endPoint, String header, String body) {
        Http h = new Http();        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(method);
        request.setTimeout(integer.valueOf(timeOut));
        //set header
        request.setHeader('Content-Type', header);
        //set body
        request.setbody(body);
        return request;
    }

    public static Map<String, String> setHTTPCalloutParameters(Apex_Callout__c callout) {    
        //set header
        String header = 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW';
        //set payload
        String body = '------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"id\"\r\n\r\n'+callout.Record_Id__c;
        body = body + '\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"agentid\"\r\n\r\n'+callout.Record_Modified_By__c;
        body = body + '\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--';
        
        Map<String, String> parametersMap = new Map<String, String>();
        parametersMap.put('endPoint', callout.End_Point_URL__c);
        parametersMap.put('method', 'POST');
        parametersMap.put('timeOut', '120000');
        parametersMap.put('header', header);
        parametersMap.put('body', body);
        return parametersMap;
    }

    public static HTTPResponse sendHTTPRequest(Http h, HttpRequest request) {
        HttpResponse response = h.send(request);
        return response;
    }
}
