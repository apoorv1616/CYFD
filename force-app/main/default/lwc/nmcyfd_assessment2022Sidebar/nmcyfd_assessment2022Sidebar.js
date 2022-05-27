import { LightningElement,api, track } from 'lwc';

export default class Nmcyfd_assessment2022Sidebar extends LightningElement {

    @api naivgationSidebar = [];
    @api totalStepsCount;
    @api currentStep;
    @track showNavigation = false;
    @api navigationItems = [];


    get handleStepsChange() {
        let count = 1;
        this.navigationItems = [];
        this.naivgationSidebar.map( item => {
            
            if ( count < this.currentStep ) {                
                this.navigationItems.push({
                    'label' : item,
                    'action' : 'action:approval',
                    'style' : 'color:#ab3a00; text-align:center; margin-left:2%; font-weight:600; ',
                    'iconcolor' : 'darkpinkicon'
                });
            }
            else if ( count === this.currentStep ) {
                this.navigationItems.push({
                    'label' : item,
                    'action' : 'action:edit',
                    'style' : 'color:#ab3a00; text-align:center; font-weight:600;  margin-left:2%;',
                    'iconcolor' : 'darkpinkicon'

                });
            }
            else {

                this.navigationItems.push({
                    'label' : item,
                    'action' : 'action:more',
                    'style' : 'color:burlywood; text-align:center;  margin-left:2%;',
                    'iconcolor' : 'pinkicon'

                });

            }

            count++;
        });

        return this.navigationItems;
    }
}