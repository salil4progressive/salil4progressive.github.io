DROP TABLE IF EXISTS Oshkosh;
CREATE EXTERNAL TABLE IF NOT EXISTS Oshkosh(Year Int, Month Int, Day Int, TimeCst String, tempf Float, DewPointF String, Humidity String, SLP String, VisMPH String, WindDir String, WindSpeed String, Gust String, Precipitate String, Events String, Conditions String, WindDD String) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/home/ubuntu/final/Oshkosh/';
DROP TABLE IF EXISTS Iowa;
CREATE EXTERNAL TABLE IF NOT EXISTS Iowa(Year String, Month String, Day String, TimeCst String, tempf Float, DewPointF String, Humidity String, SLP String, VisMPH String, WindDir String, WindSpeed String, Gust String, Precipitate String, Events String, Conditions String, WindDD String) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/home/ubuntu/final/IowaCity/';
drop view if exists OshkoshF;
create view OshkoshF as
select 
cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') 
as timestamp) as dttcolumn,
cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa') + 86400), 'UTC') 
as timestamp) as nexttime,
--cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa') -86400), 'UTC') as timestamp)as prevtime,
timecst, 
cast(to_date(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day),'yyyy-MM-dd'))) as date)as dtc,
date_add(cast(to_date(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day),'yyyy-MM-dd'))) as date),1)as nextday,
--date_add(cast(to_date(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day),'yyyy-MM-dd'))) as date),-1)as previousday,
tempf

 from Oshkosh where tempf > -100;

drop view if exists IowaF;
create view IowaF as
select 
cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') 
as timestamp) as dttcolumn,
cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa') + 86400), 'UTC') 
as timestamp) as nexttime,
--cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa') -86400), 'UTC') as timestamp)as prevtime,
timecst, 
cast(to_date(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day),'yyyy-MM-dd'))) as date)as dtc,
date_add(cast(to_date(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day),'yyyy-MM-dd'))) as date),1)as nextday,
--date_add(cast(to_date(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day),'yyyy-MM-dd'))) as date),-1)as previousday,
tempf

from Iowa where tempf > -100
and timecst <> 'No daily or hourly history data available';








select
City, abtc, startdt, enddt

from
(

select


startdt, enddt, abtc, tdur, City,


dense_rank() over(order by abtc desc, tdur asc) as therank







from

(

select startdt, enddt, abtc,  tdur, 'Oshkosh' as City from
(select startdt, enddt, abtc, tdur, 


dense_rank() over(order by abtc desc, tdur asc) as therank
from(
select abs(a.tempf-b.tempf) abtc,a.dttcolumn as startdt, b.dttcolumn as enddt,
unix_timestamp(b.dttcolumn) - unix_timestamp(a.dttcolumn) as tdur

from OshkoshF a inner join OshkoshF b
on a.dtc = b.dtc
where b.dttcolumn > a.dttcolumn
)x
)y
where y.therank = 1



union

select startdt, enddt, abtc,  tdur, 'Oshkosh' as City from
(select startdt, enddt, abtc, tdur, 


dense_rank() over(order by abtc desc, tdur asc) as therank
from(
select abs(a.tempf-b.tempf) abtc,a.dttcolumn as startdt, b.dttcolumn as enddt,
unix_timestamp(b.dttcolumn) - unix_timestamp(a.dttcolumn) as tdur

from OshkoshF a inner join OshkoshF b
on a.nextday = b.dtc
where a.nexttime > b.dttcolumn
)x
)y
where y.therank = 1


union


select startdt, enddt, abtc,  tdur, 'Iowa' as City from
(select startdt, enddt, abtc, tdur, 


dense_rank() over(order by abtc desc, tdur asc) as therank
from(
select abs(a.tempf-b.tempf) abtc,a.dttcolumn as startdt, b.dttcolumn as enddt,
unix_timestamp(b.dttcolumn) - unix_timestamp(a.dttcolumn) as tdur

from IowaF a inner join IowaF b
on a.dtc = b.dtc
where b.dttcolumn > a.dttcolumn
)x
)y
where y.therank = 1



union

select startdt, enddt, abtc,  tdur, 'Iowa' as City from
(select startdt, enddt, abtc, tdur, 


dense_rank() over(order by abtc desc, tdur asc) as therank
from(
select abs(a.tempf-b.tempf) abtc,a.dttcolumn as startdt, b.dttcolumn as enddt,
unix_timestamp(b.dttcolumn) - unix_timestamp(a.dttcolumn) as tdur

from IowaF a inner join IowaF b
on a.nextday = b.dtc
where a.nexttime > b.dttcolumn
)x
)y
where y.therank = 1

)q
)bigq
where bigq.therank = 1




