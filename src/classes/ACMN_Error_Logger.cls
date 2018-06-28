/**
 * Created by gtandeciarz on 6/21/18.
 */

public class ACMN_Error_Logger {

    @TestVisible
    static ACMN_Error_Logger.AppSettings settings = new ACMN_Error_Logger.AppSettings();
    public static Boolean Enabled {get { return settings.Enabled; } set { settings.Enabled = value; }}
    public static Boolean UsePE {get { return settings.UsePE; } set { settings.UsePE = value; }}

    public static void Log(String msg){
        Log(msg,null,null,System.now());
    }

    public static void Log(System.Exception ex){
        Log(ex, null);
    }

    public static void Log(System.Exception ex, String className){
        Log(ex, className, ex.getStackTraceString());
    }

    public static void Log(System.Exception ex, String className, String otherDetails){
        Log(ex.getMessage(),className,otherDetails,System.now());
    }

    public static void Log(String msg, String className, String otherDetails, DateTime logDate){
        ACMN_Error_Logger.LoggerCore logger = new ACMN_Error_Logger.LoggerCore();
        logger.processPayload(msg,className,otherDetails,logDate);
    }

    // Processes the Platform Event notification from the Platform Event Trigger
    public static void processPE(List<ACMN_Error_Log_PE__e> events){
        List<ACMN_Error_Log__c> records = new List<ACMN_Error_Log__c>();
        for(ACMN_Error_Log_PE__e pe : events){
            records.add(new ACMN_Error_Log__c(
                    Error_Message__c = pe.Error_Message__c,
                    Class_Name__c = pe.Class_Name__c,
                    Other_Details__c = pe.Other_Details__c,
                    Log_Date_Time__c = pe.Log_Date_Time__c
            ));
        }
        ACMN_Error_Logger.LoggerCore logger = new ACMN_Error_Logger.LoggerCore();
        logger.saveLogs(records);
    }

    @TestVisible
    class LoggerCore {
        //Core Logic
        public void processPayload(String msg, String className, String otherDetails, DateTime logDate){
            if(String.isEmpty(msg)){
                return;
            }
            DateTime logDateTime = logDate != null ? logDate : System.Now();
            //Log the error message to Salesforce Debug as well.
            System.debug(msg);
            if(ACMN_Error_Logger.Enabled){
                ACMN_Error_Log_PE__e pe = new ACMN_Error_Log_PE__e();
                pe.Error_Message__c = msg;
                pe.Class_Name__c = className;
                pe.Other_Details__c = otherDetails;
                pe.Log_Date_Time__c = logDateTime;

                if(ACMN_Error_Logger.UsePE && Schema.sObjectType.ACMN_Error_Log_PE__e.isCreateable()){
                    Database.SaveResult sr = EventBus.publish(pe);
                    processSaveResults(new List<Database.SaveResult>{sr});
                } else {
                    processPE(new List<ACMN_Error_Log_PE__e>{pe});
                }
            }
        }

        //This method should only be executed by the Platform Event User (Automated Process user)
        public void saveLogs(List<ACMN_Error_Log__c> logs){
            // Insert all cases in the list.
            if (logs.size() > 0 && Schema.sObjectType.ACMN_Error_Log__c.isCreateable()) {
                processSaveResults(Database.insert(logs,false));
            }
        }

        void processSaveResults(List<Database.SaveResult> srList){
            for(Database.SaveResult sr : srList){
                if (sr.isSuccess()) {
                    System.debug('Successfully published error log event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                    }
                }
            }
        }
    }


    @TestVisible
    public class AppSettings {
        public boolean Enabled {get;set;}
        public boolean UsePE {get;set;}
        public integer TrimAfterDays {get;set;}
        AppSettings(){
            this.Enabled = true;
            this.UsePE = true;
            this.TrimAfterDays = 30;
            try{
                List<ACMN_Logger_Setting__mdt> logSettings = [SELECT
                        Use_Platform_Events__c,
                        Enabled__c,
                        Days_To_Keep__c
                        FROM ACMN_Logger_Setting__mdt
                        WHERE Label = 'DEFAULT'];
                if(logSettings.size() > 0){
                    this.Enabled = logSettings[0].Enabled__c;
                    this.UsePE = logSettings[0].Use_Platform_Events__c;
                    this.TrimAfterDays = Integer.valueOf(logSettings[0].Days_To_Keep__c);
                }
            } catch ( Exception ex ){

            }
        }
    }
}