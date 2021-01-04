--ED CPT
select count(distinct chargekey) , cpt, servicedate, locationstate,operationalunit, 
case 
 when servicedate < '3/1/2020' then 'Feb'
when servicedate < '3/8/2020' then 'March week 1'
when servicedate < '3/15/2020' then 'March week 2'
when servicedate < '3/22/2020' then 'March week 3'
when servicedate < '3/29/2020' then 'March week 4'
when servicedate < '4/5/2020' then 'April week 1'
when servicedate < '4/12/2020' then 'April week 2'
when servicedate < '4/19/2020' then 'April week 3'
when servicedate < '4/26/2020' then 'April week 4'
when servicedate < '5/3/2020' then 'April week 5'
when servicedate < '5/10/2020' then 'May week 1'
when servicedate < '5/17/2020' then 'May week 2'
when servicedate < '5/24/2020' then 'May week 3'
when servicedate < '5/31/2020' then 'May week 4'
when servicedate < '6/7/2020' then 'June week 1'
when servicedate < '6/14/2020' then 'June week 2'
when servicedate < '6/21/2020' then 'June week 3'
when servicedate < '6/28/2020' then 'June week 4'
when servicedate < '7/5/2020' then 'June week 5'
when servicedate < '7/12/2020' then 'July week 1'
when servicedate < '7/19/2020' then 'July week 2'
when servicedate < '7/26/2020' then 'July week 3'
when servicedate < '8/2/2020' then 'July week 4'
when servicedate < '8/9/2020' then 'August week 1'
when servicedate < '8/16/2020' then 'August week 2'
when servicedate < '8/23/2020' then 'August week 3'
when servicedate < '8/30/2020' then 'August week 4'
when servicedate < '9/6/2020' then 'Sept week 1'
when servicedate < '9/13/2020' then 'Sept week 2'
when servicedate < '9/20/2020' then 'Sept week 3'
when servicedate < '9/27/2020' then 'Sept week 4'
when servicedate < '10/4/2020' then 'Sept week 5'
when servicedate < '10/11/2020' then 'Oct week 1'
when servicedate < '10/18/2020' then 'Oct week 2'
when servicedate < '10/25/2020' then 'Oct week 3'
when servicedate < '11/1/2020' then 'Oct week 4'
when servicedate < '11/8/2020' then 'Nov week 1'
when servicedate < '11/15/2020' then 'Nov week 2'
when servicedate < '11/22/2020' then 'Nov week 3'
when servicedate < '11/29/2020' then 'Nov week 4'
when servicedate < '12/6/2020' then 'Dec week 1'
when servicedate < '12/13/2020' then 'Dec week 2'
when servicedate < '12/20/2020' then 'Dec week 3'
when servicedate < '12/27/2020' then 'Dec week 4'

else 'unk'
end  as servicewindow 
from procedure where
cpt in ('99281','99282','99283','99284','99285','99291') and
  not( emcaredivision  = 'RTI' or emcaredivision  like '%MSA%') and
  siteservice in ('ED') and servicedate >= '2/1/2020' and servicedate < current_date
  group by cpt, servicedate, locationstate, operationalunit;

  
--IPS CPT
select count(distinct chargekey) , cpt, servicedate, locationstate,operationalunit,
case 
 when servicedate < '3/1/2020' then 'Feb'
when servicedate < '3/8/2020' then 'March week 1'
when servicedate < '3/15/2020' then 'March week 2'
when servicedate < '3/22/2020' then 'March week 3'
when servicedate < '3/29/2020' then 'March week 4'
when servicedate < '4/5/2020' then 'April week 1'
when servicedate < '4/12/2020' then 'April week 2'
when servicedate < '4/19/2020' then 'April week 3'
when servicedate < '4/26/2020' then 'April week 4'
when servicedate < '5/3/2020' then 'April week 5'
when servicedate < '5/10/2020' then 'May week 1'
when servicedate < '5/17/2020' then 'May week 2'
when servicedate < '5/24/2020' then 'May week 3'
when servicedate < '5/31/2020' then 'May week 4'
when servicedate < '6/7/2020' then 'June week 1'
when servicedate < '6/14/2020' then 'June week 2'
when servicedate < '6/21/2020' then 'June week 3'
when servicedate < '6/28/2020' then 'June week 4'
when servicedate < '7/5/2020' then 'June week 5'
when servicedate < '7/12/2020' then 'July week 1'
when servicedate < '7/19/2020' then 'July week 2'
when servicedate < '7/26/2020' then 'July week 3'
when servicedate < '8/2/2020' then 'July week 4'
when servicedate < '8/9/2020' then 'August week 1'
when servicedate < '8/16/2020' then 'August week 2'
when servicedate < '8/23/2020' then 'August week 3'
when servicedate < '8/30/2020' then 'August week 4'
when servicedate < '9/6/2020' then 'Sept week 1'
when servicedate < '9/13/2020' then 'Sept week 2'
when servicedate < '9/20/2020' then 'Sept week 3'
when servicedate < '9/27/2020' then 'Sept week 4'
when servicedate < '10/4/2020' then 'Sept week 5'
when servicedate < '10/11/2020' then 'Oct week 1'
when servicedate < '10/18/2020' then 'Oct week 2'
when servicedate < '10/25/2020' then 'Oct week 3'
when servicedate < '11/1/2020' then 'Oct week 4'
when servicedate < '11/8/2020' then 'Nov week 1'
when servicedate < '11/15/2020' then 'Nov week 2'
when servicedate < '11/22/2020' then 'Nov week 3'
when servicedate < '11/29/2020' then 'Nov week 4'
when servicedate < '12/6/2020' then 'Dec week 1'
when servicedate < '12/13/2020' then 'Dec week 2'
when servicedate < '12/20/2020' then 'Dec week 3'
when servicedate < '12/27/2020' then 'Dec week 4'
else 'unk'
end  as servicewindow 
from procedure where
cpt in ('99221', '99222', '99223', '99231', '99232', '99233') and
  not( emcaredivision  = 'RTI' or emcaredivision  like '%MSA%') and
  siteservice in ('IPS') and servicedate >= '2/1/2020' and servicedate < current_date
  group by cpt, servicedate, locationstate, operationalunit;
  


--ED RVU
select count(distinct accountkey) as "Patients" , sum(procedure.totalrvu) as "RVUS", sum(procedure.totalrvu)/ count(distinct accountkey) as "Avg RVUS", servicedate, locationstate,operationalunit,
case 
  when servicedate < '3/1/2020' then 'Feb'
when servicedate < '3/8/2020' then 'March week 1'
when servicedate < '3/15/2020' then 'March week 2'
when servicedate < '3/22/2020' then 'March week 3'
when servicedate < '3/29/2020' then 'March week 4'
when servicedate < '4/5/2020' then 'April week 1'
when servicedate < '4/12/2020' then 'April week 2'
when servicedate < '4/19/2020' then 'April week 3'
when servicedate < '4/26/2020' then 'April week 4'
when servicedate < '5/3/2020' then 'April week 5'
when servicedate < '5/10/2020' then 'May week 1'
when servicedate < '5/17/2020' then 'May week 2'
when servicedate < '5/24/2020' then 'May week 3'
when servicedate < '5/31/2020' then 'May week 4'
when servicedate < '6/7/2020' then 'June week 1'
when servicedate < '6/14/2020' then 'June week 2'
when servicedate < '6/21/2020' then 'June week 3'
when servicedate < '6/28/2020' then 'June week 4'
when servicedate < '7/5/2020' then 'June week 5'
when servicedate < '7/12/2020' then 'July week 1'
when servicedate < '7/19/2020' then 'July week 2'
when servicedate < '7/26/2020' then 'July week 3'
when servicedate < '8/2/2020' then 'July week 4'
when servicedate < '8/9/2020' then 'August week 1'
when servicedate < '8/16/2020' then 'August week 2'
when servicedate < '8/23/2020' then 'August week 3'
when servicedate < '8/30/2020' then 'August week 4'
when servicedate < '9/6/2020' then 'Sept week 1'
when servicedate < '9/13/2020' then 'Sept week 2'
when servicedate < '9/20/2020' then 'Sept week 3'
when servicedate < '9/27/2020' then 'Sept week 4'
when servicedate < '10/4/2020' then 'Sept week 5'
when servicedate < '10/11/2020' then 'Oct week 1'
when servicedate < '10/18/2020' then 'Oct week 2'
when servicedate < '10/25/2020' then 'Oct week 3'
when servicedate < '11/1/2020' then 'Oct week 4'
when servicedate < '11/8/2020' then 'Nov week 1'
when servicedate < '11/15/2020' then 'Nov week 2'
when servicedate < '11/22/2020' then 'Nov week 3'
when servicedate < '11/29/2020' then 'Nov week 4'
when servicedate < '12/6/2020' then 'Dec week 1'
when servicedate < '12/13/2020' then 'Dec week 2'
when servicedate < '12/20/2020' then 'Dec week 3'
when servicedate < '12/27/2020' then 'Dec week 4'
else 'unk'
end  as servicewindow 
from procedure where
  not( emcaredivision  = 'RTI' or emcaredivision  like '%MSA%')
 --and cpt in ('99221', '99222', '99223', '99231', '99232', '99233') 
  and siteservice in ('ED') and servicedate >= '2/1/2020' and servicedate < current_date
  group by  servicedate, locationstate, operationalunit;
  

--IPS RVU
select count(distinct accountkey) as "Patients" , sum(procedure.totalrvu) as "RVUS", sum(procedure.totalrvu)/ count(distinct accountkey) as "Avg RVUS", servicedate, locationstate,operationalunit,
case 
  when servicedate < '3/1/2020' then 'Feb'
when servicedate < '3/8/2020' then 'March week 1'
when servicedate < '3/15/2020' then 'March week 2'
when servicedate < '3/22/2020' then 'March week 3'
when servicedate < '3/29/2020' then 'March week 4'
when servicedate < '4/5/2020' then 'April week 1'
when servicedate < '4/12/2020' then 'April week 2'
when servicedate < '4/19/2020' then 'April week 3'
when servicedate < '4/26/2020' then 'April week 4'
when servicedate < '5/3/2020' then 'April week 5'
when servicedate < '5/10/2020' then 'May week 1'
when servicedate < '5/17/2020' then 'May week 2'
when servicedate < '5/24/2020' then 'May week 3'
when servicedate < '5/31/2020' then 'May week 4'
when servicedate < '6/7/2020' then 'June week 1'
when servicedate < '6/14/2020' then 'June week 2'
when servicedate < '6/21/2020' then 'June week 3'
when servicedate < '6/28/2020' then 'June week 4'
when servicedate < '7/5/2020' then 'June week 5'
when servicedate < '7/12/2020' then 'July week 1'
when servicedate < '7/19/2020' then 'July week 2'
when servicedate < '7/26/2020' then 'July week 3'
when servicedate < '8/2/2020' then 'July week 4'
when servicedate < '8/9/2020' then 'August week 1'
when servicedate < '8/16/2020' then 'August week 2'
when servicedate < '8/23/2020' then 'August week 3'
when servicedate < '8/30/2020' then 'August week 4'
when servicedate < '9/6/2020' then 'Sept week 1'
when servicedate < '9/13/2020' then 'Sept week 2'
when servicedate < '9/20/2020' then 'Sept week 3'
when servicedate < '9/27/2020' then 'Sept week 4'
when servicedate < '10/4/2020' then 'Sept week 5'
when servicedate < '10/11/2020' then 'Oct week 1'
when servicedate < '10/18/2020' then 'Oct week 2'
when servicedate < '10/25/2020' then 'Oct week 3'
when servicedate < '11/1/2020' then 'Oct week 4'
when servicedate < '11/8/2020' then 'Nov week 1'
when servicedate < '11/15/2020' then 'Nov week 2'
when servicedate < '11/22/2020' then 'Nov week 3'
when servicedate < '11/29/2020' then 'Nov week 4'
when servicedate < '12/6/2020' then 'Dec week 1'
when servicedate < '12/13/2020' then 'Dec week 2'
when servicedate < '12/20/2020' then 'Dec week 3'
when servicedate < '12/27/2020' then 'Dec week 4'
else 'unk'
end  as servicewindow 
from procedure where
  not( emcaredivision  = 'RTI' or emcaredivision  like '%MSA%')
 and cpt in ('99221', '99222', '99223', '99231', '99232', '99233') 
  and siteservice in ('IPS') and servicedate >= '2/1/2020' and servicedate < current_date
  group by  servicedate, locationstate, operationalunit;
  









