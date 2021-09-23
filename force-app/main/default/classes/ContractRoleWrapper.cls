public class ContractRoleWrapper{
        @AuraEnabled public String roleId;
        @AuraEnabled public Boolean selected;
        @AuraEnabled public String activityRoleId;
        @AuraEnabled public Boolean isNewActivityRole;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public Boolean status;
        @AuraEnabled public Date dob;
        @AuraEnabled public String gender;
        @AuraEnabled public String background;
        @AuraEnabled public String education;
        @AuraEnabled public String jobTitle;
        @AuraEnabled public String workExp;
        @AuraEnabled public String backgroundCheck;
    
    //Client Variables
        @AuraEnabled public String youthId;
        @AuraEnabled public String middleInitial;
        @AuraEnabled public String suffix;
        @AuraEnabled public Date initialRegistrationDate;
        @AuraEnabled public Date localSelectionPanelDate;
        @AuraEnabled public String livingArrangements;
        @AuraEnabled public String school;
        @AuraEnabled public String employmentStatus;
        @AuraEnabled public String notInLaborForce;
        @AuraEnabled public String sourceOfIncome;
        @AuraEnabled public String cyfdInvolved;
        @AuraEnabled public String referralSource;
        @AuraEnabled public String criminalJusticeReferral;
        @AuraEnabled public String arrestInPast30Days;
        @AuraEnabled public String healthInsurance;
        @AuraEnabled public Boolean noSSN;
        @AuraEnabled public String ssnNumber;
        @AuraEnabled public String driverLicenseNumber;
        @AuraEnabled public Boolean hasMedicalId;
        @AuraEnabled public String medicalId;
        @AuraEnabled public String primaryLanguage;
        @AuraEnabled public String ethnicity;
        @AuraEnabled public String tribalAffiliation;
        @AuraEnabled public String otherTribalAffiliation;
        @AuraEnabled public String race;
        @AuraEnabled public Boolean homeless;
        @AuraEnabled public String addressLine1;
        @AuraEnabled public String addressLine2;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zipCode;
        @AuraEnabled public Boolean noPhone;
        @AuraEnabled public String primaryPhone;
        //@AuraEnabled public String message;
        @AuraEnabled public String otherPhone;
        //@AuraEnabled public String otherPhoneMessage;
        @AuraEnabled public String sexualPreferrence;
        @AuraEnabled public String statusOfClient;
        @AuraEnabled public String dischargeReason;
        @AuraEnabled public String reason;
        @AuraEnabled public String atRiskFactors;
        @AuraEnabled public String lgbtq;
        @AuraEnabled public String populationServed;
        
        @AuraEnabled public String geographicLocation;
        @AuraEnabled public String otherPopulation;
        @AuraEnabled public String gangActivity;
        @AuraEnabled public String currentlyInDetention;
    
        public ContractRoleWrapper getStaffDetails(Contract_Role__c role){
            ContractRoleWrapper staff = new ContractRoleWrapper();
            staff.firstName = role.First_Name__c;
            staff.lastName = role.Last_Name__c;
            staff.name = role.Name__c == null ? (role.First_Name__c + ' ' + role.Last_Name__c) : role.Name__c;
            staff.roleId = role.Id;            
            staff.email = role.Email__c;
            staff.phone = role.Phone_Number__c;
            staff.background = role.CYFD_Background_Check__c;
            staff.education = role.Education__c;
            staff.status = role.Active_Status__c;
            staff.backgroundCheck = role.CYFD_Background_Check__c;
            staff.gender = role.Gender__c;
            staff.jobTitle = role.Job_Title__c;
            staff.workExp = role.Work_Experience__c;
            staff.dob = role.Date_of_Birth__c;
            
            return staff;
        } 
        
        public Contract_Role__c createStaff(ContractRoleWrapper roleWrapper){
            Contract_Role__c role = new Contract_Role__c();
            if(!String.isBlank(roleWrapper.roleId))
                role.Id = roleWrapper.roleId;
            role.First_Name__c = roleWrapper.firstName;
            role.Last_Name__c = roleWrapper.lastName;
            role.Date_of_Birth__c = roleWrapper.dob;
            role.Email__c = roleWrapper.email;
            role.Phone_Number__c = roleWrapper.phone;
            role.Contract_Role__c = 'Staff';
            role.CYFD_Background_Check__c  = roleWrapper.background;
            role.Education__c  = roleWrapper.education;
            role.Active_Status__c = roleWrapper.status != null ? roleWrapper.status : false;
            role.CYFD_Background_Check__c  = roleWrapper.backgroundCheck;
            role.Gender__c  = roleWrapper.gender;
            role.Job_Title__c  = roleWrapper.jobTitle;
            role.Work_Experience__c  = roleWrapper.workExp;
            
           
            
            role.RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Role__c', 'Provider');
            
            return role;           
        } 
        
        public ContractRoleWrapper getClientDetails(Contract_Role__c role){
            ContractRoleWrapper client = new ContractRoleWrapper();
            client.firstName = role.First_Name__c;
            client.lastName = role.Last_Name__c;
            client.name = role.Name__c == null ? (role.First_Name__c + ' ' + role.Last_Name__c) : role.Name__c;
            client.roleId = role.Id;
        
            client.middleInitial = role.Middle_Initial__c ;
           // client.youthId = role.Youth_ID__c;
            client.suffix = role.Suffix__c;
            client.initialRegistrationDate = role.Date_of_Initial_Registration__c;
            client.livingArrangements = role.Living_Arrangements__c;
            client.school = role.School__c;
            client.employmentStatus = role.Employment_Status__c;            
            client.notInLaborForce = role.Not_in_Labor_Force__c;
            client.sourceOfIncome = role.Source_Of_Income__c;
            client.cyfdInvolved = role.CYFD_Involved__c;           
            client.referralSource = role.Referral_Source__c;
            //client.criminalJusticeReferral = role.Criminal_Justice_Referral__c;
            client.arrestInPast30Days = role.Arrest_in_Past_30_Days__c;
            client.healthInsurance = role.Health_Insurance__c;
            client.noSSN = role.No_SSN__c;
            client.ssnNumber = role.SSN__c;
            client.driverLicenseNumber = role.Driver_s_License__c;            
            client.hasMedicalId = role.Client_has_a_Medicaid_ID__c;
            client.medicalId = role.Medicaid_ID__c;
            client.primaryLanguage = role.Primary_Language__c;
            client.ethnicity = role.Ethnicity__c;
            client.tribalAffiliation = role.Tribal_Affiliation__c;
            client.otherTribalAffiliation = role.Other_Tribal_Affiliation__c;
            client.race =role.Race__c;
            client.homeless = role.Check_if_client_is_Homeless__c;
            client.addressLine1 = role.Address_Line_1__c;
            client.addressLine2 = role.Address_Line_2__c;
            client.city = role.City__c;
            client.state = role.State__c;            
            client.zipCode = role.Zip_Code__c;
            client.noPhone = role.Check_if_client_has_no_phone__c;
            client.primaryPhone = role.Primary_Phone__c;
            client.otherPhone = role.Other_Phone__c ;           
            //client.statusOfClient = role.Status_of_Client__c;
            client.dischargeReason  = role.Discharge_Reason__c;
           // client.mco = role.MCO__c;
            client.reason = role.Reason__c;
            client.gender = role.Gender__c;
            client.sexualPreferrence = role.Sexual_Preference__c;
            client.populationServed = role.Population_Served__c;
            client.dob = role.Date_of_Birth__c;
            client.education = role.Education__c;
            client.lgbtq = role.LGBTQ__c;
            client.atRiskFactors = role.At_Risk_Factors__c;
            client.localSelectionPanelDate = role.Local_Selection_Panel_Date__c;
            client.status = role.Active_Status__c;
            
            client.geographicLocation = role.Geographic_Location__c ;
            client.otherPopulation = role.Other_Population_Information__c;
            client.gangActivity = role.Gang_Activity__c;
            client.currentlyInDetention = role.Youth_Currently_in_Detention__c;
            
            return client;
        } 
        
        public Contract_Role__c createClient(ContractRoleWrapper roleWrapper, String type){
            Contract_Role__c role = new Contract_Role__c();
            if(!String.isBlank(roleWrapper.roleId))
                role.Id = roleWrapper.roleId;
            role.First_Name__c = roleWrapper.firstName;
            role.Last_Name__c = roleWrapper.lastName;
            role.Middle_Initial__c = roleWrapper.middleInitial;
           // role.Youth_ID__c = roleWrapper.youthId;
            role.Suffix__c = roleWrapper.suffix;
            role.Date_of_Initial_Registration__c = roleWrapper.initialRegistrationDate;
            role.Living_Arrangements__c = roleWrapper.livingArrangements;
            role.School__c = roleWrapper.school;
            role.Employment_Status__c = roleWrapper.employmentStatus;
            role.Not_in_Labor_Force__c = roleWrapper.notInLaborForce;
            role.Source_Of_Income__c = roleWrapper.sourceOfIncome;
            role.CYFD_Involved__c = roleWrapper.cyfdInvolved;
            role.Referral_Source__c = roleWrapper.referralSource;
            //role.Criminal_Justice_Referral__c = roleWrapper.criminalJusticeReferral;
            role.Arrest_in_Past_30_Days__c = roleWrapper.arrestInPast30Days;
            role.Health_Insurance__c = roleWrapper.healthInsurance;
            role.No_SSN__c = roleWrapper.noSSN != null ? roleWrapper.noSSN : false;
            role.SSN__c = roleWrapper.ssnNumber;
            role.Driver_s_License__c = roleWrapper.driverLicenseNumber;
            role.Client_has_a_Medicaid_ID__c = roleWrapper.hasMedicalId != null ? roleWrapper.hasMedicalId : false;
            role.Medicaid_ID__c = roleWrapper.medicalId;
            role.Primary_Language__c = roleWrapper.primaryLanguage;
            role.Ethnicity__c = roleWrapper.ethnicity;
            role.Tribal_Affiliation__c = roleWrapper.tribalAffiliation;
            role.Other_Tribal_Affiliation__c = roleWrapper.otherTribalAffiliation;
            role.Race__c = roleWrapper.race;
            role.Check_if_client_is_Homeless__c = roleWrapper.homeless != null ? roleWrapper.homeless : false;
            role.Address_Line_1__c = roleWrapper.addressLine1;
            role.Address_Line_2__c = roleWrapper.addressLine2;
            role.City__c = roleWrapper.city;
            role.State__c = roleWrapper.state;
            role.Zip_Code__c = roleWrapper.zipCode;
            role.Check_if_client_has_no_phone__c = roleWrapper.noPhone != null ? roleWrapper.noPhone : false;
            role.Primary_Phone__c = roleWrapper.primaryPhone;
            role.Other_Phone__c = roleWrapper.otherPhone;
            //role.Status_of_Client__c = roleWrapper.statusOfClient;
            role.Discharge_Reason__c = roleWrapper.dischargeReason;
            system.debug('at risk factors ' + roleWrapper.atRiskFactors);
            role.At_Risk_Factors__c = roleWrapper.atRiskFactors;
            role.Reason__c = roleWrapper.reason;
            role.Sexual_Preference__c = roleWrapper.sexualPreferrence;
            role.Population_Served__c  = roleWrapper.populationServed;
            role.Gender__c = roleWrapper.gender;
            role.Date_of_Birth__c = roleWrapper.dob;
            role.Education__c = roleWrapper.education;
            role.LGBTQ__c = roleWrapper.lgbtq;
            role.Active_Status__c = roleWrapper.status != null ? roleWrapper.status : false;
            //role.Message__c = roleWrapper.message;
            role.Local_Selection_Panel_Date__c = roleWrapper.localSelectionPanelDate;
            role.Geographic_Location__c = roleWrapper.geographicLocation;
            role.Other_Population_Information__c = roleWrapper.otherPopulation;
            role.Gang_Activity__c = roleWrapper.gangActivity;
            role.Youth_Currently_in_Detention__c = roleWrapper.currentlyInDetention; 
            system.debug(' roleWrapper.gangActivity' + roleWrapper.gangActivity);
            system.debug(' roleWrapper.currentlyInDetention' + roleWrapper.currentlyInDetention);
            if(type == 'JCC')
                role.Contract_Role__c = 'JCC Client';
            else if(type == 'JJAC')
                role.Contract_Role__c = 'JJAC Client';
            else if(type == 'Mentoring')
                role.Contract_Role__c = 'Mentoring Client';
            if(type != '')
            role.RecordTypeId = NM_CYFD_Utility.getRecordTypeId('Contract_Role__c', role.Contract_Role__c);
            return role;           
        } 
}