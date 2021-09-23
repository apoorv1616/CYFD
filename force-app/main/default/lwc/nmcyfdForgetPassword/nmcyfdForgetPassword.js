import { LightningElement, track } from 'lwc';
import resourceName from '@salesforce/resourceUrl/CYFD_Design';
import forgotPassword from '@salesforce/apex/NM_CYFD_HeaderController.forgotPassword';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class NmcyfdForgetPassword extends NavigationMixin(LightningElement){
    @track login = resourceName + '/images/undraw_mobile_login_ikmv.svg';
    @track username = '';
    resetPassword(){
        forgotPassword({
            username: this.username
        }) 
        .then(data => {     
            if(data == 'Success'){
                this.showToast('Success!','Password Reset link has been sent to your email.','success');
                this.redirectURL();
            } else{
                this.showToast('Error!',data,'error');
            }
            // console.log('navigateToForgotPassword ' + data.redirectURL);
            // location.href = data.redirectURL;           
        })
        .catch(error => {
            alert('incorrect details')
        });
    }
    handleInput(event){
        console.log('here');
        console.log(event.target.value);
        this.username = event.target.value;
    }
    showToast(title,msg,type){
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: type,
        });
        this.dispatchEvent(evt);
    }
    redirectURL(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'nmcyfd-login'
            },
        });
    }
}