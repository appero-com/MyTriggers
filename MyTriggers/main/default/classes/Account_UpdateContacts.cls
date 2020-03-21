public class Account_UpdateContacts extends MyTriggers {
    
    public override void onBeforeInsert() {
        
        Map<Id, sObject> scope = new Map<Id, sObject>(records);
        List<Contact> contacts = [SELECT Id, LastName FROM Contact WHERE AccountId IN:scope.keyset()];
        
        
        
    }

}