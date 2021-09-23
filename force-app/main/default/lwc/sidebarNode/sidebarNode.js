import { LightningElement, api } from 'lwc';

export default class NmBrcSidebarNode extends LightningElement {
    @api node;
    @api isChild = false;
    isExpanded = false;

    get orderClass() {
        return 'slds-align_absolute-center numberCircle' + (this.node.isCurrent
            ? ' item-selected_order'
            : this.node.isComplete
                ? ' item-completed_order completed-line'
                : '');
    }

    get itemClass() {
        return 'item-text_neutral ' + (this.node.isCurrent
            ? ' item-selected_text'
            : this.node.isComplete
                ? ' item-completed_text pointer'
                : '');
    }

    get itemClassChild() {
        return 'slds-m-right_small item-text_neutral ' + (this.node.isCurrent
            ? ' item-selected_text'
            : this.node.isComplete
                ? ' item-completed_text pointer'
                : '');
    }

    get showOrderNumber() {
        return !this.isChild && !this.node.isComplete;
    }

    get showAsCompleted() {
        return !this.isChild && this.node.isComplete;
    }

    get expandChildren() {
        return this.node.items.length && this.node.isCurrent;
    }

    handleSidebarClick(event) {
        // console.log('node: ', JSON.stringify(this.node));
        if (this.node.isComplete) {
            const click = new CustomEvent('sidebarclick', {
                detail: { ...this.node },
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(click);
        }
    }
}