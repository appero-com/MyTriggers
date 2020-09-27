import { LightningElement, api, track } from 'lwc';
import MyTriggerViewBase from 'c/myTriggerViewBase';

/**
 * Show an item
 */
export default class EventCentricView extends MyTriggerViewBase {

    @track metadata = [];

    @api
    set customMetadata(value) {
        if (value.data) {
            this.metadata = value.data;
            this.options = this.calculateOptions();
            this.currentFilter = this.calculateDefaultFilter();
        }
    }

    get customMetadata(){
        return this.metadata;
    }

    get rows(){
        let mapped = this.mapTheData(this.metadata, this.currentFilter, this.headers);

        let tableCells = [];
        for (var index = 0; index < mapped.length; index++) {
            tableCells.push(mapped[index]);
        }
        return tableCells;
    }

    get headers() {
        let headers = [{"label":"Trigger Order","key":"-1","size" : 1}];
        let currentFilt = this.currentFilter;
        if (currentFilt.sobjectsValues) {
            for (let index = 0; index < currentFilt.sobjectsValues.length; index++) {
                headers.push({
                    "label" : currentFilt.sobjectsValues[index],
                    "key" : currentFilt.sobjectsValues[index],
                    "size" : 2
                });
            }
        }
        return headers;
    }

    calculateDefaultFilter() {
        let opt = this.options;

        let valueClasses = [];
        for (var i = 0; i < opt.optionClass.length; i++) {
            valueClasses.push(opt.optionClass[i].value);
        }
        let valueSobjects = [];
        for (var i = 0; i < opt.optionSobject.length; i++) {
            valueSobjects.push(opt.optionSobject[i].value);
        }
        return {
            "classValue" : valueClasses,
            "sobjectsValues" : valueSobjects,
            "crudValue" : opt.optionDml[0].value,
            "timingValue" : opt.optionTiming[0].value
        };
    }

    handleFilterChange(event){
        var filter = event.detail;
        this.currentFilter = filter;

        let headers = [{"label":"Trigger Order","key":"-1","size" : 1}];
        for (var index = 0; index < filter.sobjectsValues.length; index++) {
            headers.push({
                "label" : filter.sobjectsValues[index],
                "key" : filter.sobjectsValues[index],
                "size" : 2
            });
        }
        var mapped = this.mapTheData(this.metadata, filter);

        var tableCells = [];
        for (var index = 0; index < mapped.length; index++) {
            tableCells.push(mapped[index]);
        }


        var table = this.template.querySelector('c-table-component');
        table.update(headers, tableCells);
    }

    mapTheData(mdtDataAsList, filter) {
        var mdtData = mdtDataAsList;
        var mapped = [];
        
        var possibleOrderNumbers = this.collectAndSortPossibleOrderNumbers(mdtData);
        if (filter.classValue) {
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

                if (filter.classValue.includes(clasName)) {
                    if (filter.sobjectsValues.includes(sobject)) {
                        if (filter.crudValue === triggerEventDML && filter.timingValue === triggerEventTime) {

                            var grandParent = mapped[0];
                            if (grandParent == undefined) {
                                mapped.push(
                                    this.createTablePiece(triggerEventTime, triggerEventDML)
                                );
                            }
                        
                            var tablePiece = mapped[0].rows[0];

                            var rowIndex = possibleOrderNumbers.indexOf(orderNumber);

                            if (tablePiece.elements[rowIndex] == undefined) {
                                tablePiece.elements[rowIndex] = this.createRowElement(rowIndex, orderNumber, filter.sobjectsValues);
                            }
                            var rowElement = tablePiece.elements[rowIndex];
                            var colIndex = filter.sobjectsValues.indexOf(sobject) + 1;

                            rowElement.elements[colIndex] = this.createCellElement(mdtId, mdtRow.Description__c);
                        }
                    }
                }
            }
        }
        return mapped;
    }

    createTablePiece(triggerEventTime, triggerEventDML) {
        return {
            "title" : triggerEventTime,
            "key" : triggerEventTime,
            "rows" : [
                {
                    "title" : triggerEventDML,
                    "key" : triggerEventDML,
                    "isMultipleRows" : "true",
                    "elements" : []
                }
            ]
        }
    }

    createRowElement(rowIndex,orderNumber,sobjectValues) {
        var elements = [{"key":"0","label":orderNumber,"size" : 1}];
        for (var i = 0; i < sobjectValues.length; i++) {
            elements.push({"key":(i+1), "label":""});
        }
        return {
            "key" : rowIndex,
            "elements" : elements
        };
    }

    createCellElement(colIndex, description) {
        return {
            "key" : colIndex,
			"id" : colIndex,
            "label" : description,
            "size" : 2
        };
    }

}