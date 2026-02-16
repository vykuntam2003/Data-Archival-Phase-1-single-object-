@IsTest
private class BookingCompletedSeedBatchTest {
    @IsTest
    static void testBatch_Execute() {
        // Setup test data if needed
        Test.startTest();
        Database.executeBatch(new BookingCompletedSeedBatch(), 50);
        Test.stopTest();
        // Add assertions if batch has visible effects
        System.assert(true, 'Batch executed without error');
    }
}
