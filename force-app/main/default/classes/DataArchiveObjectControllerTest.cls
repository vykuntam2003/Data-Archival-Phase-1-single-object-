@IsTest
private class DataArchiveObjectControllerTest {

    @TestSetup
    static void setup() {

        Data_Archive__c da = new Data_Archive__c(
            Parent_Object__c = 'Account',
            Fields__c = 'Name',
            Status__c = 'Ready for Unarchive'
        );
        insert da;

        ContentVersion cv = new ContentVersion(
            Title = da.Name,
            PathOnClient = da.Name + '.csv',
            VersionData = Blob.valueOf('Name\nTest')
        );
        insert cv;

        cv = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        insert new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = da.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
    }

    @IsTest
    static void testPaginationAndDownloadUrls() {

        Test.startTest();
        DataArchiveObjectController.ArchiveWrapper w =
            DataArchiveObjectController.getArchivedObjectPaginated(1, 5);

        List<String> urls =
            DataArchiveObjectController.getAllArchiveCsvDownloadUrls(
                (Id)w.data[0].get('Id')
            );
        Test.stopTest();

        System.assert(!w.data.isEmpty());
        System.assert(!urls.isEmpty());
    }

    @IsTest
    static void testUnarchiveAsync_NoSelection() {
        String msg =
            DataArchiveObjectController.unarchiveAsync(new List<Id>());
        System.assertEquals('No records selected', msg);
    }
}
