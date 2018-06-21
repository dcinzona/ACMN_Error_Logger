/**
 * Created by gtandeciarz on 6/21/18.
 */

global class ACMN_Error_Logger {

    @TestVisible
    static final String emptyMessageString = 'Error log message is required but was empty';
    @TestVisible
    static ACMN_Error_Logger.AppSettings settings = new ACMN_Error_Logger.AppSettings();

    global static void Log(System.Exception ex){
        Log(ex, null);
    }

    global static void Log(System.Exception ex, String className){
        Log(ex, className, ex.getStackTraceString());
    }

    global static void Log(System.Exception ex, String className, String otherDetails){
        Log(ex.getMessage(),className,otherDetails,System.now());
    }

    global static void Log(String msg){
        Log(msg,null,null,System.now());
    }

    global static void Log(String msg, String className, String otherDetails, DateTime logDate){
        ErrorPayload payload = new ErrorPayload();
        payload.message = msg;
        payload.className = className;
        payload.otherDetails = otherDetails;
        payload.logDateTime = logDate;
        Log(payload);
    }

    static void Log(ErrorPayload payload){
        String msg = payload.message;
        String className = payload.className;
        String otherDetails = payload.otherDetails;
        DateTime logDateTime = payload.logDateTime != null ? payload.logDateTime : System.Now();
        if(String.isEmpty(msg)){
            msg = emptyMessageString;
            System.debug(msg);
            className = String.isEmpty(className) ? ACMN_Error_Logger.class.getName() : className;
            otherDetails = 'Original Log Details: \n\n' + JSON.serialize(payload);
        }
        ACMN_Error_Log_PE__e pe = new ACMN_Error_Log_pe__e();
        pe.Error_Message__c = msg;
        pe.Class_Name__c = className;
        pe.Other_Details__c = otherDetails;
        pe.Log_Date_Time__c = logDateTime;
        Log(pe);
    }

    global static void Log(ACMN_Error_Log_PE__e pe){
        Log(new List<ACMN_Error_Log_PE__e>{pe});
    }

    global static void Log(List<ACMN_Error_Log_PE__e> events){

        if(settings.UsePE == false || settings.Enabled == false){
            //convert to standard record object for straight DML
            List<ACMN_Error_Log__c> records = new List<ACMN_Error_Log__c>();
            for(ACMN_Error_Log_PE__e pe : events){
                records.add(new ACMN_Error_Log__c(
                        Error_Message__c = pe.Error_Message__c,
                        Class_Name__c = pe.Class_Name__c,
                        Other_Details__c = pe.Other_Details__c,
                        Log_Date_Time__c = pe.Log_Date_Time__c
                ));
            }
            Log(records);
            return;
        }
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(events);

        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
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

    //Used by the Platform Event Trigger but can be called manually
    global static void Log(ACMN_Error_Log__c log){
        Log(new List<ACMN_Error_Log__c>{log});
    }

    global static void Log(List<ACMN_Error_Log__c> logs){
        if(settings.Enabled == false){
            return;
        }
        // Insert all cases in the list.
        if (logs.size() > 0) {
            List<Database.SaveResult> results = Database.insert(logs,false);
        }
    }

    @TestVisible
    class AppSettings {
        public boolean Enabled {get;set;}
        public boolean UsePE {get;set;}
        public integer TrimAfterDays {get;set;}
        AppSettings(){
            this.Enabled = true;
            this.UsePE = true;
            this.TrimAfterDays = 30;
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
        }
    }

    global class ErrorPayload{
        public string message {get;set;}
        public string className {get;set;}
        public string otherDetails {get;set;}
        public DateTime logDateTime {get;set;}
    }
}