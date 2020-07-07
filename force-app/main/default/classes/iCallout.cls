global interface iCallout {
    void createHTTPRequest(String method, String timeOut, String endPoint, String header, String body);
    void sendHTTPRequest(Http h, HttpRequest request);
    void setHTTPCalloutParameters(Apex_Callout__c callout);
}