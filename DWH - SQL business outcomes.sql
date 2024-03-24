-- TIME SPEND PER RIDE
------- based on date and hour of the day
SELECT 
    count(fact_ride_time.trip_id) as ride_count,
    sum(fact_ride_time.ride_time_in_mins) as time_spend_in_mins,
    dim_date.[date],
    dim_date.[hour] as [hour_of_day]
 FROM 
    fact_ride_time inner join dim_date on dim_date.date_id = fact_ride_time.date_id
 GROUP BY 
    dim_date.[date],  dim_date.[hour]
 ORDER BY dim_date.[date], dim_date.[hour]   
------- based on station start and station end
SELECT 
    count(fact_ride_time.trip_id) as ride_count,
    sum(fact_ride_time.ride_time_in_mins) as time_spend_in_mins,
    ds1.[name] as starting_station,
    ds2.[name] as ending_station
 FROM 
    fact_ride_time inner join dim_station ds1 on ds1.station_id = fact_ride_time.start_station_id
    inner join dim_station ds2 on ds2.station_id = fact_ride_time.end_station_id
 GROUP BY 
    ds1.[name], ds2.[name]
------- based on age of ride at time of the ride
SELECT 
    count(f.trip_id) as ride_count,
    sum(f.ride_time_in_mins) as time_spend_in_mins,
    datediff(year,r.birthday,f.date_id) as rider_age
 FROM 
    fact_ride_time f inner join dim_rider r on r.rider_id = f.rider_id
 GROUP BY 
    datediff(year,r.birthday,f.date_id)
 ORDER BY    
   rider_age
------- based on whether the rider is a member or a casual rider
SELECT 
    count(f.trip_id) as ride_count,
    sum(f.ride_time_in_mins) as time_spend_in_mins,
    CASE [is_member] WHEN 1 THEN 'member' ELSE 'casual' END  AS membership
 FROM 
    fact_ride_time f inner join dim_rider r on r.rider_id = f.rider_id
 GROUP BY 
    CASE [is_member] WHEN 1 THEN 'member' ELSE 'casual' END
 ORDER BY    
   membership

-- MONEY SPEND 
------ Per month, quarter, year
SELECT 
   CONVERT(DECIMAL(10,0),sum(f.amount)) as amount_spend,
   d.year,
   d.quarter,
   d.month
FROM
   fact_money_spent f INNER JOIN dim_date d ON d.date_id = f.date_id   
GROUP BY year, quarter, month
ORDER BY year, quarter, month
------ Per member, based on the age of the rider at account start
SELECT 
   count(r.rider_id) as member_count,
   r.age_at_accountstart, 
   convert(decimal(10,0),sum(f.amount)) as amount_spend
FROM
   fact_money_spent f INNER JOIN dim_rider r ON r.rider_id = f.rider_id   
WHERE  r.is_member = 1  
GROUP BY age_at_accountstart
ORDER BY age_at_accountstart
------ Per member based on average rides per month
-- This query is a bit complex, I've worked on it 
-- for the sake of practicing. A better way, in terms of the business 
-- point of vue, would be to add the result of this query into a 
-- new fact table so the dataset is available straigh forward to the 
-- business  
---- Step 1. Get the dates in our trips' facts table
WITH filterDates AS (
   SELECT 
      min(date_id) as mindate,
      max(date_id) as maxdate
   FROM
      fact_ride_time          
---- Step 2  Count the trips for each month in each year
--           in our trips facts table      
), rider_trips_per_months AS (
   SELECT 
      r.rider_id,
      r.fullname,
      d.month,
      d.year, 
      count(f.trip_id) as trip_count
   FROM
   fact_ride_time f 
      INNER JOIN dim_rider r ON r.rider_id = f.rider_id 
      INNER JOIN dim_date d ON d.date_id = f.date_id  
   -- take into consideration members only
   WHERE  r.is_member = 1 
   GROUP BY r.rider_id, r.fullname, d.month, d.year 
---- Step 3   Average trips by months, no matter which year
   -- Note that in our case the data is for one year, 
   -- so no need to average per month, we can skip the next CTE
), rider_average_trips_per_month AS (
   SELECT
      t.rider_id,
      t.fullname,
      avg(t.trip_count) avg_trips,
      t.month
   FROM
      rider_trips_per_months t
   GROUP BY
      t.fullname, t.month, t.rider_id   
---- Step 4 Now do the aggregation in our payments' facts table
   -- for months in each year and date between the data found in 
   -- our trips' facts table. Note that in our case
   -- we have one payment per month for each, so no need to
   -- use the sum and the group by statements     
), rider_money_spend_per_months AS (
   SELECT 
      f.rider_id,
      sum(f.amount) as amount_per_month,
      d.year,
      d.month
   FROM
      fact_money_spent f 
         INNER JOIN dim_date d ON d.date_id = f.date_id
         INNER JOIN dim_rider r ON r.rider_id = f.rider_id
         INNER JOIN filterDates fd ON f.date_id >= fd.mindate AND d.date_id <= fd.maxdate 
   WHERE r.is_member = 1 
   GROUP BY f.rider_id,year, month
   ---- Step 5 Average our payments for months
   -- in any year. Again no need to do this with 
   -- the data analysed in our case 
), rider_avrg_money_spend_per_month AS
(
   SELECT 
      CONVERT(DECIMAL(10,2),avg(amount_per_month)) as avrg_amount_spend,
      month,
      rider_id
   FROM 
      rider_money_spend_per_months   
   GROUP BY
      month, rider_id   
)
---- Finally we get the average rides and the average payments 
   -- for each month for all years in our date 
   -- and for each member. 
   -- We've put the rider_id in addition to the rider's 
   -- fullname, because two riders can have the same fullname.
SELECT 
       t.rider_id,
       t.fullname,  
       m.month,  
       m.avrg_amount_spend, 
       t.avg_trips 
FROM rider_avrg_money_spend_per_month m 
   INNER JOIN rider_average_trips_per_month t
   ON t.rider_id = m.rider_id AND m.month = t.month
ORDER BY rider_id, fullname, month




