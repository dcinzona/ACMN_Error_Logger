/**
 * Created by gtandeciarz on 7/20/18.
 *
 * Default service implementation example used to store records via Salesforce Platform Events.
 * Create your own services and bind them via the Custom Metadata Type record
 */

public class ACMN_Logger_Service_PE extends ACMN_Error_Logger.Service{

    //default usage publishes to the platform events message bus
    public override void processRecords( List<String> recordsAsJSON ) {
        List<ACMN_Error_Log_PE__e> pes = new List<ACMN_Error_Log_PE__e>();
        for(String record : recordsAsJSON){
            ACMN_LogRecord rec = (ACMN_LogRecord)JSON.deserialize(record, ACMN_LogRecord.class);
            pes.add(rec.getPlatformEventObject());
        }
        publishPE(pes);
    }

    @TestVisible
    private void publishPE(List<ACMN_Error_Log_PE__e> pes){
        if(Schema.SObjectType.ACMN_Error_Log_PE__e.isCreateable() && !pes.isEmpty()){
            ACMN_Error_Logger.processSaveResults(EventBus.publish(pes));
        }
    }

    //Used by the Platform Events trigger to save records to the Salesforce database
    public static void savePlatformEventsAsLogs(List<ACMN_Error_Log_PE__e> events){
        List<ACMN_Error_Log__c> records = new List<ACMN_Error_Log__c>();
        for(ACMN_Error_Log_PE__e pe : events){
            records.add(new ACMN_Error_Log__c(
                    Error_Message__c = pe.Error_Message__c,
                    Class_Name__c = pe.Class_Name__c,
                    Other_Details__c = pe.Other_Details__c,
                    StackTraceString__c = pe.StackTraceString__c,
                    Log_Date_Time__c = pe.Log_Date_Time__c,
                    Running_User__c = pe.Running_User_ID__c
            ));
        }
        ACMN_Error_Logger.saveToSalesforce(records, 'ACMN_Logger_Service_PE');
    }
}