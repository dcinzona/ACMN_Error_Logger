/**
 * Created by gtandeciarz on 6/21/18.
 */

public class ACMN_Error_Logger {

    public static Boolean Enabled {get { return settings.Enabled; } set { settings.Enabled = value; }}
    public static Boolean UsePE {get { return settings.UsePE; } set { settings.UsePE = value; }}
    @TestVisible
    static ACMN_Error_Logger.AppSettings settings = new ACMN_Error_Logger.AppSettings();
    @TestVisible
    static ACMN_Error_Logger.LoggerCore logger = new ACMN_Error_Logger.LoggerCore();

    public static void Log(String msg){
        Log(new ACMN_LogRecord(msg));
    }

    public static void Log(List<String> messages){
        List<ACMN_LogRecord> recs = new List<ACMN_LogRecord>();
        for(String msg : messages){
            recs.add(new ACMN_LogRecord(msg));
        }
        Log(recs);
    }

    public static void Log(System.Exception ex){
        Log(new List<Exception>{ex});
    }

    public static void Log(ACMN_LogRecord rec){
        Log(new List<ACMN_LogRecord>{rec});
    }

    public static void Log(List<Exception> exceptions){
        logger.processRecords(logger.convertExceptions(exceptions));
    }
    public static void Log(List<ACMN_LogRecord> logs){
        logger.processRecords(logs);
    }

    // Processes the Platform Event notification from the Platform Event Trigger
    public static void processPE(List<ACMN_Error_Log_PE__e> events){
        List<ACMN_Error_Log__c> records = new List<ACMN_Error_Log__c>();
        for(ACMN_Error_Log_PE__e pe : events){
            records.add(new ACMN_Error_Log__c(
                    Error_Message__c = pe.Error_Message__c,
                    Class_Name__c = pe.Class_Name__c,
                    Other_Details__c = pe.Other_Details__c,
                    StackTraceString__c = pe.StackTraceString__c,
                    Log_Date_Time__c = pe.Log_Date_Time__c
            ));
        }
        logger.saveLogs(records);
    }

    @TestVisible
    class LoggerCore {
        public void processRecords(List<ACMN_LogRecord> records){
            List<ACMN_Error_Log_PE__e> pes = new List<ACMN_Error_Log_PE__e>();
            records.sort();
            for(ACMN_LogRecord rec : records){
                if(!String.isEmpty(rec.message)){
                    System.debug(rec.message);
                    pes.add(rec.getPlatformEventObject());
                }
            }
            if(ACMN_Error_Logger.Enabled && pes.size() > 0){
                if(ACMN_Error_Logger.UsePE && Schema.SObjectType.ACMN_Error_Log_PE__e.isCreateable()){
                    List<Database.SaveResult> sr = EventBus.publish(pes);
                    processSaveResults(sr);
                } else {
                    processPE(pes);
                }
            }
        }

        public List<ACMN_LogRecord> convertExceptions(List<Exception> exs){
            List<ACMN_LogRecord> recs = new List<ACMN_LogRecord>();
            for(Exception ex : exs){
                recs.add(new ACMN_LogRecord(ex));
            }
            return recs;
        }
        //This method should only be executed by the Platform Event User (Automated Process user)
        public void saveLogs(List<ACMN_Error_Log__c> logs){
            // Insert all cases in the list.
            if (logs.size() > 0 && Schema.SObjectType.ACMN_Error_Log__c.isCreateable()) {
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
        public Boolean Enabled {get;set;}
        public Boolean UsePE {get;set;}
        public Integer TrimAfterDays {get;set;}
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