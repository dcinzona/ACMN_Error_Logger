/* */
delete [select id from ACMN_Error_Log__c];
List<ACMN_LogRecord> recs = new List<ACMN_LogRecord>();
for(integer i = 0; i <= 150 ; i++){
    Integer rand = Math.round(Math.random()*100);
    Integer val = Math.mod(rand, 30);
    system.debug(val);
    recs.add(new ACMN_LogRecord('Error Message Bulk ' + (i+1) + ' - ran:' + val));
    recs[i].logDate = recs[i].logDate.addDays(val);
}
//EventBus.publish(new gmt__ACMN_Error_Log_PE__e(gmt__Error_Message__c = recs[0].message, gmt__Log_Date_Time__c = recs[0].logDate));
ACMN_Error_Logger.Log(recs);
/* */
//System.debug(ACMN_Error_Logger.UsePE ? 'UsePE = true' : 'UsePE = false');