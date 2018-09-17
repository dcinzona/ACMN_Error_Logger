/**
 * Created by gtandeciarz on 6/28/18.
 */

trigger ACMN_Error_Logger_PE_Trigger on ACMN_Error_Log_PE__e (after insert) {
    //Convert the Platform Event Notifications into Error Log Records for saving into the database
    ACMN_Logger_Service_PE.savePlatformEventsAsLogs(Trigger.new);
}