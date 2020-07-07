// Specific CASE integration
public without sharing class caseIntegrationService implements iCallout {
    public static final String INTEGRATION_STATUS_PENDING = 'Pending';
    public static final String INTEGRATION_STATUS_COMPLETED = 'Completed';
    public static final String INTEGRATION_STATUS_FAILED = 'Failed';
    public static final Integer INTEGRATION_SERVICE_HTTP_SUCCESS = 200;

    public caseIntegrationService() {}

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
