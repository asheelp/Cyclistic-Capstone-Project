
#Combining all the 2016 Data:
Create Table high-transit-381405.Cyclistic.Combined_2016 AS
Select *
From (
 Select *
 From `high-transit-381405.Cyclistic.2016-Q1`
 UNION ALL
 Select * From `high-transit-381405.Cyclistic.2016-May`
 UNION ALL
 Select * From `high-transit-381405.Cyclistic.2016-Jun`
 UNION ALL
 Select * From `high-transit-381405.Cyclistic.2016-Apr`);


#Combining 2015 and 2016 Data:
CREATE TABLE high-transit-381405.Cyclistic.combined_data AS
SELECT *
FROM (
 SELECT * FROM `high-transit-381405.Cyclistic.2015-Aug`
 UNION ALL
 SELECT * FROM `high-transit-381405.Cyclistic.2015-July`
 UNION ALL
 SELECT * FROM `high-transit-381405.Cyclistic.2015-Sep`
 UNION ALL
 SELECT * FROM `high-transit-381405.Cyclistic.2015-Q4`
 UNION ALL
 SELECT * FROM `high-transit-381405.Cyclistic.Combined_2016`
)



Data Cleaning:


#Cleaning the Column Names and splitting date and time
WITH clean_column_table as(
SELECT
 date(starttime) as start_date,
 time(starttime) as start_time,
 date(stoptime) as stop_date,
 time(stoptime) as  stop_time,
 trip_id,
 bikeid,
 tripduration,
 from_station_id as start_station_id,
 from_station_name as start_station,
 to_station_id as end_station_id,
 to_station_name as end_station,
 usertype,
 gender,
 birthyear
FROM `high-transit-381405.Cyclistic.combined_data`
Order By starttime),


##Check to see if there are any duplicates in trip_id
Select count(DISTINCT trip_id)
From clean_column_table
#returns same value as number of rows, therefore no duplicates



##Check start and end stations to see if there are any stations that could be spelled incorrectly, duplicates, used for maintenance, etc.


Select start_station, count(*)
From clean_column_table
Group By start_station
Order By start_station;


Select end_station, count(*)
From clean_column_table
Group By end_station
Order By end_station


/* Found duplicates of Clinton St & Polk St, Canal St & Monroe St, Halsted St & 35th St, Halsted St & Blackhawk St, Loomis St & Taylor St, MLK Jr Dr & 56th St, Orleans St & Elm St, Ravenswood Ave & Montrose Ave, Sangamon St & Washington Blvd, Washtenaw Ave & 15th St
/*

#To Clean the Station Duplicates
clean_station_names as(
 select
    *,
   CASE
     When start_station='Clinton St & Polk St (*)' THEN 'Clinton St & Polk St'
     When start_station='Canal St & Monroe St (*)' THEN 'Canal St & Monroe St'
     When start_station='Halsted St & 35th St (*)' THEN 'Halsted St & 35th St'
     When start_station='Halsted St & Blackhawk St (*)' THEN 'Halsted St & Blackhawk St'
     When start_station='Loomis St & Taylor St (*)' THEN 'Loomis St & Taylor St'
     When start_station='MLK Jr Dr & 56th St (*)' THEN 'MLK Jr Dr & 56th St'
     When start_station='Orleans St & Elm St (*)' THEN 'Orleans St & Elm St'
     When start_station='Ravenswood Ave & Montrose Ave (*)' THEN 'Ravenswood Ave & Montrose Ave'
     When start_station='Sangamon St & Washington Blvd (*)' THEN 'Sangamon St & Washington Blvd'
     When start_station='Washtenaw Ave & 15th St (*)' THEN 'Washtenaw Ave & 15th St'
     ELSE start_station
     End as clean_start_stations,
   CASE
     When end_station='Clinton St & Polk St (*)' THEN 'Clinton St & Polk St'
     When end_station='Canal St & Monroe St (*)' THEN 'Canal St & Monroe St'
     When end_station='Halsted St & 35th St (*)' THEN 'Halsted St & 35th St'
     When end_station='Halsted St & Blackhawk St (*)' THEN 'Halsted St & Blackhawk St'
     When end_station='Loomis St & Taylor St (*)' THEN 'Loomis St & Taylor St'
     When end_station='MLK Jr Dr & 56th St (*)' THEN 'MLK Jr Dr & 56th St'
     When end_station='Orleans St & Elm St (*)' THEN 'Orleans St & Elm St'
     When end_station='Ravenswood Ave & Montrose Ave (*)' THEN 'Ravenswood Ave & Montrose Ave'
     When end_station='Sangamon St & Washington Blvd (*)' THEN 'Sangamon St & Washington Blvd'
     When end_station='Washtenaw Ave & 15th St (*)' THEN 'Washtenaw Ave & 15th St'
     ELSE end_station
     End as clean_end_stations
 From clean_column_table
),






#Confirm that the station IDs match the stations 


Select distinct(clean_start_stations), start_station_id
From clean_station_names
Order by clean_start_stations




Select distinct(clean_end_stations), start_station_id
From clean_station_names
Order by clean_end_stations


/* Stations and IDs match














#Confirm there is only 2 user types


Select usertype, count(*)
From clean_station_names
Group by usertype


/* There is a 3rd user type named dependent. After some digging, this seems to be the same person - we will remove him from the data as there is no further information regarding him:


clean_usertypes as(
 Select *
 From clean_station_names
 Where usertype='Subscriber' OR usertype='Customer'),


#Join the current data with location data for the stations


data_stations as(
 Select *
 From clean_usertypes
 JOIN `high-transit-381405.Cyclistic.stations` stations
 ON clean_usertypes.clean_start_stations = stations.name
),
















#Finalize the columns that we need
final_columns as (
 SELECT
   start_date,
   start_time,
   stop_date,
   stop_time,
   trip_id,
   bikeid,
   tripduration/60 as tripduration_minutes,
   start_station_id,
   clean_start_stations as start_station,
   end_station_id,
   clean_end_stations as end_station,
   usertype,
   latitude as start_station_latitude,
   longitude as start_station_longitude,
   dpcapacity,
   online_date
 FROM
   data_stations)




















 
