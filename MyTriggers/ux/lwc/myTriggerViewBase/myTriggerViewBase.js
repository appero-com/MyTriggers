import {LightningElement, wire, api, track} from 'lwc';
//import getMDTRowsApex from '@salesforce/apex/MyTriggers.getAllTriggerHandlerSettings';

export default class MyTriggerViewBase extends LightningElement {

    //@wire(getMDTRowsApex)
    //mdtFromApex;

    /*@api
    customMetadata;*/

    initialized = false;

    @track options = {};

    @track _currentFilter = {};

    

    get filterOptions() {
        //console.log("MyTriggerViewBase get filterOptions");
        return this.options;
    }

    @api
    set currentFilter(value) {
        this._currentFilter = value;
    }

    get currentFilter() {
        return this._currentFilter;
    }

    calculateOptions() {
        console.log("MyTriggerViewBase get calculateOptions");
        console.log(JSON.stringify(this.customMetadata));
        var optionsTiming = [];
        var includedTiming = [];

        var optionsDml = [];
        var includedDmls = [];

        var optionsSobject = [];
        var includedSobjects = [];

        var optionsClasses = [];
        var includedClasses = [];

        let customMDT = this.customMetadata;

        for (var i = 0; i < customMDT.length; i++) {

            var mdtRow = customMDT[i];
            ////console.log(mdtRow); 
            var clasName = mdtRow.Class__c;
            var triggerEventDML = mdtRow.Event__c.split('_')[1];
            var triggerEventTime = mdtRow.Event__c.split('_')[0];
			console.log("sobject " + mdtRow.sObject__c);
			console.log("sobjectapi " + mdtRow.sObjectAPIName__c);
            var sobject = (
				mdtRow.sObject__c === null || mdtRow.sObject__c === "" || mdtRow.sObject__c === undefined 
					? mdtRow.sObjectAPIName__c 
					: mdtRow.sObject__c
			);
			console.log("sobject " + sobject);
            if (includedTiming.indexOf(triggerEventTime) < 0) {
                includedTiming.push(triggerEventTime);
                optionsTiming.push({
                    label: triggerEventTime, 
                    value: triggerEventTime, 
                    defaultValue: true
                });
            }

            if (includedDmls.indexOf(triggerEventDML) < 0) {
                includedDmls.push(triggerEventDML);
                optionsDml.push({
                    label: triggerEventDML, 
                    value: triggerEventDML,
                    defaultValue: true
                });
            }

            if (includedSobjects.indexOf(sobject) < 0) {
                includedSobjects.push(sobject);
                optionsSobject.push({
                    label: sobject, 
                    value: sobject,
                    defaultValue: true
                });
            }

            if (includedClasses.indexOf(clasName) < 0) {
                includedClasses.push(clasName);
                optionsClasses.push({
                    label: clasName, 
                    value: clasName,
                    defaultValue: true
                });
            }
        }

        var result = {
            "optionTiming" : optionsTiming,
            "optionDml" : optionsDml,
            "optionSobject" : optionsSobject,
            "optionClass" : optionsClasses
        };

		console.log("MyTriggerViewBase@calculateOptions");
        console.log(result);

		this.initialized = true;

        return result;
    }

    get possibleDMLs() {
        return ['INSERT', 'UPDATE', 'DELETE', 'UNDELETE'];
    }

    get possibleTimings() {
        return  ['BEFORE', 'AFTER'];
    }

    collectAndSortPossibleOrderNumbers(mdtData) {
        var possibleOrderNumbers = [];
        for (var mdtIndexer = 0; mdtIndexer < mdtData.length; mdtIndexer++) {
            var mdtRow = mdtData[mdtIndexer];
            var orderNumber = mdtRow.Order__c;
            if (!possibleOrderNumbers.includes(orderNumber)) {
                possibleOrderNumbers.push(orderNumber);
            }
        }
        possibleOrderNumbers.sort();
        return possibleOrderNumbers;
    }
}