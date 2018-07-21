/**
 * Created by gtandeciarz on 6/21/18.
 */

@IsTest
private class ACMN_Error_Logger_TESTS {

    @IsTest
    static void testEventLogger() {
        enableLogging();
        Test.startTest();
        ACMN_Error_Logger.Log(new CustomException('manually generated exception message'));
        Test.stopTest();
        List<ACMN_Error_Log__c> logs = [SELECT Id, Error_Message__c FROM ACMN_Error_Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('manually generated exception message', logs[0].Error_Message__c);
    }

    @IsTest
    static void testEventLoggerEmptyMessage() {
        enableLogging();
        Test.startTest();
        ACMN_Error_Logger.Log('');
        Test.stopTest();
        assertNoRecords();
    }

    @IsTest
    static void testGetSettingsMap() {
        List<ACMN_Logger_Setting__mdt> settings = [SELECT Id
                FROM ACMN_Logger_Setting__mdt
                WHERE Enabled__c = TRUE];
        System.assertEquals(settings.size(), ACMN_Error_Logger.servicesMap.size());
    }

    @IsTest
    static void processSaveResultsFail(){
        ACMN_Error_Log__c log = new ACMN_Error_Log__c();
        ACMN_Error_Logger.processSaveResults(Database.insert(new List<ACMN_Error_Log__c>{log},false));
        assertNoRecords();
    }

    @IsTest
    static void testSendToServicesFail() {
        enableLogging();
        Test.startTest();
        ACMN_Error_Logger.sendToServices(new List<String>{'bad data'});
        Test.stopTest();
        assertNoRecords();
    }

    @IsTest
    static void testGetService() {
        ACMN_Logger_Setting__mdt mdt = [SELECT Id, Custom_Logger_Class__c FROM ACMN_Logger_Setting__mdt WHERE DeveloperName = 'DEFAULT'];
        System.assert(ACMN_Error_Logger.getServiceInstance(mdt) != null);
    }

    @IsTest
    static void testGetServiceFail() {
        ACMN_Logger_Setting__mdt badMDT = new ACMN_Logger_Setting__mdt();
        System.assert(ACMN_Error_Logger.getServiceInstance(badMDT) == null);
    }

    @IsTest
    static void testACMNLoggerSObjectMethod() {
        ACMN_LogRecord rec = new ACMN_LogRecord('error message');
        Test.startTest();
        ACMN_Error_Log__c recObj = rec.getSObject();
        Test.stopTest();
        System.assert(recObj.Error_Message__c.equals(rec.message));
        System.assert(recObj.Log_Date_Time__c != null);
    }

    @IsTest
    static void testEventLoggerMultipleLogRecords() {
        enableLogging();
        Test.startTest();
        List<String> messages = new List<String>{'err1', 'err2', 'err3'};
        ACMN_Error_Logger.Log(messages);
        Test.stopTest();
        List<ACMN_Error_Log__c> logs = [SELECT Id, Error_Message__c FROM ACMN_Error_Log__c];
        System.assertEquals(3, logs.size(),'There should be 3 error logs saved');
    }

    @IsTest
    static void testLogRecordSorting(){
        ACMN_LogRecord rec1 = new ACMN_LogRecord('should be last');
        ACMN_LogRecord rec2 = new ACMN_LogRecord('rec2');
        ACMN_LogRecord rec3 = new ACMN_LogRecord('should be first');
        rec1.logDate = rec1.logDate.addDays(3);
        rec3.logDate = rec3.logDate.addDays(-1);
        List<ACMN_LogRecord> recs = new List<ACMN_LogRecord>{rec1,rec2,rec3};
        recs.sort();
        System.assertEquals(recs[0],rec3);
        System.assertEquals(recs[2],rec1);
    }

    @IsTest
    static void testLogRecordConstructors(){
        String className = ACMN_Error_Logger_TESTS.class.getName();
        ACMN_LogRecord rec1 = new ACMN_LogRecord('should be last');
        ACMN_LogRecord rec2 = new ACMN_LogRecord('rec2', className, 'testing string message');
        ACMN_LogRecord rec3 = new ACMN_LogRecord(new CustomException('test exception'));
        ACMN_LogRecord rec4 = new ACMN_LogRecord(new CustomException('test exception'),className,'testing custom exception');
        List<ACMN_LogRecord> recs = new List<ACMN_LogRecord>{rec1,rec2,rec3,rec4};
        //message
        System.assert(String.isNotEmpty(rec1.message));
        System.assert(String.isNotEmpty(rec2.message));
        System.assert(String.isNotEmpty(rec3.message));
        System.assert(String.isNotEmpty(rec4.message));
        //classname
        System.assert(String.isEmpty(rec1.className));
        System.assert(String.isNotEmpty(rec2.className));
        System.assert(String.isEmpty(rec3.className));
        System.assert(String.isNotEmpty(rec4.className));
        //other details
        System.assert(String.isEmpty(rec1.otherDetails));
        System.assert(String.isNotEmpty(rec2.otherDetails));
        System.assert(String.isNotEmpty(rec3.otherDetails));
        System.assert(String.isNotEmpty(rec4.otherDetails));
        //stacktrace
        System.assert(String.isEmpty(rec1.stacktrace));
        System.assert(String.isEmpty(rec2.stacktrace));
        System.assert(String.isNotEmpty(rec3.stacktrace));
        System.assert(String.isNotEmpty(rec4.stacktrace));

        System.debug(rec3.stacktrace);
        //exception type defaults
        System.assertEquals(rec3.otherDetails,
                ACMN_LogRecord.getOtherDetailsExceptionTypeString(new CustomException('t')));
    }

    static void assertNoRecords(){
        List<ACMN_Error_Log__c> logs = [SELECT Id, Error_Message__c FROM ACMN_Error_Log__c];
        System.assertEquals(0, logs.size(), 'No error logs should exist');
    }

    static void enableLogging(){
        ACMN_Logger_Setting__mdt mdt = [SELECT Id, Custom_Logger_Class__c, Save_To_Salesforce__c, Enabled__c FROM ACMN_Logger_Setting__mdt WHERE Custom_Logger_Class__c='ACMN_Logger_Service_PE'];
        ACMN_Error_Logger.Service svc = ACMN_Error_Logger.getServiceInstance(mdt);
        svc.isEnabled = true;
        svc.saveToSalesforce = true;
        ACMN_Error_Logger.servicesCache = new Map<String, ACMN_Error_Logger.Service>();
        ACMN_Error_Logger.servicesMap.put('ACMN_Logger_Service_PE', svc);
    }

    class CustomException extends Exception {

    }
}