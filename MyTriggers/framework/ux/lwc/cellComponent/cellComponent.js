import {LightningElement, api} from 'lwc';

export default class CellComponent extends LightningElement {

	@api
	label;

	@api
	value;

	_changed = false;

	@api
	set changed(value) {
		this._changed = value;
	}

	get changed() {
		return this._changed;
	}

	get cellClass() {
		if (this._changed) {
			return "background-red";
		} else {
			return "";
		}
	}

	handleDblClickOnCell(event) {
		console.log("RowComponent@handleDblClickOnCell");
		if (this.value) {
			this.dispatchEvent(
				new CustomEvent(
					'celldblclick', 
					{ 
						detail: this.value,
						bubbles: true,
						composed: true
					}
				)
			);
		}
	}

}