import { LightningElement, track, wire } from 'lwc';
import getMDTRowsApex from '@salesforce/apex/MyTriggers.getAllTriggerHandlerSettings';
//import updateMetadata from '@salesforce/apex/CreateUpdateMetadataUtils.updateMdt';

export default class MyTriggersViewer extends LightningElement {

    @wire(getMDTRowsApex)
    mdtFromApex;
	
	_currentRecord;
	currentRecordChanged;

	changedData = new Map();

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
		let mdtRaw = this.mdtFromApex.data;
		let mapped = new Map();
		for (let index = 0; index < mdtRaw.length; index++) {
			mapped.set(mdtRaw[index].Id, mdtRaw[index]);
		}
		return mapped;
	}

	get mdt() {
		console.log("myTriggerViewer@mdt");
		let fromApex = JSON.parse(JSON.stringify(this.mdtFromApex));
		if (this.mdtFromApex.data) {
			for (let index = 0; index < fromApex.data.length; index++) {
				let mdtRow = fromApex.data[index];
				if (this.changedData.get(mdtRow.Id)) {
					fromApex.data[index].isChanged = true;
				}
			}
			console.log(JSON.stringify(fromApex));
			return fromApex;
		} else {
			return this.mdtFromApex;
		}
		
	}

    handleCellDblClick(event) {
		console.log("MyTriggersViewer@handleCellDblClick");
		console.log(event.detail);		
		console.log(this.changedData.get(event.detail));
		if (this.changedData.get(event.detail)) {
			this._currentRecord = this.changedData.get(event.detail);
		} else {
			this._currentRecord = this.mdtById.get(event.detail);
		}
		this.modalWindow.show();
	}

	handleMetadataChange(event) {
		console.log("MyTriggersViewer@handleMetadataChange");
		this.currentRecordChanged = JSON.parse(JSON.stringify(event.detail));
		
	}

	handleOkClick(event) {
		console.log("MyTriggersViewer@handleOkClick");
		if (this.currentRecordChanged != null) {
			this.changedData.set(this.currentRecordChanged.Id, this.currentRecordChanged);
		}
		this._currentRecord = null;
		console.log(this.changedData);
		console.log("ok clicked");
	}

	handleSaveChangedClick(event) {
		console.log("MyTriggersViewer@handleSaveChangedClick");

		console.log(this.changedData);

		let toUpdate = [];
		this.changedData.forEach(function(value){
			toUpdate.push(value);
		});

		updateMetadata(
			{ 
				metadataAsString: JSON.stringify(toUpdate)
			}
		).then(result => {
            console.log(result);
        })
        .catch(error => {
            console.log(error);
        });
	}
}