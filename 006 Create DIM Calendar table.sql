-- =============================================   
-- Author:      <Name>   
-- Create date: <Create Date,,>   
-- Description: <Description,,>   
-- =============================================   

/*

In this scenario, fiscal year starts in October and ends in September

*/
  
CREATE PROCEDURE [DIM].[Calendar_CREATE]  
	@StartDate DATE,  
	@EndDate DATE  
AS  
BEGIN  
	SET NOCOUNT ON;  
  
IF @StartDate IS NULL OR @EndDate IS NULL  
BEGIN  
	SELECT 'Start and end dates MUST be provided in order for this stored procedure to work.';  
	RETURN;  
END  
   
IF @StartDate > @EndDate  
BEGIN  
    SELECT 'Start date must be less than or equal to the end date.';  
    RETURN;  
END  
  
  
DROP TABLE IF EXISTS DIM.Calendar  
  
CREATE TABLE DIM.Calendar  
(	CalendarDate DATE NOT NULL CONSTRAINT PKDimDate PRIMARY KEY CLUSTERED, -- The date addressed in this row.  
	CalendarDateString VARCHAR(25) NOT NULL, -- The VARCHAR formatted date, such as 07/03/2017  
  
    CalendarYear SMALLINT NOT NULL, -- Current year, eg: 2017, 2025, 1984.  
    DayofYear SMALLINT NOT NULL, -- Number from 1-366  
    FirstDateofYear DATE NOT NULL, -- Date of the first day of this year.  
	LastDateofYear DATE NOT NULL, -- Date of the last day of this year.  
  
	CalendarQuarter TINYINT NOT NULL, -- 1-4, indicates quarter within the current year.  
    DayofQuarter TINYINT NOT NULL, -- Number from 1-92, indicates the day # in the quarter.  
    FirstDateofQuarter DATE NOT NULL, -- Date of the first day of this quarter.  
	LastDateofQuarter DATE NOT NULL, -- Date of the last day of this quarter.  
  
	CalendarMonth TINYINT NOT NULL, -- Number from 1-12  
    MonthName VARCHAR(9) NOT NULL, -- January-December  
    FirstDateofMonth DATE NOT NULL, -- Date of the first day of this month.  
	LastDateofMonth DATE NOT NULL, -- Date of the last day of this month.  
    YearMonth INT NOT NULL, ---Number eg: 202101 for 2021 Jan  
    YearMonthName VARCHAR(50) NOT NULL, ---2021 Jan etc  
  
    FirstDateofWeek DATE NOT NULL, -- Date of the first day of this week.  
	LastDateofWeek DATE NOT NULL, -- Date of the last day of this week.  
    WeekofMonth TINYINT NOT NULL, -- Number from 1-6, indicates the number of week within the current month.  
	WeekofQuarter TINYINT NOT NULL, -- Number from 1-14, indicates the number of week within the current quarter.  
	WeekofYear TINYINT NOT NULL, -- Number from 1-53, indicates the number of week within the current year.  
    YearWeek INT NOT NULL, -- Number eg: 202101 for first week of 2021 
    WeekStartingName VARCHAR(50) NOT NULL, -- Week starting 2021-01-01 etc 
    WeekEndingName VARCHAR(50) NOT NULL, -- Week ending 2021-01-07 etc 
      
    CalendarDay TINYINT NOT NULL, -- Number from 1 through 31  
    DayName VARCHAR(9) NOT NULL, -- Name of the day of the week, Sunday...Saturday  
	DayofWeek TINYINT NOT NULL, -- Number from 1-7 (1 = Sunday)  
    DayofWeekinMonth TINYINT NOT NULL, -- Number from 1-5, indicates for example that it's the Nth saturday of the month.  
	DayofWeekinYear TINYINT NOT NULL, -- Number from 1-53, indicates for example that it's the Nth saturday of the year.  
	DayofWeekinQuarter TINYINT NOT NULL, -- Number from 1-13, indicates for example that it's the Nth saturday of the quarter.  
	  
	IsWeekday BIT NOT NULL, -- 1 if Monday-->Friday, 0 for Saturday/Sunday  
  
	IsLeapYear BIT NOT NULL, -- 1 if current year is a leap year.  
	DaysinMonth TINYINT NOT NULL, -- Number of days in the current month.  
  
    FiscalYear SMALLINT NOT NULL, --FY starting October  
    FiscalYearName VARCHAR(50) NOT NULL, --FY Name  
  
    FiscalQuarter TINYINT NOT NULL, --FY Quarter  
    FiscalQuarterNum INT NOT NULL, --FY Quarter Num  
    FiscalQuarterName VARCHAR(50) NOT NULL, --FY Quarter Name  
  
    FiscalMonthNum INT NOT NULL  
)  
  
SET DATEFIRST  1;  
  
DECLARE @DateCounter DATE = @StartDate;  
DECLARE @CalendarDateString VARCHAR(25);  
DECLARE @CalendarMonth TINYINT;  
DECLARE @CalendarDay TINYINT;  
DECLARE @CalendarYear SMALLINT;  
DECLARE @CalendarQuarter TINYINT;  
DECLARE @DayName VARCHAR(9);  
DECLARE @DayofWeek TINYINT;  
DECLARE @DayofWeekinMonth TINYINT;  
DECLARE @DayofWeekinYear TINYINT;  
DECLARE @DayofWeekinQuarter TINYINT;  
DECLARE @DayofQuarter TINYINT;  
DECLARE @DayofYear SMALLINT;  
DECLARE @WeekofMonth TINYINT;  
DECLARE @WeekofQuarter TINYINT;  
DECLARE @WeekofYear TINYINT;  
DECLARE @MonthName VARCHAR(9);  
DECLARE @FirstDateofWeek DATE;  
DECLARE @LastDateofWeek DATE;  
DECLARE @FirstDateofMonth DATE;  
DECLARE @LastDateofMonth DATE;  
DECLARE @FirstDateofQuarter DATE;  
DECLARE @LastDateofQuarter DATE;  
DECLARE @FirstDateofYear DATE;  
DECLARE @LastDateofYear DATE;  
DECLARE @IsWeekday BIT;  
DECLARE @IsLeapYear BIT;  
DECLARE @DaysinMonth TINYINT;  
  
While @DateCounter<=@EndDate  
    BEGIN  
  
SELECT @CalendarMonth = DATEPART(MONTH, @DateCounter);  
SELECT @CalendarDay = DATEPART(DAY, @DateCounter);  
SELECT @CalendarYear = DATEPART(YEAR, @DateCounter);  
SELECT @CalendarQuarter = DATEPART(QUARTER, @DateCounter);  
SELECT @DayofWeek = DATEPART(WEEKDAY, @DateCounter);  
SELECT @DayofYear = DATEPART(DAYOFYEAR, @DateCounter);  
SELECT @WeekofYear = DATEPART(WEEK, @DateCounter);  
  
SELECT @CalendarDateString = CONVERT (VARCHAR(25), @DateCounter, 107);  
  
SELECT @IsWeekday = CASE  
				WHEN @DayofWeek IN (1, 7)  
					THEN 0  
				ELSE 1  
			END;  
  
SELECT @DayName = CASE @DayofWeek  
					WHEN 1 THEN 'Monday'  
					WHEN 2 THEN 'Tuesday'  
					WHEN 3 THEN 'Wednesday'  
					WHEN 4 THEN 'Thursday'  
					WHEN 5 THEN 'Friday'  
					WHEN 6 THEN 'Saturday'  
                    WHEN 7 THEN 'Sunday'  
				END;  
   
SELECT @MonthName = CASE @CalendarMonth  
					WHEN 1 THEN 'January'  
					WHEN 2 THEN 'February'  
					WHEN 3 THEN 'March'  
					WHEN 4 THEN 'April'  
					WHEN 5 THEN 'May'  
					WHEN 6 THEN 'June'  
					WHEN 7 THEN 'July'  
					WHEN 8 THEN 'August'  
					WHEN 9 THEN 'September'  
					WHEN 10 THEN 'October'  
					WHEN 11 THEN 'November'  
					WHEN 12 THEN 'December'  
				END;  
  
SELECT @DayofQuarter = DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0 , @DateCounter), 0), @DateCounter) + 1;  
SELECT @DayofYear = DATEPART(DAYOFYEAR, @DateCounter);  
SELECT @WeekofMonth = DATEDIFF(WEEK, DATEADD(WEEK, DATEDIFF(WEEK, 0, DATEADD(MONTH, DATEDIFF(MONTH, 0, @DateCounter), 0)), 0), @DateCounter ) + 1;  
SELECT @WeekofQuarter = DATEDIFF(DAY, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @DateCounter), 0), @DateCounter)/7 + 1;  
  
SELECT @FirstDateofWeek = DATEADD(DAY, -1 * @DayofWeek + 1, @DateCounter);  
SELECT @LastDateofWeek = DATEADD(DAY, 1 * (7 - @DayofWeek), @DateCounter);  
SELECT @FirstDateofMonth = DATEADD(DAY, -1 * DATEPART(DAY, @DateCounter) + 1, @DateCounter);  
SELECT @LastDateofMonth = EOMONTH(@DateCounter);  
SELECT @FirstDateofQuarter = DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @DateCounter), 0);  
SELECT @LastDateofQuarter = DATEADD (DAY, -1, DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @DateCounter) + 1, 0));  
SELECT @FirstDateofYear = DATEADD(YEAR, DATEDIFF(YEAR, 0, @DateCounter), 0);  
SELECT @LastDateofYear = DATEADD(DAY, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, @DateCounter) + 1, 0));  
SELECT @DayofWeekinMonth = (@CalendarDay + 6) / 7;  
SELECT @DayofWeekinYear = (@DayofYear + 6) / 7;  
SELECT @DayofWeekinQuarter = (@DayofQuarter + 6) / 7;  
  
SELECT @IsLeapYear = CASE  
					WHEN @CalendarYear % 4 <> 0 THEN 0  
					WHEN @CalendarYear % 100 <> 0 THEN 1  
					WHEN @CalendarYear % 400 <> 0 THEN 0  
					ELSE 1  
				END;  
   
SELECT @DaysinMonth = CASE  
					WHEN @CalendarMonth IN (4, 6, 9, 11) THEN 30				  
                                        WHEN @CalendarMonth IN (1, 3, 5, 7, 8, 10, 12) THEN 31  
					WHEN @CalendarMonth = 2 AND @IsLeapYear = 1 THEN 29  
					ELSE 28  
				END;  
  
  
  
    INSERT INTO DIM.Calendar  
  
	SELECT  
		@DateCounter AS CalendarDate,  
		@CalendarDateString AS CalendarDateString,  
  
        @CalendarYear AS CalendarYear,  
        @DayofYear AS DayofYear,  
        @FirstDateofYear AS FirstDateofYear,  
		@LastDateofYear AS LastDateofYear,  
          
        @CalendarQuarter AS CalendarQuarter,  
        @DayofQuarter AS DayofQuarter,  
        @FirstDateofQuarter AS FirstDateofQuarter,  
		@LastDateofQuarter AS LastDateofQuarter,  
  
		@CalendarMonth AS CalendarMonth,          
        @MonthName AS MonthName,  
        @FirstDateofMonth AS FirstDateofMonth,  
		@LastDateofMonth AS LastDateofMonth,  
        @CalendarYear*100+@CalendarMonth AS YearMonth,  
        CONCAT (@CalendarYear, ' ', @MonthName) AS YearMonthName,  
 
        @FirstDateofWeek AS FirstDateofWeek,  
		@LastDateofWeek AS LastDateofWeek,  
		@WeekofMonth AS WeekofMonth,  
		@WeekofQuarter AS WeekofQuarter,  
		@WeekofYear AS WeekofYear, 
        @CalendarYear*100+@WeekofYear as YearWeek, 
        CONCAT('Week starting ', @FirstDateofWeek) as WeekStartingName, 
        CONCAT('Week ending ', @LastDateofWeek) as WeekEndingName,  
		  
        @CalendarDay AS CalendarDay,	  
		@DayName AS DayName,  
		@DayofWeek AS DayofWeek,  
		@DayofWeekinMonth AS DayofWeekinMonth,  
		@DayofWeekinYear AS DayofWeekinYear,  
		@DayofWeekinQuarter AS DayofWeekinQuarter,  
		@IsWeekday AS IsWeekday,  
		@IsLeapYear AS IsLeapYear,  
		@DaysinMonth AS DaysinMonth,  
  
        year(dateadd(month, 3, @DateCounter)) as FiscalYear,  
        concat ('FY - ',year(dateadd(month, 3, @DateCounter))) as FiscalYearName,  
  
        case when @CalendarQuarter<4 then @CalendarQuarter+1 else 1 end as FiscalQuarter,  
        year(dateadd(month, 3, @DateCounter)) * 100 + (case when @CalendarQuarter<4 then @CalendarQuarter+1 else 1 end) as FiscalQuarterNum,  
        concat ('FY - ',year(dateadd(month, 3, @DateCounter)), ' Q', case when @CalendarQuarter<4 then @CalendarQuarter+1 else 1 end) as FiscalQuarterName,  
  
        case when @CalendarMonth>9 then @CalendarMonth-9 else @CalendarMonth+3 end as FiscalMonthNum  
   
	SELECT @DateCounter = DATEADD(DAY, 1, @DateCounter);  
     
    END  
END 