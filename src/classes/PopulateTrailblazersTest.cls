/*****************************************
* File: PopulateTrailblazersTest
* Author: meruff
* Description: Unit Tests for PopulateTrailblazers.cls
******************************************/
@IsTest
private class PopulateTrailblazersTest {
    @TestSetup
    static void setUpData() {
        Trailblazer__c newBlazer = new Trailblazer__c(
            Name = 'Tony Stark',
            Profile_Id__c = '005500000061jCZBBB'
        );
        insert newBlazer;
    }

    @IsTest
    static void testPopulateTrailblazers() {
        // Arrange
        TrailheadCalloutMock mock = new TrailheadCalloutMock();
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setHeader('Location', 'forwardToUrl.com');
        res1.setStatusCode(301);
        mock.addResponse(res1);

        HttpResponse res2 = new HttpResponse();
        res2.setHeader('Content-Type', 'application/json');
        res2.setStatusCode(200);
        res2.setBody(TrailheadCalloutMock.getSuccessfulResponseBody());
        mock.addResponse(res2);

        Test.setMock(HttpCalloutMock.class, mock);

        // Act 
        Test.startTest();
        PopulateTrailblazers pop = new PopulateTrailblazers();
        Test.stopTest();

        // Assert
        List<Trailblazer__c> assertTrailblazers = [
            SELECT Name, Badges__c, Trails__c, (SELECT Id FROM Badges__r)
            FROM Trailblazer__c
        ];

        System.assertEquals(1, assertTrailblazers.size(),
            'Should have created 1 Trailblazer during test set up and upserted that singular record.');
        System.assertEquals('Tony Stark', assertTrailblazers[0].Name,
            'Name should have been upserted to Detonation. Capitalized and numbers removed.');
        System.assertEquals(1, assertTrailblazers[0].Badges__c,
            'Badges__c count should have been upserted to 1');
        System.assertEquals(1, assertTrailblazers[0].Badges__r.size(),
            'Related child Badges__r count should have been upserted to 1');
        System.assertEquals(0, assertTrailblazers[0].Trails__c,
            'Trails__c should have been upserted to 0');
    }

    @IsTest
    static void testSchedulePopulation() {
        // Arrange
        TrailheadCalloutMock mock = new TrailheadCalloutMock();
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setHeader('Location', 'forwardToUrl.com');
        res1.setStatusCode(301);
        mock.addResponse(res1);

        HttpResponse res2 = new HttpResponse();
        res2.setHeader('Content-Type', 'application/json');
        res2.setStatusCode(200);
        res2.setBody(TrailheadCalloutMock.getSuccessfulResponseBody());
        mock.addResponse(res2);

        System.debug('merf: ' + mock);

        Test.setMock(HttpCalloutMock.class, mock);

        // Act
        Test.startTest();
        System.schedule('Test Scheduling PopulateTrailblazers', '0 0 23 * * ?', new PopulateTrailblazers());
        Test.stopTest();

        // Assert
        List<Trailblazer__c> assertTrailblazers = [
            SELECT Name, Badges__c, Trails__c, (SELECT Id FROM Badges__r)
            FROM Trailblazer__c
        ];

        System.assertEquals(1, assertTrailblazers.size(),
            'Should have created 1 Trailblazer during test set up and upserted that singular record.');
        System.assertEquals('Tony Stark', assertTrailblazers[0].Name,
            'Name should have been upserted to Detonation. Capitalized and numbers removed.');
        System.assertEquals(1, assertTrailblazers[0].Badges__c,
            'Badges__c count should have been upserted to 1');
        System.assertEquals(1, assertTrailblazers[0].Badges__r.size(),
            'Related child Badges__r count should have been upserted to 1');
        System.assertEquals(0, assertTrailblazers[0].Trails__c,
            'Trails__c should have been upserted to 0');
    }
}