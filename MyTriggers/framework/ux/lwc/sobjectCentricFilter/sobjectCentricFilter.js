import { LightningElement, api, track } from 'lwc';

/**
 * Show an item
 */
export default class SobjectCentricFilter extends LightningElement {
    @track valueBA = []; 
    @track valueCRUD = []; 
    @track valueSobjects = '';
    @track classValue = [];

    @track filterOptions = {"optionTiming" : [], "optionDml":[],"optionClass":[],"optionSobject":[]};

    @api
    set options(value) {
        this.filterOptions = value;
        if (value.optionTiming) {
            this.setupDefaultValues();
        }
    }

    get options(){
        return this.filterOptions;
    }

    setupDefaultValues(){
        console.log("SobjectCentricFilter setupDefaultValues");
        for (let i = 0; i < this.filterOptions.optionTiming.length; i++) {
            this.valueBA.push(this.filterOptions.optionTiming[i].value);
        }
        for (let i = 0; i < this.filterOptions.optionDml.length; i++) {
            this.valueCRUD.push(this.filterOptions.optionDml[i].value);
        }
        for (let i = 0; i < this.filterOptions.optionClass.length; i++) {
            this.classValue.push(this.filterOptions.optionClass[i].value);
        }
        
        this.valueSobjects = this.filterOptions.optionSobject[0].value;
        
        //this.valueBA = this.filterOptions.optionTiming;
        console.log(JSON.stringify(this.valueBA));
        console.log(JSON.stringify(this.valueCRUD));
        console.log(JSON.stringify(this.valueSobjects));
        console.log(JSON.stringify(this.classValue));

        //this.dispatchFilterChange();
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
        this.valueSobjects = event.detail.value;
        this.dispatchFilterChange();
    }

    dispatchFilterChange() {
        var classValues = [];
        for (var i = 0; i < this.classValue.length; i++) {
            classValues.push(this.classValue[i]);
        }

        var crudValues = [];
        for (var i = 0; i < this.valueCRUD.length; i++) {
            crudValues.push(this.valueCRUD[i]);
        }

        var timingValues = [];
        for (var i = 0; i < this.valueBA.length; i++) {
            timingValues.push(this.valueBA[i]);
        }

        this.dispatchEvent(
            new CustomEvent(
                'filterchange', 
                { 
                    detail: {
                        "classValue" : classValues,
                        "sobjectsValues" : this.valueSobjects,
                        "crudValue" : crudValues,
                        "timingValue" : timingValues
                    }
                }
            )
        );
    }
}