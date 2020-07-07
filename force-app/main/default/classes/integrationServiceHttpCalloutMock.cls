@isTest
global class integrationServiceHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'text/html');
        response.setBody('{"success":true,"secretKey":"secret key"}');
        response.setStatusCode(200);
        return response; 
    }
}
