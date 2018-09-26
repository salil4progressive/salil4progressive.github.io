DROP TABLE IF EXISTS Oshkosh;
CREATE EXTERNAL TABLE IF NOT EXISTS Oshkosh(Year Int, Month Int, Day Int, TimeCst String, tempf Float, DewPointF String, Humidity String, SLP String, VisMPH String, WindDir String, WindSpeed String, Gust String, Precipitate String, Events String, Conditions String, WindDD String) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/home/ubuntu/final/Oshkosh/';
drop view if exists mydata;
create view mydata as
select cast(to_utc_timestamp(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day, ' ', TimeCST),'yyyy-MM-dd hh:mm aa')), 'UTC') as timestamp) as dttc,
timecst, 
cast(to_date(from_unixtime(unix_timestamp(CONCAT(Year, '-', Month,'-',Day),'yyyy-MM-dd'))) as date)as dtc,
substr(timecst,0,2) as hour,tempf
 from Oshkosh where tempf > -100;
select count(distinct dtc) as distday from mydata where tempf >=95;
select count(distinct dtc) as distday from mydata where tempf <= -10;
