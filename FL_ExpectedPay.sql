select pay.practice, pay.practicedivision as div, p.locationstate as state, pay.chargekey, pay.accountkey, to_char(pay.servicedate,'mm/dd/yyyy') as DOS, p.primarypayornationalfinancialclass,	
p.primarypayorlocalfinancialclass, p.isparticipating, p.primarypayorreportgroup, pay.primarypayorno, pay.cpt, p.cptclass, p.modifier1, pay.chargeamount, pay.transactionamount as pmt, pay.carc, pay.allowedamount, 	
	
case when pay.allowedamount=0 then pay.transactionamount else pay.allowedamount end as pdappd, p.contractualallowance, pay.payorno, to_char(pay.postingdate,'mm/dd/yyyy')as postingdate, pay.docnum,	
p.docno, p.billingproviderkey, p.billingprovidertype, p.siteservice, 'FL-04'||pay.cpt as LocCPT, isnull(ex.fee_schedule,'NULL') as fee_schedule, isnull(ex.contract_name,'NULL') as contract_name,	
isnull(ex.percent_med * isnull(med.expected_amount,0),0) as expected_pay1, isnull(ex.altval2 * isnull(med.expected_amount,0),0) as expected_pay2, 
case when p.billingprovidertype <> 'MD' then round(med2.expected_amount * .85,2) else round(med2.expected_amount, 2) end as med_amount, 
case when p.billingprovidertype <> 'MD' then round(med.expected_amount * .85,2) else round(med.expected_amount, 2) end as med_amount_ContractAdjustment, 
pdappd/med_amount medpercentage, 
pdappd/med_amount_ContractAdjustment medpercent2,

case when expected_pay1 <> 0 then pdappd-expected_pay1 else 0 end as variance1, 	
case when expected_pay2 <> 0 then pdappd-expected_pay2 else 0 end as variance2,	
	
case when expected_pay1= 0 and expected_pay2 = 0 then 'NULL'	
     when ABS(variance1) <= 2 or ex.altval2 is not NULL and ABS(variance2) <=2           	
	
       or p.modifier1 = 54 and (expected_pay1 <>0 and round(pdappd/expected_pay1,2)>= 0.7)	
       or p.modifier1 = 54 and (expected_pay2 <>0 and round(pdappd/expected_pay2,2)>= 0.7)	
	
       or p.billingprovidertype in ('PA', 'NP') and ABS(pdappd-0.85*expected_pay1) <=2	
       or p.billingprovidertype in ('PA', 'NP') and ABS(pdappd-0.85*expected_pay2) <=2  ---------MLPs are not directly contracted with Florida Blue will be paid 85% of contracted rates-----------      	
       	
     then 'YES'	
     else 'NO' 	
     end as compliant_yesorno, pdappd-pmt as patient_responsible, p.totalrvu, p.billinggroupname
	
from payments pay inner join procedure p on pay.chargekey = p.chargekey	
left join medicare_allowable med on med.medicare_locality = 'FL-04'	
                                 and pay.cpt=med.cpt	
                                 and med.degree = 'MD'	
                                 and med.year=2013

left join site_medicare_locality sml on sml.sitekey = p.sitekey
left join medicare_allowable med2 on med2.medicare_locality = sml.locality_number and date_part(year, p.servicedate) = med2.year and p.cpt = med2.cpt and med2.degree = 'MD'                                   	
	
left join payments_expected ex on p.primarypayorlocalfinancialclass=ex.local_fc 	
                                  and p.locationstate=ex.state	
                                  and p.siteservice=ex.ss              	
                                  and pay.servicedate between ex.dos_from and ex.dos_to	
                                  and p.cptclass=ex.cpt_class	
                                	
where p.primarypayorlocalfinancialclass in ('BLUFL','BLUEX') and p.locationstate = 'FL' and p.siteservice = 'ED'	
and pay.servicedate >= '01/01/2019'	
and (p.practice in ('AEP', 'BYC', 'PAN') or p.billinggroupname like '%FL EM-I%')
and p.isparticipating = 'yes' and pay.primarypayorno=pay.payorno	
and pay.carc in ('PA','UC', 'DN','SF', 'PR1', 'PR2', 'PR3', 'CLP', 'VI', 'MC', 'AM', 'FBAL', 'APA')	
and pay.remitclass in ('CASH', 'REFUND') and (pay.allowedamount>0 or pay.transactionamount>0)	
and pay.postingdate = (select min(b.postingdate) from payments b where b.chargekey = pay.chargekey and b.remitclass in ('CASH', 'REFUND'))	
	
union	
	
---------------------------------------BLUFL Statewide IPS Contract (% of MED, Locality 3)-(Column 4,9,10,11,12,17&21) ------------------------------------------------------	
select pay.practice, pay.practicedivision as div, p.locationstate as state, pay.chargekey, pay.accountkey, to_char(pay.servicedate,'mm/dd/yyyy') as DOS, p.primarypayornationalfinancialclass,	
p.primarypayorlocalfinancialclass, p.isparticipating, p.primarypayorreportgroup, pay.primarypayorno, pay.cpt, p.cptclass, p.modifier1, pay.chargeamount, pay.transactionamount as pmt, pay.carc, pay.allowedamount, 	
	
case when pay.allowedamount=0 then pay.transactionamount else pay.allowedamount end as pdappd, p.contractualallowance, pay.payorno, to_char(pay.postingdate,'mm/dd/yyyy')as postingdate, pay.docnum,	
p.docno, p.billingproviderkey, p.billingprovidertype, p.siteservice, 'FL-03'||pay.cpt as LocCPT, isnull(ex.fee_schedule,'NULL') as fee_schedule, isnull(ex.contract_name,'NULL') as contract_name,	
isnull(ex.percent_med * isnull(med.expected_amount,0),0) as expected_pay1, 0 as expected_pay2, pdappd- expected_pay1  as variance1, 0 as variance2,	
case when p.billingprovidertype <> 'MD' then round(med2.expected_amount * .85,2) else round(med2.expected_amount, 2) end as med_amount, 
case when p.billingprovidertype <> 'MD' then round(med.expected_amount * .85,2) else round(med.expected_amount, 2) end as med_amount_ContractAdjustment, 
pdappd/med_amount medpercentage, 
pdappd/med_amount_ContractAdjustment medpercent2,
	
case when expected_pay1= 0 then 'NULL'	
     when ABS(variance1) <= 2 	
	
       or p.billingprovidertype in ('PA', 'NP') and ABS(pdappd-0.85*expected_pay1) <=2	
       or p.billingprovidertype in ('PA', 'NP') and ABS(pdappd-0.85*expected_pay2) <=2   ---------MLPs are not directly contracted with Florida Blue will be paid 85% of contracted rates-----------       	
	
     then 'YES'	
     else 'NO' 	
     end as compliant_yesorno, pdappd-pmt as patient_responsible, p.totalrvu, p.billinggroupname
	
from payments pay inner join procedure p on pay.chargekey = p.chargekey	
left join medicare_allowable med on med.medicare_locality = 'FL-03'	
                                 and pay.cpt=med.cpt	
                                 and med.degree = 'MD'	
                                 and datepart(year, pay.servicedate)=med.year
                                 

left join site_medicare_locality sml on sml.sitekey = p.sitekey
left join medicare_allowable med2 on med2.medicare_locality = sml.locality_number and date_part(year, p.servicedate) = med2.year and p.cpt = med2.cpt and med2.degree = 'MD'                                          	
	
left join payments_expected ex on p.primarypayorlocalfinancialclass=ex.local_fc 	
                                  and p.locationstate=ex.state	
                                  and p.siteservice=ex.ss                     	
                                  and pay.servicedate between ex.dos_from and ex.dos_to	
	
where p.primarypayorlocalfinancialclass in ('BLUFL','BLUEX') and p.locationstate = 'FL' and p.siteservice = 'IPS'	
and pay.servicedate >= '01/01/2019' and p.cptclass = 'Exam' 	
and p.isparticipating = 'yes' and pay.primarypayorno=pay.payorno	
and pay.carc in ('PA','UC', 'DN','SF', 'PR1', 'PR2', 'PR3', 'CLP', 'VI', 'MC', 'AM', 'FBAL', 'APA')	
and (p.practice in ('AEP', 'BYC', 'PAN') or p.billinggroupname like '%FL EM-I%')
and pay.remitclass in ('CASH', 'REFUND') and (pay.allowedamount>0 or pay.transactionamount>0)	
and pay.postingdate = (select min(b.postingdate) from payments b where b.chargekey = pay.chargekey and b.remitclass in ('CASH', 'REFUND'))	
	
8-14-20 QUERY	
	
select p.siteservice, pay.practice, pay.practicedivision as dv, pay.accountkey, pay.chargekey, pay.servicedate, pay.primarypayorlocalfinancialclass as LocalFC, pay.primarypayorreportgroup as RG, 	
pay.primarypayor, pay.CPT, pay.chargeamount as charge, pay.arcurrentbalance as bal, pay.transactionamount as paid, pay.allowedamount as allowed, pay.carc, pay.remitclass, pay.payorno,	
pay.postingdate, pay.responsiblepayor,case when pay.allowedamount = '0' then pay.transactionamount else pay.allowedamount end as pd_appd,  	
p.contractualallowance, p.netcash, p.baddebt, p.courtesywriteoffs, p.refunds, pp.sum as patient_paid, prim.sum as first_payorpaid, pay.docnum, p.docno	
from payments pay JOIN procedure p ON pay.chargekey = p.chargekey	
left join (select distinct chargekey, sum(transactionamount) from payments where remitclass='CASH' and payorno in('PER','COL','CHECK','MCARD','DISC','AMEX','VISA') group by 1) pp on p.chargekey=pp.chargekey	
left join (select distinct chargekey, sum(transactionamount) from payments where remitclass='CASH' and primarypayor = payorno group by 1) prim on p.chargekey=prim.chargekey	
where p.servicedate >= '01/01/2019'	
and pay.payorfinancialclass in ('BLUEX', 'BLUFL')	
and (p.practice in ('AEP', 'BYC', 'PAN') or p.billingroupname like '%Florida EM-1%')
and p.locationstate = 'FL'	
and p.operationalunit <> 'RTI'	
and p.cptclass <> 'QM'	
and p.cpt not like 'S9%'	
and pay.remitclass = 'CASH'	
and ((p.adjustment is null) or (p.adjustment = 'Replacement'))	
and ((pay.payorno = 'CLP' AND pay.remittancesource = '835') or (pay.primarypayor = pay.payorno));	

select * from procedure where billinggroupname like '%FL EM-I%' limit 10
