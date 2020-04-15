import { LightningElement, api, track } from 'lwc';

/**
 * Show an item
 */
export default class RowComponent extends LightningElement {
    @api
    elements = [];

	handleCellDblClick(event) {
		console.log("RowComponent@handleCellDblClick");
		console.log(event.detail);
	}
}