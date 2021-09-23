import { LightningElement,track,api } from 'lwc';

export default class NmcyfdPaginator extends LightningElement {
    @track _totalItems = 0;
    @track _currentPage = 1;
    @api itemsPerPage= 10 ;
    @track initNumber = 1;
    @track lastNumber = this.initNumber;
    @track noPrevious = false;
    @track noNext = false;
    @track noPreviousOrNext = false;

    constructor() {
        super();
        setTimeout(() => { // give the data time to load
            this.currentPage = 1; // this setter updates initNumber and lastNumber and disables buttons as needed
        }, 1000);
    }

    /**
     * return the total number of items
     * @returns {number}
     */
    @api get totalItems() {
        return this._totalItems;
    }

    /**
     * set the total number of items
     * @param num -- a positive integer number of items
     */
    set totalItems(num) {
        this._totalItems = Math.max(0, parseInt(num, 10));
        //console.log("totalItems:",this._totalItems);
        this.currentPage = 1;
        //this.initNumber = Math.min(this.initNumber, this._totalItems);
        //this.lastNumber = Math.min(this.lastNumber, this._totalItems);
        //console.log("setting totalItems -- initNumber:",this.initNumber," lastNumber:",this.lastNumber);
        this.disableButtons();
    }

    /**
     * return the number of the current page
     * @returns {number}
     */
    @api get currentPage() {
        return this._currentPage;
    }

    /**
     * set the current page dynamically after validating it
     * @param num - should be an integer between 1 and totalPage, inclusive
     */
    
    set currentPage(num) {
        this._currentPage = Math.min(Math.max(1, parseInt(num, 10)), this.totalPage);
        this.initNumber = this.itemsPerPage * (this._currentPage - 1) + 1;
        this.lastNumber = Math.min(this.totalItems, this._currentPage * this.itemsPerPage);
        this.disableButtons();
        //console.log("setting CurrentPage -- initNumber:",this.initNumber," lastNumber:",this.lastNumber);
        //console.log("noNext:",this.noNext);
    }

    /**
     * dynamically compute the total number of pages based on the number of items and items per page
     * @returns {number}
     */
    get totalPage() {
        //console.log("totalItems:",this.totalItems," itemsPerPage:",this.itemsPerPage);
        return Math.ceil(this.totalItems / this.itemsPerPage) || 1;
    }

    /**
     * handle a click on the "Next" button by updating the current page and dispatching an event to the parent
     */
    @api handleNextButton() {
        //console.log("lastNumber:",this.lastNumber," totalItems:",this.totalItems)
        this.currentPage = this.currentPage + 1; // uses currentPage setter to adjust initNumber and lastNumber
        this.disableButtons();
        this.dispatchEvent(new CustomEvent('next', {
            detail: {
                currentPage: this.currentPage,
                initNumber: this.initNumber,
                lastNumber: this.lastNumber
            }
        }));
    }

    /**
     * handle a click on the "Previous" button by updating the current page and dispatching an event to the parent
     */
    @api handlePrevButton() {
        this.currentPage = this.currentPage - 1; // uses currentPage setter to adjust initNumber and lastNumber
        this.disableButtons();
        this.dispatchEvent(new CustomEvent('previous', {
            detail: {
                currentPage: this.currentPage,
                initNumber: this.initNumber,
                lastNumber: this.lastNumber
            }
        }));
    }

    /**
     * set boolean values to enable or disable the Previous and Next buttons
     */
    disableButtons() {
        this.noPrevious = (this.initNumber <= 1);
        this.noNext = (this.lastNumber >= this.totalItems); // || (this.totalItems <= this.itemsPerPage);
        this.noPreviousOrNext = this.noPrevious && this.noNext;
    }
}