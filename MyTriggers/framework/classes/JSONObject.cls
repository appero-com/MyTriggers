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
public class JSONObject {
    public class JSONObjectException extends Exception {}

    public static String NAMESPACEPREFIX {
        get {
            if (namespacePrefix == null) {
                namespacePrefix = JSONObject.class.getName().substringBefore('.JSONObject');
                namespacePrefix = namespacePrefix.length() > 0 && namespacePrefix != 'JSONObject' ? namespacePrefix + '__' : '';
            }
            return namespacePrefix;
        }
        private set;
    }
    
    @testvisible
    private Map<String,Object> propertyMap = new Map<String,Object>(); 
    
    public JSONObject(String singleObjectJSON) {
        try {
            JSON.deserializeUntyped(singleObjectJSON);
        } catch (exception e) {
            throw new JSONOBjectException('This is not a valid JSON String.');
        }
        
        try {
            propertyMap = (Map<String,Object>)JSON.deserializeUntyped(singleObjectJSON);
        } catch (exception e) {
            throw new JSONOBjectException('A single JSON Object is expected. The JSON String contains a list of Objects.');
        }
    }
    
    public JSONObject(Object anyObject) {
        this(JSON.serialize(anyObject));
    }
    
    public Boolean hasProperty(String propertyName) {
        return propertyMap.get(propertyName) != null ? true : false; 
    }
    
    public Object get(String propertyName) {
        return propertyMap.get(propertyName);
    }
    
    public void set(String propertyName, Object value) {
        propertyMap.put(propertyName, value);
    }

    public void set(String propertyName, Object value, Boolean appendNamespace) {
        if(appendNamespace){
            propertyName = NAMESPACEPREFIX + propertyName;
        }
        propertyMap.put(propertyName, value);
    }
    
    public Object deserialize(System.Type apexType) {
        return JSON.deserializeStrict(toJSON(), apexType);
    }
    
    @testVisible
    private String toJSON() {
        return JSON.serialize(propertyMap);
    }

    @testVisible
    private static Boolean hasProperty(String json, String propertyName) {
        return json.contains(propertyName);
    }
}