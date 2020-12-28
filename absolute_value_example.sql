select pay.practice, pay.practicedivision as div, p.locationstate as state, pay.chargekey, pay.accountkey, pay.servicedate, p.primarypayornationalfinancialclass, pay.primarypayorname,
p.primarypayorlocalfinancialclass, p.isparticipating, p.primarypayorreportgroup, pay.primarypayorno, pay.cpt, p.cptclass, p.modifier1, pay.chargeamount, pay.transactionamount as pmt, pay.carc, pay.allowedamount, 

case when pay.allowedamount=0 then pay.transactionamount else pay.allowedamount end as pdappd, p.contractualallowance, pay.payorno, to_char(pay.postingdate,'mm/dd/yyyy')as postingdate, pay.docnum,
p.docno, p.billingproviderkey, p.billingprovidertype, p.siteservice, sml.locality_number||pay.cpt as LocCPT, isnull(ex.fee_schedule,'NULL') as fee_schedule, isnull(ex.contract_name,'NULL') as contract_name,
isnull(ex.value1,0) as expected_pay1, isnull(ex.altval2,0) as expected_pay2,

case when fee_schedule <> 'NULL' then pdappd-expected_pay1 else 0 end as variance1, 
case when fee_schedule <> 'NULL' and ex.altval2 is not NULL then pdappd-expected_pay2 else 0 end as variance2,

case when fee_schedule is NULL then 'NULL'
     when ABS(variance1) <= 2 or (ex.altval2 is not NULL and ABS(variance2) <=2)
     or (pay.cpt=99283 and ((ABS(pdappd-52.38)<=2) or (ABS(pdappd-44.53)<=2)))
     
     or (pay.cpt=99284 and ((ABS(pdappd-81.74)<=2)or (ABS(pdappd-69.48)<=2)))
     
     or (pay.cpt=99285 and ((ABS(pdappd-127.98)<=2)or (ABS(pdappd-108.78)<=2)))
    
     or (pay.cpt=99291 and ((ABS(pdappd-219.9)<=2)))
          
     or (ABS(pdappd-expected_pay1 * 0.9)<=2 or ABS(pdappd-expected_pay2 *0.9)<=2)
      
     or (pay.cpt=99283 and ((ABS(pdappd-52.38*0.9)<=2) or (ABS(pdappd-44.53*0.9)<=2)))
     
     or (pay.cpt=99284 and ((ABS(pdappd-81.74*0.9)<=2)or (ABS(pdappd-69.48*0.9)<=2)))
     
     or (pay.cpt=99285 and ((ABS(pdappd-127.98*0.9)<=2)or (ABS(pdappd-108.78*0.9)<=2)))
    
     or (pay.cpt=99291 and ((ABS(pdappd-219.9*0.9)<=2)))
          
     then 'YES'
     else 'NO' 
     end as compliant_yesorno, pdappd-pmt as patient_responsible

from payments pay inner join procedure p on pay.chargekey = p.chargekey
left join site_medicare_locality sml on sml.sitekey=pay.sitekey
left join payments_expected ex on p.primarypayornationalfinancialclass=ex.nat_fc 
                                  and p.locationstate=ex.state
                                  and pay.servicedate between ex.dos_from and ex.dos_to
                                  and p.cpt=ex.cpt  
                                                                 
where
p.primarypayornationalfinancialclass = 'MCDMC' and p.locationstate = 'NJ' 
                                                                                     
                                                                                     and pay.primarypayor like '%MH%'
                                                                                     and p.practice in ('CHS', 'HMS', 'JCM', 'BEM', 'MNS', 'MMO', 'NBI', 'CMH', 'BRN', 'BYE', 'CMU', 'SMA', 'NTO', 'OVR', 'RAH', 'HAC')
and pay.primarypayorno=pay.payorno
and pay.carc in ('PA','UC', 'DN','SF', 'PR1', 'PR2', 'PR3', 'CLP', 'VI', 'MC', 'AM', 'FBAL', 'APA')
and pay.remitclass in ('CASH', 'REFUND') and (pay.allowedamount>0 or pay.transactionamount>0)
and pay.postingdate = (select min(b.postingdate) from payments b where b.chargekey = pay.chargekey and b.remitclass in ('CASH', 'REFUND'))

