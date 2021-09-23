import { LightningElement, track } from 'lwc';
import resourceName from '@salesforce/resourceUrl/CYFD_Design';
import userLogin from '@salesforce/apex/NM_CYFD_HeaderController.userLogin';
import basepath from '@salesforce/community/basePath';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import loginVerbiage from '@salesforce/label/c.NM_CYFD_Login_Verbiage';

export default class NmcyfdLogin extends LightningElement {
    @track login = resourceName + '/images/undraw_mobile_login_ikmv.svg';
    @track username ='';
    @track password = '';
    @track errormsg = '';
    @track showError = false;

    label = {
        loginVerbiage
    }

    handleInputChange(event){
        if(event.target.name == 'username'){
            this.showError = false;
           this.username = event.target.value;
        }else if(event.target.name == 'password'){
            this.showError = false;
            this.password = event.target.value;
         }       
    }

    doLogin(){    
        this.showError = false;   
        userLogin({
            username: this.username,
            password: this.password
        }) 
        .then(data => {      
            // console.log('navigateToForgotPassword ' + data.redirectURL);
            location.href = data.redirectURL;             
        })
        .catch(error => {
            console.log('fail>',error);
            this.showError = true;
            this.errormsg = error.message || error.body.message;
            
        });
    }

    

    redirectURL(){
        window.open('/cyfd/s/nmcyfd-forget-password','_self');
    }
}