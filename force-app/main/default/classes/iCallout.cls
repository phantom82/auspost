global interface iCallout {
    HttpRequest createHTTPRequest(String method, String timeOut, String endPoint, String header, String body);
    HttpResponse sendHTTPRequest(Http h, HttpRequest request);
    Map<String, String> setHTTPCalloutParameters(Apex_Callout__c callout);
}