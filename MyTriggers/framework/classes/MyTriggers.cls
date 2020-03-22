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


global virtual class MyTriggers {

	global class myTriggersException extends Exception {}

	@TestVisible
	private static List<MyTriggerSetting__mdt> triggerHandlerSettingMocks;

	@TestVisible
	private static sObjectType sObjectTypeMock;

	@TestVisible
	private static String triggerEventMock;

	@Testvisible
	private static String qualifiedApiNameMock;

	/**
	 * cast records to appropriate sObjectType in implementations
	 */
	global sObject[] records;

	/**
	 * Global Constructor reserved for future use
	 *
	 */
	global myTriggers(){
		//empty
	}

	/**
	 * used instead of constructor since handlers are instanciated with an empty contructor
	 * @param  records Array of sObjects. for INSERT & UPDATE Trigger.new otherwise Trigger.old
	 * @return         instance
	 */
	global virtual myTriggers doConstruct(sObject[] records){

		this.records = records;
		return this;
	}

	//--------------------------------------------------------------
	// implementable Handlers
	//--------------------------------------------------------------

	/**
	 * executed to perform BEFORE_INSERT operations
	 */
	global virtual void onBeforeInsert(){
	}

	/**
	 * executed to perform AFTER_INSERT operations
	 */
	global virtual void onAfterInsert(){
	}

	/**
	 * executed to perform BEFORE_UPDATE operations
	 * @param  triggerOldMap
	 */
	global virtual void onBeforeUpdate(Map<Id,sObject> triggerOldMap){
	}

	/**
	 * executed to perform AFTER_UPDATE operations
	 * @param  triggerOldMap
	 */
	global virtual void onAfterUpdate(Map<Id,sObject> triggerOldMap){
	}

	/**
	 * executed to perform BEFORE_DELETE operations
	 */
	global virtual void onBeforeDelete(){
	}

	/**
	 * executed to perform AFTER_DELETE operations
	 */
	global virtual void onAfterDelete(){
	}

	/**
	 * executed to perform AFTER_UNDELETE operations
	 */
	global virtual void onAfterUndelete(){
	}

	//--------------------------------------------------------------
	// General Handling
	//--------------------------------------------------------------


	/**
	 * Entry point of myTriggers framework - called from implementations
	 */
	global static void run(){

		SObjectType currentSObjectType;
		if (Test.isRunningTest() && sObjectTypeMock != null) {
			currentSObjectType = sObjectTypeMock;
		} else {
			currentSObjectType = Trigger.new != null ? Trigger.new.getSObjectType() : Trigger.old.getSObjectType();
		}

		//if (currentSObjectType != executionContextSObjectType) {
		setTriggerHandlerMaps(currentSObjectType);
		//}
		executionContextSObjectType = currentSObjectType;

		if (triggerEventsToTriggerHandlers == null || triggerEventsToTriggerHandlers.isEmpty()) {
			if (!Test.isRunningTest()) {
				return;
			}

		}

		String eventString = Test.isRunningTest() && triggerEventMock != null ? triggerEventMock : Trigger.operationType.name();

		List<MyTriggerSetting__mdt> triggerHandlerSettings = triggerEventsToTriggerHandlers.get(eventString);

		if (triggerHandlerSettings == null) {
			return;
		}

		if (processedTriggerHandlerSettings == null) {
			processedTriggerHandlerSettings = new Set<String>();
		}
		//system.debug('FW    We processed: ' + processedTriggerHandlerSettings);
		for (MyTriggerSetting__mdt triggerHandlerSetting : triggerHandlerSettings) {
			Type handlerType = getTriggerHandlerType(triggerHandlerSetting.ClassNamespacePrefix__c, triggerHandlerSetting.Class__c);
			if (!processedTriggerHandlerSettings.contains(triggerHandlerSetting.DeveloperName)) {
				system.debug('FW   now running: '+ Integer.valueOf(triggerHandlerSetting.Order__c) +' '+ triggerHandlerSetting.Class__c + ' for ' + triggerHandlerSetting.sObject__c + ' and event: ' +triggerHandlerSetting.Event__c + ' -' + triggerHandlerSetting.DeveloperName);
				processedTriggerHandlerSettings.add(triggerHandlerSetting.DeveloperName);
				run(handlerType);
			}
		}
	}


	//--------------------------------------------------------------
	// Methods to track updated records or if a record has changed fields
	//--------------------------------------------------------------

	static Set<Id> alreadyUpdatedIds = new Set<Id>();

	/**
	 * add set of ids to updatedIds
	 * @param  idSet usally Trigger.newMap.keyset()
	 */
	global static void addUpdatedIds(Set<Id> idSet){
		alreadyUpdatedIds.addAll(idSet);
	}


	/**
	 * return all updated ids
	 * @return   set of updated/already touched Ids
	 */
	global static Set<Id> getUpdatedIds(){
		return alreadyUpdatedIds;
	}


	/**
	 * returns a list of objects that have not been processed yet
	 * @return           records[] not yet processed
	 */
	global protected sObject[] getRecordsNotYetProcessed(){

		Set<Id> updatedIds = myTriggers.getUpdatedIds();
		sObject[] recordsNotYetProcessed  = records.clone();
		recordsNotYetProcessed.clear();

		for (sObject record : records) {
			if (!updatedIds.contains((Id)record.get('Id'))) {
				recordsNotYetProcessed.add(record);
			}
		}

		return recordsNotYetProcessed;
	}

	/**
	 * returns true if a value of one of the specified fields has changed
	 * @param  fieldList
	 * @param  record
	 * @param  recordOld
	 */
	global static Boolean hasChangedFields(String[] fieldList, sObject record, sObject recordOld){
		for (String field : fieldList) {
			if (record.get(field) != recordOld.get(field)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * returns true if a value of one of the specified fields has changed
	 * @param  fieldList
	 * @param  record
	 * @param  recordOld
	 */
	global static Boolean hasChangedFields(sObjectField[] fieldList, sObject record, sObject recordOld){
		for (sObjectField field : fieldList) {
			if (record.get(field) != recordOld.get(field)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * returns a list of changed fields based on provided fieldList list
	 * @param  fieldList
	 * @param  record
	 * @param  recordOld
	 */
	global static String[] getChangedFields(String[] fieldList, sObject record, sObject recordOld){
		String[] changedFieldNames = new String[] {};

		for (String field:fieldList) {
			if (record.get(field) != recordOld.get(field)) {
				changedFieldNames.add(field);
			}
		}

		return changedFieldNames;
	}


	/**
	 * returns a list of changed fields based on provided fieldList list
	 * @param  fieldList
	 * @param  record
	 * @param  recordOld
	 */
	global static sObjectField[] getChangedFields(sObjectField[] fieldList, sObject record, sObject recordOld){
		sObjectField[] changedFields = new sObjectField[] {};

		for (sObjectField field:fieldList) {
			if (record.get(field) != recordOld.get(field)) {
				changedFields.add(field);
			}
		}

		return changedFields;
	}

	//--------------------------------------------------------------
	// EVENT Control for advanced use cases
	//--------------------------------------------------------------

	static Map<Type,Set<String> > classNameToDisabledTriggerEventsMap = new Map<Type,Set<String> >();

	static Set<Type> alreadyCheckedClasses = new Set<Type>();


	/**
	 * loads trigger event settings MyTriggerSetting__mdt
	 * @param  triggerHandlerType
	 * @param  forceInit            force reload of event settings
	 */
	global static void setAllowedTriggerEvents(Type triggerHandlerType, Boolean forceInit){
		if (alreadyCheckedClasses.contains(triggerHandlerType) && !forceInit) {
			return;
		}
		Set<String> events = getDisabledEvents(triggerHandlerType);
		Set<String> enabledEventsInSettings = new Set<String>();
		String classNameWithNamespace = triggerHandlerType.getName().toUpperCase();

		if (handlerClassesToTriggerHandlers!= null && handlerClassesToTriggerHandlers.containsKey(classNameWithNamespace)) {
			for (MyTriggerSetting__mdt handlerSetting : handlerClassesToTriggerHandlers.get(classNameWithNamespace)) {
				enabledEventsInSettings.add(handlerSetting.Event__c);
			}
		}

		for (System.TriggerOperation op : System.TriggerOperation.values()) {
			if (!enabledEventsInSettings.contains(op.name())) {
				events.add(op.name());
			}
		}

		alreadyCheckedClasses.add(triggerHandlerType);
	}

	/**
	 * loads trigger event settings MyTriggerSetting__mdt
	 * Method also works in subscriber org with hidden (public) trigger handlers from managed package
	 * @param  namespacePrefix
	 * @param  className
	 * @param  forceInit
	 */
	global static void setAllowedTriggerEvents(String namespacePrefix, String className, Boolean forceInit){
		Type triggerHandlerType = getTriggerHandlerType(namespacePrefix, className);
		setAllowedTriggerEvents(triggerHandlerType, forceInit);
	}

	/**
	 * returns set of disabled events
	 * @param  className
	 * @return           Set of disabled Event Namens (e.g. 'AFTER_UPDATE')
	 */
	global static Set<String> getDisabledEvents(Type className){

		if (!classNameToDisabledTriggerEventsMap.containsKey(className)) {
			classNameToDisabledTriggerEventsMap.put(className,new Set<String>());
		}
		return classNameToDisabledTriggerEventsMap.get(className);
	}

	/**
	 * returns set of disabled events
	 * Method also works in subscriber org with hidden (public) trigger handlers from managed package
	 * @param  namespacePrefix
	 * @param  className
	 * @return                 Set<String>
	 */
	global static Set<String> getDisabledEvents(String namespacePrefix, String className){
		Type triggerHandlerType = getTriggerHandlerType(namespacePrefix, className);
		return getDisabledEvents(triggerHandlerType);
	}

	/**
	 * returns true if the specified event is disabled
	 * @param  className className String
	 * @param  event     event System.TriggerOperation
	 * @return           Boolean
	 */
	global static Boolean isDisabled(Type className, System.TriggerOperation event){
		return getDisabledEvents(className).contains(event.name());
	}

	/**
	 * returns true if the specified event is disabled
	 * Method also works in subscriber org with hidden (public) trigger handlers from managed package
	 * @param  namespacePrefix
	 * @param  className
	 * @param  event
	 */
	global static Boolean isDisabled(String namespacePrefix, String className, System.TriggerOperation event){
		Type triggerHandlerType = getTriggerHandlerType(namespacePrefix, className);
		return isDisabled(triggerHandlerType, event);
	}

	/**
	 * getInsertEvents all insert events
	 * @return   System.TriggerOperation[]
	 */
	global static System.TriggerOperation[] getInsertEvents(){
		return new System.TriggerOperation[] {System.TriggerOperation.BEFORE_INSERT,
			                              System.TriggerOperation.AFTER_INSERT};
	}

	/**
	 * get all upadte Events
	 * @return   all update events
	 */
	global static System.TriggerOperation[] getUpdateEvents(){
		return new System.TriggerOperation[] {System.TriggerOperation.BEFORE_UPDATE,
			                              System.TriggerOperation.AFTER_UPDATE};
	}

	/**
	 * getDeleteEvents all delete events
	 * @return   all delete events
	 */
	global static System.TriggerOperation[] getDeleteEvents(){
		return new System.TriggerOperation[] {
			       System.TriggerOperation.BEFORE_DELETE
			       , System.TriggerOperation.AFTER_DELETE
		};
	}

	/**
	 * list of all BEFORE System.TriggerOperation enums
	 * @return   all before events
	 */
	global static System.TriggerOperation[] getBeforeEvents(){
		return new System.TriggerOperation[] {
			       System.TriggerOperation.BEFORE_INSERT
			       , System.TriggerOperation.BEFORE_UPDATE
			       , System.TriggerOperation.BEFORE_DELETE
		};
	}

	/**
	 * list of all AFTER System.TriggerOperation enums
	 * @return   all after events
	 */
	global static System.TriggerOperation[] getAfterEvents(){
		return new System.TriggerOperation[] {System.TriggerOperation.AFTER_INSERT,
			                              System.TriggerOperation.AFTER_UPDATE,
			                              System.TriggerOperation.AFTER_DELETE,
			                              System.TriggerOperation.AFTER_UNDELETE};
	}


	/**
	 * disables all events for System.Type MyClass
	 * @param  myClass
	 */
	global static void disable(Type MyClass){

		System.TriggerOperation[] allEvents = new System.TriggerOperation[] {};
		allEvents.addAll(getBeforeEvents());
		allEvents.addAll(getAfterEvents());

		disable(MyClass,allEvents);
	}

	/**
	 * disable disables all events for the trigger handler with given namespace and classname
	 * Method also works in subscriber org with hidden (public) trigger handlers from managed package
	 * @param  namespacePrefix
	 * @param  className
	 */
	global static void disable(String namespacePrefix, String className){

		System.TriggerOperation[] allEvents = new System.TriggerOperation[] {};
		allEvents.addAll(getBeforeEvents());
		allEvents.addAll(getAfterEvents());

		disable(namespacePrefix,className,allEvents);
	}

	/**
	 * removes all disabled events for the System.Type MyClass
	 * @param  MyClass
	 */
	global static void enable(Type MyClass){
		getDisabledEvents(MyClass).clear();
	}

	/**
	 * removes all disabled events for given ClassName and Namespace
	 * Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
	 * @param  namespacePrefix String
	 * @param  className       String
	 */
	global static void enable(String namespacePrefix, String className){
		Type triggerHandlerType = getTriggerHandlerType(namespacePrefix, className);
		enable(triggerHandlerType);
	}

	/**
	 * disable disable all specificed events for the System.Type MyClass
	 * @param  MyClass
	 * @param  events
	 */
	global static void disable(Type MyClass, System.TriggerOperation[] events){
		getDisabledEvents(MyClass).addAll(toStringEvents(events));
	}

	/**
	 * disable all specificed events for given ClassName and Namespace
	 * Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
	 * @param  namespacePrefix
	 * @param  className
	 * @param  events
	 */
	global static void disable(String namespacePrefix, String className, System.TriggerOperation[] events){
		getDisabledEvents(namespacePrefix, className).addAll(toStringEvents(events));
	}

	/**
	 * enable all specificed events for the System.Type MyClass
	 * @param  MyClass
	 * @param  events
	 */
	global static void enable(Type MyClass, System.TriggerOperation[] events){
		getDisabledEvents(MyClass).removeAll(toStringEvents(events));
	}

	/**
	 * enable all specificed events for given ClassName and Namespace
	 * Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
	 * @param  namespacePrefix
	 * @param  className
	 * @param  events
	 */
	global static void enable(String namespacePrefix, String className, System.TriggerOperation[] events){
		Type triggerHandlerType = getTriggerHandlerType(namespacePrefix, className);
		enable(triggerHandlerType, events);
	}

	/**
	 * disable a single event for System.Type MyClass
	 * @param  MyClass
	 * @param  event
	 */
	global static void disable(Type MyClass, System.TriggerOperation event){
		getDisabledEvents(MyClass).add(event.name());
	}

	/**
	 * disable a single event for ClassName and Namespace
	 * Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
	 * @param  namespacePrefix
	 * @param  className
	 * @param  event
	 */
	global static void disable(String namespacePrefix, String className, System.TriggerOperation event){
		getDisabledEvents(namespacePrefix, className).add(event.name());
	}

	/**
	 * enable a single event for System.Type MyClass
	 * @param  MyClass
	 * @param  event
	 */
	global static void enable(Type MyClass, System.TriggerOperation event){
		getDisabledEvents(MyClass).remove(event.name());
	}

	/**
	 * enable a single event for ClassName and Namespace
	 * Also works in subscriber org with packaged public trigger handlers implementing MyTriggers
	 * @param  namespacePrefix
	 * @param  className
	 * @param  event
	 */
	global static void enable(String namespacePrefix, String className, System.TriggerOperation event){
		Type triggerHandlerType = getTriggerHandlerType(namespacePrefix, className);
		enable(triggerHandlerType, event);
	}

	/**
	 * converts a Set of Event enums into Strings
	 * @param  events
	 * @return        Names of Enums
	 */
	global static Set<String> toStringEvents(System.TriggerOperation[] events){
		Set<String> output = new Set<String>();
		for (System.TriggerOperation e:events) {
			output.add(e.name());
		}
		return output;
	}

	//--------------------------------------------------------------
	// TRIGGER FRAMEWORK
	//--------------------------------------------------------------

	@TestVisible
	private static SObjectType executionContextSObjectType;

	@TestVisible
	private static Set<sObjectType> knownExecutionContextSobjectTypes;

	@TestVisible
	private static Set<String> processedTriggerHandlerSettings;

	private static Set<String> namespacePrefixes;

	private static Map<String, List<MyTriggerSetting__mdt> > triggerEventsToTriggerHandlers;

	private static Map<String, List<MyTriggerSetting__mdt> > handlerClassesToTriggerHandlers;

	/**
	 * instanciates the applicable Trigger Handler object and passes it with Trigger context to run()
	 * @param  handlerType
	 */
	@testVisible
	private static void run(Type handlerType){
		run((myTriggers)handlerType.newInstance(),
		    handlerType,
		    Trigger.isBefore,
		    Trigger.isInsert,
		    Trigger.IsUpdate,
		    Trigger.isDelete,
		    Trigger.isUndelete,
		    Trigger.new,
		    Trigger.oldMap);
	}

	/**
	 * routes Trigger contexts to methods
	 * @param  handler
	 * @param  handlerType
	 * @param  isBefore
	 * @param  isInsert
	 * @param  isUpdate
	 * @param  isDelete
	 * @param  isUndelete
	 * @param  triggerNew
	 * @param  triggerOldMap
	 */
	@testVisible
	private static void run(myTriggers handler, Type handlerType, Boolean isBefore, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete, sObject[] triggerNew, Map<Id,sObject> triggerOldMap){
		setAllowedTriggerEvents(handlerType,false);

		Set<String> disabledTriggerEvents = getDisabledEvents(handlerType);
		if (isBefore) {
			if (isInsert && !disabledTriggerEvents.contains(System.TriggerOperation.BEFORE_INSERT.name())) {
				handler.doConstruct(triggerNew).onBeforeInsert();
			}
			else if (isUpdate && !disabledTriggerEvents.contains(System.TriggerOperation.BEFORE_UPDATE.name())) {
				handler.doConstruct(triggerNew).onBeforeUpdate(triggerOldMap);
			}
			else if (isDelete && !disabledTriggerEvents.contains(System.TriggerOperation.BEFORE_DELETE.name())) {
				handler.doConstruct(triggerOldMap.values()).onBeforeDelete();
			}
		} else {
			if (isInsert && !disabledTriggerEvents.contains(System.TriggerOperation.AFTER_INSERT.name())) {
				handler.doConstruct(triggerNew).onAfterInsert();
			}
			else if (isUpdate && !disabledTriggerEvents.contains(System.TriggerOperation.AFTER_UPDATE.name())) {
				handler.doConstruct(triggerNew).onAfterUpdate(triggerOldMap);
			}
			else if (isDelete && !disabledTriggerEvents.contains(System.TriggerOperation.AFTER_DELETE.name())) {
				handler.doConstruct(triggerOldMap.values()).onAfterDelete();
			}
			else if (isUndelete && !disabledTriggerEvents.contains(System.TriggerOperation.AFTER_UNDELETE.name())) {
				handler.doConstruct(triggerNew).onAfterUndelete();
			}
		}
	}

	/**
	 * Returns type of triggerHandler class according to given triggerHandlerSetting
	 * @param  triggerHandlerSetting
	 * @param  namespacePrefixes
	 * @return handlerType
	 */
	@testVisible
	private static Type getTriggerHandlerType(String namespacePrefix, String className){
		namespacePrefix = namespacePrefix == null ? '' : namespacePrefix;
		Type handlerType = Type.forName(namespacePrefix, className);

		//In case handler is part of the subscriber org
		if (handlerType == null) {
			handlerType = Type.forName('', className);
		}
		if (handlerType == null) {
			throw new myTriggersException(Label.Errors_CannotFindTriggerHandlerClass + ':' + (namespacePrefix == null ? '' : namespacePrefix + '.') + className);
		}
		return handlerType;
	}

	/**
	 * Set maps containing triggerHandlerSetting records for given sObjectType
	 * @param  objectType SobjectType
	 */
	@TestVisible
	private static void setTriggerHandlerMaps(sObjectType objectType) {
		if (triggerEventsToTriggerHandlers == null) {
			triggerEventsToTriggerHandlers = new Map<String, List<MyTriggerSetting__mdt> >();
		}
		if (handlerClassesToTriggerHandlers == null) {
			handlerClassesToTriggerHandlers = new Map<String, List<MyTriggerSetting__mdt> >();
		}
		for (MyTriggerSetting__mdt triggerSetting : getTriggerHandlerSettings(objectType)) {
			if (!triggerEventsToTriggerHandlers.containsKey(triggerSetting.Event__c)) {
				triggerEventsToTriggerHandlers.put(triggerSetting.Event__c, new List<MyTriggerSetting__mdt>());
			}
			triggerEventsToTriggerHandlers.get(triggerSetting.Event__c).add(triggerSetting);
			String namespacePrefix = triggerSetting.ClassNamespacePrefix__c == null ? '' : triggerSetting.ClassNamespacePrefix__c;
			String classWithNamespaceKey = getClassNameWithNamespace(triggerSetting);
			if (!handlerClassesToTriggerHandlers.containsKey(classWithNamespaceKey)) {
				handlerClassesToTriggerHandlers.put(classWithNamespaceKey, new List<MyTriggerSetting__mdt>());
			}
			handlerClassesToTriggerHandlers.get(classWithNamespaceKey).add(triggerSetting);
		}
		sortTriggerEventsToTriggerHandlers();
		//System.debug('FW events ' +triggerEventsToTriggerHandlers.keySet());
		//System.debug('FW classes ' +handlerClassesToTriggerHandlers.keySet());
	}

	@testvisible
	private static String getClassNameWithNamespace(MyTriggerSetting__mdt triggerHandlerSetting){
		String namespacePrefix = String.isBlank(triggerHandlerSetting.ClassNamespacePrefix__c) ? '' : triggerHandlerSetting.ClassNamespacePrefix__c;
		return (String.isBlank(namespacePrefix) ? '' :  namespacePrefix.toUpperCase() + '.') + triggerHandlerSetting.Class__c.toUpperCase();
	}

	/**
	 * Returns list of triggerHandlerSetting for sObjectType
	 * @param sObjectType
	 * @return triggerHandlerSetting for sObjectType
	 */
	private static List<MyTriggerSetting__mdt> getTriggerHandlerSettings(sObjectType objectType){
		// if already seen, return empty list
		if (knownExecutionContextSobjectTypes == null) {
			knownExecutionContextSobjectTypes = new Set<sObjectType>();
		}
		String sObjectName = objectType.getDescribe().getName();
		List<MyTriggerSetting__mdt> triggerHandlerSettings;

		if (Test.isRunningTest() && triggerHandlerSettingMocks != null) {
			triggerHandlerSettings = triggerHandlerSettingMocks;
		} else {
			if (knownExecutionContextSobjectTypes.contains(objectType)) {
				//system.assert (false, 'wtf');
				triggerHandlerSettings = new List<MyTriggerSetting__mdt>();
			} else {
				triggerHandlerSettings = runTriggerHandlerSettingsQuery(sObjectName);
				knownExecutionContextSobjectTypes.add(objectType);
			}
		}

		triggerHandlerSettings = filterForByPass(triggerHandlerSettings);
		triggerHandlerSettings = validate(triggerHandlerSettings);

		return triggerHandlerSettings;
	}

	@testvisible
	private static List<MyTriggerSetting__mdt> runTriggerHandlerSettingsQuery(String sObjectName){
		// Custom Metadata SOQL does neither support the keyword OR
		// nor disjunctions
		Map<Id,MyTriggerSetting__mdt> allSettingsMap = new Map<Id,MyTriggerSetting__mdt>();
		Map<Id,MyTriggerSetting__mdt> settingsQualifiedAPINameMatch =  new Map<Id,MyTriggerSetting__mdt>([SELECT DeveloperName,
		                                                                                                  ClassNamespacePrefix__c,
		                                                                                                  Event__c,
		                                                                                                  sObject__c,
		                                                                                                  sObject__r.QualifiedApiName,
		                                                                                                  sObjectAPIName__c,
		                                                                                                  Class__c,
		                                                                                                  Order__c
		                                                                                                  FROM MyTriggerSetting__mdt
		                                                                                                  WHERE Active__c = true
		                                                                                                                    AND sObject__r.QualifiedApiName = : sObjectName
		                                                                                                                                                      ORDER BY Order__c,
		                                                                                                  DeveloperName ASC]);
		Map<Id,MyTriggerSetting__mdt> settingsSObjectOverride = new Map<Id,MyTriggerSetting__mdt>([SELECT DeveloperName,
		                                                                                           ClassNamespacePrefix__c,
		                                                                                           Event__c,
		                                                                                           sObject__c,
		                                                                                           sObject__r.QualifiedApiName,
		                                                                                           sObjectAPIName__c,
		                                                                                           Class__c,
		                                                                                           Order__c
		                                                                                           FROM MyTriggerSetting__mdt
		                                                                                           WHERE Active__c = true
		                                                                                                             AND sObjectAPIName__c = : sObjectName
		                                                                                                                                     ORDER BY Order__c,
		                                                                                           DeveloperName ASC]);
		allSettingsMap.putAll(settingsQualifiedAPINameMatch);
		allSettingsMap.putAll(settingsSObjectOverride);
		return allSettingsMap.values();
	}

	@testvisible
	private static void sortTriggerEventsToTriggerHandlers() {

		for (String event : triggerEventsToTriggerHandlers.keyset()) {

			List<MyTriggerSetting__mdt> triggerSettings = triggerEventsToTriggerHandlers.get(event);
			Map<String, MyTriggerSetting__mdt> triggerSettingMap = new Map<String, MyTriggerSetting__mdt>();
			List<String> triggerSettingSortKeys = new List<String>();
			List<MyTriggerSetting__mdt> sortedTriggerSettings = new List<MyTriggerSetting__mdt>();

			for (MyTriggerSetting__mdt triggerSetting : triggerSettings) {
				String sortKey = leftPadWithZero(triggerSetting.Order__c, 4);
				triggerSettingSortKeys.add(sortKey);
				triggerSettingMap.put(sortKey, triggerSetting);
			}

			triggerSettingSortKeys.sort();

			for (String s : triggerSettingSortKeys) {
				sortedTriggerSettings.add(triggerSettingMap.get(s));
			}

			triggerEventsToTriggerHandlers.put(event, sortedTriggerSettings);

			//system.debug('FW       '+event);
			/*
			triggerEventsToTriggerHandlers.get(event).sort();
			List<MyTriggerSetting__mdt> reversed = new List<MyTriggerSetting__mdt>();
			for(Integer i = triggerEventsToTriggerHandlers.get(event).size() - 1; i >= 0; i--) {
				reversed.add(triggerEventsToTriggerHandlers.get(event)[i]);
			}
			triggerEventsToTriggerHandlers.put(event,reversed);

			// for (MyTriggerSetting__mdt setting : triggerEventsToTriggerHandlers.get(event)) {
			// 	system.debug('FW              '+Integer.valueOf(setting.Order__c)+'-'+setting.sObject__c+'-'+setting.DeveloperName);
			// }

			 */
		}
	}

	/**
	 * converts the input object to a string of at least the length given as the second parameter
	 *
	 * @param Object toPad
	 * @param Integer targetLength the desired length
	 *
	 * @return
	 */
	@testvisible static String leftPadWithZero(Object toPad, Integer targetLength) {

		String targetString = String.valueOf(toPad);

		if (targetString.length() > targetLength) {
			return targetString;
		}

		while (targetString.length() < targetLength) {
			targetString = '0' + targetString;
		}

		return targetString;
	}

	@testvisible
	private static List<MyTriggerSetting__mdt> filterforBypass(List<MyTriggerSetting__mdt> settings) {
		List<MyTriggerSetting__mdt> triggerHandlerSettingsFilteredForBypass = new List<MyTriggerSetting__mdt>();

		for (MyTriggerSetting__mdt setting : settings) {

			if (FeatureManagement.checkPermission('bypassMyTriggers')
			    && setting.IsByPassAllowed__c != null && setting.IsByPassAllowed__c) {
				continue;
			}
			triggerHandlerSettingsFilteredForBypass.add(setting);
		}
		return triggerHandlerSettingsFilteredForBypass;
	}

	@testvisible
	private static List<MyTriggerSetting__mdt> validate(List<MyTriggerSetting__mdt> settings) {
		for (MyTriggerSetting__mdt setting : settings) {
			if(setting.sObject__c != null && setting.sObjectAPIName__c != null) {
				String qualifiedAPIName = Test.isRunningTest() ? qualifiedApiNameMock : setting.sObject__r.QualifiedAPIName;
				if (qualifiedAPIName != setting.sObjectAPIName__c)
					throw new myTriggersException(String.format(Label.Errors_InvalidSettingConfiguration, new List<String> {setting.developerName}));
			}
		}
		return settings;
	}

}