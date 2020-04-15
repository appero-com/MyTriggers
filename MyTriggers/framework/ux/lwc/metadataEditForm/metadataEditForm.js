import {LightningElement, api, track} from 'lwc';

export default class MetadataEditForm extends LightningElement {

	currentRecord;

	sobjOpts;

	eventOptions = [
		{"value":"BEFORE_INSERT", "label":"Before Insert"},
		{"value":"BEFORE_UPDATE", "label":"Before Update"},
		{"value":"BEFORE_Delete", "label":"Before Before"},
		{"value":"AFTER_INSERT", "label":"After Insert"},
		{"value":"AFTER_UPDATE", "label":"After Update"},
		{"value":"AFTER_DELETE", "label":"After Delete"},
		{"value":"AFTER_UNDELETE", "label":"After Undelete"}
	];

	@api
	set sobjectOptions(value){
		this.sobjOpts = value;
	}

	get sobjectOptions(){
		return this.sobjOpts;
	}
	//isActive;

	@api
	set record(value) {
		this.currentRecord = value;
		//console.log("MetadataEditForm set record");
		//console.log(this.currentRecord.Active__c);
		//this.isActive = this.currentRecord.Active__c;
	}

	get record() {
		return this.currentRecord;
	}

	handleChangeLabel(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.Label = event.detail.value;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}

	handleChangeDescription(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.Description__c = event.detail.value;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}

	handleChangeActive(event){
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.Active__c = event.detail.value;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}

	handleChangeBypassAllowed(event){
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.IsBypassAllowed__c = event.detail.checked;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}
	handleChangeSobject(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.sObject__c = event.detail.value;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}
	handleChangeEvent(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.Event__c = event.detail.value;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}
	handleChangeSobjectOverride(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.sObjectAPIName__c = event.detail.value;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}
	handleChangeOrder(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.Order__c = event.detail.value;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}
	handleChangeClassNamespace(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.ClassNamespacePrefix__c = event.detail.value;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}
	handleChangeClass(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.Class__c = event.detail.value;
		this.record = rec;
		this.dispatchChangeEvent(rec);
	}

    handleKeyUp({code}) {
        console.log(code);
    }

	dispatchChangeEvent(rec) {
		this.dispatchEvent(
			new CustomEvent(
				'metadatachange', 
				{ 
					detail: rec,
					bubbles: true,
					composed: true
				}
			)
		);
	}
}