/**
 * Created by gtandeciarz on 6/21/18.
 */

public class ACMN_Error_Logger {

    public abstract class Service {
        public Boolean isEnabled {get;set;}
        public Boolean saveToSalesforce{get;set;}
        public abstract void processRecords(List<String> recordsAsJSON);
    }

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
        List<ACMN_LogRecord> recs = new List<ACMN_LogRecord>();
        for(Exception ex : exceptions){
            recs.add(new ACMN_LogRecord(ex));
        }
        Log(recs);
    }

    public static void Log(List<ACMN_LogRecord> records){
        records.sort();
        List<String> logsAsJSON = new List<String>();
        for(ACMN_LogRecord rec : records){
            if(!String.isEmpty(rec.message)){
                System.debug(rec.message);
                logsAsJSON.add(JSON.serialize(rec));
            }
        }
        sendToServices(logsAsJSON);
    }

    public static void processSaveResults(List<Database.SaveResult> srList){
        for(Database.SaveResult sr : srList){
            if (sr.isSuccess()) {
                System.debug('Successfully published error log event: ' + sr.getId());
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

    //Calling callingClass is required.  Queries the custom metadata type to check if records should be saved to Salesforce.
    //CallingClass should be the name of your service class
    public static void saveToSalesforce(List<ACMN_Error_Log__c> records, String callingClass){
        if(!String.isEmpty(callingClass)){
            System.debug('**** saveToSalesforce: callingClass: ' + callingClass);
            Boolean shouldSave = servicesMap.containsKey(callingClass) &&
                    servicesMap.get(callingClass).saveToSalesforce == true &&
                    records.size() > 0 &&
                    Schema.SObjectType.ACMN_Error_Log__c.isCreateable();
            if(shouldSave) {
                ACMN_Error_Logger.processSaveResults(Database.insert(records,false));
            }
        }
    }

    public static Map<String, ACMN_Error_Logger.Service> servicesMap {
        get {
            if(servicesCache == null){
                servicesCache = new Map<String, ACMN_Error_Logger.Service>();

                for(ACMN_Logger_Setting__mdt mdt : [SELECT
                        Enabled__c,
                        Custom_Logger_Class__c,
                        Save_To_Salesforce__c
                        FROM ACMN_Logger_Setting__mdt
                        WHERE Enabled__c = TRUE
                        ORDER BY Id DESC]){

                    servicesCache.put(mdt.Custom_Logger_Class__c, getServiceInstance(mdt));

                }
            }
            return servicesCache;
        }
    }
    @TestVisible
    static Map<String, ACMN_Error_Logger.Service> servicesCache {get;set;}

    @TestVisible
    static void sendToServices(List<String> logs){
        try{
            for(ACMN_Error_Logger.Service svc : servicesMap.values()){
                svc.processRecords( logs );
            }
        } catch (Exception ex){
            System.debug(ex.getMessage());
        }
    }

    @TestVisible
    static ACMN_Error_Logger.Service getServiceInstance(ACMN_Logger_Setting__mdt mdt){
        ACMN_Error_Logger.Service svc;
        try {
            svc = (ACMN_Error_Logger.Service)Type.forName(mdt.Custom_Logger_Class__c).newInstance();
            svc.isEnabled = mdt.Enabled__c;
            svc.saveToSalesforce = mdt.Save_To_Salesforce__c;
        } catch (Exception ex){
            System.debug(ex.getMessage());
        }
        return svc;
    }

}