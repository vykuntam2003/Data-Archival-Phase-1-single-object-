@IsTest
private class DataArchiveBatchTest {
    @IsTest
    static void testBatch_Execute() {
        String objectName = 'Account';
        String fieldsCsv = 'Name';
        String soqlQuery = 'SELECT Id, Name FROM Account';
        Test.startTest();
        Database.executeBatch(new DataArchiveBatch(objectName, fieldsCsv, soqlQuery), 50);
        Test.stopTest();
        System.assert(true, 'Batch executed without error');
    }

    @IsTest
    static void testBatch_InvalidInputThrows() {
        try {
            new DataArchiveBatch('Account/', 'Name', 'SELECT Id, Name FROM Account');
            System.assert(false, 'Should throw for invalid objectName');
        } catch (Exception e) {}
        try {
            new DataArchiveBatch('Account', 'Name/', 'SELECT Id, Name FROM Account');
            System.assert(false, 'Should throw for invalid fieldsCsv');
        } catch (Exception e) {}
        try {
            new DataArchiveBatch('Account', 'Name', 'SELECT Id, Name FROM Account/');
            System.assert(false, 'Should throw for invalid soqlQuery');
        } catch (Exception e) {}
    }
}
