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

	initialized = false;

    @api
    set options(value) {
		console.log("SobjectCentricFilter set options");
        console.log(JSON.stringify(value));
		console.log(JSON.stringify(this.filterOptions.optionClass));

		let isChanged = false;
		if (this.filterOptions.optionClass) {
			isChanged = this.isAnyChanged(value);
		}

        this.filterOptions = value;
        if (value.optionTiming  && !this.initialized) {
            this.setupDefaultValues();
			this.initialized = true;
        } else

		//console.log("isChanged " + isChanged);
		if (isChanged && this.initialized) {
			console.log("this.isAnyChanged");
			this.setupDefaultValues();
			this.dispatchFilterChange(); 
		}
    }

    get options(){
        return this.filterOptions;
    }

    setupDefaultValues(){
        console.log("SobjectCentricFilter setupDefaultValues");
		this.valueBA = [];
        for (let i = 0; i < this.filterOptions.optionTiming.length; i++) {
            this.valueBA.push(this.filterOptions.optionTiming[i].value);
        }
		this.valueCRUD = [];
        for (let i = 0; i < this.filterOptions.optionDml.length; i++) {
            this.valueCRUD.push(this.filterOptions.optionDml[i].value);
        }
		this.classValue = [];
        for (let i = 0; i < this.filterOptions.optionClass.length; i++) {
            this.classValue.push(this.filterOptions.optionClass[i].value);
        }
        
        this.valueSobjects = this.filterOptions.optionSobject[0].value;
        
        //this.valueBA = this.filterOptions.optionTiming;
        console.log(JSON.stringify(this.valueBA));
        console.log(JSON.stringify(this.valueCRUD));
        console.log(JSON.stringify(this.valueSobjects));
        console.log(JSON.stringify(this.classValue));

    }

	isAnyChanged(newOptions) {
		console.log("@isAnyChanged");
		
		if (JSON.stringify(this.filterOptions.optionTiming) !== JSON.stringify(newOptions.optionTiming)) {
			return true;
		}
		if (JSON.stringify(this.filterOptions.optionDml) !== JSON.stringify(newOptions.optionDml)) {
			return true;
		}
		if (JSON.stringify(this.filterOptions.optionSobject) !== JSON.stringify(newOptions.optionSobject)) {
			return true;
		}
		if (JSON.stringify(this.filterOptions.optionClass) !== JSON.stringify(newOptions.optionClass)) {
			return true;
		}
		return false;
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