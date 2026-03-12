import LightningDatatable from 'lightning/datatable';
import picklistTemplate from './picklistTemplate.html';

export default class CustomDatatable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: picklistTemplate,
            standardCellLayout: false,
            typeAttributes: ['options', 'value', 'context']
        }
    };

    connectedCallback() {
        super.connectedCallback();
        this.template.addEventListener('change', this.handlePicklistValueChange.bind(this));
    }

    handlePicklistValueChange(event) {
        const combobox = event.target;
        if (combobox && combobox.tagName === 'LIGHTNING-COMBOBOX') {
            const newValue = event.detail.value;

            // Find the row id by traversing the datatable's internal structure
            const row = combobox.closest('tr');
            if (row) {
                const rowKeyAttr = row.getAttribute('data-row-key-value');
                if (rowKeyAttr) {
                    this.dispatchEvent(new CustomEvent('picklistchange', {
                        composed: true,
                        bubbles: true,
                        detail: {
                            rowId: rowKeyAttr,
                            value: newValue
                        }
                    }));
                }
            }
        }
    }
}