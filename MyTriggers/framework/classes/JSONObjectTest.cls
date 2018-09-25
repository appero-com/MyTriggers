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
@istest
public class JSONObjectTest {
    private static final Account newAccount = new Account(Name = 'Johnson Inc.', 
                                                          Industry = 'Publishing',
                                                          Type = 'Customer');

    public static final String accountJSON = JSON.serialize(newAccount);
    public Static final String accountListJSON = JSON.serialize(new List<Account>{newAccount});
    public static final String noJSONAtAll = 'Abced,[,[,{}/@""';
     
    @isTest
    public static void constructorJSON_Error_InvalidJSON() {
       exception e;
        try {
            new JSONObject(noJSONAtAll);
        } catch (exception ex) {
            e = ex;
        }
        System.Assert(e!=null,'Exception expected');
        System.Assert(e.getMessage().containsIgnoreCase('valid'),'valid must be part of error message');
    }
    
    
    @isTest
    public static void constructorJSON_Error_ReceivedList() {
        exception e;
        try {
            new JSONObject(accountListJSON);
        } catch (exception ex) {
            e = ex;
        }
        System.Assert(e!=null,'Exception expected');
        System.Assert(e.getMessage().containsIgnoreCase('list'),'List error message must be shown');
    }
    
    @isTest
    public static void constructorJSON_Success() {
        exception e;
        JSONObject jAccount; 
        try {
            jAccount = new JSONObject(accountJSON);
        } catch (exception ex) {
            e = ex;
        }
        System.Assert(e==null,'No Exception allowed');
        System.AssertEquals('Publishing',String.ValueOf(jAccount.propertyMap.get('Industry')),'Expected Value Publishing needs to be returned');
    }
    
    @isTest
    public static void constructorAnyObject_Success() {
        exception e;
        JSONObject jAccount; 
        try {
            jAccount = new JSONObject(newAccount);
        } catch (exception ex) {
            e = ex;
        }
        System.Assert(e==null,'No Exception allowed');
        System.AssertEquals('Publishing',String.ValueOf(jAccount.propertyMap.get('Industry')),'Expected Value Publishing needs to be returned');
    }
    
    @isTest 
    public static void getProperty_ReturnsNullIfPropertyNotFound() {
        JSONObject jAccount = new JSONObject(accountJSON);
        System.assertEquals(null, jAccount.get('InvalidKey'),'Null return value expected');
    }
    
    
    @isTest 
    public static void getProperty_Success() {
        JSONObject jAccount = new JSONObject(accountJSON);
        System.assertNotEquals(null, jAccount.get('Industry'),'No null return accepted');
        System.AssertEquals('Publishing',String.ValueOf(jAccount.get('Industry')),'Expected Value Publishing needs to be returned');
    }
    
    @isTest
    public static void setProperty_AlreadyPresent() {
        JSONObject jAccount = new JSONObject(accountJSON);
        jAccount.set('Industry','Media');
        System.AssertEquals('Media',String.ValueOf(jAccount.get('Industry')),'Expected Value Media needs to be returned');
    }
    
    @isTest
    public static void setProperty_NewProperty() {
        JSONObject jAccount = new JSONObject(accountJSON);
        jAccount.set('Description','Test Account');
        System.AssertEquals('Test Account',String.ValueOf(jAccount.get('Description')),'Expected Value Media needs to be returned');
    }
    
    @isTest
    public static void hasProperty() {
        JSONObject jAccount = new JSONObject(accountJSON);
        System.assertEquals(true, jAccount.hasProperty('Industry'),'Must return true');
    }
    
    @isTest
    public static void castBackToSObject() {
        JSONObject jAccount = new JSONObject(accountJSON);
        jAccount.set('Industry','Media');
        jAccount.set('Description','Test Account');
        Account myAccount = (Account)jAccount.deserialize(Account.class);
        insert myAccount;
        System.Assert(myAccount.Id!=null,'Successful insert expected');
    }
}