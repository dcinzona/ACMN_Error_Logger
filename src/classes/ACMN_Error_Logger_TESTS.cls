/**
 * Created by gtandeciarz on 6/21/18.
 */

@IsTest
private class ACMN_Error_Logger_TESTS {

    static final String PE_SERVICE_API_NAME = 'ACMN_Logger_Service_PE';

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
    static void testEventLoggerNoPermissionSet() {
        removeLoggingPermissionSet();
        setService(true);
        System.debug(JSON.serializePretty(ACMN_Error_Logger.servicesMap.values()));
        Test.startTest();
        ACMN_Error_Logger.Log(new CustomException('manually generated exception message'));
        Test.stopTest();
        assertNoRecords();
    }

    @IsTest
    static void testCheckPermissionsForService(){
        removeLoggingPermissionSet();
        ACMN_Logger_Setting__mdt mdt = getMDTFromJSON(true);
        System.assert(ACMN_Error_Logger.checkPermissionsForService(mdt) == false);
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
        List<ACMN_Logger_Setting__mdt> settings = [SELECT Id FROM ACMN_Logger_Setting__mdt];
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
        ACMN_Logger_Setting__mdt mdt = [SELECT Id, Custom_Logger_Class__c FROM ACMN_Logger_Setting__mdt
        WHERE Custom_Logger_Class__c =: PE_SERVICE_API_NAME];
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
        assignLoggingPermission();
        setService(true);
    }

    static void setService(Boolean enabled){
        ACMN_Logger_Setting__mdt mdt = getMDTFromJSON(enabled);
        ACMN_Logger_Service svc = ACMN_Error_Logger.getServiceInstance(mdt);
        ACMN_Error_Logger.servicesCache = new Map<String, ACMN_Logger_Service>();
        ACMN_Error_Logger.servicesMap.put(PE_SERVICE_API_NAME, svc);
    }

    static String getNamespacePrefix(){
        ApexClass cs =[SELECT NamespacePrefix FROM ApexClass WHERE Name =:'ACMN_Error_Logger'];
        String nameSpacePrefix= cs.NamespacePrefix;
        String prefix = '';
        if(String.isNotEmpty(nameSpacePrefix)){
            prefix = nameSpacePrefix +'__';
        }
        return prefix;
    }

    static ACMN_Logger_Setting__mdt getMDTFromJSON(Boolean enabled){
        String enabledString = enabled ? 'true' : 'false';
        Map<String, SObjectField> fields = Schema.SObjectType.ACMN_Logger_Setting__mdt.fields.getMap();
        JSONGenerator jq = JSON.createGenerator(true);
        jq.writeStartObject();
        for(ACMN_Logger_Setting__mdt m : ACMN_Logger_MDT_DAO.getCustomMetadataRecords()){
            if(m.Custom_Logger_Class__c.equalsIgnoreCase(PE_SERVICE_API_NAME)){
                for(SObjectField fld : fields.values()){
                    if(fld.getDescribe().isCustom()){
                        jq.writeFieldName(fld.getDescribe().getName());
                        String val = m.get(fld.getDescribe().getName()).toString();
                        if(fld.getDescribe().getName().endsWithIgnoreCase('enabled__c')){
                            val = enabledString;
                        }
                        jq.writeString(val);
                    }
                }
            }
        }
        jq.writeEndObject();
        System.debug('*********** jq.getAsString():\n');
        System.debug(jq.getAsString());
        ACMN_Logger_Setting__mdt mdt = (ACMN_Logger_Setting__mdt)JSON.deserialize(jq.getAsString(), ACMN_Logger_Setting__mdt.class);
        System.debug('*********** deserialized JSON:\n');
        System.debug(mdt);
        return mdt;
    }

    static void assignLoggingPermission(){
        // Create PermissionSet with Custom Permission and assign to test user
        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test_Logging_Custom_Permission';
        ps.Label = 'Test';
        insert ps;
        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id FROM CustomPermission
                WHERE DeveloperName =: ACMN_Error_Logger.DEFAULT_CUSTOM_PERMISSION_API_NAME][0].Id;
        insert sea;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = UserInfo.getUserId();
        psa.PermissionSetId = ps.Id;
        insert psa;

        System.assert(ACMN_Error_Logger.hasPermissions);
    }

    static void removeLoggingPermissionSet(){
        List<Id> assigneeIds = new List<Id>{UserInfo.getUserId(), UserInfo.getProfileId()};

        Map<Id,CustomPermission> customPermissionNamesById = new Map<Id, CustomPermission>( [SELECT Id, DeveloperName
                FROM CustomPermission WHERE DeveloperName=: ACMN_Error_Logger.DEFAULT_CUSTOM_PERMISSION_API_NAME] );

        List<SetupEntityAccess> setupEntities =
        [SELECT SetupEntityId
                FROM SetupEntityAccess
                WHERE SetupEntityId IN :customPermissionNamesById.keySet() AND
                        ParentId IN (SELECT PermissionSetId
                                FROM PermissionSetAssignment
                                WHERE AssigneeId in :assigneeIds
                                    )
        ];
        delete setupEntities;

       	setupEntities =
        [SELECT SetupEntityId
                FROM SetupEntityAccess
                WHERE SetupEntityId IN :customPermissionNamesById.keySet() AND
                        ParentId IN (SELECT PermissionSetId
                                FROM PermissionSetAssignment
                                WHERE AssigneeId in :assigneeIds
                                    )
        ];
        System.assertEquals(0,setupEntities.size());
        System.assert(ACMN_Error_Logger.hasPermissions == false);
    }

    class CustomException extends Exception { }
}