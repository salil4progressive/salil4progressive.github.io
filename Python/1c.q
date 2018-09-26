
DROP TABLE IF EXISTS Oshkosh;
CREATE EXTERNAL TABLE IF NOT EXISTS Oshkosh(Year Int, Month Int, Day Int, TimeCst String, tempf Float, DewPointF String, Humidity String, SLP String, VisMPH String, WindDir String, WindSpeed String, Gust String, Precipitate String, Events String, Conditions String, WindDD String) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/home/ubuntu/final/Oshkosh/';

drop view if exists OshkoshF;
create view OshkoshF as
select cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') as timestamp) as dttc,
timecst, 
cast(to_date(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day),'yyyy-MM-dd'))) as date)as dtc,
substr(timecst,0,2) as hour,tempf
 from Oshkosh where tempf > -100;


select startday, sevweekavg, therank from
(select
startday,
sevweekavg,
rank() over (order by sevweekavg desc) as therank 
from 
(
SELECT 

sum(SumTemp)/sum(CountTemp) as sevweekavg,
startday

FROM
(

SELECT * FROM 
(select 


dtc as startday

 from 
OshkoshF a

GROUP BY dtc

)X
INNER JOIN
 (select 

SUM(tempf)  AS SumTemp,
COUNT(tempf)  AS CountTemp,
dtc as dayingroup

 from 
OshkoshF a
where tempf > -40

GROUP BY dtc

)Y
ON 1 =1 
--where datediff(x.startday,y.dayingroup) >= 1 AND datediff(x.startday,y.dayingroup) <= 7 
where datediff(y.dayingroup,x.startday) >= 1 AND datediff(y.dayingroup,x.startday) <= 7 

)Z

group by z.startday

)x)q
where q.therank =1
order by therank desc



