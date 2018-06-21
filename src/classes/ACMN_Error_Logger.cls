/**
 * Created by gtandeciarz on 6/21/18.
 */

global class ACMN_Error_Logger {

    @TestVisible
    static final String emptyMessageString = 'Error log message is required but was empty';

    global static void Log(System.Exception ex){
        Log(ex, null);
    }
    global static void Log(System.Exception ex, String className){
        Log(ex, className, ex.getStackTraceString());
    }
    global static void Log(System.Exception ex, String className, String otherDetails){
        Log(ex.getMessage(),className,otherDetails,System.now());
    }
    global static void Log(String msg, String className, String otherDetails, DateTime logDate){
        ErrorPayload payload = new ErrorPayload();
        payload.message = msg;
        payload.className = className;
        payload.otherDetails = otherDetails;
        payload.logDateTime = logDate;
        Log(payload);
    }
    global static void Log(ErrorPayload payload){
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
        // Insert all cases in the list.
        if (logs.size() > 0) {
            List<Database.SaveResult> results = Database.insert(logs,false);
        }
    }

    global class ErrorPayload{
        public string message {get;set;}
        public string className {get;set;}
        public string otherDetails {get;set;}
        public DateTime logDateTime {get;set;}
    }
}