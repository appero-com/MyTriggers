import { LightningElement, api, track } from 'lwc';

/**
 * Show an item
 */
export default class BusinessCentricFilter extends LightningElement {

    @track valueBA = []; 
    @track valueCRUD = []; 
    @track valueSobjects = [];
    @track classValue = '';

    @track filterOptions = {"optionTiming" : [], "optionDml":[],"optionClass":[],"optionSobject":[]};
    
	initialized = false;

    @api
    set options(value) {
        //console.log("BusinessCentricFilter set selected");
        //console.log(JSON.stringify(value));
        this.filterOptions = value;
        if (value.optionTiming  && !this.initialized) {
            this.setupDefaultValues();
        }
    }

    get options(){
        return this.filterOptions;
    }

    setupDefaultValues(){
        console.log("BusinessCentricFilter setupDefaultValues");
		this.valueBA = [];
        for (let i = 0; i < this.filterOptions.optionTiming.length; i++) {
            this.valueBA.push(this.filterOptions.optionTiming[i].value);
        }
		this.valueCRUD = [];
        for (let i = 0; i < this.filterOptions.optionDml.length; i++) {
            this.valueCRUD.push(this.filterOptions.optionDml[i].value);
        }
		this.valueSobjects = [];
        for (let i = 0; i < this.filterOptions.optionSobject.length; i++) {
            this.valueSobjects.push(this.filterOptions.optionSobject[i].value);
        }
        
        this.classValue = this.filterOptions.optionClass[0].value;
        
        //this.valueBA = this.filterOptions.optionTiming;
        //console.log(JSON.stringify(this.valueBA));
        //console.log(JSON.stringify(this.valueCRUD));
        //console.log(JSON.stringify(this.valueSobjects));
        //console.log(JSON.stringify(this.classValue));

        //this.dispatchFilterChange();
		this.initialized = true;
    }

    get optionsBA() {
        return this.filterOptions.optionTiming;
    }

    get optionsCRUD() {
        return this.filterOptions.optionDml;
    }

    get optionsSobjects() {
        return this.filterOptions.optionSobject;
    }
    get optionsClasses() {
        return this.filterOptions.optionClass;
    }

    handleClassChange(event) {
        this.classValue = event.detail.value;
        this.dispatchFilterChange();
    }

    handleDMLTypeChange(event) {
        this.valueCRUD = event.detail.value;
        this.dispatchFilterChange();
    }

    handleDMLTimingChange(event) {
        this.valueBA = event.detail.value;
        this.dispatchFilterChange();
    }

    handleSobjectChange(event) {
        console.log("handleSobjectChange");
        console.log(event.detail.value);
        this.valueSobjects = event.detail.value;
        this.dispatchFilterChange();
    }

    dispatchFilterChange() {
        var sobjectValues = [];
        for (var i = 0; i < this.valueSobjects.length; i++) {
            sobjectValues.push(this.valueSobjects[i]);
        }

        var crudValues = [];
        for (var i = 0; i < this.valueCRUD.length; i++) {
            crudValues.push(this.valueCRUD[i]);
        }

        var timingValues = [];
        for (var i = 0; i < this.valueBA.length; i++) {
            timingValues.push(this.valueBA[i]);
        }

        let detailtoSend = {
            "classValue" : this.classValue,
            "sobjectsValues" : sobjectValues,
            "crudValue" : crudValues,
            "timingValue" : timingValues
        };
        console.log(detailtoSend);

        this.dispatchEvent(
            new CustomEvent(
                'filterchange', 
                { 
                    detail: detailtoSend
                }
            )
        );
    }
}