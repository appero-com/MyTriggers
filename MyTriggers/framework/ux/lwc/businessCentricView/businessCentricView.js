import { LightningElement, api, track } from 'lwc';
import MyTriggerViewBase from 'c/myTriggerViewBase';

/**
 * Show an item
 */
export default class BusinessCentricView extends MyTriggerViewBase {

    @track metadata = [];

	isAnyChanged = false;

    @api
    set customMetadata(value) {
        if (value.data) {
			console.log("BusinessCentricView customMetadata " + JSON.stringify(value.data));
            this.metadata = value.data;
			if (!this.initialized) {
				this.options = this.calculateOptions();
				this.currentFilter = this.calculateDefaultFilter();
			}
			
			
        }
    }

    get customMetadata(){
        return this.metadata;
    }

    get rows(){
        let mapped = this.mapTheData(this.metadata, this.currentFilter);

        let tableCells = [];
        for (var index = 0; index < mapped.length; index++) {
            tableCells.push(mapped[index]);
        }
        return tableCells;
    }

    get headers() {
        let headers = [];
        //let filterOpt = this.filterOptions;
        if (this.currentFilter.sobjectsValues) {
            for (let index = 0; index < this.currentFilter.sobjectsValues.length; index++) {
                headers.push({
                    "label" : this.currentFilter.sobjectsValues[index],
                    "key" : this.currentFilter.sobjectsValues[index],
                    "size" : 2
                });
            }
        }
        return headers;
    }

    calculateDefaultFilter() {
        let opt = this.options;
        
        let valueSobjects = [];
        for (var i = 0; i < opt.optionSobject.length; i++) {
            valueSobjects.push(opt.optionSobject[i].value);
        }
        var crudValues = [];
        for (var i = 0; i < opt.optionDml.length; i++) {
            crudValues.push(opt.optionDml[i].value);
        }

        var timingValues = [];
        for (var i = 0; i < opt.optionTiming.length; i++) {
            timingValues.push(opt.optionTiming[i].value);
        }
        return {
            "classValue" : opt.optionClass[0].value,
            "sobjectsValues" : valueSobjects,
            "crudValue" : crudValues,
            "timingValue" : timingValues
        };
    }

    handleFilterChange(event){
        console.log("BusinessCentricView handleFilterChange");
        let filter = event.detail;
        this.currentFilter = filter;

        let headers = [];
        for (var index = 0; index < this.currentFilter.sobjectsValues.length; index++) {
            headers.push({
                "label" : filter.sobjectsValues[index],
                "key" : filter.sobjectsValues[index],
                "size" : 2
            });
        }
        console.log(headers);
        var mapped = this.mapTheData(this.metadata, filter);

        var tableCells = [];
        for (var index = 0; index < mapped.length; index++) {
            tableCells.push(mapped[index]);
        }

        var table = this.template.querySelector('c-table-component');
		console.log(tableCells);
        table.update(headers, tableCells);
    }

	handleSaveChanges(event) {
		console.log("BusinessCentricView@handleSaveChanges");
		this.dispatchEvent(
            new CustomEvent(
                'savechangedclick'
            )
        );
	}

    mapTheData(mdtDataAsList, filter) {
		console.log("mapTheData");
        var mdtData = mdtDataAsList;
        var mapped = [];
		//console.log(103);
        for (var mdtIndexer = 0; mdtIndexer < mdtData.length; mdtIndexer++) {
		
            let mdtRow = mdtData[mdtIndexer];
			//console.log(JSON.stringify(mdtRow));
			this.isAnyChanged = this.isAnyChanged || mdtRow.isChanged;
			let mdtId = mdtRow.Id;
            let clasName = mdtRow.Class__c;
            let triggerEventDML = mdtRow.Event__c.split('_')[1];
            let triggerEventTime = mdtRow.Event__c.split('_')[0];
            let sobject = (
				mdtRow.sObject__c === null || mdtRow.sObject__c === "" || mdtRow.sObject__c === undefined 
					? mdtRow.sObjectAPIName__c 
					: mdtRow.sObject__c
			);
			
            var eventDMLOrderNumber = this.possibleDMLs.indexOf(triggerEventDML);
            var eventTimingOrderNumber = this.possibleTimings.indexOf(triggerEventTime);
			
			//console.log(clasName + ' ' + filter.classValue);
            if (clasName === filter.classValue) {
				
				//console.log(triggerEventDML + ' ' + filter.crudValue);
                if (filter.crudValue.includes(triggerEventDML)) {

                    var grandParent = mapped[eventDMLOrderNumber];
                    if (grandParent == undefined) {
                        mapped[eventDMLOrderNumber] = this.createGrandParentElement(triggerEventDML);
                        grandParent = mapped[eventDMLOrderNumber];
                    }

					//console.log(triggerEventTime + ' ' + filter.timingValue);
                    if (filter.timingValue.includes(triggerEventTime)) {

                        var parent = grandParent.rows[eventTimingOrderNumber];
                        if (parent == undefined) {
                            grandParent.rows[eventTimingOrderNumber] = this.createGrandParentRow(triggerEventTime);
                            parent = grandParent.rows[eventTimingOrderNumber];
                        }

						//console.log(sobject + ' ' + filter.sobjectsValues);
                        parent.elements[filter.sobjectsValues.indexOf(sobject)] = 
                            this.createCellElement(mdtRow);

                    }

                }
            }
            //console.log(mapped);
        }
		//console.log(146);
		//console.log(mapped);
		var possibleOrderNumbers = this.collectAndSortPossibleOrderNumbers(mdtData);

		for (var dmlIndex = 0; dmlIndex < mapped.length; dmlIndex++) {
            var dmlElement = mapped[dmlIndex];
            //console.log("dml " + dmlIndex);
			//console.log(dmlElement)
            if (dmlElement != undefined) {
				
                for (var timingIndex = 0; timingIndex < dmlElement.rows.length; timingIndex++){
                    var timingElement = dmlElement.rows[timingIndex];
					//console.log("time " + timingIndex);
					//console.log(timingElement);
                    if (timingElement != undefined) {
                        for (var rowy = 0; rowy < filter.sobjectsValues.length; rowy++) {
                            var rowElement = timingElement.elements[rowy];
							if (rowElement == undefined) {
								timingElement.elements[rowy] = this.createCellElement("", "-1");
							}
							//console.log("rows " + rowy);
							//console.log(rowElement);
                        }
                    }
                }
            }
        }
		//console.log(187);
		//console.log(mapped);
        return mapped;
    }

    createGrandParentElement(triggerEventDML){
        return {
            "title" : triggerEventDML,
            "key" : triggerEventDML,
            "rows" : []
        };
    }

    createGrandParentRow(triggerEventTime) {
        return {
            "title" : triggerEventTime,
            "key" : triggerEventTime,
            "isLastRow" : "false",
            "elements" : []
        };
    }

    createCellElement(mdtRow) {
        return {
            "label" : mdtRow.Description__c,
            "key" : mdtRow.Id,
			"id" : mdtRow.Id,
			"isChanged" : mdtRow.isChanged,
            "size" : 2
        };
    }
}