import { LightningElement, api, track } from 'lwc';
import MyTriggerViewBase from 'c/myTriggerViewBase';

/**
 * Show an item
 */
export default class SobjectCentricView extends MyTriggerViewBase {
    @track metadata = [];

    @api
    set customMetadata(value) {
        console.log("SobjectCentricView set customMetadata");
        console.log(value.data);
        if (value.data) {
            this.metadata = value.data;
            this.options = this.calculateOptions();
            this.currentFilter = this.calculateDefaultFilter();
        }
    }

    get customMetadata(){
        console.log("SobjectCentricView get customMetadata");
        return this.metadata;
    }

    get rows(){
        console.log("SobjectCentricView get rows");
        let mapped = this.mapTheData(this.metadata, this.currentFilter);

        let tableCells = [];
        for (var index = 0; index < mapped.length; index++) {
            tableCells.push(mapped[index]);
        }
        return tableCells;
    }

    get headers() {
        console.log("SobjectCentricView get headers");
        let headers = [{"label":"Trigger Order","key":"-1","size" : 1}];
        let filter = this.currentFilter;
        if (filter.classValue) {
            console.log(JSON.stringify(filter.classValue));
            for (let index = 0; index < filter.classValue.length; index++) {
                headers.push({
                    "label" : filter.classValue[index],
                    "key" : filter.classValue[index],
                    "size" : 2
                });
            }
        }
        console.log(headers);
        return headers;
    }

    calculateDefaultFilter() {
        console.log("SobjectCentricView calculateDefaultFilter");
        let opt = this.options;
        
        let valueClasses = [];
        for (var i = 0; i < opt.optionClass.length; i++) {
            valueClasses.push(opt.optionClass[i].value);
        }
        let valueDml = [];
        for (var i = 0; i < opt.optionDml.length; i++) {
            valueDml.push(opt.optionDml[i].value);
        }
        let valueTiming = [];
        for (var i = 0; i < opt.optionTiming.length; i++) {
            valueTiming.push(opt.optionTiming[i].value);
        }
        return {
            "classValue" : valueClasses,
            "sobjectsValues" : opt.optionSobject[0].value,
            "crudValue" : valueDml,
            "timingValue" : valueTiming
        };
    }

    handleFilterChange(event){
        console.log("SobjectCentricView handleFilterChange");
        var filter = event.detail;
        this.currentFilter = filter;

        console.log(filter.classValue);
        console.log(filter.sobjectsValues);
        console.log(filter.crudValue);
        console.log(filter.timingValue);
        

        var headers = [{"label":"Trigger Order","key":"-1","size" : 1}];
        for (var index = 0; index < filter.classValue.length; index++) {
            headers.push({
                "label" : filter.classValue[index],
                "key" : filter.classValue[index],
                "size" : 2
            });
        }
        var mapped = this.mapTheData(this.metadata, filter);

        var tableCells = [];
        for (var index = 0; index < mapped.length; index++) {
            tableCells.push(mapped[index]);
        }

        console.log(tableCells);

        var table = this.template.querySelector('c-table-component');
        table.update(headers, tableCells);
    }

    mapTheData(mdtDataAsList, filter) {
        console.log('SobjectCentricView mapTheData');
        //console.log(mdtDataAsList);
        var mdtData = mdtDataAsList;
        var mapped = [];

        var possibleDMLs = ['INSERT', 'UPDATE', 'DELETE', 'UNDELETE'];
        var possibleTimings = ['BEFORE', 'AFTER'];

        //console.log('SobjectCentricView before possible');
        var possibleOrderNumbers = this.collectAndSortPossibleOrderNumbers(mdtData);

        console.log("possibleOrderNumber calculated");
        console.log(possibleOrderNumbers);

        for (var mdtIndexer = 0; mdtIndexer < mdtData.length; mdtIndexer++) {
            let mdtRow = mdtData[mdtIndexer];
			let mdtId = mdtRow.Id;
            let clasName = mdtRow.Class__c;
            let triggerEventDML = mdtRow.Event__c.split('_')[1];
            let triggerEventTime = mdtRow.Event__c.split('_')[0];
            let sobject = (
				mdtRow.sObject__c === null || mdtRow.sObject__c === "" || mdtRow.sObject__c === undefined 
					? mdtRow.sObjectAPIName__c 
					: mdtRow.sObject__c
			);
            let orderNumber = mdtRow.Order__c;
            
            //console.log(clasName + ' ' + triggerEventDML + ' ' + triggerEventTime + ' ' + sobject);
            if (sobject === filter.sobjectsValues) {
                if (filter.crudValue.includes(triggerEventDML)) {

                    var grandParent = mapped[possibleDMLs.indexOf(triggerEventDML)];
                    if (grandParent == undefined) {
                        mapped[possibleDMLs.indexOf(triggerEventDML)] = this.createGrandParentElement(triggerEventDML);
                        grandParent = mapped[possibleDMLs.indexOf(triggerEventDML)];
                    }

                    if (filter.timingValue.includes(triggerEventTime)) {

                        if (filter.classValue.includes(clasName)) {

                            var parent = grandParent.rows[possibleTimings.indexOf(triggerEventTime)];
                            if (parent == undefined) {
                                grandParent.rows[possibleTimings.indexOf(triggerEventTime)] = this.createParentRowElement(triggerEventTime);
                                parent = grandParent.rows[possibleTimings.indexOf(triggerEventTime)];
                            }

                            var rowIndex = possibleOrderNumbers.indexOf(orderNumber);
                            //console.log(rowIndex);

                            if (parent.elements[rowIndex] == undefined) {
                                parent.elements[rowIndex] = this.createChildRowElement(rowIndex, orderNumber);
                            }

                            var rowElement = parent.elements[rowIndex];
                            rowElement.elements[filter.classValue.indexOf(clasName)+1] = 
                                this.createCellElement(mdtRow.Description__c, mdtId);
                        }

                    }

                }
            }
            
        }
        //console.log('mapped before');
        //console.log(mapped);

        console.log('mapped after');

        for (var dmlIndex = 0; dmlIndex < mapped.length; dmlIndex++) {
            var dmlElement = mapped[dmlIndex];
            console.log(dmlElement);
            if (dmlElement != undefined) {
                for (var timingIndex = 0; timingIndex < dmlElement.rows.length; timingIndex++){
                    var timingElement = dmlElement.rows[timingIndex];

                    if (timingElement != undefined) {
                        //console.log(timingElement);
                        for (var rowy = 0; rowy < possibleOrderNumbers.length; rowy++) {
                            var rowElement = timingElement.elements[rowy];

                            if (rowElement != undefined) {
                                //console.log(rowElement);
                                for (var coly = 0; coly < filter.classValue.length+1; coly++) {
                                    if (rowElement.elements[coly] == undefined) {
                                        rowElement.elements[coly] = {
                                            "label" : "",
                                            "key" : coly,
                                            "size" : 2
                                        };
                                    }
                                }

                            }
                        }
                    }
                }
            }

        }
        //console.log(mapped);
        return mapped;
    }

    createGrandParentElement(triggerEventDML) {
        return {
            "title" : triggerEventDML,
            "key" : triggerEventDML,
            "rows" : []
        };
    }

    createParentRowElement(triggerEventTime) {
        return {
            "title" : triggerEventTime,
            "key" : triggerEventTime,
            "isLastRow" : "false",
            "isMultipleRows" : "true",
            "elements" : []
        };
    }

    createChildRowElement(rowIndex, orderNumber) {
        return {
            "key" : rowIndex,
            "elements" : [{"key":"0","label":orderNumber,"size" : 1}]
        };
    }

    createCellElement(description, mdtId) {
        return {
            "label" : description,
            "key" : mdtId,
			"id" : mdtId,
            "size" : 2
        };
    }
}