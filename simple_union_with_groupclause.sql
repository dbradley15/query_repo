select '360+ days' as category, date_part(month, postingdate) as month, sum(transactionamount) as total from payments where datediff(days, servicedate, current_date) >= 360 and postingdate between '2019-03-01' and '2019-05-31' and remitclass = 'CASH'
group by date_part(month, postingdate)
union
select  '0-360 days' as category, date_part(month, postingdate) as month, sum(transactionamount) as total from payments where datediff(days, servicedate, current_date) < 360 and postingdate between '2019-03-01' and '2019-05-31' and remitclass = 'CASH'
group by date_part(month, postingdate)









