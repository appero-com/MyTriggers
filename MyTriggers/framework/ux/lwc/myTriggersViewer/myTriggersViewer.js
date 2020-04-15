import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMDTRowsApex from '@salesforce/apex/MyTriggerViewerController.getAllTriggerHandlerSettings';
import updateMetadata from '@salesforce/apex/MyTriggerViewerController.updateMdt';
import checkDeployment from '@salesforce/apex/MyTriggerViewerController.checkMdt';
import getAllSObjects from '@salesforce/apex/MyTriggerViewerController.getSobjects';

export default class MyTriggersViewer extends LightningElement {

    @wire(getAllSObjects)
    allSobjectOptions;
	
	_currentRecord;
	currentRecordChanged;

	@track
	currentData;
	changedData = new Map();

	currentDeploymentId;

	isDeploying = false;

    connectedCallback() {
        let gen = function(comp) {
            return function(event){
                if (event.keyCode == 27) {//ESC
                    comp.modalWindow.close();
                } else if (event.keyCode == 13) {//ENTER
                    if (comp.currentRecordChanged) {
                        comp.handleOkClick(event);
                    }
                    comp.modalWindow.close();
                }
                
            }
        };
        
        window.onkeydown = gen(this);
    }

	get modalWindow() {
		return this.template.querySelector("c-modal-window");
	}
	
	get modalButtons(){
		return [
			{
				"label": "OK",
				"click": function(){
					this.dispatchEvent(
						new CustomEvent(
							'okclick', 
							{ 
								bubbles: true,
								composed: true
							}
						)
					);
					this.close();
				},
				"class":"slds-button slds-button_brand"
			},
			{
				"label": "Cancel",
				"click": function(){
					this.close();
				},
				"class":"slds-button slds-button_neutral"
			}
		];
	}

	get currentRecord() {
		return this._currentRecord;
	}

	get mdtById() {
		let mdtRaw = this.currentData.data;
		let mapped = new Map();
		for (let index = 0; index < mdtRaw.length; index++) {
			mapped.set(mdtRaw[index].Id, mdtRaw[index]);
		}
		return mapped;
	}

	get mdt() {
		console.log("myTriggerViewer@mdt");
		
		if (this.currentData) {
			console.log("should not refreshData");
			console.log(this.currentData);
			console.log(this.currentData.data);
			if (this.currentData.data){
				for (let index = 0; index < this.currentData.data.length; index++) {
					let mdtRow = this.currentData.data[index];
					//console.log(mdtRow);
					if (this.changedData.get(mdtRow.Id)) {
						this.currentData.data[index].isChanged = true;
					} else {
						this.currentData.data[index].isChanged = false;
					}
				}
			}
		} else {
			console.log("refreshData");
			this.currentData = {};
			this.refreshData();
		}
		console.log(this.currentData);
		return this.currentData;
	}

	get sobjectOptions() {
		console.log("MyTriggersViewer get sobjectOptions");
		return this.allSobjectOptions.data;
	}

    handleCellDblClick(event) {
		console.log("MyTriggersViewer@handleCellDblClick");
		console.log(event.detail);		
		console.log(this.changedData.get(event.detail));
		console.log(this.allSobjectOptions);
		if (this.changedData.get(event.detail)) {
			this._currentRecord = this.changedData.get(event.detail);
		} else {
			this._currentRecord = this.mdtById.get(event.detail);
		}
		this.modalWindow.show();
        //setTimeout(() => {
        //});
	}

	handleMetadataChange(event) {
		console.log("MyTriggersViewer@handleMetadataChange");
		this.currentRecordChanged = JSON.parse(JSON.stringify(event.detail));
		console.log(this.currentRecordChanged);
	}

	handleOkClick(event) {
		console.log("MyTriggersViewer@handleOkClick");
		if (this.currentRecordChanged != null) {
			delete this.currentRecordChanged.isChanged;
			delete this.currentRecordChanged.sObject__r;
			this.changedData.set(this.currentRecordChanged.Id, this.currentRecordChanged);
		}
		this._currentRecord = null;
		console.log(this.changedData);
		console.log("ok clicked");
	}

	handleSaveChangedClick(event) {
		console.log("MyTriggersViewer@handleSaveChangedClick");
		this.isDeploying = true;
		console.log(this.changedData);

		let toUpdate = [];
		this.changedData.forEach(function(value){
			toUpdate.push(value);
		});
		console.log(toUpdate);
		updateMetadata(
			{ 
				metadataAsString: JSON.stringify(toUpdate)
			}
		).then(result => {
			this.currentDeploymentId = result;
			setTimeout(
				() => {
					this.asyncCheckDeployment();
				}, 
				2000
			);
            console.log(result); 
        })
        .catch(error => {
            console.log(error);
        });
	}

    handleKeyPress({code}) {
        console.log(code);
        if ('Escape' === code) {
            console.log("MyTriggersViewer@handleKeyPress");
            console.log(event.which);
        }
        
    }

	asyncCheckDeployment() {
		console.log("asyncCheckDeployment");
		checkDeployment(
			{
				deploymentId : this.currentDeploymentId
			}
		).then(
			result => {
				if (result.isSuccess && result.isDeployed) {
					console.log("result.isSuccess && result.isDeployed");
					console.log(result);
					this.changedData = new Map();
					this.isDeploying = false;
					this.showToast("Success!", "success", "Metadata records successfully deployed!", "dismissable");
					this.refreshData();
				} else if (result.isSuccess && !result.isDeployed){
					console.log("result.isSuccess && !result.isDeployed");
					setTimeout(
						() => {
							this.asyncCheckDeployment();
						}, 
						1000
					);
				} else {
					console.log("!result.isSuccess && !result.isDeployed");
					this.isDeploying = false;
					this.showToast("Error!", "error", result.error, "sticky");
					console.log(result);
				}
				
			}
		).catch(
			error => {
				this.isDeploying = false;
				this.showToast("Error!", "error", error, "sticky");
				console.log(error);
			}
		);
	}

	refreshData() {
		getMDTRowsApex()
		.then(
			result => {
				console.log("refreshData -> getMDTRowsApex -> result");
				this.currentData = {"data" : JSON.parse(JSON.stringify(result))};
				
			}
		).catch(
			error => {
				console.log(error);
			}
		);
	}

	showToast(title, variant, message, mode){
        this.dispatchEvent(
			new ShowToastEvent({
				"title": title,
				"variant" : variant,
				"message": message,
				"mode" : mode
			})
		);
	}
}