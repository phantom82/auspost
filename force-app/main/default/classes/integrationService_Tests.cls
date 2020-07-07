@isTest
public with sharing class integrationService_Tests {
    public integrationService_Tests() {

    }

    
    @isTest static void testPostCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new integrationServiceHttpCalloutMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse response ;//= integrationService.callout(calloutList);
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
