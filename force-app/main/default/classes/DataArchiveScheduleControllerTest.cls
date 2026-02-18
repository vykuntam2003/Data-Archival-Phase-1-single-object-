@IsTest
private class DataArchiveScheduleControllerTest {

    // ─────────────────────────────────────────────────
    //  Test: getActiveSchedules returns records
    // ─────────────────────────────────────────────────
    @IsTest
    static void testGetActiveSchedules() {
        // Insert a schedule record
        insert new Data_Archive_Schedule__c(
            Object_Name__c     = 'Account',
            Frequency__c       = 'DAILY',
            Date_Field__c      = 'CreatedDate',
            Days__c            = 30,
            Cron_Expression__c = '0 0 2 * * ?',
            Status__c          = 'Active',
            Preferred_Time__c  = '02:00',
            Day_Of_Week__c     = 'MON'
        );

        Test.startTest();
        List<DataArchiveScheduleController.ScheduleInfo> results =
            DataArchiveScheduleController.getActiveSchedules();
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Should return at least one active schedule');
        System.assertEquals('Account', results[0].objectName);
    }

    // ─────────────────────────────────────────────────
    //  Test: getSchedulesForObject returns matching
    // ─────────────────────────────────────────────────
    @IsTest
    static void testGetSchedulesForObject() {
        insert new Data_Archive_Schedule__c(
            Object_Name__c     = 'Contact',
            Frequency__c       = 'WEEKLY',
            Date_Field__c      = 'CreatedDate',
            Days__c            = 60,
            Cron_Expression__c = '0 0 2 ? * MON',
            Status__c          = 'Active',
            Preferred_Time__c  = '09:00',
            Day_Of_Week__c     = 'MON'
        );

        Test.startTest();
        List<DataArchiveScheduleController.ScheduleInfo> results =
            DataArchiveScheduleController.getSchedulesForObject('Contact');
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Should return schedules for Contact');
        System.assertEquals('Contact', results[0].objectName);
    }

    // ─────────────────────────────────────────────────
    //  Test: getSchedulesForObject returns empty
    // ─────────────────────────────────────────────────
    @IsTest
    static void testGetSchedulesForObject_Empty() {
        Test.startTest();
        List<DataArchiveScheduleController.ScheduleInfo> results =
            DataArchiveScheduleController.getSchedulesForObject('NoSuchObject__c');
        Test.stopTest();

        System.assert(results.isEmpty(), 'Should return empty list');
    }

    // ─────────────────────────────────────────────────
    //  Test: scheduleArchive with text filter (success)
    // ─────────────────────────────────────────────────
    @IsTest
    static void testScheduleArchive_TextFilter() {
        String objectName   = 'Account';
        String frequency    = 'DAILY';
        String dateField    = 'Name';
        Integer days        = 0;
        String filterValue  = 'TestAccount';
        String preferredTime = '14:30';
        String dayOfWeek     = null;

        Test.startTest();
        String result = DataArchiveScheduleController.scheduleArchive(
            objectName, frequency, dateField, days, filterValue,
            preferredTime, dayOfWeek
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return success message');
        System.assert(result.contains('Successfully'), 'Message should confirm schedule creation');
    }

    // ─────────────────────────────────────────────────
    //  Test: Duplicate schedule throws validation error
    // ─────────────────────────────────────────────────
    @IsTest
    static void testScheduleArchive_DuplicateValidation() {
        // Create a schedule record directly
        insert new Data_Archive_Schedule__c(
            Object_Name__c     = 'Account',
            Frequency__c       = 'DAILY',
            Date_Field__c      = 'Name',
            Days__c            = 30,
            Cron_Expression__c = '0 30 14 * * ?',
            Status__c          = 'Active',
            Preferred_Time__c  = '14:30',
            Day_Of_Week__c     = null
        );

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            DataArchiveScheduleController.scheduleArchive(
                'Account', 'DAILY', 'Name', 30, null,
                '14:30', null
            );
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(
                e.getMessage().contains('already exists'),
                'Error message should mention duplicate: ' + e.getMessage()
            );
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw AuraHandledException for duplicate schedule');
    }

    // ─────────────────────────────────────────────────
    //  Test: Different criteria replaces existing
    // ─────────────────────────────────────────────────
    @IsTest
    static void testScheduleArchive_ReplacesExistingSchedule() {
        Test.startTest();
        // First schedule
        DataArchiveScheduleController.scheduleArchive(
            'Account', 'DAILY', 'Name', 0, 'First',
            '02:00', null
        );

        // Second schedule: same object+field but different frequency → replaces
        String result = DataArchiveScheduleController.scheduleArchive(
            'Account', 'MONTHLY', 'Name', 0, 'Second',
            '03:00', null
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    // ─────────────────────────────────────────────────
    //  Test: All frequency branches covered
    // ─────────────────────────────────────────────────
    @IsTest
    static void testScheduleArchive_AllFrequencies() {
        List<String> frequencies = new List<String>{
            'WEEKLY', 'MONTHLY', 'YEARLY', 'UNKNOWN'
        };

        Test.startTest();
        for (String freq : frequencies) {
            String result = DataArchiveScheduleController.scheduleArchive(
                'Account', freq, 'Name', 0, 'FreqTest',
                '08:00', 'FRI'
            );
            System.assertNotEquals(null, result);
        }
        Test.stopTest();
    }

    // ─────────────────────────────────────────────────
    //  Test: Custom preferred time in cron
    // ─────────────────────────────────────────────────
    @IsTest
    static void testScheduleArchive_CustomTime() {
        Test.startTest();
        String result = DataArchiveScheduleController.scheduleArchive(
            'Account', 'DAILY', 'Name', 10, 'TimeTest',
            '16:45', null
        );
        Test.stopTest();

        System.assertNotEquals(null, result);

        // Verify the cron uses the custom time
        Data_Archive_Schedule__c saved = [
            SELECT Cron_Expression__c, Preferred_Time__c
            FROM Data_Archive_Schedule__c
            WHERE Object_Name__c = 'Account'
            AND Days__c = 10
            LIMIT 1
        ];

        System.assertEquals('16:45', saved.Preferred_Time__c);
        System.assert(saved.Cron_Expression__c.contains('45'), 'Cron should contain minute 45');
        System.assert(saved.Cron_Expression__c.contains('16'), 'Cron should contain hour 16');
    }

    // ─────────────────────────────────────────────────
    //  Test: Weekly with custom day
    // ─────────────────────────────────────────────────
    @IsTest
    static void testScheduleArchive_WeeklyWithDay() {
        Test.startTest();
        String result = DataArchiveScheduleController.scheduleArchive(
            'Account', 'WEEKLY', 'Name', 5, 'DayTest',
            '10:00', 'WED'
        );
        Test.stopTest();

        System.assertNotEquals(null, result);

        Data_Archive_Schedule__c saved = [
            SELECT Cron_Expression__c, Day_Of_Week__c
            FROM Data_Archive_Schedule__c
            WHERE Object_Name__c = 'Account'
            AND Days__c = 5
            LIMIT 1
        ];

        System.assertEquals('WED', saved.Day_Of_Week__c);
        System.assert(saved.Cron_Expression__c.contains('WED'), 'Cron should contain WED');
    }
}