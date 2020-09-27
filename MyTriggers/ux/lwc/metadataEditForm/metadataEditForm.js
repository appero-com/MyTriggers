import {LightningElement, api, track} from 'lwc';

export default class MetadataEditForm extends LightningElement {

	currentRecord;

	@api
	set record(value) {
		this.currentRecord = value;
	}

	get record() {
		return this.currentRecord;
	}

	handleChangeLabel(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.Label = event.detail.value;
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

	handleChangeDescription(event) {
		let rec = JSON.parse(JSON.stringify(this.currentRecord));
		rec.Description__c = event.detail.value;
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