use boston_airbnb;

select * from boston_listings;
--alter table boston_listings drop column propherty_type, neighbourhood_group_cleansed, bathrooms_text;

select year(host_since) as host_since, count(*) as total 
from boston_listings group by year(host_since) order by total desc

--- how many hosts are superhosts?
select distinct(host_is_superhost), count(*) as total from boston_listings group by host_is_superhost;

--what is the median price with different bedroom count?
with med_cte as (select bedrooms ,price,
PERCENTILE_CONT(0.5) 
     within group(order by price)
     over (partition by bedrooms) as median_price
from boston_listings )
select distinct(median_price), bedrooms from med_cte



--- median price per neighbourhood 
with n_cte as (select neighbourhood_cleansed ,price,
PERCENTILE_CONT(0.5) 
     within group(order by price)
     over (partition by neighbourhood_cleansed) as median_price
from boston_listings )
select distinct(median_price), neighbourhood_cleansed from n_cte order by median_price desc


 --- top hosts and other metrics
select top 5 host_id, calculated_host_listings_count, host_is_superhost, host_response_rate, host_response_time
from boston_listings b join listings_1 i on b.id = i.id
group by host_id, calculated_host_listings_count, host_is_superhost, host_response_rate, host_response_time
order by calculated_host_listings_count desc

--- most listings by neighbourhood 
select neighbourhood_cleansed, sum(calculated_host_listings_count) as total_listings
from boston_listings b join listings_1 i on b.id = i.id
group by neighbourhood_cleansed
order by total_listings desc

---room type count
select room_type, sum(calculated_host_listings_count) as total_listings
from listings_1 group by room_type

--- occupancy rate by date
select * from calendar
select date, format(cast(COUNT(CASE WHEN available= 'f' THEN available END) as decimal)/COUNT(available)*100,'0.00') 
from calendar group by date order by date desc

---- occupancy rate by room type
select room_type, format(cast(COUNT(CASE WHEN available= 'f' THEN available END) as decimal)/COUNT(available)*100,'0.00') as occupany_rate 
from calendar c join listings_1 l on l.id=c.listing_id
group by room_type

---how much do the top earners make ? are top hosts are the top earners?
select host_id, (l.price*COUNT(CASE WHEN available= 'f' THEN available END)) as earning
from calendar c join listings_1 l on l.id=c.listing_id
group by host_id, l.price order by earning desc

---- \
select * from boston_listings
select * from listings_1

--- median value of review score by neighbourhood
-- caomparing review scores and price of neighbourhoods to determine a pattern, if any
with rev_cte as (select neighbourhood_cleansed ,review_scores_location,
PERCENTILE_CONT(0.5) 
     within group(order by review_scores_location)
     over (partition by neighbourhood_cleansed) as median_score
from boston_listings )
select distinct(median_score), neighbourhood_cleansed from rev_cte order by median_score desc

---property type 
select neighbourhood_cleansed ,property_type, count(property_type) 
from boston_listings 
group by  neighbourhood_cleansed, property_type

---what makes a superhost? /review rating and response rate shoud be 70-100
select host_is_superhost, host_response_rate, review_scores_value
from boston_listings b join listings_1 l on l.id=b.id
order by host_response_rate

