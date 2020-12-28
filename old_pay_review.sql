select distinct p.practice, p.practicedivision, p.billinggroupname, p.billinggrouptaxid, p.chargekey, p.accountkey, p.encounterkey, p.siteservice, p.locationstate, p.servicedate, p.firstbilldate,
p.primarypayornationalfinancialclass as nfc, p.primarypayorlocalfinancialclass as lfc, p.primarypayorreportgroup as rg, p.firstpayor, p.primarypayorname, p.cpt, p.cptclass, p.grosscharges as fee, case when p.allowedamount = 0 and fp.transactionamount > 0 then fp.transactionamount else p.allowedamount end as allowed,
p.balance as bal, p.netcash, nvl(prim.total,0.0) as primaryPayments, nvl(fp.transactionamount,0.0) as first_pay, fp.payorno, fp.postingdate, fp.docnum, percentile_compare.percentile, percentile_compare_loc.percentile_by_locality, 
((case when p.allowedamount = 0 and fp.transactionamount > 0 then fp.transactionamount else p.allowedamount end)-percentile_compare_loc.percentile_by_locality) as diff, pay_counter.total, p.zerobalancedate,

case when p.allowedamount <> 0 then (prim.total/p.allowedamount) else 0 end as percent_paid_by_ins,  
case when p.allowedamount = 0 and fp.transactionamount > 0 then (fp.transactionamount/p.grosscharges) else nvl(p.allowedamount/p.grosscharges,0.0) end as percent_charges,
case when med.expected_amount <> 0 then nvl(p.allowedamount/med.expected_amount, 0.0) else 0 end as medpercentage, med.expected_amount as med_rate, 

 nvl(denial_counter.total, 0.0) as denial_count,
 ld.payorno as denied_pyr, ld.postingdate as latest_den_date, ld.carc, ld.remitdescription,  ld.dtc, --p.firstholdreason, p.firstexplicitholdreasondescr, p.currentholdreason, p.currentexplicitholdreasondescr, 
 --p.lastholdreason, p.lastexplicitholdreasondescr,
 
case when aae.campaign is null then 'No' else 'Yes' end as inCampaign,
case when fp.payorno is null then 'No' else 'Yes' end as hasPayResponse,
case when fp.payorno is null and ld.payorno is null then 'No' else 'Yes' end as hasResponse,
case when p.firstbilldate is null then 'No' else 'Yes' end as hasBilled,
case when ld.payorno is null then 'No' else 'Yes' end as hasDenied,

p.icd10diag, p.billingprovidername, p.billingprovidertype, p.billinggrouptaxid, p.isparticipating, --p.renderingprovidername, p.renderingprovidertype, p.responsiblepayorname, p.responisblepayorreportgroup, p.responsiblepayornationalfinancialclass,

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
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end = 3 then '300% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end = 2 then '200% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end = 1 then '100% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end = 1.5 then '150% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end = 1.25 then '125% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end = 2.5 then '250% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end between 4 and 5 then '400-500% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end >= 3 then '301-399% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end >= 2 then '201-299% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end >= 1.6 then '160-199% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end >= 1.02 then '102-159% MED'
     when case when p.allowedamount = 0 and fp.transactionamount > 0 then nvl((fp.transactionamount/med.expected_amount), 0.0) else nvl(p.allowedamount/med.expected_amount,0.0) end >= 0.95 then '~MED'
     else 'Other' end as Pay_Category,
     
case when p.accountkey in (select distinct accountkey from agencyacctextract where campaign='BILLDELAY') then 'BILLDELAY' else null end as campaign_billdelay, first_campaign.campaign, p.billinggrouptaxid, p.billinggroupname
     

from procedure p
left join agencyacctextract aae on p.accountkey = aae.accountkey
left join site_medicare_locality sml on sml.sitekey = p.sitekey
left join medicare_allowable med on med.medicare_locality = sml.locality_number and date_part(year, p.servicedate) = med.year and p.cpt = med.cpt and p.billingprovidertype = med.degree


--Get 1st Pay info
left join (  
select distinct chargekey, 
  first_value(payorno) over (partition by chargekey order by chargekey, postingdate, payorno, payorname, allowedamount  rows between unbounded preceding and unbounded following) as payorno, 
  first_value(payorname) over (partition by chargekey order by chargekey, postingdate, payorno, payorname, allowedamount  rows between unbounded preceding and unbounded following) as payorname,
  first_value(transactionamount) over (partition by chargekey order by chargekey, postingdate, payorno, payorname, allowedamount  rows between unbounded preceding and unbounded following) as transactionamount,
  first_value(postingdate) over (partition by chargekey order by chargekey, postingdate, payorno, payorname, allowedamount rows between unbounded preceding and unbounded following) as postingdate, 
  first_value(allowedamount) over (partition by chargekey order by chargekey, postingdate, payorno, payorname, allowedamount rows between unbounded preceding and unbounded following) as allowedamount,
  first_value(docnum) over (partition by chargekey order by chargekey, postingdate, payorno, payorname, allowedamount rows between unbounded preceding and unbounded following) as docnum
from (select chargekey, payorno, payorname, transactionamount, postingdate, CARC, allowedamount, docnum from payments 
      where (remitclass in ('CASH', 'REFUND') OR carc in ('PA','UC', 'DN','SF', 'PR1', 'PR2', 'PR3', 'CLP', 'VI', 'MC', 'AM', 'FBAL', 'APA')) 
      and (primarypayor=payorno or (payorno='CLP' and remittancesource='835'))
))fp on p.chargekey = fp.chargekey

--Total Primary Insurance Payments
left join (
select chargekey, sum(transactionamount) as total 
from payments where primarypayor = payorno and remitclass in ('CASH', 'REFUND')  OR carc in ('PA','UC', 'DN','SF', 'PR1', 'PR2', 'PR3', 'CLP', 'VI', 'MC', 'AM', 'FBAL', 'APA')
group by chargekey) prim on prim.chargekey = p.chargekey

--total denials
left join (
	select chargekey, count(carc) as total from payments 
	where (primarypayor=payorno or (payorno='CLP' and remittancesource='835'))
	and (remitclass = 'DENIAL' and carc not in('NR60', 'NR120', 'NR180', 'PR1', 'PR2', 'PR3', 'HU', 'HUNC', 'DN'))
	group by chargekey
) denial_counter on denial_counter.chargekey = p.chargekey

--Last Denial
left outer join 
(  
select distinct chargekey,
  last_value(payorno) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname  rows between unbounded preceding and unbounded following) as payorno, 
  last_value(payorname) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname  rows between unbounded preceding and unbounded following) as payorname,
  last_value(postingdate) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname rows between unbounded preceding and unbounded following) as postingdate,
  last_value(carc) over (partition by chargekey order by chargekey,postingdate, payorkey, payorno, payorname rows between unbounded preceding and unbounded following) as carc,
  last_value(denialtrackingcategory) over (partition by chargekey,postingdate, payorkey, payorno, payorname rows between unbounded preceding and unbounded following) as dtc,
  last_value(remitdescription) over (partition by chargekey order by chargekey, postingdate, payorkey, payorno, payorname rows between unbounded preceding and unbounded following) as remitdescription
  from (select chargekey, payorkey, payorno, payorname, postingdate, carc, remitdescription, denialtrackingcategory from payments 
  join carc_master on carc_master.remitno = payments.carc 
  where (remitclass = 'DENIAL' and carc not in('NR60', 'NR120', 'NR180', 'PR1', 'PR2', 'PR3', 'HU', 'HUNC', 'DN'))
  and (primarypayor = payorno or (payorno='CLP' and remittancesource='835'))
)) ld on p.chargekey = ld.chargekey 

--total transactions
left join (
	select chargekey, count(carc) as total from payments
	where (primarypayor=payorno or (payorno='CLP' and remittancesource='835'))
	and (remitclass in ('CASH', 'REFUND') OR carc in ('PA','UC', 'DN','SF', 'PR1', 'PR2', 'PR3', 'CLP', 'VI', 'MC', 'AM', 'FBAL', 'APA'))
	group by chargekey
) pay_counter on pay_counter.chargekey = p.chargekey 
	
--Get 50th Percentile Rates by Practice
left join (
    select billingprovidertype, cpt, practice, date_part(month, servicedate) as dos_month, date_part(year, servicedate) as dos_year, firstpayor, percentile_cont(0.5) within group (order by allowedamount) as percentile
    from procedure
    group by billingprovidertype, cpt, practice, date_part(month, servicedate), date_part(year, servicedate), firstpayor
  ) percentile_compare on (p.practice = percentile_compare.practice and p.billingprovidertype = percentile_compare.billingprovidertype and p.firstpayor = percentile_compare.firstpayor and percentile_compare.dos_month = date_part(month, p.servicedate) 
  and percentile_compare.dos_year = date_part(year, p.servicedate) and p.cpt = percentile_compare.cpt)

--Get 50th Percentile Rates by locality
left join (
    select p.billingprovidertype, p.cpt, sml.locality_number, date_part(month, p.servicedate) as dos_month, date_part(year, p.servicedate) as dos_year, p.firstpayor, percentile_cont(0.5) within group (order by p.allowedamount) as percentile_by_locality
    from procedure p
    join site_medicare_locality sml on sml.sitekey = p.sitekey
  group by p.billingprovidertype, p.cpt, sml.locality_number, date_part(month, p.servicedate), date_part(year, p.servicedate), p.firstpayor
  ) percentile_compare_loc on (sml.locality_number = percentile_compare_loc.locality_number and p.billingprovidertype = percentile_compare_loc.billingprovidertype and p.firstpayor = percentile_compare_loc.firstpayor and percentile_compare_loc.dos_month = date_part(month, p.servicedate) 
  and percentile_compare_loc.dos_year = date_part(year, p.servicedate) and p.cpt = percentile_compare_loc.cpt)
  

--Get first campaign
left join (
  select distinct accountkey,
  first_value(startdate) over (partition by accountkey order by accountkey, startdate, campaign, campaigndescription  rows between unbounded preceding and unbounded following) as startdate,  
  first_value(campaign) over (partition by accountkey order by accountkey, startdate, campaign, campaigndescription  rows between unbounded preceding and unbounded following) as campaign,
  first_value(campaigndescription) over (partition by accountkey order by accountkey, startdate, campaign, campaigndescription  rows between unbounded preceding and unbounded following) as campaigndescription 
  from (select accountkey, startdate, campaign,campaigndescription from agencyacctextract where campaign not like '%HRI%'  and campaign not in ( 'BILLDELAY', 'GEBBSAR360', 'MVASB', 'MMSBP1', 'SIMPLEE', 'MCDDISC') 
  and campaign not like '%P2P%' 
  and campaigndescription not like '%CREDENCE%'
  order by accountkey, startdate, campaign
)) first_campaign on first_campaign.accountkey = p.accountkey



where --UPPER(p.isparticipating) = 'NO'
datediff(month, p.servicedate, current_date) <= 12
--and p.primarypayornationalfinancialclass = 'BLU'
--p.servicedate between '2019-01-01'  and '2019-12-31'
--and p.primarypayornationalfinancialclass in ('CHA')
--and p.primarypayornationalfinancialclass in ('AETNA', 'BCROS', 'BLU', 'BLUEX', 'CIGNA', 'COM', 'COMEX', 'HMO', 'HMOEX', 'GOV', 'HUMANA', 'WOR', 'MVA')
--and sml.locality_number = 'FL-99'
and p.primarypayorreportgroup = 'CIG' --and p.billingprovidertype <> 'MD'
--and p.cptclass = 'Exam'
--and p.primarypayorreportgroup not in ('WOR')
--and fp.allowedamount in (74.98, 142.3, 209.56)
--and p.isparticipating = 'no'
--and p.cpt = 93010
--and p.billingprovidertype = 'PA'
--and p.firstpayor in ('NTHP')
--and p.firstpayor like '%HEE%'
--and p.primarypayorname like '%HUMANA%'
and p.grosscharges > 0
and p.billinggrouptaxid in (752684562, 581920755, 581943417, 475053353, 474833253, 611770552, 475108462, 262492386, 262307339, 474980349, 475119624, 474943712, 203512079, 475641516, 471352316, 200625450, 474988411, 811656824, 
263656680, 810907539, 20657245, 474927651, 384022762, 271409294, 200463397, 463957733, 474898274, 260706037, 471383037, 812881206)
--and hasPayResponse = 'Yes'
--and p.billingprovidername like '%CULEN%'
--and hasDenied = 'Denied'
--and  p.primarypayorname like '%MEDCOST%'
and (p.adjustment is null or adjustment = 'Replacement')






