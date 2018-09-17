/**
 * Created by gtandeciarz on 9/17/18.
 */

global abstract class ACMN_Logger_Service {
    public ACMN_Logger_Setting__mdt settingsMDT {get; set;}
    global abstract void processRecords(List<String> recordsAsJSON);
}