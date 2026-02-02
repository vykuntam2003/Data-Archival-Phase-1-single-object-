/**
 * @description Tests for InsertAccountsBatch (Batchable)
 * Creates the batch, runs via Test.startTest/stopTest, and asserts results.
 */
@IsTest
private class InsertAccountsBatchTest {

    @IsTest
    static void testBatch_ExecuteInsertsRecords() {
        // Pre-count
        Integer before = [SELECT COUNT() FROM Account];

        Test.startTest();
        // Many batches accept a size; if class uses default, system will chunk accordingly
        Database.executeBatch(new InsertAccountsBatch(10), 50);
        Test.stopTest();

        Integer after = [SELECT COUNT() FROM Account];
        System.assert(after > before, 'Batch should insert Accounts');
    }
}
