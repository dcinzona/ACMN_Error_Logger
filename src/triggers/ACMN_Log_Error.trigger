trigger ACMN_Log_Error on ACMN_Error_Log_PE__e (after insert) {
    // List to hold all error logs to be created.
    List<ACMN_Error_Log__c> logs = new List<ACMN_Error_Log__c>();
       
    // Iterate through each notification.
    for (ACMN_Error_Log_PE__e ev : Trigger.new) {
        System.debug('Logging Error: ' + ev.Error_Message__c);
        ACMN_Error_Log__c log = new ACMN_Error_Log__c();
        log.Class_Name__c = ev.Class_Name__c;
        log.Error_Message__c = ev.Error_Message__c;
        log.Log_Date_Time__c = ev.Log_Date_Time__c;
        log.Other_Details__c = ev.Other_Details__c;
        logs.add(log);
    }

    ACMN_Error_Logger.Log(logs);
}