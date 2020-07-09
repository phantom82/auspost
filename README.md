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

1. End_Point__mdt is the metadata type capturing all end points used by the system and thier related parameters.<br>
2. Case is updated by the user, after update on Case (caseTriggers.cls) where Status is Closed, leads to creation of corresponding Intergration (Apex_Callout__c) records.<br> 

<img src="https://github.com/phantom82/auspost/blob/master/main2.PNG">

3. caseIntegrationService.cls implements iCallout interface, setting up callout specifically for Case object.<br>

<img src="https://github.com/phantom82/auspost/blob/master/main.PNG">

4. caseIntegrationServiceBatch.cls processes all the integration (Apex_Callout__c) records in Pending status. In case of service timeout or any intermittent error causing failure in integration, the corresponding record remains in Pending status and only gets picked up in the next batch run.<br>
5. Successive batch runs are enabled using batch chaining, new batch job runs only if there are any pending integration records from existing job.<br>
6. Max_Attemps__c value can be configured specific to endpoint (End_Point__mdt) for each integration, this value can be overriden for individual integration records as well.<br>
7. If a certain integration record keeps failing and exceeds the Max_Attempts__c value, it's status is set to Failed and is not considered for integration anymore.<br>
8. Keeping batch size as a custom metadata value can be implemented.<br>


<b>Notes:</b>

-Object specific batches are catering for the any response processing from the external service.<br>
-A new Salesforce object integration will require the following:<br>
a) object specific service class implementing iCallout interface.<br>
b) object specific batch class<br>
c) Entry for endpoint details in the End_Point__mdt metadata type.<br>
d) New fields creation in Apex_Callout__c for the payload.<br>

-At 200 cases getting closed a min is approx. 100000 cases in 8 hours. Advisable to execute integration batch after hours.<br>
-There are 100 callouts allowed per apex transaction but only possible if the service at the other end supports. Most of the cases, a good percentage will time out. Therefore, the batch needs to be executed in small chucks i.e. 10.

<b>Testing:</b>

1. Pull the git source into a scratch org.
2. Create couple of cases in the org developer console using:<br>
  //--------------- CASE CREATION--<br>
List<Case> caseList = new List<Case>();<br>
for(Integer i=0; i<100; i++) {<br>
    Case c = new Case();<br>
    c.Subject = 'testcase '+i;<br>
    c.Status = 'Working';<br>
    caseList.add(c);<br>
}<br>
insert caseList;<br>
                        
3. Update the cases and set them Closed.<br>
//---------------CASE STATUS UPDATE--- <br>
List<Case> caseList = new List<Case>();<br>
for(Case c : [Select Id, Integrated_Secret_Key__c, Status from Case]) {<br>
    c.Status = 'Closed';<br>
    c.Integrated_Secret_Key__c = '';<br>
    caseList.add(c);<br>
}<br>
update caseList;<br>

4. Run the batch:
Database.executeBatch(new caseIntegrationServiceBatch(), 5);<br>
<img src="https://github.com/phantom82/auspost/blob/master/main3.PNG">
