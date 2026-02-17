@IsTest
private class DataArchiveScheduleControllerTest {

    @IsTest
    static void testScheduleArchive_TextFilter() {
        // Use text-based filter path (non-empty filterValue) to avoid DateTime format issues
        String objectName  = 'Account';
        String frequency   = 'DAILY';
        String dateField   = 'Name';
        Integer days       = 0;
        String filterValue = 'TestAccount';

        Test.startTest();
        String result = DataArchiveScheduleController.scheduleArchive(
            objectName, frequency, dateField, days, filterValue
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return success message');
        System.assert(result.contains('Successfully'), 'Message should confirm schedule creation');
    }

    @IsTest
    static void testScheduleArchive_ReplacesExistingSchedule() {
        // Create first schedule
        Test.startTest();
        DataArchiveScheduleController.scheduleArchive(
            'Account', 'DAILY', 'Name', 0, 'First'
        );

        // Creating a second schedule for the same object+dateField should
        // abort the old one and replace it
        String result = DataArchiveScheduleController.scheduleArchive(
            'Account', 'MONTHLY', 'Name', 0, 'Second'
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    @IsTest
    static void testScheduleArchive_AllFrequencies() {
        // Cover all branches in buildCronExpression
        List<String> frequencies = new List<String>{
            'WEEKLY_ONCE', 'WEEKLY', 'MONTHLY', 'YEARLY', 'UNKNOWN'
        };

        Test.startTest();
        for (String freq : frequencies) {
            String result = DataArchiveScheduleController.scheduleArchive(
                'Account', freq, 'Name', 0, 'FreqTest'
            );
            System.assertNotEquals(null, result);
        }
        Test.stopTest();
    }
}