
DROP TABLE IF EXISTS Oshkosh;
CREATE EXTERNAL TABLE IF NOT EXISTS Oshkosh(Year Int, Month Int, Day Int, TimeCst String, tempf Float, DewPointF String, Humidity String, SLP String, VisMPH String, WindDir String, WindSpeed String, Gust String, Precipitate String, Events String, Conditions String, WindDD String) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/home/ubuntu/final/Oshkosh/';
DROP TABLE IF EXISTS Iowa;
CREATE EXTERNAL TABLE IF NOT EXISTS Iowa(Year String, Month String, Day String, TimeCst String, tempf Float, DewPointF String, Humidity String, SLP String, VisMPH String, WindDir String, WindSpeed String, Gust String, Precipitate String, Events String, Conditions String, WindDD String) ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/home/ubuntu/final/IowaCity/';
drop view if exists OshkoshF;
create view OshkoshF as
select tempf, Month
 from Oshkosh where tempf > -100;
drop view if exists IowaF;

create view IowaF as
select tempf, Month
 from Iowa where tempf > -100;
select

x.avgtemp - y.avgtemp as TemperatureDiff , y.season


 from (
SELECT 

avg(tempf) as avgtemp,
count(tempf) as noofreadings,
sum(   tempf)/count(tempf) as rawaverage,
CASE
WHEN Month in ('12','1','2') then 'Winter'
WHEN Month in ('3','4','5') then 'Spring'
WHEN Month in ('6','7','8') then 'Summer'
WHEN Month in ('9','10','11') then 'Fall'
  end as season

 

FROM 
OshkoshF

GROUP BY 

CASE
WHEN Month in ('12','1','2') then 'Winter'
WHEN Month in ('3','4','5') then 'Spring'
WHEN Month in ('6','7','8') then 'Summer'
WHEN Month in ('9','10','11') then 'Fall'
  end
  )x

  inner join (
SELECT 

avg(   tempf) as avgtemp,
count(tempf) as noofreadings,
sum(  tempf)/count(tempf) as rawaverage,
CASE
WHEN Month in ('12','1','2') then 'Winter'
WHEN Month in ('3','4','5') then 'Spring'
WHEN Month in ('6','7','8') then 'Summer'
WHEN Month in ('9','10','11') then 'Fall'
  end as season
  FROM 
IowaF

GROUP BY 

CASE
WHEN Month in ('12','1','2') then 'Winter'
WHEN Month in ('3','4','5') then 'Spring'
WHEN Month in ('6','7','8') then 'Summer'
WHEN Month in ('9','10','11') then 'Fall'
  end )y on
  y.season = x.season;
