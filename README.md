# auspost
Code challenge

<b>Requirement:</b>
  
A Case has been updated to be closed. When a Case is closed, the workforce planning team need to be notified to ensure they are correctly tracking Case closures and new work assignments. This is currently handled by an API call to the workforce management platform.
The environment is a relatively high volume environment with roughly 200 Case closures per minute. The API recently has had some performance issues and every now and again it times out.
It’s not necessary for the API to be called immediately after the case is closed, as long as the workforce management platform is notified within the day. 
The case should be updated with the secretKey returned from the API.
We are looking for a workable (or semi-workable) solution that addresses the following key points:
1.	Code style and structure
2.	Solution one-pager outlining inclusions, exclusions, justifications
3.	Ability to write well structured, efficient unit test classes 
4.	Ideas (and possible implementation) for a fail-over strategy where API fails
5.	Code checked into GIT for review
We would like this challenge to be completed within a week. Please let us know if that is not possible.
Workforce Planning API
Endpoint: https://nfapihub.herokuapp.com/
Method: POST
Body params:
id: the case id
agentid: the id of the agent that performed the closure
Error Response:
500
{"success":false,"error":"error message"}

Success Response:
200
{"success":true,"secretKey":"secret key"}


<b>Solution:</b>

1. End_Point__mdt is the metadata type capturing all end points used by the system and related parameters.
2. Case is updated by the user, after update on Case (caseTriggers.cls) Where Status is Closed, leads to creation of corresponding Apex_Callout__c records. 
<img src="https://github.com/phantom82/auspost/blob/master/main2.PNG">

3. caseIntegrationService.cls implements iCallout, setting up callout specifically for Case object.
<img src="https://github.com/phantom82/auspost/blob/master/main.PNG">
4. caseIntegrationServiceBatch.cls processes all the integration (Apex_Callout__c) records in Pending status. In case of service timeout or any intermittent error causing failure in integration, the corresponding record remains in Pending status and only gets picked up in the next batch run.
5. Successive batch runs are enabled using batch chaining, batch runs only if there are any pending integration records.

<b>Notes:</b>
-Object specific batches are catering for the any response processing in bi-directional integrations.
-New object integration will require the following:
a) object specific service class implementing iCallout interface.
b) object specific batch class
c) Entry for endpoint details in the End_Point__mdt metadata type.
d) New fields creation in Apex_Callout__c for the payload.

-The callout limit is 250000 calls/ 24 hours, at 200 cases getting closed a min is approx. 100000 cases in 8 hours.
-There are 100 callouts allowed per apex transaction but only possible if the service at the other end supports. Most of the cases, a good percentage will time out. Therefore, the batch needs to be executed in small chucks i.e. 10.
