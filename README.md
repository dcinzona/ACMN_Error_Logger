#Acumen Error Logger Utility

Used to write to a custom object for error logging outside of debug.  
Includes support for Platform Events as well as passing in an exception directly into the static helper class.

Simple Exception logging:
`ACMN_Error_Logger.Log(Exception ex);`

More verbose example would use this method:

`ACMN_Error_Logger.Log(String errorMessage, String ClassName, String OtherDetails, DateTime ErrorLogDateTime);`

Example:
`ACMN_Error_Logger.Log('Something is broken',null,null,null);`

Todo: Add support for passing in a generic message string without requiring null.