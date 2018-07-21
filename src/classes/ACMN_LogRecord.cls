/**
 * Created by gtandeciarz on 7/10/18.
 */

public class ACMN_LogRecord implements Comparable{
    public String message {get;set;}
    public String className {get;set;}
    public String otherDetails {get;set;}
    public String stacktrace {get;set;}
    public DateTime logDate {get;set;}

    public ACMN_LogRecord(Exception ex){
        setVars(ex.getMessage(),null,getOtherDetailsExceptionTypeString(ex),ex.getStackTraceString(),null);
    }

    public ACMN_LogRecord(String msg){
        setVars(msg,null,null,null,null);
    }

    public ACMN_LogRecord(Exception ex, String className, String otherDetails){
        String details  = String.isEmpty(otherDetails) ? getOtherDetailsExceptionTypeString(ex) : otherDetails;
        setVars(ex.getMessage(),className, details, ex.getStackTraceString(), null);
    }

    public ACMN_LogRecord(String msg, String className, String otherDetails){
        setVars(msg,className,otherDetails,null,null);
    }

    @TestVisible
    static String getOtherDetailsExceptionTypeString(Exception ex){
        return 'Exception Type: ' + ex.getTypeName();
    }

    @TestVisible
    void setVars(String msg, String className, String otherDetails, String stackTrace, Datetime dt){
        this.message = msg;
        this.className = className;
        this.otherDetails = otherDetails;
        this.stacktrace = stackTrace;
        this.logDate = dt == null ? System.now() : dt;
    }

    public ACMN_Error_Log__c getSObject(){
        ACMN_Error_Log__c log = new ACMN_Error_Log__c();
        log.Error_Message__c = this.message;
        log.Class_Name__c = this.className;
        log.Other_Details__c = this.otherDetails;
        log.StackTraceString__c = this.stacktrace;
        log.Log_Date_Time__c = this.logDate;
        return log;
    }

    public ACMN_Error_Log_PE__e getPlatformEventObject(){
        ACMN_Error_Log_PE__e log = new ACMN_Error_Log_PE__e();
        log.Error_Message__c = this.message;
        log.Class_Name__c = this.className;
        log.Other_Details__c = this.otherDetails;
        log.StackTraceString__c = this.stacktrace;
        log.Log_Date_Time__c = this.logDate;
        return log;
    }

    public Integer compareTo( Object objToCompare ) {
        ACMN_LogRecord obj2 = (ACMN_LogRecord)objToCompare;
        if(logDate > obj2.logDate) return 1;
        if(logDate < obj2.logDate) return -1;
        return 0;
    }
}