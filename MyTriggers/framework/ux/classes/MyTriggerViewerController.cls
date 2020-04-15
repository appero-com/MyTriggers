public class MyTriggerViewerController implements Metadata.DeployCallback {
    /**
     * Returns list of all triggerHandlerSetting
     * @return all triggerHandlerSetting
     */
    @AuraEnabled
    public static List<MyTriggerSetting__mdt> getAllTriggerHandlerSettings(){
        List<MyTriggerSetting__mdt> triggerHandlerSettings;

            triggerHandlerSettings = new List<MyTriggerSetting__mdt>(
                [SELECT DeveloperName, 
                        Label,
                        ClassNamespacePrefix__c, 
                        Event__c, 
                        sObject__c,
                        sObject__r.QualifiedApiName, 
                        sObjectAPIName__c,
                        Class__c, 
                        Order__c,
                        Description__c,
                        Active__c,
                        IsBypassAllowed__c
                FROM MyTriggerSetting__mdt
                WHERE Active__c = true
                ORDER BY Order__c, 
                         DeveloperName ASC]);

        System.debug(JSON.serialize(triggerHandlerSettings));
        return triggerHandlerSettings;
    }

    /* Below method recieves the 2 parameters 
       1 - Metadata.DeployResult => Object of MetadataContainer class where this method has been implemented.
       2 - Metadata.DeployCallbackContext => Object of the class where this method has been implemented
   */
    public void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('success');
        } else {
            // Deployment was not successful
        }
    }

	@AuraEnabled(cacheable=true)
    public static String updateMdt(String metadataAsString) {
		System.debug(metadataAsString);
		List<MyTriggerSetting__mdt> metadataRecords = (List<MyTriggerSetting__mdt>) JSON.deserialize(metadataAsString, List<MyTriggerSetting__mdt>.class); 
		Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
		
		for (MyTriggerSetting__mdt currentMetadataRecord : metadataRecords) {
			Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();

			customMetadata.fullName = 'MyTriggerSetting.'+currentMetadataRecord.DeveloperName;
			customMetadata.label = currentMetadataRecord.Label;

			customMetadata.values.add(createField('Class__c', currentMetadataRecord.Class__c));
			customMetadata.values.add(createField('Description__c', currentMetadataRecord.Description__c));
			customMetadata.values.add(createField('Event__c', currentMetadataRecord.Event__c));
			customMetadata.values.add(createField('sObject__c', currentMetadataRecord.sObject__c));
			customMetadata.values.add(createField('sObjectAPIName__c', currentMetadataRecord.sObjectAPIName__c));
			customMetadata.values.add(createField('IsBypassAllowed__c', currentMetadataRecord.IsBypassAllowed__c));
			customMetadata.values.add(createField('Active__c', currentMetadataRecord.Active__c));
			customMetadata.values.add(createField('Order__c', currentMetadataRecord.Order__c));
			customMetadata.values.add(createField('ClassNamespacePrefix__c', currentMetadataRecord.ClassNamespacePrefix__c));

			mdContainer.addMetadata(customMetadata);
		}
		MyTriggerViewerController callback = new MyTriggerViewerController();
		Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
		
		return jobId;
	}

	@AuraEnabled
    public static Map<String,Object> checkMdt(String deploymentId) {
		Map<String,Object> result = new Map<String,Object>();
		
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployResult deployResult = service.checkDeployStatus(deploymentId, true);
		if(deployResult.done) {
			System.debug('Deployment complete');
			result.put('isSuccess', true);
			result.put('isDeployed', true);
			result.put('message', 'Deployment complete');
			// Deployment errors?
			if(deployResult.details!=null && deployResult.details.componentFailures!=null) {
				for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures) {
					if(deployMessage.problem!=null) {
						String errorMsg = deployMessage.fileName + 
									' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
										deployMessage.problem;
						result.put('isSuccess', false);
						result.put('isDeployed', false);
						result.put('error', errorMsg);
					}
				}
			}
		} else {
			result.put('isSuccess', true);
			result.put('isDeployed', false);
			result.put('message', 'Deploying...');
		}

		return result;
	}

	public static Metadata.CustomMetadataValue createField(String fieldName, String value) {
		Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
		customField.field = fieldName;
		customField.value = value;
		return customField;
	}

	public static Metadata.CustomMetadataValue createField(String fieldName, Boolean value) {
		Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
		customField.field = fieldName;
		customField.value = value;
		return customField;
	}

	public static Metadata.CustomMetadataValue createField(String fieldName, Decimal value) {
		Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
		customField.field = fieldName;
		customField.value = value;
		return customField;
	}

	private static MetadataService.MetadataPort createService() { 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}
     
	@AuraEnabled(cacheable=true)
	public static List<Object> getSobjects(){
		List<Object> result = new List<Object>();
        for (EntityDefinition entity : [
				SELECT
					DeveloperName,
					Id,
					Label
				FROM EntityDefinition
				where IsWorkflowEnabled = true 
				order by Label ]
		) {
            result.add(
				new SobjectItem(
					entity.DeveloperName, 
					entity.Label
				)
			);
        }
        return result;
	}

	public class SobjectItem {
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String label;

		public SobjectItem(String value, String label) {
			this.value = value;
			this.label = label;
		}
	}
}