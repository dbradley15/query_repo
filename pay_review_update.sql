
--Version 07.09.19 -- Updates: Added Agency Info, Denial Count
--Version 07.15.19 -- Updates: Added DOCNUM column for payment information.  Added % charge, % MED calculations. Added column indicating account participating in Bill Delay/Deductible Mitigation project
--Version 07.17.19 -- Updates: Adjusted pmt_percentmed column to accommodate MLP rates. Revised WHERE clause.



select p.practice, p.accountkey, p.chargekey, p.locationstate as ST, p.practicedivision as DIV, sml.locality_number, p.servicedate, p.primarypayornationalfinancialclass as NATFC, 
p.primarypayorlocalfinancialclass as locfc, p.primarypayorreportgroup as rptgrp, p.firstpayor, p.grosscharges as chgamt, p.allowedamount as allowed_proc, p.cpt, p.cptclass, p.balance as bal, p.siteservice as ss,
p.isparticipating as ispar, p.billingprovidername,p.billingprovidertype,
p.billinggroupname, p.billinggrouptaxid, p.firstbilldate, case when p.producttype='PREFERRED PROVIDER ORGANIZATION' then 'PPO' when p.producttype='HEALTH MAINTENANCE ORGANIZATION' then 'HMO' else p.producttype end as producttype, 
p.secondarypayorkey, pm.payorname as secondarypayorname, pm.nationalfinancialclass as secondarypayorFC,

CASE WHEN fp.payorno is null then 'NO PMT' ELSE 'PAID' END AS ACCTPDORNO,
fp.transactionamount as pmt_transactionamount, case when fp.allowedamount=0 then fp.transactionamount else fp.allowedamount end as pmt_appdamt, fp.carc as pmt_carc, fp.postingdate as pmt_postingdate, fp.payorno as pmt_pdpyr, fp.docnum as pmt_doc, 
case
when fp.allowedamount=0 then fp.transactionamount/p.grosscharges 
when fp.allowedamount>p.grosscharges then fp.transactionamount/p.grosscharges
else fp.allowedamount/p.grosscharges end as pmt_PercentCharge, 
case
when p.billingprovidertype<>'MD' and fp.allowedamount=0 then fp.transactionamount/round(.85*med.expected_amount,2)
when p.billingprovidertype<>'MD' then fp.allowedamount/round(.85*med.expected_amount,2)
when fp.allowedamount=0 then fp.transactionamount/med.expected_amount
else fp.allowedamount/med.expected_amount
end as pmt_percentmed,
case
when med.expected_amount is null then 00 
when p.billingprovidertype<>'MD' then round(.85*med.expected_amount,2)
else med.expected_amount
end as expected_AMT,

aa.count as Count, pp.patient_pay,

CASE
WHEN fd.payorno is null then 'NO DNL'
ELSE 'DENIED'
END AS ACCTDNDORNO,

fd.carc as dnl_carc, fd.denialtrackingcategory as dnl_cat, cm.remitdescription as dnl_remitdescription, fD.payorno as dnl_pyr,  fd.postingdate as dnl_postingdate, fd.docnum as dnl_doc,

case when p.chargekey in(select distinct chargekey from payments where payorno=primarypayor and payments.carc in('PP','PR100','NR53','CR100','PCT51')) THEN 'Yes' else 'No' end as PdPtYN,

p.netcash, p.docno, denial_counter.total as denial_count, CASE WHEN first_campaign.campaign is not null THEN 'YES' ELSE  'NO' END AS inAgency, first_campaign.campaign,
case when p.accountkey in (select distinct accountkey from agencyacctextract where campaign='BILLDELAY') then 'BILLDELAY' else null end as campaign_billdelay, med.expected_amount as medrate,

case when first_campaign.campaign is null then 'No' else 'Yes' end as inCampaign,
case when fp.payorno is null then 'No' else 'Yes' end as hasPayResponse,
case when p.firstbilldate is null then 'No' else 'Yes' end as hasBilled,


case 
     when p.allowedamount = 0 and (fp.transactionamount = 0 or fp.transactionamount is null) then 'No Pay'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/p.grosscharges), 0.0) else nvl(p.allowedamount/p.grosscharges,0.0) end  = 1 then '100% BC'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/p.grosscharges), 0.0) else nvl(p.allowedamount/p.grosscharges,0.0) end  = 0.9 then '90% BC'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/p.grosscharges), 0.0) else nvl(p.allowedamount/p.grosscharges,0.0) end  = 0.8 then '80% BC'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/p.grosscharges), 0.0) else nvl(p.allowedamount/p.grosscharges,0.0) end  = 0.85 then '85% BC'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/p.grosscharges), 0.0) else nvl(p.allowedamount/p.grosscharges,0.0) end  = 0.6 then '60% BC'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/p.grosscharges), 0.0) else nvl(p.allowedamount/p.grosscharges,0.0) end  = 0.5 then '50% BC'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/p.grosscharges), 0.0) else nvl(p.allowedamount/p.grosscharges,0.0) end  >= 0.75 then '75-99% BC'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/p.grosscharges), 0.0) else nvl(p.allowedamount/p.grosscharges,0.0) end  >= 0.50 then '51-74% BC'
     when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) 
          else nvl(p.allowedamount/med.expected_amount,0.0) 
          end = 3 
          then '300% MED'
     when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end = 2 
          then '200% MED'
     when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end = 1 
          then '100% MED'
     when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end = 1.5
          then '150% MED'
     when case 
         when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end = 1.25
          then '125% MED'
     when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end = 2.5
          then '250% MED'
     when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end between 4 and 6
          then '400-600% MED'
     when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end between 4 and 6
          then '400-600% MED'  
     when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end > 3 
          then '301-399% MED'
     when case 
         when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end > 2 
          then '201-299% MED'      
     when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end >= 1.6 
          then '160-199% MED'      
      when case 
         when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end > 1.02 
          then '102-159% MED'
      when case 
          when p.allowedamount = 0 and fp.transactionamount > 0 and p.billingprovidertype <> 'MD' then nvl((fp.transactionamount/(med.expected_amount * 0.85)), 0.0) 
          when p.billingprovidertype <> 'MD' then nvl((p.allowedamount/(med.expected_amount * 0.85)),0.0) 
          when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0)
          else nvl(p.allowedamount/med.expected_amount,0.0)
          end >= 0.95 
          then '~MED'                                                                  
     else 'Other' end as Pay_Category



from procedure p 
left join site_medicare_locality sml on sml.sitekey = p.sitekey
left join medicare_allowable med on med.medicare_locality = sml.locality_number and date_part(year, p.servicedate)=med.year and p.cpt = med.cpt and med.degree='MD'

inner join payor_master pm on pm.payorkey = p.secondarypayorkey
left outer join 
(select distinct chargekey, 
  first_value(payorkey) over (partition by chargekey order by chargekey, postingdate, payorkey, docnum, payorno, carc, allowedamount  rows between unbounded preceding and unbounded following) as payorkey, 
  first_value(docnum) over (partition by chargekey order by chargekey, postingdate, payorkey, docnum, payorno, carc, allowedamount  rows between unbounded preceding and unbounded following) as docnum, 
  first_value(payorno) over (partition by chargekey order by chargekey, postingdate, payorkey, docnum, payorno, carc, allowedamount  rows between unbounded preceding and unbounded following) as payorno, 
  first_value(carc) over (partition by chargekey order by chargekey, postingdate, payorkey, docnum, payorno, carc, allowedamount  rows between unbounded preceding and unbounded following) as carc,
  first_value(transactionamount) over (partition by chargekey order by chargekey, postingdate, payorkey, docnum, payorno, carc, allowedamount  rows between unbounded preceding and unbounded following) as transactionamount,
  first_value(postingdate) over (partition by chargekey order by chargekey, postingdate, payorkey, docnum, payorno, carc, allowedamount rows between unbounded preceding and unbounded following) as postingdate, 
  first_value(allowedamount) over (partition by chargekey order by chargekey, postingdate, payorkey, docnum, payorno, carc, allowedamount rows between unbounded preceding and unbounded following) as allowedamount
from (select chargekey, docnum, payorkey, payorno, transactionamount, postingdate, CARC, allowedamount from payments where remitclass = 'CASH' OR CARC IN ('PR1', 'PR2', 'PR3', 'DN')
and primarypayorreportgroup = payorreportgroup)
) fp on p.chargekey = fp.chargekey

left outer join 
(  
select distinct chargekey, 
  first_value(payorno) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname, chargeamount  rows between unbounded preceding and unbounded following) as payorno, 
  first_value(payorname) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname, chargeamount  rows between unbounded preceding and unbounded following) as payorname,
  first_value(postingdate) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname, chargeamount rows between unbounded preceding and unbounded following) as postingdate,
  first_value(carc) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname, chargeamount rows between unbounded preceding and unbounded following) as carc,
  first_value(chargeamount) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname, chargeamount rows between unbounded preceding and unbounded following) as chargeamount,
  first_value(denialtrackingcategory) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname, chargeamount rows between unbounded preceding and unbounded following) as denialtrackingcategory,
  first_value(docnum) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname, chargeamount rows between unbounded preceding and unbounded following) as docnum
  from (select chargekey, payorkey, payorno, payorname, transactionamount, postingdate, carc, chargeamount, denialtrackingcategory, docnum from payments where remitclass = 'DENIAL' and carc not in('NR60', 'NR120', 'NR180', 'PR1', 'PR2', 'PR3', 'HU', 'HUNC', 'DN'))
) fd on p.chargekey = fd.chargekey
left join
(select procedure.chargekey, count(procedure.chargekey) from payments inner join procedure on procedure.chargekey=payments.chargekey where (carc in ('PA','UC','DN','SF','PR1','PR2','PR3','CLP','FBAL') or remitclass='CASH') 
  and firstpayor=payorno group by procedure.chargekey
) aa on aa.chargekey=p.chargekey
left join carc_master cm on fd.carc=cm.remitno


left join (
select p1.chargekey, count(p1.carc) as total from payments p1
where (p1.primarypayorreportgroup=p1.payorreportgroup or (p1.payorno='CLP' and p1.remittancesource='835') or (p1.payorno in ('PENCP', 'CAPIO')))
and (p1.remitclass = 'DENIAL' and carc not in('NR60', 'NR120', 'NR180', 'PR1', 'PR2', 'PR3', 'HU', 'HUNC', 'DN'))
group by p1.chargekey
) denial_counter on denial_counter.chargekey = p.chargekey

left join (
  select distinct accountkey,
  first_value(startdate) over (partition by accountkey order by accountkey, startdate, campaign, campaigndescription  rows between unbounded preceding and unbounded following) as startdate,  
  first_value(campaign) over (partition by accountkey order by accountkey, startdate, campaign, campaigndescription  rows between unbounded preceding and unbounded following) as campaign,
  first_value(campaigndescription) over (partition by accountkey order by accountkey, startdate, campaign, campaigndescription  rows between unbounded preceding and unbounded following) as campaigndescription 
  from (select accountkey, startdate, campaign,campaigndescription from agencyacctextract where campaign not like '%HRI%'  and campaign not in ( 'LETTERTRACKING','BILLDELAY', 'GEBBSAR360', 'MVASB', 'MMSBP1', 'SIMPLEE', 'BILLDELAY-AMBETTER', 'MCDDISC') 
  and campaign not like '%P2P%' 
  and campaigndescription not like '%CREDENCE%'
  order by accountkey, startdate, campaign
)) first_campaign on first_campaign.accountkey = p.accountkey

--patient payments
left outer join(
select chargekey, sum(transactionamount) patient_pay from payments where payorno in('PER','COL','CHECK','MCARD','DISC','AMEX','VISA') and 
remitclass in('CASH', 'REFUND') group by chargekey) pp on pp.chargekey = p.chargekey

where
   p.grosscharges>'0' and p.cptclass='Exam' AND DATEDIFF(month, p.servicedate, current_date)<=15 --AND p.isparticipating='no'
    and p.locationstate in ('MD','WV', 'AR', 'HI')
    --and p.primarypayorname like '%CAREFIRST%'
    --and p.practice = 'MEM'
    --and p.primarypayornationalfinancialclass in ('BCROS', 'BLU', 'BLUEX')
    --and p.primarypayorreportgroup = 'AET'
    --and p.practice in ('GWI', 'NEA')
    --and p.primarypayorreportgroup = 'AET'
    and p.primarypayornationalfinancialclass in ('AETNA', 'BCROS', 'BLU', 'BLUEX', 'CIGNA', 'COM', 'COMEX', 'HMO', 'HMOEX', 'GOV', 'HUMANA')
    and (p.adjustment is null or adjustment = 'Replacement') ---ADD YOUR FILTERS HERE----    


   -- p.grosscharges>'0' and p.cptclass='Exam' AND DATEDIFF(month, p.servicedate, current_date)<=15
    --and p.practice = 'CEP'
    --and p.practice in ('GCE', 'FST', 'KDM', 'HIL', 'HLL', 'GBM', 'KCM', 'IPH', 'KRI')
    --and p.locationstate in ('AL', 'AR', 'CT', 'DC', 'MD', 'MO', 'VA', 'OR', 'OK')
    --and round((fp.allowedamount / p.grosscharges), 2) = .6
    --and p.primarypayorreportgroup = 'AET'
    --and p.primarypayornationalfinancialclass in ('MCDMC')
    --and (p.adjustment is null or adjustment = 'Replacement') ---ADD YOUR FILTERS HERE----    
    
