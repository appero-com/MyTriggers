/**
 * MyTriggers - adapted from TriggerX (2013) by Sebastian Wagner
 * Copyright (c) 2018 appero GmbH. All rights reserved.
 *
 * This work is licensed under the terms of the MIT license.
 * For a copy, see <LICENCE> in this repository or
 * <https://opensource.org/licenses/MIT>.
 *
 * @created: 8-2018
 * @author: info@appero.com
 *
 * @Description Leightweight Custom Metadata driven Trigger Framework that scales to your needs. Provided with <3 by appero.com
 */

@isTest
private class MyTriggersTest {

	//--------------------------------------------------------------
	// DataTypes
	//--------------------------------------------------------------
	public class AccountHandlerWithoutOverride extends myTriggers {}

	// Test handler that sets the System.TriggerOperation of the executed method
	public class AccountHandler extends myTriggers {

		public System.TriggerOperation tiggerEvent;

		// set tiggerEvent to null
		public void reset(){
			tiggerEvent = null;
		}

		public override void onBeforeInsert(){
			tiggerEvent = System.TriggerOperation.BEFORE_INSERT;
		}

		public override void onAfterInsert(){
			tiggerEvent = System.TriggerOperation.AFTER_INSERT;
		}

		public override void onBeforeUpdate(Map<Id,sObject> triggerOldMap){
			tiggerEvent = System.TriggerOperation.BEFORE_UPDATE;
		}

		public override void onAfterUpdate(Map<Id,sObject> triggerOldMap){
			tiggerEvent = System.TriggerOperation.AFTER_UPDATE;
		}

		public override void onBeforeDelete(){
			tiggerEvent = System.TriggerOperation.BEFORE_DELETE;
		}

		public override void onAfterDelete(){
			tiggerEvent = System.TriggerOperation.AFTER_DELETE;
		}

		public override void onAfterUndelete(){
			tiggerEvent = System.TriggerOperation.AFTER_UNDELETE;
		}


		public sObject[] getNonRecursiveRecords(){

			return super.getRecordsNotYetProcessed();
		}


		public Boolean hasChangedNameOrPhoneField(sObject record, sObject recordOld){
			return myTriggers.hasChangedFields(new sObjectField[] {Account.Name,Account.Phone},record,recordOld);
		}


		public Boolean hasChangedNameOrPhoneString(sObject record, sObject recordOld){
			return myTriggers.hasChangedFields(new String[] {'Name','Phone'},record,recordOld);
		}


		public sObjectField[] getNameAndPhoneChangesField(sObject record, sObject recordOld){
			return myTriggers.getChangedFields(new sObjectField[] {Account.Name,Account.Phone},record,recordOld);
		}

		public String[] getNameAndPhoneChangesString(sObject record, sObject recordOld){
			return myTriggers.getChangedFields(new String[] {'Name','Phone'},record,recordOld);
		}

	}


	// Holds context variables for #handleTriggerTest
	private class TestContext {

		public System.TriggerOperation tiggerEvent;
		public Boolean isBefore;
		public Boolean isInsert;
		public Boolean isUpdate;
		public Boolean isDelete;
		public Boolean isUndelete;

		public sObject[] records = new sObject[] {};
		public Map<Id,sObject> triggerOldMap = new Map<Id,sObject>();

		public TestContext(){
		}

		// sets context variables based on the trigger operation
		public void setEvent(System.TriggerOperation tiggerEvent){

			this.tiggerEvent = tiggerEvent;
			String name = tiggerEvent.name();
			this.isBefore = tiggerEvent.name().contains('BEFORE');
			this.isInsert = name.contains('INSERT');
			this.isUpdate = name.contains('UPDATE');
			this.isDelete = name.contains('_DELETE');
			this.isUndelete = name.contains('UNDELETE');
		}
	}

	private static List<MyTriggerSetting__mdt> getTriggerHandlingSettingsForSObjectType(String objTypeName){
		List<MyTriggerSetting__mdt> triggerHandlerSettings = new List<MyTriggerSetting__mdt>();
		for(System.TriggerOperation event : System.TriggerOperation.values()) {
			triggerHandlerSettings.add(getTriggerHandlingSetting(objTypeName, event, 'myTriggersTest.AccountHandler'));
		}
		return triggerHandlerSettings;
	}

	private static MyTriggerSetting__mdt getTriggerHandlingSetting(String objTypeName, System.TriggerOperation event, String className){
		MyTriggerSetting__mdt triggerHandlerSetting = new MyTriggerSetting__mdt(
			DeveloperName = 'TestHandler'+event.name(),
			Event__c = event.name(),
			sObject__c = objTypeName,
			sobjectAPIName__c = objTypeName,
			Class__c = className);
		return triggerHandlerSetting;
	}


	//--------------------------------------------------------------
	// Handler Features
	//--------------------------------------------------------------
	// test #hasChangedFields and #getChangedFields for myTriggers
	@isTest
	private static void fieldChangesTest(){

		String name = 'SAME_NAME';
		Account record = new Account(Name = name, Phone = '123456');
		Account recordOld = new Account(Name = name, Phone = record.Phone);

		Test.startTest();

		AccountHandler hndl = new AccountHandler();

		system.assertEquals(false,hndl.hasChangedNameOrPhoneField(record, recordOld),'should be not true because nothing has changed');
		system.assertEquals(false,hndl.hasChangedNameOrPhoneString(record, recordOld),'should be not true because nothing has changed');
		recordOld.Phone += '1';
		system.assertEquals(true,hndl.hasChangedNameOrPhoneField(record, recordOld),'should be true because Phone has changed');
		system.assertEquals(true,hndl.hasChangedNameOrPhoneString(record, recordOld),'should be true because Phone has changed');

		system.assertEquals(Account.Phone,hndl.getNameAndPhoneChangesField(record, recordOld).get(0),'should return changed sObjectField Account.Phone');
		system.assertEquals('Phone',hndl.getNameAndPhoneChangesString(record, recordOld).get(0),'should return changed Fieldname Phone');

		Test.stopTest();
	}


	// test for recusion control while updating
	@isTest
	private static void recursionControlTest(){

		Test.startTest();

		AccountHandler hndl = new AccountHandler();
		sObject[] records = new sObject[] {
			new User(Id = UserInfo.getUserId()),
			new User(Id = null)
		};

		hndl.doConstruct(records);
		myTriggers.addUpdatedIds(new Set<Id> {UserInfo.getUserId()});

		system.assertEquals(true,myTriggers.getUpdatedIds().contains(UserInfo.getUserId()));
		system.assertEquals(null,hndl.getNonRecursiveRecords().get(0).Id,'should not return any record which id is returned by myTriggers.getUpdatedIds()');

		Test.stopTest();
	}

	//--------------------------------------------------------------
	// Event Control
	//--------------------------------------------------------------

	// test support with trigger control
	@isTest
	private static void fromControlTest(){

		Type typ = AccountHandler.class;

		// list of Event strings to disable
		System.TriggerOperation[] triggerEvents = System.TriggerOperation.values();

		// set empty trigger handler setting mock
		List<MyTriggerSetting__mdt> triggerHandlerSettingMocks = new List<MyTriggerSetting__mdt>();

		Test.startTest();

		// Set handler setting mocks
		myTriggers.triggerHandlerSettingMocks = triggerHandlerSettingMocks;

		// Set handler setting maps
		myTriggers.setTriggerHandlerMaps(Account.getSObjectType());

		// load Controls
		myTriggers.setAllowedTriggerEvents(typ,true);

		// make sure all events are disabled
		for (System.TriggerOperation tiggerEvent:triggerEvents)
		{
			system.assert (myTriggers.isDisabled(typ, tiggerEvent),tiggerEvent.name() + ' should be disabled because no active handler setting available');
		}

		Test.stopTest();
	}

	// test support with trigger control
	@isTest
	private static void fromControlTest_publicManagedHandlers(){

		Type typ = AccountHandler.class;
		String namespacePrefix = '';
		String className = typ.getName();

		// list of Event strings to disable
		System.TriggerOperation[] triggerEvents = System.TriggerOperation.values();

		// set empty trigger handler setting mock
		List<MyTriggerSetting__mdt> triggerHandlerSettingMocks = new List<MyTriggerSetting__mdt>();

		Test.startTest();

		// Set handler setting mocks
		myTriggers.triggerHandlerSettingMocks = triggerHandlerSettingMocks;

		// Set handler setting maps
		myTriggers.setTriggerHandlerMaps(Account.getSObjectType());

		// load Controls
		myTriggers.setAllowedTriggerEvents(namespacePrefix,className,true);

		// make sure all events are disabled
		for (System.TriggerOperation tiggerEvent:triggerEvents) {
			system.assert (myTriggers.isDisabled(namespacePrefix, className, tiggerEvent),tiggerEvent.name() + ' should be disabled because no active handler setting available');
		}

		Test.stopTest();
	}


	// Test for myTriggers.handleTrigger methods, with event control
	@isTest
	private static void handleTriggerTest(){

		Test.startTest();

		AccountHandler hndl = new AccountHandler();
		Type typ = AccountHandler.class;
		TestContext tx = new TestContext();

		// run test for each trigger operation
		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values()) {

			// update the context
			tx.setEvent(tiggerEvent);
			hndl.reset();

			// disabled event
			myTriggers.disable(typ,tx.tiggerEvent);
			myTriggers.run(hndl, typ, tx.isBefore, tx.isInsert, tx.isUpdate, tx.isDelete, tx.isUndelete, tx.records, tx.triggerOldMap);
			system.assertEquals(null,hndl.tiggerEvent,tx.tiggerEvent.name() + ' should be disabled for ' + typ.toString());

			// enabled event
			myTriggers.enable(typ,tx.tiggerEvent);
			myTriggers.run(hndl, typ, tx.isBefore, tx.isInsert, tx.isUpdate, tx.isDelete, tx.isUndelete, tx.records, tx.triggerOldMap);
			system.assertEquals(tx.tiggerEvent,hndl.tiggerEvent,tx.tiggerEvent.name() + ' should be enabled for ' + typ.toString());

		}

		Test.stopTest();
	}

	// Test for myTriggers.handleTrigger methods, with event control
	@isTest
	private static void handleTriggerTest_publicManagedHandlers(){

		Test.startTest();

		AccountHandler hndl = new AccountHandler();
		Type typ = AccountHandler.class;
		String namespacePrefix = '';
		String className = typ.getName();
		TestContext tx = new TestContext();

		// run test for each trigger operation
		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values()) {

			// update the context
			tx.setEvent(tiggerEvent);
			hndl.reset();

			// disabled event
			myTriggers.disable(namespacePrefix,className,tx.tiggerEvent);
			myTriggers.run(hndl, typ, tx.isBefore, tx.isInsert, tx.isUpdate, tx.isDelete, tx.isUndelete, tx.records, tx.triggerOldMap);
			system.assertEquals(null,hndl.tiggerEvent,tx.tiggerEvent.name() + ' should be disabled for ' + typ.toString());

			// enabled event
			myTriggers.enable(namespacePrefix,className,tx.tiggerEvent);
			myTriggers.run(hndl, typ, tx.isBefore, tx.isInsert, tx.isUpdate, tx.isDelete, tx.isUndelete, tx.records, tx.triggerOldMap);
			system.assertEquals(tx.tiggerEvent,hndl.tiggerEvent,tx.tiggerEvent.name() + ' should be enabled for ' + typ.toString());

		}

		Test.stopTest();
	}

	@isTest
	private static void handleTriggerTest_UsingTriggerHandlerSettings(){

		Test.startTest();

		AccountHandler hndl = new AccountHandler();
		Type typ = AccountHandler.class;
		TestContext tx = new TestContext();

		//Set mock data
		myTriggers.triggerHandlerSettingMocks = getTriggerHandlingSettingsForSObjectType('Account');
		myTriggers.sObjectTypeMock = Account.sObjectType;
		myTriggers.triggerEventMock = System.TriggerOperation.values()[0].name();

		Boolean success = true;
		try {
			myTriggers.run();
		} catch(Exception e) {
			success = false;
		}
		system.assert (!success, 'myTriggers.run() should fail in Non-Trigger mode');

		Test.stopTest();
	}

	@isTest
	private static void handleTriggerTest_NoExistingTriggerHandlers(){

		Test.startTest();

		//Set mock data
		myTriggers.triggerHandlerSettingMocks = new List<MyTriggerSetting__mdt>();
		myTriggers.sObjectTypeMock = Account.sObjectType;
		myTriggers.triggerEventMock = System.TriggerOperation.values()[0].name();

		Boolean success = true;
		try {
			myTriggers.run();
		} catch(Exception e) {
			success = false;
		}
		system.assert (success, 'myTriggers.run() should not fail if trigger handlers is found');

		Test.stopTest();
	}


	// controls all events via myTriggers.disable(Type) and myTriggers.enable(Type)
	@isTest
	public static void dynamicControlAllTest_publicManagedHandlers(){

		Test.startTest();
		Type typ = AccountHandler.class;
		String namespacePrefix = '';
		String className = typ.getName();
		TestContext tx = new TestContext();

		// disable all events
		myTriggers.disable(namespacePrefix,className);

		// make sure all events are disabled
		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values())
		{
			system.assert (myTriggers.isDisabled(namespacePrefix, className, tiggerEvent),tiggerEvent.name() + ' shoud be disabled for ' + typ.toString());
		}

		// enable em all
		myTriggers.enable(namespacePrefix,className);

		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values()) {
			system.assert (!myTriggers.isDisabled(namespacePrefix, className, tiggerEvent),tiggerEvent.name() + ' shoud be enabled for ' + typ.toString());
		}

		Test.stopTest();
	}

	// controls all events via myTriggers.disable(Type) and myTriggers.enable(Type)
	@isTest
	public static void dynamicControlAllTest(){

		Test.startTest();
		Type typ = AccountHandler.class;

		// disable all events
		myTriggers.disable(typ);

		// make sure all events are disabled
		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values()) {
			system.assert (myTriggers.isDisabled(typ, tiggerEvent),tiggerEvent.name() + ' shoud be disabled for ' + typ.toString());
		}

		// enable em all
		myTriggers.enable(typ);

		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values()) {
			system.assert (!myTriggers.isDisabled(typ, tiggerEvent),tiggerEvent.name() + ' shoud be enabled for ' + typ.toString());
		}

		Test.stopTest();
	}


	// enables all events via myTriggers.enable(Type, EventType[])
	@isTest
	public static void dynamicControlTest(){

		Test.startTest();
		Type typ = AccountHandler.class;

		// disable all events
		myTriggers.disable(typ);

		// make sure all events are disabled
		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values())      {
			system.assert (myTriggers.isDisabled(typ, tiggerEvent),tiggerEvent.name() + ' shoud be disabled for ' + typ.toString());
		}


		// and enable all
		myTriggers.enable(typ, System.TriggerOperation.values());

		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values())      {
			system.assert (!myTriggers.isDisabled(typ, tiggerEvent),tiggerEvent.name() + ' shoud be enabled for ' + typ.toString());
		}

		Test.stopTest();
	}

	// enables all events via myTriggers.enable(Type, EventType[])
	@isTest
	public static void dynamicControlTest_publicManagedHandlers() {

		Test.startTest();
		Type typ = AccountHandler.class;
		String namespacePrefix = '';
		String className = typ.getName();

		// disable all events
		myTriggers.disable(namespacePrefix,className);

		// make sure all events are disabled
		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values())
		{
			system.assert (myTriggers.isDisabled(namespacePrefix, className, tiggerEvent),tiggerEvent.name() + ' shoud be disabled for ' + typ.toString());
		}


		// and enable all
		myTriggers.enable(namespacePrefix, className, System.TriggerOperation.values());

		for (System.TriggerOperation tiggerEvent:System.TriggerOperation.values())
		{
			system.assert (!myTriggers.isDisabled(namespacePrefix, className, tiggerEvent),tiggerEvent.name() + ' shoud be enabled for ' + typ.toString());
		}

		Test.stopTest();
	}


	// tests myTriggers.run(Type) without Trigger context, coverage only
	@isTest
	private static void nonTriggerContextTest() {

		Boolean success = true;
		try
		{
			myTriggers.run(AccountHandler.class);
		}
		catch(Exception ex)
		{
			success = false;
		}
		system.assert (!success, 'myTriggers.run(Type) should fail in Non-Trigger mode');
	}


	// calls virtual myTriggers methods, just for TestCoverage
	@isTest
	private static void nonOverrideTest(){

		Test.startTest();

		AccountHandlerWithoutOverride hndl = new AccountHandlerWithoutOverride();
		hndl.onBeforeInsert();
		hndl.onAfterInsert();
		hndl.onBeforeUpdate(null);
		hndl.onAfterUpdate(null);
		hndl.onBeforeDelete();
		hndl.onAfterDelete();
		hndl.onAfterUndelete();

		Test.stopTest();
	}

	/**
	 * Individual Tests
	 ********/

	// calls getInsertEvents, getUpdateEvents and getDeleteEvents()
	@isTest
	private static void getTypesTest(){

		Test.startTest();

		for (System.TriggerOperation tiggerEvent:myTriggers.getDeleteEvents()) {
			system.assert (tiggerEvent.name().contains('DELETE'),'DELETE events should contain DELETE');
		}
		for (System.TriggerOperation tiggerEvent:myTriggers.getInsertEvents()) {
			system.assert (tiggerEvent.name().contains('INSERT'),'INSERT events should contain INSERT');
		}
		for (System.TriggerOperation tiggerEvent:myTriggers.getUpdateEvents()) {
			system.assert (tiggerEvent.name().contains('UPDATE'),'UPDATE events should contain UPDATE');
		}
		Test.stopTest();
	}

	@isTest
	private static void getTriggerHandlerType_Success(){
		Boolean success = true;

		MyTriggerSetting__mdt triggerHandlerSetting = getTriggerHandlingSetting('Account', System.TriggerOperation.BEFORE_INSERT, 'myTriggersTest.AccountHandler');
		Type triggerHandlerType = myTriggers.getTriggerHandlerType(triggerHandlerSetting.ClassNamespacePrefix__c, triggerHandlerSetting.Class__c);

		System.assertEquals(myTriggersTest.AccountHandler.class, triggerHandlerType, 'Type of trigger handler should be found');
	}

	@isTest
	private static void getTriggerHandlerType_Failure_NoClassFound(){
		Boolean success = true;

		MyTriggerSetting__mdt invalidHandlerSetting = getTriggerHandlingSetting('Account', System.TriggerOperation.BEFORE_INSERT, 'InvalidClassname');

		try {
			myTriggers.getTriggerHandlerType(invalidHandlerSetting.ClassNamespacePrefix__c, invalidHandlerSetting.Class__c);
		} catch(myTriggers.myTriggersException e) {
			success = false;
		}

		System.assertEquals(false, success, 'myTriggers.getTriggerHandlerType should fail for invalid trigger handler classname');
	}

	@isTest
	private static void runQuery_Success() {
		Exception ex;
		String errorMsg = '';
		try {
			MyTriggers.runTriggerHandlerSettingsQuery('Account');
		} catch (exception e) {
			ex =e;
			errorMsg = e.getMessage();
		}
		System.assertEquals(null,ex,'The custom metadata query must run without errors. '+errorMsg);
	}

	@isTest
	private static void validate_NoError() {
		Boolean success = true;
		MyTriggers.qualifiedApiNameMock = 'Account';
		try {
			myTriggers.validate (getTriggerHandlingSettingsForSObjectType('Account'));
		} catch(myTriggers.myTriggersException e) {
			success = false;
		}
		System.assertEquals(true, success, 'Setting should pass since both sObject fields point to the same object');
	}

	@isTest
	private static void validate_ValidException() {
		Boolean success = true;
		MyTriggers.qualifiedApiNameMock = 'Case';
		try {
			myTriggers.validate (getTriggerHandlingSettingsForSObjectType('Account'));
		} catch(myTriggers.myTriggersException e) {
			success = false;
		}
		System.assertEquals(false, success, 'Setting must raise exception since sObject fields point to different objects');
	}

	@isTest
	private static void getNamespace_Success() {
		System.assertEquals('myTriggersTest.AccountHandler'.toUpperCase(),
		                    myTriggers.getClassNameWithNamespace(getTriggerHandlingSettingsForSObjectType('Account')[0]),
		                    'Empty namespace in test context, all uppercase');
	}

}