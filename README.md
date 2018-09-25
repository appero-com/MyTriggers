# MyTriggers

Lightweight Custom Metadata driven Trigger Framework that scales to your needs. Provided with <3 by appero.com

## Installation

### Developer Controlled Package

* Production Instances: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1i000000gNXOAA2
* Sandbox Instances: https://test.salesforce.com/packaging/installPackage.apexp?p0=04t1i000000gNXOAA2
### From Source
Clone this repo

```
git clone https://github.com/appero-com/MyTriggers
```

Create a scratch org and push source 
```
sfdx force:org:create -a MyTriggers -s -f config/project-scratch-def.json && sfdx force:source:push -r MyTriggers/framework
```

or deploy to your org 

```
sfdx force:source:convert -r MyTriggers/framework -d src && sfdx force:mdapi:deploy -u <username> -d src
```


## Resources

[TriggerX by Sebastian Wagner](https://github.com/se6wagner/TriggerX)


## Issues

Use the issues page

## Contribution

PRs are welcome

# Documentation

## [MyTriggers](MyTriggers.cls#L16)

[global virtual class MyTriggers](MyTriggers.cls#L16)

Leightweight Custom Metadata driven Trigger Framework that scales to your needs  
  
: info@appero.com

## Properties

records

[global sObject\[\] records](MyTriggers.cls#L32)

cast records to appropriate sObjectType in implementations

## Methods

-   [addUpdatedIds](#addUpdatedIds)
    
    add set of ids to updatedIds
    
-   [disable](#disable)
    
    disable disables all events for System.Type MyClass
    
-   [disable](#disable)
    
    disable disables all events for the trigger handler with given namespace and classname Method also works in subscriber org with hidden (public) trigger handlers from managed package
    
-   [disable](#disable)
    
    disable disable all specificed events for the System.Type MyClass
    
-   [disable](#disable)
    
    disable all specificed events for given ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
    
-   [disable](#disable)
    
    disable a single event for System.Type MyClass
    
-   [disable](#disable)
    
    disable a single event for ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
    
-   [doConstruct](#doConstruct)
    
    used instead of constructor since handlers are instanciated with an empty contructor
    
-   [enable](#enable)
    
    removes all disabled events for the System.Type MyClass
    
-   [enable](#enable)
    
    removes all disabled events for given ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
    
-   [enable](#enable)
    
    enable all specificed events for the System.Type MyClass
    
-   [enable](#enable)
    
    enable all specificed events for given ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
    
-   [enable](#enable)
    
    enable a single event for System.Type MyClass
    
-   [enable](#enable)
    
    enable a single event for ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
    
-   [getAfterEvents](#getAfterEvents)
    
    getAfterEvents list of all AFTER System.TriggerOperation enums
    
-   [getBeforeEvents](#getBeforeEvents)
    
    getBeforeEvents list of all BEFORE System.TriggerOperation enums
    
-   [getChangedFields](#getChangedFields)
    
    returns a list of changed fields based on provided fieldList list
    
-   [getChangedFields](#getChangedFields)
    
    returns a list of changed fields based on provided fieldList list
    
-   [getDeleteEvents](#getDeleteEvents)
    
    getDeleteEvents all delete events
    
-   [getDisabledEvents](#getDisabledEvents)
    
    returns set of disabled events
    
-   [getDisabledEvents](#getDisabledEvents)
    
    returns set of disabled events Method also works in subscriber org with hidden (public) trigger handlers from managed package
    
-   [getInsertEvents](#getInsertEvents)
    
    getInsertEvents all insert events
    
-   [getRecordsNotYetProcessed](#getRecordsNotYetProcessed)
    
    returns a list of objects that have not been processed yet
    
-   [getUpdatedIds](#getUpdatedIds)
    
    return all updated ids
    
-   [getUpdateEvents](#getUpdateEvents)
    
    getUpdateEvents all update events
    
-   [hasChangedFields](#hasChangedFields)
    
    returns true if a value of one of the specified fields has changed
    
-   [hasChangedFields](#hasChangedFields)
    
    returns true if a value of one of the specified fields has changed
    
-   [isDisabled](#isDisabled)
    
    isDisabled returns true if the specified event is disabled
    
-   [isDisabled](#isDisabled)
    
    isDisabled returns true if the specified event is disabled Method also works in subscriber org with hidden (public) trigger handlers from managed package
    
-   [myTriggers](#myTriggers)
    
    Global Constructor reserved for future use
    
-   [onAfterDelete](#onAfterDelete)
    
    executed to perform AFTER\_DELETE operations
    
-   [onAfterInsert](#onAfterInsert)
    
    executed to perform AFTER\_INSERT operations
    
-   [onAfterUndelete](#onAfterUndelete)
    
    executed to perform AFTER\_UNDELETE operations
    
-   [onAfterUpdate](#onAfterUpdate)
    
    executed to perform AFTER\_UPDATE operations
    
-   [onBeforeDelete](#onBeforeDelete)
    
    executed to perform BEFORE\_DELETE operations
    
-   [onBeforeInsert](#onBeforeInsert)
    
    executed to perform BEFORE\_INSERT operations
    
-   [onBeforeUpdate](#onBeforeUpdate)
    
    executed to perform BEFORE\_UPDATE operations
    
-   [run](#run)
    
    Entry point of myTriggers framework - called from implementations
    
-   [setAllowedTriggerEvents](#setAllowedTriggerEvents)
    
    loads trigger event settings MyTriggerSetting\_\_mdt
    
-   [setAllowedTriggerEvents](#setAllowedTriggerEvents)
    
    loads trigger event settings MyTriggerSetting\_\_mdt Method also works in subscriber org with hidden (public) trigger handlers from managed package
    
-   [toStringEvents](#toStringEvents)
    
    converts a Set of Event enums into Strings
    

## addUpdatedIds

[global static void addUpdatedIds(Set<Id> idSet)](MyTriggers.cls#L145)

add set of ids to updatedIds

### Parameters

- idSet - Set, usally Trigger.newMap.keyset()

## disable

[global static void disable(Type MyClass)](MyTriggers.cls#L401)

disable disables all events for System.Type MyClass

## disable

[global static void disable(String namespacePrefix, String className)](MyTriggers.cls#L416)

disable disables all events for the trigger handler with given namespace and classname
Method also works in subscriber org with hidden (public) trigger handlers from managed package

## disable

[global static void disable(Type MyClass, System.TriggerOperation\[\] events)](MyTriggers.cls#L449)

disable all specificed events for the System.Type MyClass

## disable

[global static void disable(String namespacePrefix, String className, System.TriggerOperation\[\] events)](MyTriggers.cls#L460)

disable all specificed events for given ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers


## disable

[global static void disable(Type MyClass, System.TriggerOperation event)](MyTriggers.cls#L490)

disable a single event for System.Type MyClass

## disable

[global static void disable(String namespacePrefix, String className, System.TriggerOperation event)](MyTriggers.cls#L501)

disable a single event for ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

## doConstruct

[global virtual myTriggers doConstruct(sObject\[\] records)](MyTriggers.cls#L47)

used instead of constructor since handlers are instanciated with an empty contructor

### Parameters

- records - Array of current sObjects. For INSERT & UPDATE Trigger.new otherwise Trigger.old

## enable

[global static void enable(Type MyClass)](MyTriggers.cls#L429)

removes all disabled events for the System.Type MyClass

## enable

[global static void enable(String namespacePrefix, String className)](MyTriggers.cls#L439)

removes all disabled events for given ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

## enable

[global static void enable(Type MyClass, System.TriggerOperation\[\] events)](MyTriggers.cls#L469)

enable all specificed events for the System.Type MyClass

## enable

[global static void enable(String namespacePrefix, String className, System.TriggerOperation\[\] events)](MyTriggers.cls#L480)

enable all specificed events for given ClassName and Namespace. Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

## enable

[global static void enable(Type MyClass, System.TriggerOperation event)](MyTriggers.cls#L510)

enable a single event for System.Type MyClass

## enable

[global static void enable(String namespacePrefix, String className, System.TriggerOperation event)](MyTriggers.cls#L521)

enable a single event for ClassName and Namespace. Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

## getAfterEvents

[global static System.TriggerOperation\[\] getAfterEvents()](MyTriggers.cls#L389)

getAfterEvents list of all AFTER System.TriggerOperation enums

## getBeforeEvents

[global static System.TriggerOperation\[\] getBeforeEvents()](MyTriggers.cls#L378)

getBeforeEvents list of all BEFORE System.TriggerOperation enums


## getChangedFields

[global static String\[\] getChangedFields(String\[\] fieldList, sObject record, sObject recordOld)](MyTriggers.cls#L217)

returns a list of changed fields based on provided fieldList list

## getChangedFields

[global static sObjectField\[\] getChangedFields(sObjectField\[\] fieldList, sObject record, sObject recordOld)](MyTriggers.cls#L237)

returns a list of changed fields based on provided fieldList list


## getDeleteEvents

[global static System.TriggerOperation\[\] getDeleteEvents()](MyTriggers.cls#L368)

getDeleteEvents all delete events

## getDisabledEvents

[global static Set<String> getDisabledEvents(Type MyClass)](MyTriggers.cls#L303)

returns set of disabled events

### Return Value

- Set of disabled Event Namens (e.g. 'AFTER\_UPDATE')

## getDisabledEvents

[global static Set<String> getDisabledEvents(String namespacePrefix, String className)](MyTriggers.cls#L318)

returns set of disabled events. Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

## getInsertEvents

[global static System.TriggerOperation\[\] getInsertEvents()](MyTriggers.cls#L350)

get all insert events

## getRecordsNotYetProcessed

[global protected sObject\[\] getRecordsNotYetProcessed()](MyTriggers.cls#L163)

returns a list of objects that have not been processed yet

## getUpdatedIds

[global static Set<Id> getUpdatedIds()](MyTriggers.cls#L154)

return all updated ids

### Return Value

- set of updated/already touched Ids

## getUpdateEvents

[global static System.TriggerOperation\[\] getUpdateEvents()](MyTriggers.cls#L359)

getUpdateEvents all update events

### Return Value

System.TriggerOperation\[\]

## hasChangedFields

[global static Boolean hasChangedFields(String\[\] fieldList, sObject record, sObject recordOld)](MyTriggers.cls#L185)

returns true if a value of one of the specified fields has changed

## hasChangedFields

[global static Boolean hasChangedFields(sObjectField\[\] fieldList, sObject record, sObject recordOld)](MyTriggers.cls#L201)

returns true if a value of one of the specified fields has changed

## isDisabled

[global static Boolean isDisabled(Type MyClass, System.TriggerOperation event)](MyTriggers.cls#L329)

returns true if the specified event is disabled

## isDisabled

[global static Boolean isDisabled(String namespacePrefix, String className, System.TriggerOperation event)](MyTriggers.cls#L341)

returns true if the specified event is disabled Method. Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

## myTriggers

[global myTriggers()](MyTriggers.cls#L38)

Global Constructor reserved for future use

## onAfterDelete

[global virtual void onAfterDelete()](MyTriggers.cls#L87)

executed to perform AFTER\_DELETE operations

## onAfterInsert

[global virtual void onAfterInsert()](MyTriggers.cls#L65)

executed to perform AFTER\_INSERT operations

## onAfterUndelete

[global virtual void onAfterUndelete()](MyTriggers.cls#L92)

executed to perform AFTER\_UNDELETE operations

## onAfterUpdate

[global virtual void onAfterUpdate(Map<Id,sObject> triggerOldMap)](MyTriggers.cls#L77)

executed to perform AFTER\_UPDATE operations

## onBeforeDelete

[global virtual void onBeforeDelete()](MyTriggers.cls#L82)

executed to perform BEFORE\_DELETE operations

## onBeforeInsert

[global virtual void onBeforeInsert()](MyTriggers.cls#L60)

executed to perform BEFORE\_INSERT operations

## onBeforeUpdate

[global virtual void onBeforeUpdate(Map<Id,sObject> triggerOldMap)](MyTriggers.cls#L71)

executed to perform BEFORE\_UPDATE operations

## run

[global static void run()](MyTriggers.cls#L102)

Entry point of myTriggers framework - called from implementations

## setAllowedTriggerEvents

[global static void setAllowedTriggerEvents(Type triggerHandlerType, Boolean forceInit)](MyTriggers.cls#L263)

loads trigger event settings MyTriggerSetting\_\_mdt

### Parameters

- triggerHandlerType
- forceInit - force reload of event settings

## setAllowedTriggerEvents

[global static void setAllowedTriggerEvents(String namespacePrefix, String className, Boolean forceInit)](MyTriggers.cls#L293)

loads trigger event settings MyTriggerSetting\_\_mdt records. Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

### Parameters

- namespacePrefix
- className
- forceInit - force reload of event settings

## toStringEvents

[global static Set<String> toStringEvents(System.TriggerOperation\[\] events)](MyTriggers.cls#L531)

converts a Set of Event enums into Strings