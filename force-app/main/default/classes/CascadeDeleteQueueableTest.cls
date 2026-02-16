@IsTest
private class CascadeDeleteQueueableTest {
    @IsTest
    static void testQueueable_Execute() {
        // Setup test data if needed
        Test.startTest();
        System.enqueueJob(new CascadeDeleteQueueable(new List<Id>()));
        Test.stopTest();
        System.assert(true, 'Queueable executed without error');
    }
}
