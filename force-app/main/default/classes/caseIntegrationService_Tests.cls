@isTest
public with sharing class caseIntegrationService_Tests {
     
    @isTest static void testPostCallout() {
        List<Case> caseList = TestDataFactory.createCaseWithStatus(1, 'Working');
        List<Apex_Callout__c> calloutList = TestDataFactory.createIntegrationServiceRecord(caseList);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new integrationServiceHttpCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Http h = new Http();
        Map<String, String> paramsMap = caseIntegrationService.setHTTPCalloutParameters(calloutList[0]);
        HttpRequest request = caseIntegrationService.createHTTPRequest('POST', '120000', 'https://test.com', 'HEADER', 'BODY');
        HttpResponse response = h.send(request); 
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'text/html');
        String actualValue = response.getBody();
        System.debug(response.getBody());
        String expectedValue = '{"success":true,"secretKey":"secret key"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, response.getStatusCode());
    }
}
