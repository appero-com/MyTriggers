# MyTriggers

Lightweight Custom Metadata driven Trigger Framework that scales to your needs. Extended from [TriggerX](https://github.com/se6wagner/TriggerX) by Seb Wagner, provided with <3 by appero.com

## ChangeLog

### 09-2019

- added `SObjectApiName__c` to `MyTrigger Settings` to accomodate for sObjects not available in the `sObject` picklist
- added `IsByPassAllowed__c` to `MyTrigger Settings` and a custom permission `bypassMyTriggers`. This allows exclude certain users from trigger execution.

### 10-2018

- initial release

## Installation

### Developer Controlled Package

- Production Instances: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1i000000gZ4HAAU
- Sandbox Instances: https://test.salesforce.com/packaging/installPackage.apexp?p0=04t1i000000gZ4HAAU

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

## Issues / Known Limitations

- Custom Metadata Types cannot reference `User sObject` currently.

Found something? Use the issues page

## Contribution

PRs are welcome

# MyTriggers HowTo

MyTriggers is a lightweight Custom Metadata driven Trigger Framework that scales to your needs.
It is based upon the foundation of [TriggerX that Sebastian Wagner wrote in 2013](https://github.com/se6wagner/TriggerX), which was a perfect starting point since it covered all one could wish for in a trigger handler except Custom Metadata Types.

The general approach behind MyTriggers is

- run all triggers through one central handler, even across namespaces.
- design the orchestration of logic in a way that allows you to declarative wire things differently
- think about Triggers in new ways: configurable, closer to business needs/processes than database changes

## Dreamforce 2018: "Route Your Triggers Like a Pro"

MyTriggers was released by [appero GmbH](http://www.appero.com) and publicly presented by [Christian Szandor Knapp](https://www.shoreforce.de) and [Daniel Stange](https://blog.danielstange.de).

If you want to recap the session, a recording will be available a few weeks after Dreamforce. The session discussion and assets will be stored at [the session's tralblazer commuinty page](https://bit.ly/df18triggeers).

You can follow Szandor on Twitter at [@ch_sz_knapp](https://twitter.com/ch_sz_knapp), Daniel is [@stangomat](https://twitter.com/stangomat).

## A change in perspective - a Business Process Centric Approach

When you reflect upon what your triggers actually do, you may hardly ever say that they are pieces of code that react to changes in data whenever they happen.
You'd rather describe them as _entry points for your business processes_ that, for example, create an onboarding case for new customers whenever an opportunity closes, but only for accounts that never had a closed opportunity before.

Now, with that description in mind, we should build our trigger handlers in a way that they can react to change in business requirements, and that they handle a lot more than just the records that initially started the process.

This is why MyTriggers has a _records_ property that contains any sObject type (but all the records that are handled currently), and this is why there are Custom Metadata Type records that can be activated, grouped by names, put in a sequential orders (and re-ordered if need be).

You decide what happens when a trigger fires - the constant is that it will always open one central instance of MyTriggers that orchestrates your business processes according to your Metadata config.

## General Design

- Trigger execution will be started by instantion of MyTriggers and calling the run() method from a Trigger
- records contains all objects currently handled by the trigger context
- recordsNotYetProcessed can be inspected through their getter method
- Ids of updated records can be accessed through their getter method
- handled trigger contexts can be accessed through their setter method
- you can enable() or disable() specific handler steps or trigger contexts at runtime
- for each handler step, MyTriggers has to be extended
- each handler step orchestrates its logic through overriding methods specific for the trigger contexts.
  _ onBeforeInsert()
  _ onAfterInsert()
  _ onBeforeUpdate()
  _ onAfterUpdate()
  _ onBeforeDelete()
  _ onAfterDelete() \* onAfterUndelete()

## Registering MyTriggers for all Trigger contexts

For MyTriggers to handle your triggers, create a Trigger for _all_ contexts. Create a new instance of MyTriggers and call `run()`.

```
Trigger AccountTrigger on Account (
	before insert,
	before update,
	before delete,
	after insert,
	after update,
	after delete,
	after undelete) {

	MyTriggers.run();

}
```

## Building Trigger Handler Steps

Each handler step should extend the MyTriggers class and can override any of the methods.

```
public class newAccounts_ValidateType extends MyTriggers {


	public override void onBeforeInsert() {
		List<Account> newAccounts = (List<Account>)records;
    	}

	private void stepLogic() {
		// some method to handle the logic
	}
}
```

## Working With the "records" Propery

MyTriggers exposes a public instance variable _records_ that contains all records that are handled by MyTriggers. When working with the _records_ property,
you should cast it to a specific type.

```
(List<Account>)records
```

MyTriggers has a helper property for you to control your the process flow: _recordsNotYetProcessed_. You can access it through its getter method, Same goes for updated records - you can access their Ids through a getter

## Registering Steps For Execution

The execution flow is controlled by custom metadata records of the MyTriggerSetting type.
You have to specify

- an sObject Type of a standard or custom object or a platform event
- a class that contains your logic for this step
- a trigger context

Additionally, you should set

- the activation flag
- a sequence number

Optionally, set

- a namespace prefix for the class that you are going to call if you want to call (or build) namespaced trigger handler steps.

### One Word About Sequence Numbering

It doesn't really matter which sequence numbering you choose as long as it can be sorted. To avoid renumbering a whole set of steps, choose a numbering method that allows for gaps.

Classic ERP numbering styles and sequence might make you smile - but if your initial numbering sequence was 100, 200, 300, 400, 500 ..., you can add 190 and 210 later, and 195 and 215... without renumbering the whole list if you add one step inbetween.

### Deactivating Triggers

MyTriggers allows you to deactivate or re-wire Trigger steps in productive environments. But just because it is possible does not mean that it is a good idea, necessarily.

Be **extra careful** when you **deactivate** or **modify** productive Trigger handler steps and keep a reminder that works for you (sticky notes, an alarm clock) so that you don't forget to activate your triggers again.

## Enable Steps Or Trigger Contexts at Runtime

MyTriggers allows total control over all trigger operation at runtime.

```
public override void onAfterInsert() {

        // records property provided by myTriggers
        List<Account> newAccounts = new Map<Id,Map>(records);

        // disable after insert trigger on Opp so it doesn't interfere
        myTriggers.disable(myCaseTrigger.class,
                           new List<System.TriggerOperation>{
                               System.TriggerOperation.AFTER_UPDATE});

        CaseService.updateCustomerCareCases(newAccounts);
    }
```

## Finding Out If (And Which) Data Has Changed

```
// use string field names
List<String> fieldNamesToCheck = new String[]{'Multiplier__c','Revenue__c','OwnerId','Type__c'};

if (MyTriggers.hasChangedFields(fieldNamesToCheck,record,recordOld)){
	// logic executed when condition is true
}

// or sObjectFields
sObjectField[] fieldsToCheck = new sObjectField[]{Share__c.Multiplier__c, Share__c.Revenue__c, Share__c.OwnerId, Share__c.Type__c};

for (sObjectField field : MyTriggers.getChangedFields(fieldsToCheck,record,recordOld)){
	// process field
}
```

## Recursion control

```
// add all records in the current update context
MyTriggers.addUpdatedIds(triggerOldMap.keySet());

// and use this to return only records which havent been processed before
List<Sobject> untouchedRecords = MyTriggers.getRecordsNotYetProcessed();
```

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

- [addUpdatedIds](#addUpdatedIds)

  add set of ids to updatedIds

- [disable](#disable)

  disable disables all events for System.Type MyClass

- [disable](#disable)

  disable disables all events for the trigger handler with given namespace and classname Method also works in subscriber org with hidden (public) trigger handlers from managed package

- [disable](#disable)

  disable disable all specificed events for the System.Type MyClass

- [disable](#disable)

  disable all specificed events for given ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

- [disable](#disable)

  disable a single event for System.Type MyClass

- [disable](#disable)

  disable a single event for ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

- [doConstruct](#doConstruct)

  used instead of constructor since handlers are instanciated with an empty contructor

- [enable](#enable)

  removes all disabled events for the System.Type MyClass

- [enable](#enable)

  removes all disabled events for given ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

- [enable](#enable)

  enable all specificed events for the System.Type MyClass

- [enable](#enable)

  enable all specificed events for given ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

- [enable](#enable)

  enable a single event for System.Type MyClass

- [enable](#enable)

  enable a single event for ClassName and Namespace Also works in subscriber org with packaged public trigger handlers implementing MyTriggers

- [getAfterEvents](#getAfterEvents)

  getAfterEvents list of all AFTER System.TriggerOperation enums

- [getBeforeEvents](#getBeforeEvents)

  getBeforeEvents list of all BEFORE System.TriggerOperation enums

- [getChangedFields](#getChangedFields)

  returns a list of changed fields based on provided fieldList list

- [getChangedFields](#getChangedFields)

  returns a list of changed fields based on provided fieldList list

- [getDeleteEvents](#getDeleteEvents)

  getDeleteEvents all delete events

- [getDisabledEvents](#getDisabledEvents)

  returns set of disabled events

- [getDisabledEvents](#getDisabledEvents)

  returns set of disabled events Method also works in subscriber org with hidden (public) trigger handlers from managed package

- [getInsertEvents](#getInsertEvents)

  getInsertEvents all insert events

- [getRecordsNotYetProcessed](#getRecordsNotYetProcessed)

  returns a list of objects that have not been processed yet

- [getUpdatedIds](#getUpdatedIds)

  return all updated ids

- [getUpdateEvents](#getUpdateEvents)

  getUpdateEvents all update events

- [hasChangedFields](#hasChangedFields)

  returns true if a value of one of the specified fields has changed

- [hasChangedFields](#hasChangedFields)

  returns true if a value of one of the specified fields has changed

- [isDisabled](#isDisabled)

  isDisabled returns true if the specified event is disabled

- [isDisabled](#isDisabled)

  isDisabled returns true if the specified event is disabled Method also works in subscriber org with hidden (public) trigger handlers from managed package

- [myTriggers](#myTriggers)

  Global Constructor reserved for future use

- [onAfterDelete](#onAfterDelete)

  executed to perform AFTER_DELETE operations

- [onAfterInsert](#onAfterInsert)

  executed to perform AFTER_INSERT operations

- [onAfterUndelete](#onAfterUndelete)

  executed to perform AFTER_UNDELETE operations

- [onAfterUpdate](#onAfterUpdate)

  executed to perform AFTER_UPDATE operations

- [onBeforeDelete](#onBeforeDelete)

  executed to perform BEFORE_DELETE operations

- [onBeforeInsert](#onBeforeInsert)

  executed to perform BEFORE_INSERT operations

- [onBeforeUpdate](#onBeforeUpdate)

  executed to perform BEFORE_UPDATE operations

- [run](#run)

  Entry point of myTriggers framework - called from implementations

- [setAllowedTriggerEvents](#setAllowedTriggerEvents)

  loads trigger event settings MyTriggerSetting\_\_mdt

- [setAllowedTriggerEvents](#setAllowedTriggerEvents)

  loads trigger event settings MyTriggerSetting\_\_mdt Method also works in subscriber org with hidden (public) trigger handlers from managed package

- [toStringEvents](#toStringEvents)

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

- Set of disabled Event Namens (e.g. 'AFTER_UPDATE')

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

executed to perform AFTER_DELETE operations

## onAfterInsert

[global virtual void onAfterInsert()](MyTriggers.cls#L65)

executed to perform AFTER_INSERT operations

## onAfterUndelete

[global virtual void onAfterUndelete()](MyTriggers.cls#L92)

executed to perform AFTER_UNDELETE operations

## onAfterUpdate

[global virtual void onAfterUpdate(Map<Id,sObject> triggerOldMap)](MyTriggers.cls#L77)

executed to perform AFTER_UPDATE operations

## onBeforeDelete

[global virtual void onBeforeDelete()](MyTriggers.cls#L82)

executed to perform BEFORE_DELETE operations

## onBeforeInsert

[global virtual void onBeforeInsert()](MyTriggers.cls#L60)

executed to perform BEFORE_INSERT operations

## onBeforeUpdate

[global virtual void onBeforeUpdate(Map<Id,sObject> triggerOldMap)](MyTriggers.cls#L71)

executed to perform BEFORE_UPDATE operations

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
