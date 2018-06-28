/**
 * Created by gtandeciarz on 6/21/18.
 */

@IsTest
private class ACMN_Error_Logger_TESTS {

    @IsTest
    static void testEventTrigger() {
        ACMN_Error_Log_PE__e pe = new ACMN_Error_Log_PE__e();
        pe.Error_Message__c = 'testEventTrigger';
        pe.Class_Name__c = 'ACMN_Error_Logger_TESTS';
        pe.Other_Details__c = 'Other Details';
        pe.Log_Date_Time__c = System.now();

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(pe);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
        List<ACMN_Error_Log__c> logs = [SELECT Id FROM ACMN_Error_Log__c];
        System.assertEquals(1, logs.size());
    }

    @IsTest
    static void testEventLogger() {
        Test.startTest();
        try{
            throw new CustomException('manually generated exception message');
        } catch (Exception ex){
            ACMN_Error_Logger.Log(ex);
        }
        Test.stopTest();
        List<ACMN_Error_Log__c> logs = [SELECT Id, Error_Message__c FROM ACMN_Error_Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('manually generated exception message', logs[0].Error_Message__c);
    }

    @IsTest
    static void testEventLoggerEmptyMessage() {
        Test.startTest();
        ACMN_Error_Logger.Log(null,'ACMN_Error_Logger_TESTS',null,null);
        Test.stopTest();
        List<ACMN_Error_Log__c> logs = [SELECT Id, Error_Message__c FROM ACMN_Error_Log__c];
        System.assertEquals(0, logs.size());
    }

    @IsTest
    static void testEventLoggerSingleLogRecord() {
        Test.startTest();
        ACMN_Error_Log__c log = new ACMN_Error_Log__c();
        log.Error_Message__c = 'testEventLoggerSingleLogRecord';
        ACMN_Error_Logger.LoggerCore core = new ACMN_Error_Logger.LoggerCore();
        core.saveLogs(new List<ACMN_Error_Log__c>{log});
        Test.stopTest();
        List<ACMN_Error_Log__c> logs = [SELECT Id, Error_Message__c FROM ACMN_Error_Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('testEventLoggerSingleLogRecord', logs[0].Error_Message__c);
    }

    @IsTest
    static void testEventLoggerPEPublishError() {
        Test.startTest();
        ACMN_Error_Log_PE__e pe = new ACMN_Error_Log_PE__e();
        pe.Error_Message__c = 'Log Date Time is required and this should fail';
        pe.Class_Name__c = 'ACMN_Error_Logger_TESTS';
        pe.Other_Details__c = 'Other Details';
        pe.Log_Date_Time__c = null;
        ACMN_Error_Logger.processPE(new List<ACMN_Error_Log_PE__e>{pe});
        Test.stopTest();
        List<ACMN_Error_Log__c> logs = [SELECT Id, Error_Message__c FROM ACMN_Error_Log__c];
        System.assertEquals(0, logs.size());
    }

    @IsTest
    static void testEventLoggerDisabled() {
        ACMN_Error_Logger.settings.Enabled = false;
        Test.startTest();
        ACMN_Error_Logger.Log('Testing disabled logger');
        Test.stopTest();
        List<ACMN_Error_Log__c> logs = [SELECT Id, Error_Message__c FROM ACMN_Error_Log__c];
        System.assertEquals(0, logs.size());
    }

    @IsTest
    static void testEventPEDisabled() {
        ACMN_Error_Logger.settings.UsePE = false;
        ACMN_Error_Logger.Log('Testing disabled logger');
        List<ACMN_Error_Log__c> logs = [SELECT Id, Error_Message__c FROM ACMN_Error_Log__c];
        System.assertEquals(1, logs.size());
    }

    class CustomException extends Exception {

    }
}