<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>DEFAULT</label>
    <protected>true</protected>
    <values>
        <field>Custom_Logger_Class__c</field>
        <value xsi:type="xsd:string">ACMN_Logger_Service_PE</value>
    </values>
    <values>
        <field>Custom_Permission_API_Name__c</field>
        <value xsi:type="xsd:string">ACMN_Logging_Enabled</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Uses Platform Events to write to the ACMN Error Log object.  

Requires users the ability to create platform event records for the service to function - which is enabled by assigning the Custom Permission ACMN Logging Enabled.</value>
    </values>
    <values>
        <field>Enabled__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Use_Custom_Permissions__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
</CustomMetadata>
