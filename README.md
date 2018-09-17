#Acumen Error Logger Utility

Used to write to a custom object for error logging outside of debug.  
Includes support for Platform Events as well as passing in an exception directly into the static helper class.

Settings are managed via Custom Metadata Types.  By default, logging is turned off.

### Enabling for users
For logging to be enabled, the users must be added to the permission set `ACMN_Error_Logger`.  This permission set gives the user the ability to create the specific platform event records used by the default implementation.

### Logging in Apex
Simple Exception logging:
* `ACMN_Error_Logger.Log(Exception ex);`
* `ACMN_Error_Logger.Log('my error message')`

More verbose example would use this method:

```
ACMN_LogRecord rec = new ACMN_LogRecord(Exception ex, String className, String otherDetails);
ACMN_Error_Logger.Log(new List<ACMN_LogRecord>{rec});
```

### Logging elsewhere
The beauty of using platform events is that you can create one from a flow or an external system.  You can also write your own plugins using the plugin service class and Custom Metadata Type to implement your own logic.

### Updates

* Added support for toggling logging on and off via Custom MetaData Types
* Added generic method for logging a simple string message.  Use `ACMN_Error_Logger.Log('my error message')`
* Added Report to display error logs
* Better support for bulk error logging
* Adding support for custom logging modules / plugins (these will be implementations of abstract classes).  Take a look at `ACMN_Logger_Service_PE.cls` as an example of how to implement your own logging service.
  * Custom logging services must have a related `ACMN_Logger_Setting` Custom Metadata Type record.

### In Progress
* Managed Package

