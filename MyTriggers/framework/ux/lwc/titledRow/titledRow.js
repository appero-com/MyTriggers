import { LightningElement, api, track } from 'lwc';

/**
 * Show an item
 */
export default class TitledRow extends LightningElement {
    @api
    title = "";

    @api
    titleSize = "1";

    @api
    scrollable = false;

    get scrollableClass() {
        return (this.scrollable === "true" ? "slds-scrollable--x" : "slds-scrollable_none" );
    }

    @api
    scroll(value) {
        this.template.querySelector('div').scrollLeft = value;
    }

    handleScroll(event){
        if (this.scrollable) {
            var scroolValue = event.target.scrollLeft;
            this.dispatchEvent(
                new CustomEvent(
                    'customscroll', 
                    { 
                        detail: scroolValue
                    }
                )
            );
        }
        //console.log('Child: ' + scroolValue);
    }

    get contentSize() {
        return (12 - Number.parseInt(this.titleSize));
    }

    @api
    elements = [
        {
            "label" : "Test",
            "key" : "header_1"
        },
        {
            "label" : "Test",
            "key" : "header_3"
        },
        {
            "label" : "Test",
            "key" : "header_4"
        },
        {
            "label" : "Test",
            "key" : "header_5"
        },
        {
            "label" : "Test",
            "key" : "header_6"
        },
        {
            "label" : "Test",
            "key" : "header_7"
        },
        {
            "label" : "Test",
            "key" : "header_8"
        }
    ];
}