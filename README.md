#Acumen Error Logger Utility

Used to write to a custom object for error logging outside of debug.  
Includes support for Platform Events as well as passing in an exception directly into the static helper class.

Settings are managed via Custom Metadata Types.  By default, logging is turned on.

Simple Exception logging:
* `ACMN_Error_Logger.Log(Exception ex);`
* `ACMN_Error_Logger.Log('my error message')`

More verbose example would use this method:

`ACMN_Error_Logger.Log(String errorMessage, String ClassName, String OtherDetails, DateTime ErrorLogDateTime);`

Example:
`ACMN_Error_Logger.Log('Something is broken',null,null,null);`

### Updates

* Added support for toggling logging on and off via Custom MetaData Types
* Added generic method for logging a simple string message.  Use `ACMN_Error_Logger.Log('my error message')`
