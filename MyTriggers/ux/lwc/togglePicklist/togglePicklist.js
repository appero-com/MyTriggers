import {LightningElement, api, track} from 'lwc';

export default class TogglePicklist extends LightningElement {

    labels = {
        uncheckAll : "uncheckall"
    }

    @track
    _options = [];

    @api 
    title;

    value =[];

    @api
    set options(value) {
        //console.log("TogglePicklist set options");
        //console.log(JSON.stringify(value));
        if (value != null) {
			this._options = [];
            for (let i = 0; i < value.length; i++) {
                //console.log(value[i].value);
                this._options.push( {"value" : value[i].value, "label" : value[i].label, "isSelected" : true});
                this.value.push(value[i].value);
            }
        
            /*let lightningButtons = this.querySelectorAll("lightning-button");
            //console.log(lightningButtons.length);*/
        }
        //console.log(JSON.stringify(this._options));
    }

    get options() {
        return this._options;
    }

    handleToggleChange(event) {
        console.log("TogglePicklist handleToggleChange");

        let valIndex = this.value.indexOf(event.detail.value);
        if (valIndex >= 0) {
            this.value.splice(valIndex, 1);
        } else {
            this.value.push(event.detail.value);
        }

        //console.log(this.value);
        this.dispatchPicklistChange();
    }

    dispatchPicklistChange() {
        this.dispatchEvent(
            new CustomEvent(
                'change', 
                { 
                    detail: {
                        'value' : this.value
                    }
                }
            )
        );
    }

    handleCheckAll(event) {
        console.log("TogglePicklist handleCheckAll");
        this.value = [];
        for (let i = 0; i < this._options.length; i++) {
            console.log("TogglePicklist for " + i);
            this._options[i].isSelected = true;
            console.log("TogglePicklist for true");
            this.value.push(this._options[i].value);
            console.log("TogglePicklist for " + this._options[i].value);
        }
        console.log("TogglePicklist after for");
        this.dispatchPicklistChange();
    }

    handleUncheckAll(event) {
        console.log("TogglePicklist handleUncheckAll");
        this.value = [];
        for (let i = 0; i < this._options.length; i++) {
            this._options[i].isSelected = false;
        }
        this.dispatchPicklistChange();
    }
}