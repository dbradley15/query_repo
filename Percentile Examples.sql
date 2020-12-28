
--Percentile Example    
select sum(allowedamount), date_part(month, servicedate) as month, approximate percentile_disc(0.5) within group (order by allowedamount)
 from procedure where firstpayor = 'USH' and servicedate between '2018-01-01' and '2018-03-31' and cpt = 99285
 group by  date_part(month, servicedate)
 

select sum(allowedamount), date_part(month, servicedate) as month, approximate percentile_disc(0.5) within group (order by allowedamount), count(chargekey)
 from procedure where firstpayor like '%CIG%' and servicedate between '2018-01-01' and '2018-03-31' and cpt = 99285 and practice = 'FRE'
 group by   date_part(month, servicedate)
 

select  sum(allowedamount), date_part(month, servicedate) as month, percentile_cont(0.5) within group (order by allowedamount), count(chargekey)
 from procedure join site_medicare_locality sml on sml.sitekey = procedure.sitekey where primarypayorreportgroup like '%AET%' and servicedate between '2018-01-01' and '2018-03-31' and cpt = 99283 and locality_number = 'FL-99'
 group by   date_part(month, servicedate)
