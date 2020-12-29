select p.practice, p.practicedivision, p.chargekey, p.accountkey, p.encounterkey, p.siteservice, p.locationstate, p.servicedate, p.modifier1, p.modifier2, p.grosscharges, p.contractualallowance, p.firstpayor, p.duefrompayor, p.firstbilldate, p.cpt, p.cptclass, p.icd10diag, 
p.billingprovidername, p.billingprovidertype, p.originalprimarypayornationalfinclass, p.originalfirstpayor, p.primarypayornationalfinancialclass, p.primarypayorlocalfinancialclass, 

case when p.primarypayornationalfinancialclass in ('AETNA', 'CIGNA', 'UHC') then p.primarypayorlocalfinancialclass
else p.primarypayornationalfinancialclass end as nat_fin_class, 

case when fp.payorNFC in ('AETNA', 'CIGNA', 'UHC') then fp.payorLFC
else fp.payorNFC end as paid_nat_fin_class,

p.responsiblepayornationalfinancialclass, p.balance, p.isparticipating, sec.payorno as secondary, third.payorno as tertiary, p.operationalunit,
p.netcash, fp.payorno, fp.payorNFC, fp.payorLFC, fp.transactionamount, fp.allowedamount, fp.postingdate, fp.docnum, fm.payorno as firstmarker_payor, fm.payornfc as firstmarker_nfc, fm.postingdate as firstmarker_postingdate,
fm.carc as firstmarker_carc,  fm.remitdescription, lm.payorno as lastmarker_payor, lm.payornfc as lastmarker_nfc, lm.postingdate as lastmarker_postingdate,
lm.carc as lastmarker_carc,  lm.remitdescription as lastmarkerdesc,

currentholdreason, currentexplicitholdreasondescr,

case when (icd10diag like '%B342%' 
     or icd10diag like '%B9729%'
     or icd10diag like '%J029%'
     or icd10diag like '%J1289%'
     or icd10diag like '%J208%'
     or icd10diag like '%J22%'
     or icd10diag like '%J40%'
     or icd10diag like '%J80%'
     or icd10diag like '%J988%'
     or icd10diag like '%M7910%'
     or icd10diag like '%M7918%'
     or icd10diag like '%R05%'
     or icd10diag like '%R0602%'
     or icd10diag like '%R197%'
     or icd10diag like '%R430%'
     or icd10diag like '%R432%'
     or icd10diag like '%R509%'
     or icd10diag like '%R51%'
     or icd10diag like '%R6883%'
     or icd10diag like '%U071%'
     or icd10diag like '%Z03818%'
     or icd10diag like '%Z1159%'
     or icd10diag like '%Z20828%')
     --and (p.originalfirstpayor in ('CV2ND', 'NC2ND', 'CVPER', 'NCPER', 'UNICO') 
   -- or p.firstpayor in ('CV2ND', 'NC2ND', 'CVPER', 'NCPER', 'UNICO') 
   -- or sec.payorname in ('CV2ND', 'NC2ND', 'CVPER', 'NCPER', 'UNICO'))
  then 'Yes'
  else 'No' end as ConfirmCOVID,
case when fp.allowedamount is null then 'No' else 'Yes' end as hasPaid,
case when p.firstbilldate is null then 'No' else 'Yes' end as hasBilled,
case when upper(p.currentexplicitholdreasondescr) like '%COVID%' then 'Yes' else 'No' end as hasCovidHold,
covid_claim.cpt as cv_cpt




from procedure p
left join payor_master sec on sec.payorkey = p.secondarypayorkey
left join payor_master third on third.payorkey = p.tertiarypayorkey

join(
select distinct accountkey, cpt, servicedate from procedure where cpt in ('BP005X1', 'BP005X2', 'BP005X3')
)covid_claim on covid_claim.accountkey = p.accountkey and p.servicedate = covid_claim.servicedate

--Get 1st Pay info
left join (  
select distinct chargekey, 
  first_value(payorno) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorfinancialclass,payorno, allowedamount, transactionamount, docnum  rows between unbounded preceding and unbounded following) as payorno, 
  first_value(payornationalfinancialclass) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass,payorfinancialclass, payorno, allowedamount, transactionamount, docnum  rows between unbounded preceding and unbounded following) as payorNFC,
  first_value(payorfinancialclass) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass,payorfinancialclass, payorno, allowedamount, transactionamount, docnum  rows between unbounded preceding and unbounded following) as payorLFC,
  first_value(transactionamount) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass,payorfinancialclass, payorno, allowedamount, transactionamount, docnum  rows between unbounded preceding and unbounded following) as transactionamount,
  first_value(postingdate) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass,payorfinancialclass, payorno, allowedamount, transactionamount, docnum  rows between unbounded preceding and unbounded following) as postingdate, 
  first_value(allowedamount) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass,payorfinancialclass, payorno, allowedamount, transactionamount, docnum  rows between unbounded preceding and unbounded following) as allowedamount,
  first_value(docnum) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass,payorfinancialclass, payorno, allowedamount, transactionamount, docnum  rows between unbounded preceding and unbounded following) as docnum
from (select chargekey, payorno, payornationalfinancialclass, payorfinancialclass,transactionamount, postingdate, allowedamount, docnum from payments 
      where (remitclass in ('CASH') OR carc in ('PA','UC', 'DN','SF', 'PR1', 'PR2', 'PR3', 'CLP', 'VI', 'MC', 'AM', 'FBAL', 'APA')) 
))fp on p.chargekey = fp.chargekey


--Last Marker
left outer join 
(  
select distinct chargekey,
  last_value(payorno) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as payorno, 
  last_value(payornationalfinancialclass) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as payornfc,
  last_value(postingdate) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following)as postingdate,
  last_value(carc) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as carc,
  last_value(denialtrackingcategory) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as dtc,
  last_value(remitdescription) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as remitdescription,
  last_value(docnum) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as docnum
  from (select chargekey, payorno, payornationalfinancialclass, postingdate, denialtrackingcategory, carc, docnum, remitdescription from payments 
  left join carc_master on carc_master.remitno = payments.carc 
  where (remitclass = 'MARKER')
)) lm on p.chargekey = lm.chargekey  

--First Marker
left outer join 
(  
select distinct chargekey,
  first_value(payorno) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as payorno, 
  first_value(payornationalfinancialclass) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as payornfc,
  first_value(postingdate) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following)as postingdate,
  first_value(carc) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as carc,
  first_value(denialtrackingcategory) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as dtc,
  first_value(remitdescription) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as remitdescription,
  first_value(docnum) over (partition by chargekey order by chargekey, postingdate, payornationalfinancialclass, payorno, docnum, denialtrackingcategory, carc  rows between unbounded preceding and unbounded following) as docnum
  from (select chargekey, payorno, payornationalfinancialclass, postingdate, denialtrackingcategory, carc, docnum, remitdescription from payments 
  left join carc_master on carc_master.remitno = payments.carc 
  where (remitclass = 'MARKER')
)) fm on p.chargekey = fm.chargekey  


where (p.adjustment is null or adjustment = 'Replacement')

limit 10
