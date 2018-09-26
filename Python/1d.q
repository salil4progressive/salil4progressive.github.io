DROP TABLE IF EXISTS Oshkosh;
CREATE EXTERNAL TABLE IF NOT EXISTS Oshkosh(Year Int, Month Int, Day Int, TimeCst String, tempf Float, DewPointF String, Humidity String, SLP String, VisMPH String, WindDir String, WindSpeed String, Gust String, Precipitate String, Events String, Conditions String, WindDD String) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/home/ubuntu/final/Oshkosh/';
drop view if exists OshkoshF;
create view OshkoshF as
select 
--cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') 
--as timestamp) as dttc,
timecst, 
cast(to_date(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day),'yyyy-MM-dd'))) as date)as dtc,
hour(cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') as timestamp)) as hower,
--substr(timecst,0,2) as hower,
LTRIM(substr(timecst,6,3)) as ampm,
tempf, Month, Year, Day
 from Oshkosh where tempf > -100;



select 
hower, ampm
from
(
select *,dense_rank() over( order by z.rct desc ) as therank
 from ( 
  select count(*)as rct, hower, ampm from 
  (select *, dense_rank() over(partition by x.dtc order by avgtemp asc ) as therank
   from
(


select
 avg(tempf) as avgtemp, 
hower, ampm,
 dtc
,'Oshkosh' as City 
from OshkoshF

group by 
hower, ampm, dtc
)x
)y
where y.therank = 1 
group by hower, ampm

)z
)s
where s.therank = 1 




