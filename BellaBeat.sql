								## BellaBeat Case Study


		## Data Cleaning and Wrangling 

## Find the unique number of Ids.
SELECT COUNT(DISTINCT (id)) 
FROM Project_schema.dailyactivity_merged;
# 33 Ids found 

SELECT COUNT(DISTINCT (id)) 
FROM Project_schema.SleepLog;
# 24 Ids found

SELECT COUNT(DISTINCT (id))
FROM Project_schema.weightloginfo_merged;
# 8 Ids found

## Checking for duplicate rows

SELECT ID, ActivityDate, COUNT(*) AS num_row
FROM dailyactivity_merged
GROUP BY ID, ActivityDate 
HAVING num_row > 1;
# No duplicates found

SELECT *, COUNT(*) AS num_row
FROM SleepLog
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING num_row > 1;
# 3 Duplicate rows found

CREATE TABLE SleepLogv2 
SELECT DISTINCT * 
FROM SleepLog;
# Created a new sleeplog table with unique rows

SELECT *, COUNT(*) AS num_row
FROM SleepLogv2
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING num_row > 1;
#Double Check if still duplicate row
#None found

DROP TABLE SleepLog;

ALTER TABLE SleepLog2 RENAME SleepLog;
# After creating and renaming the table I needed to delete the old one to avoid confusion

SELECT *, COUNT(*) AS num_row
FROM weightloginfo_merged
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
HAVING num_row > 1;
# No duplicates found


## Checked if all Id are same length
SELECT LENGTH(Id)
FROM dailyactivity_merged;
# The length is 10

SELECT Id
FROM dailyactivity_merged
WHERE LENGTH(Id) > 10 
OR LENGTH(Id) < 10;

SELECT Id
FROM SleepLog
WHERE LENGTH(Id) > 10 
OR LENGTH(Id) < 10;

SELECT Id
FROM weightloginfo_merged
WHERE LENGTH(Id) > 10  
OR LENGTH(Id) < 10;
# All of the three tables has the same id length

## Making sure the date of the tables conincides with each other.

SELECT MIN(ActivityDate) AS start_date, MAX(ActivityDate) AS end_date
FROM dailyactivity_merged;

SELECT MIN(SleepDay) AS start_date, MAX(SleepDay) AS end_date
FROM SleepLog;

SELECT MIN(Date) AS start_date, MAX(Date) AS end_date
FROM weightloginfo_merged;
# The start date 2016-04-12 and end date 2016-05-12 of the 3 tables


## Looking for null 
SELECT *
FROM dailyactivity_merged
WHERE Id IS NULL;
# None was found
SELECT *
FROM Sleeplog
WHERE id IS NULL;
# None was found
SELECT *
FROM weightloginfo_merged
WHERE Id IS NULL;
# None was found


## Converting ActivityDate from string data to Date type date
UPDATE dailyactivity_merged
SET ActivityDate = STR_TO_DATE(ActivityDate,"%m/%d/%Y");

SET SQL_SAFE_UPDATES = 0;

SELECT ActivityDate
FROM dailyactivity_merged;

SELECT ActivityDate, DAYNAME(ActivityDate) AS day_of_week
FROM dailyactivity_merged;

	##ANALYSIS

## User type/category
    
SELECT Id, Count(Id) as total_user_activity,
  CASE
  WHEN COUNT(Id) BETWEEN 21 and 31 THEN 'Active User'
  WHEN COUNT(Id) BETWEEN 11 and 20 THEN 'Moderate User'
  WHEN COUNT(Id) BETWEEN 1 and 10 THEN 'Idle User'
  END AS user_activity_class
FROM Project_schema.dailyactivity_merged
Group by Id
ORDER BY total_user_activity;


# Convert string data to date data
SELECT STR_TO_DATE(SleepDay, "%m/%d/%Y %r")
FROM SleepLog;

# Had to update the table for further use
UPDATE SleepLog
SET SleepDay = STR_TO_DATE(SleepDay, "%m/%d/%Y  %r");

# To enable the update had to turn off the safe mode in mysql workbench
SET SQL_SAFE_UPDATES = 0;


##avg steps/distance and cal per day 
SELECT DAYNAME(ActivityDate) AS day_of_week, AVG(TotalSteps) AS avg_steps, AVG(TotalDistance) AS avg_distance, AVG(Calories) AS avg_calories
FROM dailyactivity_merged
GROUP BY day_of_week
ORDER BY avg_steps DESC;


##avg weight of user vs total active minutes
SELECT activity.Id, AVG(activity.LightlyActiveMinutes) as avg_lightly_act, AVG(activity.FairlyActiveMinutes) as avg_fairly_act, 
					AVG(activity.VeryActiveMinutes) as avg_very_act,
                    (AVG(activity.LightlyActiveMinutes) + AVG(activity.FairlyActiveMinutes) + 
                    AVG(activity.VeryActiveMinutes)) AS avg_total_mins, 
					AVG(weight.WeightKg) as avg_weight_kg
FROM dailyactivity_merged AS activity
INNER JOIN weightloginfo_merged AS weight
ON activity.Id = weight.Id
GROUP BY activity.Id;


#Converting and updating for analysis
SET SQL_SAFE_UPDATES = 0;

SELECT STR_TO_DATE(ActivityHour, "%m/%d/%Y %r")
FROM hourlyintensities_merged;

UPDATE hourlyintensities_merged
SET ActivityHour = STR_TO_DATE(ActivityHour, "%m/%d/%Y  %r");

##Day and Time most intense 
SELECT  
 TIME(ActivityHour) AS time, DAYNAME(Activityhour) AS day,
  SUM(TotalIntensity) AS sum_total_intensity
FROM hourlyintensities_merged
GROUP BY ActivityHour;

## avg hours of sleep per day
SELECT DAYNAME(SleepDay) AS day_of_week, AVG(TotalMinutesAsleep) AS avg_min_asleep, AVG(TotalMinutesAsleep / 60) AS avg_hrs_asleep
FROM SleepLog
GROUP BY day_of_week
ORDER BY avg_hrs_asleep DESC;