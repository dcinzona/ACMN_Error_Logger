/**
 * Created by gtandeciarz on 7/30/18.
 */

@IsTest
private class ACMN_Logger_MDT_DAO_TESTS {
    static testMethod void testGetMetadata() {
        List<ACMN_Logger_Setting__mdt> customMetadataRecords;
        Test.startTest();
        customMetadataRecords = ACMN_Logger_MDT_DAO.getCustomMetadataRecords();
        Test.stopTest();
        System.assertEquals( [ SELECT Id FROM ACMN_Logger_Setting__mdt ].size(), customMetadataRecords.size(), 'Size should match' );
    }
}