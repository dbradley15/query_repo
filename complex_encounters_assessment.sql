select distinct e.encounterkey, e.practice, e.siteservice, e.grosscharges as fee, e.primarypayorreportgroup, e.primarypayorlocalfinancialclass, e.primarypayornationalfinancialclass, e.servicedate, date_part(year, e.servicedate) as year, 
e.netcash, alt_netcash.netcash2, aae.campaign, pp.patient_pay, (e.netcash - nvl(pp.patient_pay,0.0)) as inspaid, ( nvl(alt_netcash.netcash2,0) - nvl(pp.patient_pay, 0)) as inspaid2, e.netcash - nvl(nonPrimaryPay.transactionamount,0) as pay_without_nonprimary, e.grosscharges - e.contractualallowance as allowed_via_contractual,

case when date_part(year, e.servicedate) = 2018 then netcash_2018.netcash_2018 else e.netcash end as netcash_adjusted,
case when date_part(year, e.servicedate) = 2018 then (netcash_2018.netcash_2018 - nvl(pp2018.patient_pay, 0.0)) else (e.netcash - nvl(pp.patient_pay,0)) end as inspaid_adjusted,

case when aae.campaign is not null then 'Yes' else 'No' end as inCampaign,
case when e.netcash > 0 then 'PAID' else 'UNPAID' end as isPaid,
case when e.primarypayorkey <> e.responsiblepayorkey then 'Transfered' else 'Primary' end as currentPayor,
case when totals.allowed = 0 and totals.firstpayorpaid > 0 then totals.firstpayorpaid else totals.allowed end as allowed_adjusted,
case when date_part(year, e.servicedate) = 2019 and aae.campaign is null then 'No' else 'Yes' end as shouldCompare,
billingDOS.billingDOS, e.participating, totals.grosscharges, totals.allowed, totals.firstpayorpaid, nonPrimaryPay.transactionamount as NonPrimaryTotal

from encounter e
join procedure p on p.encounterkey = e.encounterkey
left outer join agencyacctextract aae on aae.accountkey = e.accountkey and (campaigndescription = 'BILLING DELAY FOR DEDUCTIBLE MITIGATION')

--single bill date
left outer join(
select encounterkey, first_value(firstbilldate) over (partition by encounterkey order by firstbilldate rows between unbounded preceding and unbounded following) as billingDOS
from procedure where (adjustment is null or adjustment = 'Replacement')) as billingDOS on billingDOS.encounterkey = e.encounterkey

--Combine gross charges, allowed amount, and first payor paid (to put a value when allowed = $0)
left outer join (
select encounterkey, sum(grosscharges) grosscharges, sum(allowedamount) allowed, sum(firstpayorpaid) firstpayorpaid from procedure 
where (adjustment is null or adjustment = 'Replacement') group by encounterkey) totals on totals.encounterkey = e.encounterkey

--Patient Payments
left outer join(
select encounterkey, sum(transactionamount) patient_pay from payments where payorno in('PER','COL','CHECK','MCARD','DISC','AMEX','VISA') and 
remitclass in('CASH', 'REFUND') group by encounterkey) pp on pp.encounterkey = e.encounterkey

--Patient Payments 2018 - cutoff payments 1 year prior to current date
left outer join(
select encounterkey, sum(transactionamount) patient_pay from payments where payorno in('PER','COL','CHECK','MCARD','DISC','AMEX','VISA') and 
remitclass in('CASH', 'REFUND') and datediff(days, postingdate, current_date) >= 365 group by encounterkey) pp2018 on pp2018.encounterkey = e.encounterkey

--Alternate Netcash
left outer join(
select encounterkey, sum(transactionamount) netcash2 from payments where remitclass in ('CASH', 'REFUND') group by encounterkey) alt_netcash on alt_netcash.encounterkey = e.encounterkey

--Alternate Netcash for 2018
left outer join(
select encounterkey, sum(transactionamount) netcash_2018 from payments where remitclass in ('CASH', 'REFUND') and datediff(days, postingdate, current_date) >= 365 group by encounterkey) netcash_2018 on netcash_2018.encounterkey = e.encounterkey


--NonPrimary Pay
left outer join(
select encounterkey, sum(transactionamount) transactionamount from payments where remitclass in ('CASH', 'REFUND') and payornationalfinancialclass <> primarypayornationalfinancialclass group by encounterkey) nonPrimaryPay on p.encounterkey = nonPrimaryPay.encounterkey

where --((e.servicedate >= '2018-01-01' and datediff(days, e.servicedate, current_date) >= 425) or  e.servicedate between '2019-01-01' and current_date)
e.servicedate between '2019-01-01' and current_date
and (p.firstbilldate is not null and p.servicedate  < p.firstbilldate and datediff(days, p.firstbilldate, current_date) >= 60)
and e.operationalunit <> 'RTI' and e.operationalunit not like '%MSA%' 
and (p.adjustment is null or p.adjustment = 'Replacement')
and e.primarypayornationalfinancialclass in ('MNGCR','BLU','BLUEX','BCROSS','AETNA','HUMANA','UNH','CIGNA','COM')
--and aae.campaigndescription = 'BILLING DELAY FOR DEDUCTIBLE MITIGATION'
