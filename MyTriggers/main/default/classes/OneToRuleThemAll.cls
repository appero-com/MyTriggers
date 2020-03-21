public with sharing class OneToRuleThemAll extends MyTriggers {

	public override void onBeforeInsert() {
		String objectType = String.valueOf(records[0].getSObjectType());
		switch on objectType {
			when 'Account' {
				//system.debug('IMPL Account Code Order 0 ' + Trigger.operationType);
			}
			when 'Contact' {
				//system.debug('IMPL Contact Code Order 0 ' + Trigger.operationType);
			}
		}
	}

	public override void onAfterInsert() {
		String objectType = String.valueOf(records[0].getSObjectType());
		switch on objectType {
			when 'Account' {
				system.debug('IMPL Inserting new Contact');
				insert new Contact(accountid = records[0].id, LastName = 'Test'+System.now());
			}
			when 'Contact' {
				//system.debug('IMPL Contact Code Order 0  ' + Trigger.operationType);
			}
		}
	}

}