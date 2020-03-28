import {LightningElement, api} from 'lwc';

export default class TogglePicklistItem extends LightningElement {

    @api
    label;

    @api
    value;

    @api
    isSelected;

    handleClick(event) {
        console.log("TogglePicklistItem handleClick");
        if (event.target.variant === 'neutral') {
            event.target.variant = 'brand';
        } else {
            event.target.variant = 'neutral';
        }
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

    get variant(){
        return this.isSelected ? 'brand' : 'neutral';
    }

}