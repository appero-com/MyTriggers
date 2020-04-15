import {LightningElement, track, api} from 'lwc';

export default class ModalWindow extends LightningElement {

	@track
	isVisible = false;

	@api
	title;

	@api
	width = "slds-modal_large";

	@api
	footerButtons;

	@api
	show() {
		this.isVisible = true;
	}

	@api
	close() {
		this.isVisible = false;
	}
    
	get modalClass(){
		return "slds-modal slds-fade-in-open " + this.width;
	}


}