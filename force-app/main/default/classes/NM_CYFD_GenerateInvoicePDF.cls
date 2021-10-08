public without sharing class NM_CYFD_GenerateInvoicePDF {

    public NM_CYFD_GenerateInvoicePDF(ApexPages.StandardController controller) {
     String appId = ApexPages.CurrentPage().getparameters().get('id');
        invoice = new Invoice__c();
        serviceRenderedDate = '';
        contractDateRange = '';
        invoiceDate = '';
        contractActivityList = new List<ContractActivityWrapper>();
        Map<String, Decimal> mapOfActivityAndRoleToSumOfUnits = new Map<String, Decimal>();
       
        if(String.isNotBlank(appId)){
            List<Invoice__c> invoices = [SELECT Id, Name, Match_Amount__c, Invoice_Date__c, Contract__c, COntract__r.Start_Date__c, COntract__r.End_Date__c, COntract__r.Grant__c, 
                                         COntract__r.Name, COntract__r.PO_Number__c, COntract__r.Contract_Number__c, COntract__r.Name__c, COntract__r.Address__c, 
                                         COntract__r.Zip__c, COntract__r.City__c, COntract__r.Amount__c, COntract__r.State__c,Amount__c, Program_Support_Fee__c , 
                                         Invoice_Total__c, Adjustment_Amount__c,
                                         (SELECT Id, Name, Number_of_Youth__c , Activity_Label__c, Unit__c, Rate__c, 
                                         Invoice_Amount__c, Amount__c, Mentoring_Units__c, Mulitplied_by_Number_of_Youth__c FROM Contract_Activities__r WHERE Match__c = false)
                                         FROM Invoice__c WHERE Id = :appId];
                           
            String fiscalYearFromPeriod = String.valueOf([SELECT FiscalYearSettings.Name,FiscalYearSettings.EndDate  FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.EndDate.year());
            if(!invoices.isEmpty()) {

                /*
                 * Author : Apoorv Anand 
                 * Desc   : fiscalYear value should be contract's end data year. If null then populating from period end date.
                */
                if(invoices[0].Contract__r.End_Date__c != null )
                	fiscalYear = String.valueOf(invoices[0].Contract__r.End_Date__c.year());
                
                if ( fiscalYear == null ) {
                    fiscalYear = fiscalYearFromPeriod;
                }
                invoice = invoices[0];
                invoiceDate = formatDate(invoices[0].Invoice_Date__c);
                jjac = (invoices[0].Contract__c != null && invoices[0].COntract__r.Grant__c == 'JJAC') ? true :  false;
                jcc = (invoices[0].Contract__c != null && invoices[0].COntract__r.Grant__c == 'JCC' )? true :  false;
                mentoring = (invoices[0].Contract__c != null && invoices[0].COntract__r.Grant__c == 'Mentoring') ? true :  false;
                Date lastMonth = (invoices[0].Invoice_Date__c != null ? invoices[0].Invoice_Date__c.addmonths(-1) : null);
                Date FirstOfLastMonth = date.newInstance(lastMonth.year(), lastMonth.month(), 1);
                Integer numberOfDays = Date.daysInMonth(FirstOfLastMonth.year(), FirstOfLastMonth.month());
                Date LastDayOfLastMonth = Date.newInstance(FirstOfLastMonth.year(), FirstOfLastMonth.month(), numberOfDays);
                serviceRenderedDate = formatDate(FirstOfLastMonth) + ' - ' + formatDate(LastDayOfLastMonth); 
                contractDateRange = formatDate(invoices[0].COntract__r.Start_Date__c) + ' - ' + formatDate(invoices[0].COntract__r.End_Date__c);
                
                if(!invoices[0].Contract_Activities__r.isEmpty()){
                    
                    // Changes related to Invoice Contract Activity Issue Start | Yash Agarwal
                    Map<String,ContractActivityWrapper> activityLabelToWrapperMap= new Map<String, ContractActivityWrapper>();
                    for(Contract_Activity__c ca : invoices[0].Contract_Activities__r){
                        
                        if(!activityLabelToWrapperMap.containsKey(ca.Activity_Label__c)){
                            //!ca.Mulitplied_by_Number_of_Youth__c && 
                            Decimal units = ca.Unit__c !=null ? ca.Unit__c : 0;
                            
                            if(mentoring){
                                //units = ca.Unit__c;
                            }else if(ca.Mulitplied_by_Number_of_Youth__c && ca.Number_of_Youth__c !=null && ca.Number_of_Youth__c != 0)
                                units = units* ca.Number_of_Youth__c;
                                
                            
                            ContractActivityWrapper wrapperRec = new ContractActivityWrapper(ca.Activity_Label__c,units,
                                                                                             (ca.Rate__c !=null ? ca.Rate__c : 0),
                                                                                             (ca.Invoice_Amount__c !=null ? ca.Invoice_Amount__c : 0));
                            activityLabelToWrapperMap.put(ca.Activity_Label__c,wrapperRec);
                            system.debug('contractActivityRec.Activity_Label__c ' + ca.Activity_Label__c +units);
                        
                        } else {
                        
                            Decimal units = ca.Unit__c !=null ? ca.Unit__c : 0;
                            if(mentoring){
                                //units = sumOfMentoringUnits;
                            }else if(ca.Mulitplied_by_Number_of_Youth__c && ca.Number_of_Youth__c !=null && ca.Number_of_Youth__c != 0)
                                units = units* ca.Number_of_Youth__c;
                                
                            ContractActivityWrapper wrapperRec = activityLabelToWrapperMap.get(ca.Activity_Label__c);
                            wrapperRec.rate = (ca.Rate__c !=null ? ca.Rate__c : wrapperRec.rate);
                            wrapperRec.amount += (ca.Invoice_Amount__c !=null ? ca.Invoice_Amount__c : 0);
                            
                            if ( !mentoring )
                            	wrapperRec.units += units;
                            else
                                wrapperRec.units = wrapperRec.amount / wrapperRec.rate;
                                //sumOfMentoringUnits;
                            
                            //wrapperRec.amount = wrapperRec.rate * wrapperRec.units;
                            activityLabelToWrapperMap.put(ca.Activity_Label__c,wrapperRec);
                        }
                    }
                    for(ContractActivityWrapper contractActivityWrapperRec:activityLabelToWrapperMap.values()){
                        Decimal decimalZeroCheck = 0;
                        if(contractActivityWrapperRec.rate != decimalZeroCheck){
                           contractActivityWrapperRec.units = contractActivityWrapperRec.units;
                               //(contractActivityWrapperRec.amount / contractActivityWrapperRec.rate).setScale(2);
                        }
                        contractActivityList.add(contractActivityWrapperRec);
                    }
                    // End
                }
            }
        }
    }
    
    public static String formatDate(Date d) {
        if(d != null)
            return  d.month() + '/' + d.day() + '/' + d.year() ;
        return null;
    }

    public Invoice__c invoice{get;set;}
    public String serviceRenderedDate{get;set;}
    public String contractDateRange{get;set;}
    public Decimal matchAmount{get;set;}
    public Boolean jjac{get;set;}
    public Boolean jcc{get;set;}
    public Boolean mentoring{get;set;}
    public String invoiceDate{get;set;}
    public List<String> keyList {get;set;}
    //public Map<Id, Contract_Activity__c> contractActivitiesMap{get;set;}
    public String fiscalYear {get;set;}
    // Changes related to Invoice Contract Activity Issue Start | Yash Agarwal
    public class ContractActivityWrapper{
        public String name          {get;set;}
        public Decimal units        {get;set;}
        public Decimal rate         {get;set;}
        public Decimal amount       {get;set;}
        public Decimal numOfYouth       {get;set;}
        public ContractActivityWrapper(String name,Decimal units, Decimal rate, Decimal amount){
            this.name = name;
            this.units = units;
            this.rate = rate;
            this.amount = amount;
//            this.numOfYouth = numOfYouth;
        }
    }
    public List<ContractActivityWrapper> contractActivityList{get;set;}
    // End
}