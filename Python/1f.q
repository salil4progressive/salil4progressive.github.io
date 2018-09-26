DROP TABLE IF EXISTS Oshkosh;
CREATE EXTERNAL TABLE IF NOT EXISTS Oshkosh(Year Int, Month Int, Day Int, TimeCst String, tempf Float, DewPointF String, Humidity String, SLP String, VisMPH String, WindDir String, WindSpeed String, Gust String, Precipitate String, Events String, Conditions String, WindDD String) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/home/ubuntu/final/Oshkosh/';

DROP TABLE IF EXISTS Iowa;
CREATE EXTERNAL TABLE IF NOT EXISTS Iowa(Year String, Month Int, Day String, TimeCst String, tempf Float, DewPointF String, Humidity String, SLP String, VisMPH String, WindDir String, WindSpeed String, Gust String, Precipitate String, Events String, Conditions String, WindDD String) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/home/ubuntu/final/IowaCity/';

drop view if exists OshkoshF;
create view OshkoshF as
select 
hour(cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') as timestamp)) as hower,
LTRIM(substr(timecst,6,3)) as ampm,
tempf, Month
from Oshkosh where tempf > -100;

drop view if exists IowaF;
create view IowaF as
select 
hour(cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') as timestamp)) as hower,
LTRIM(substr(timecst,6,3)) as ampm,
tempf, Month
from Iowa where tempf > -100
and timecst <> 'No daily or hourly history data available';

drop view if exists OshkoshW;
create view OshkoshW as
select 
hour(cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') as timestamp)) as hower,
LTRIM(substr(timecst,6,3)) as ampm,
Month, cast(WindSpeed as float) WindSpeed
from Oshkosh where Windspeed <> '-9999' and Windspeed <> 'Calm';

drop view if exists IowaW;
create view IowaW as
select 
hour(cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') as timestamp)) as hower,
LTRIM(substr(timecst,6,3)) as ampm,
Month, cast(WindSpeed as float) WindSpeed
from Iowa where timecst <> 'No daily or hourly history data available'
and Windspeed <> '-9999' and Windspeed <> 'Calm';;


select  z.month, z.city, case when z.hower > 12 then z.hower - 12 when z.hower = 0 then 12 else z.hower end , z.ampm from 
(select 

y.Month, y.Hower, y.ampm, y.City, dense_rank() over(partition by y.Month order by y.metric asc, wind.avgwind asc) as therank

from
  ---Groupings y
  (

  select 
  avg(tempf) as avgtemp, 
  --abs(avg(tempf)-50) as metric,
abs((sum(tempf)/count(tempf))-50) as metric,
Hower,
ampm,
 Month, City
from
--Unioned Data
(select hower,ampm,tempf, Month, 'Iowa' as City from
 IowaF

union
select hower,ampm,tempf, Month, 'Oshkosh' as City from
OshkoshF
)x
group by 
Hower,
ampm,
 Month, City
 )y

 inner join 
 --wind
 (
  --Group Part
  select 
  avg(WindSpeed) as avgwind, 

Hower,
ampm,
 Month, City


from
--Data Unioned
(

select hower, ampm, month,  windspeed, 'Oshkosh' as City from OshkoshW 
union

select hower, ampm, month, windspeed, 'Iowa' as City  from IowaW 


)blah
group by 
Hower,
ampm,
 Month, City
)wind
on wind.ampm = y.ampm 
and wind.city = y.City
and wind.month = y.Month
and wind.hower = y.Hower
 )z
 where z.therank = 1 
order by z.month asc
