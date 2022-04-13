CREATE OR ALTER   proc [dbo].[rebuild_date_dim] as
BEGIN

DROP TABLE if exists dim.date;

/**********************************************************************************/

CREATE TABLE	dim.date
	(	[DateKey]				INT primary key, 
		[Date]					DATE,
		[FullDateUK]			CHAR(10),			-- Date in dd-MM-yyyy format
		[FullDateUS]			CHAR(10),			-- Date in MM-dd-yyyy format
		[DayOfMonth]			VARCHAR(2),			-- Field will hold day number of Month
		[DaySuffix]				VARCHAR(4),			-- Apply suffix as 1st, 2nd ,3rd etc
		[DayName]				VARCHAR(9),			-- Contains name of the day, Sunday, Monday 
		[DayOfWeekUS]			CHAR(1),			-- First Day Sunday=1 and Saturday=7
		[DayOfWeekUK]			CHAR(1),			-- First Day Monday=1 and Sunday=7
		[DayOfWeekInMonth]		VARCHAR(2),			--1st Monday or 2nd Monday in Month
		[DayOfWeekInYear]		VARCHAR(2),
		[DayOfQuarter]			VARCHAR(3),
		[DayOfYear]				VARCHAR(3),
		[WeekOfMonth]			VARCHAR(1),			-- Week Number of Month 
		[WeekOfQuarter]			VARCHAR(2),			--Week Number of the Quarter
		[WeekOfYear]			VARCHAR(2),			--Week Number of the Year
		[Month]					VARCHAR(2),			--Number of the Month 1 to 12
		[MonthName]				VARCHAR(9),			--January, February etc
		[MonthOfQuarter]		VARCHAR(2),			-- Month Number belongs to Quarter
		[Quarter]				CHAR(1),
		[QuarterName]			VARCHAR(9),			--First,Second..
		[Year]					CHAR(4),			-- Year value of Date stored in Row
		[YearName]				CHAR(7),			--CY 2012,CY 2013
		[MonthYear]				CHAR(10),			--Jan-2013,Feb-2013
		[MMYYYY]				CHAR(6),
		[FirstDayOfMonth]		DATE,
		[LastDayOfMonth]		DATE,
		[FirstDayOfQuarter]		DATE,
		[LastDayOfQuarter]		DATE,
		[FirstDayOfYear]		DATE,
		[LastDayOfYear]			DATE,
		[IsHolidayUS]			BIT,				-- Flag 1=National Holiday, 0-No National Holiday
		[IsWeekday]				BIT,				-- 0=Week End ,1=Week Day
		[HolidayUS]				VARCHAR(50),		--Name of Holiday in US
		[IsHolidayUK]			BIT Null,			-- Flag 1=National Holiday, 0-No National Holiday
		[HolidayUK]				VARCHAR(50) Null,	--Name of Holiday in UK

		Daily					VARCHAR(15),
		Weekly					VARCHAR(15),
		WeeklyWednesday			VARCHAR(15),
		WeeklyThursday			VARCHAR(15),
		WeeklySaturday			VARCHAR(15),
		WeeklySunday			VARCHAR(15),
		Biweekly				VARCHAR(15),
		Monthly					VARCHAR(15),
		Bimonthly				VARCHAR(15),
		Quarterly				VARCHAR(15),
		Sixmonthly				VARCHAR(15),
		SixmonthlyApril			VARCHAR(15),
		SixmonthlyNov			VARCHAR(15),
		Yearly					VARCHAR(15),
		FinancialApril			VARCHAR(15),
		FinancialJuly			VARCHAR(15),
		FinancialOct			VARCHAR(15),
		FinancialNov			VARCHAR(15),

		FiscalYearJuly			smallint,

		[FiscalDayOfYear]		VARCHAR(3),
		[FiscalWeekOfYear]		VARCHAR(3),
		[FiscalMonth]			VARCHAR(2), 
		[FiscalQuarter]			CHAR(1),
		[FiscalQuarterName]		VARCHAR(9),
		[FiscalYear]			CHAR(4),
		[FiscalYearName]		CHAR(7),
		[FiscalMonthYear]		CHAR(10),
		[FiscalMMYYYY]			CHAR(6),
		[FiscalFirstDayOfMonth]		DATE,
		[FiscalLastDayOfMonth]		DATE,
		[FiscalFirstDayOfQuarter]	DATE,
		[FiscalLastDayOfQuarter]	DATE,
		[FiscalFirstDayOfYear]		DATE,
		[FiscalLastDayOfYear]		DATE
	)


BEGIN
/********************************************************************************************/
--Specify Start Date and End date here
--Value of Start Date Must be Less than Your End Date 

DECLARE @StartDate DATETIME = '01/01/1980' --Starting value of Date Range
DECLARE @EndDate DATETIME = '01/01/2100' --End Value of Date Range

--Temporary Variables To Hold the Values During Processing of Each Date of Year
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

/*Table Data type to store the day of week count for the month and year*/
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

--Extract and assign various parts of Values from Current Date to Variable

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

/********************************************************************************************/
--Proceed only if Start Date(Current date ) is less than End date you specified above

WHILE @CurrentDate < @EndDate
BEGIN
 
/*Begin day of week logic*/

         /*Check for Change in Month of the Current date if Month changed then 
          Change variable value*/
	IF @CurrentMonth != DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END

        /* Check for Change in Quarter of the Current date if Quarter changed then change 
         Variable value*/

	IF @CurrentQuarter != DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
       
        /* Check for Change in Year of the Current date if Year changed then change 
         Variable value*/
	

	IF @CurrentYear != DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END
	
        -- Set values in table data type created above from variables 

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	
/*End day of week logic*/


/* Populate Your Dimension Table with values*/
	
	INSERT INTO dim.date
	SELECT
		
		CONVERT (char(8),@CurrentDate,112) as DateKey,
		@CurrentDate AS Date,
		CONVERT (char(10),@CurrentDate,103) as FullDateUK,
		CONVERT (char(10),@CurrentDate,101) as FullDateUS,
		DATEPART(DD, @CurrentDate) AS DayOfMonth,
		--Apply Suffix values like 1st, 2nd 3rd etc..
		CASE 
			WHEN DATEPART(DD,@CurrentDate) IN (11,12,13) 
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 1 
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'st'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 2 
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'nd'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 3 
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'rd'
			ELSE CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th' 
			END AS DaySuffix,
		
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(DW, @CurrentDate) AS DayOfWeekUS,

		-- check for day of week as Per US and change it as per UK format 
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 7
			WHEN 2 THEN 1
			WHEN 3 THEN 2
			WHEN 4 THEN 3
			WHEN 5 THEN 4
			WHEN 6 THEN 5
			WHEN 7 THEN 6
			END 
			AS DayOfWeekUK,
		
		@DayOfWeekInMonth AS DayOfWeekInMonth,
		@DayOfWeekInYear AS DayOfWeekInYear,
		@DayOfQuarter AS DayOfQuarter,
		DATEPART(DY, @CurrentDate) AS DayOfYear,
		DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, CONVERT(VARCHAR, 
		DATEPART(MM, @CurrentDate)) + '/1/' + CONVERT(VARCHAR, 
		DATEPART(YY, @CurrentDate))) AS WeekOfMonth,
		(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0), 
		@CurrentDate) / 7) + 1 AS WeekOfQuarter,
		DATEPART(WW, @CurrentDate) AS WeekOfYear,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		CASE
			WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
			WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
			WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
			END AS MonthOfQuarter,
		DATEPART(QQ, @CurrentDate) AS Quarter,
		CASE DATEPART(QQ, @CurrentDate)
			WHEN 1 THEN 'First'
			WHEN 2 THEN 'Second'
			WHEN 3 THEN 'Third'
			WHEN 4 THEN 'Fourth'
			END AS QuarterName,
		DATEPART(YEAR, @CurrentDate) AS Year,
		'CY ' + CONVERT(VARCHAR, DATEPART(YEAR, @CurrentDate)) AS YearName,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, 
		DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + 
		CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, 
		@CurrentDate) - 1), @CurrentDate))) AS FirstDayOfMonth,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, 
		(DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1, 
		@CurrentDate)))) AS LastDayOfMonth,
		DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS FirstDayOfQuarter,
		DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS LastDayOfQuarter,
		CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, 
		@CurrentDate))) AS FirstDayOfYear,
		CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, 
		@CurrentDate))) AS LastDayOfYear,
		NULL AS IsHolidayUS,
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 0
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			WHEN 4 THEN 1
			WHEN 5 THEN 1
			WHEN 6 THEN 1
			WHEN 7 THEN 0
			END AS IsWeekday,
		NULL AS HolidayUS, Null, Null,
		
		-- dhis2 columns
		null, null, null, null, null, null,
		null, null, null, null, null, null,
		null, null, null, null, null, null,

		-- temp FY col
		case when DATEPART(MM, @CurrentDate) > 6
			then DATEPART(Year, @CurrentDate) + 1
			else DATEPART(Year, @CurrentDate) end as FiscalYearJuly,

		-- fiscal columns
		Null, Null, Null, Null, Null
		, Null, Null, Null, Null, Null
		, Null, Null, Null, Null, Null

	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

/********************************************************************************************/
 
--Step 3.
--Update Values of Holiday as per UK Government Declaration for National Holiday.

/*Update HOLIDAY fields of UK as per Govt. Declaration of National Holiday*/
	
-- Good Friday  April 18 
	UPDATE dim.date
		SET HolidayUK = 'Good Friday'
	WHERE [Month] = 4 AND [DayOfMonth]  = 18

-- Easter Monday  April 21 
	UPDATE dim.date
		SET HolidayUK = 'Easter Monday'
	WHERE [Month] = 4 AND [DayOfMonth]  = 21

-- Early May Bank Holiday   May 5 
   UPDATE dim.date
		SET HolidayUK = 'Early May Bank Holiday'
	WHERE [Month] = 5 AND [DayOfMonth]  = 5

-- Spring Bank Holiday  May 26 
	UPDATE dim.date
		SET HolidayUK = 'Spring Bank Holiday'
	WHERE [Month] = 5 AND [DayOfMonth]  = 26

-- Summer Bank Holiday  August 25 
    UPDATE dim.date
		SET HolidayUK = 'Summer Bank Holiday'
	WHERE [Month] = 8 AND [DayOfMonth]  = 25

-- Boxing Day  December 26  	
    UPDATE dim.date
		SET HolidayUK = 'Boxing Day'
	WHERE [Month] = 12 AND [DayOfMonth]  = 26	

--CHRISTMAS
	UPDATE dim.date
		SET HolidayUK = 'Christmas Day'
	WHERE [Month] = 12 AND [DayOfMonth]  = 25

--New Years Day
	UPDATE dim.date
		SET HolidayUK  = 'New Year''s Day'
	WHERE [Month] = 1 AND [DayOfMonth] = 1

--Update flag for UK Holidays 1= Holiday, 0=No Holiday
	
	UPDATE dim.date
		SET IsHolidayUK  = CASE WHEN HolidayUK   IS NULL 
		THEN 0 WHEN HolidayUK   IS NOT NULL THEN 1 END
		
 
--Step 4.
--Update Values of Holiday as per US Govt. Declaration for National Holiday.

/*Update HOLIDAY Field of US In dimension*/
	
 	/*THANKSGIVING - Fourth THURSDAY in November*/
	UPDATE dim.date
		SET HolidayUS = 'Thanksgiving Day'
	WHERE
		[Month] = 11 
		AND [DayOfWeekUS] = 'Thursday' 
		AND DayOfWeekInMonth = 4

	/*CHRISTMAS*/
	UPDATE dim.date
		SET HolidayUS = 'Christmas Day'
		
	WHERE [Month] = 12 AND [DayOfMonth]  = 25

	/*4th of July*/
	UPDATE dim.date
		SET HolidayUS = 'Independance Day'
	WHERE [Month] = 7 AND [DayOfMonth] = 4

	/*New Years Day*/
	UPDATE dim.date
		SET HolidayUS = 'New Year''s Day'
	WHERE [Month] = 1 AND [DayOfMonth] = 1

	/*Memorial Day - Last Monday in May*/
	UPDATE dim.date
		SET HolidayUS = 'Memorial Day'
	FROM dim.date
	WHERE DateKey IN 
		(
		SELECT
			MAX(DateKey)
		FROM dim.date
		WHERE
			[MonthName] = 'May'
			AND [DayOfWeekUS]  = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	/*Labor Day - First Monday in September*/
	UPDATE dim.date
		SET HolidayUS = 'Labor Day'
	FROM dim.date
	WHERE DateKey IN 
		(
		SELECT
			MIN(DateKey)
		FROM dim.date
		WHERE
			[MonthName] = 'September'
			AND [DayOfWeekUS] = 'Monday'
		GROUP BY
			[Year],
			[Month]
		)

	/*Valentine's Day*/
	UPDATE dim.date
		SET HolidayUS = 'Valentine''s Day'
	WHERE
		[Month] = 2 
		AND [DayOfMonth] = 14

	/*Saint Patrick's Day*/
	UPDATE dim.date
		SET HolidayUS = 'Saint Patrick''s Day'
	WHERE
		[Month] = 3
		AND [DayOfMonth] = 17

	/*Martin Luthor King Day - Third Monday in January starting in 1983*/
	UPDATE dim.date
		SET HolidayUS = 'Martin Luthor King Jr Day'
	WHERE
		[Month] = 1
		AND [DayOfWeekUS]  = 'Monday'
		AND [Year] >= 1983
		AND DayOfWeekInMonth = 3

	/*President's Day - Third Monday in February*/
	UPDATE dim.date
		SET HolidayUS = 'President''s Day'
	WHERE
		[Month] = 2
		AND [DayOfWeekUS] = 'Monday'
		AND DayOfWeekInMonth = 3

	/*Mother's Day - Second Sunday of May*/
	UPDATE dim.date
		SET HolidayUS = 'Mother''s Day'
	WHERE
		[Month] = 5
		AND [DayOfWeekUS] = 'Sunday'
		AND DayOfWeekInMonth = 2

	/*Father's Day - Third Sunday of June*/
	UPDATE dim.date
		SET HolidayUS = 'Father''s Day'
	WHERE
		[Month] = 6
		AND [DayOfWeekUS] = 'Sunday'
		AND DayOfWeekInMonth = 3

	/*Halloween 10/31*/
	UPDATE dim.date
		SET HolidayUS = 'Halloween'
	WHERE
		[Month] = 10
		AND [DayOfMonth] = 31

	/*Election Day - The first Tuesday after the first Monday in November*/
	BEGIN
	DECLARE @Holidays TABLE (ID INT IDENTITY(1,1), 
	DateID int, Week TINYINT, YEAR CHAR(4), DAY CHAR(2))

		INSERT INTO @Holidays(DateID, [Year],[Day])
		SELECT
			DateKey,
			[Year],
			[DayOfMonth] 
		FROM dim.date
		WHERE
			[Month] = 11
			AND [DayOfWeekUS] = 'Monday'
		ORDER BY
			YEAR,
			DayOfMonth 

		DECLARE @CNTR INT, @POS INT, @STARTYEAR INT, @ENDYEAR INT, @MINDAY INT

		SELECT
			@CURRENTYEAR = MIN([Year])
			, @STARTYEAR = MIN([Year])
			, @ENDYEAR = MAX([Year])
		FROM @Holidays

		WHILE @CURRENTYEAR <= @ENDYEAR
		BEGIN
			SELECT @CNTR = COUNT([Year])
			FROM @Holidays
			WHERE [Year] = @CURRENTYEAR

			SET @POS = 1

			WHILE @POS <= @CNTR
			BEGIN
				SELECT @MINDAY = MIN(DAY)
				FROM @Holidays
				WHERE
					[Year] = @CURRENTYEAR
					AND [Week] IS NULL

				UPDATE @Holidays
					SET [Week] = @POS
				WHERE
					[Year] = @CURRENTYEAR
					AND [Day] = @MINDAY

				SELECT @POS = @POS + 1
			END

			SELECT @CURRENTYEAR = @CURRENTYEAR + 1
		END

		UPDATE dim.date
			SET HolidayUS  = 'Election Day'				
		FROM dim.date DT
			JOIN @Holidays HL ON (HL.DateID + 1) = DT.DateKey
		WHERE
			[Week] = 1
	END
	--set flag for US holidays in Dimension
	UPDATE dim.date
SET IsHolidayUS = CASE WHEN HolidayUS  IS NULL THEN 0 WHEN HolidayUS  IS NOT NULL THEN 1 END;
/*****************************************************************************************/
END



/** DHIS2 ****************************************************************************************/
BEGIN

UPDATE dim.date
	SET Daily = DateKey
		, Weekly = [Year] + 'W' + WeekOfYear
		, Biweekly = [Year] + 'BiW' + convert( varchar, ((WeekOfYear + 1) / 2))
		, Monthly = [Year] + RIGHT('0' + CONVERT(VARCHAR, [Month]),2)
		, Bimonthly = [Year] + RIGHT('0' + CONVERT(VARCHAR, (([Month] + 1) / 2)),2) + 'B'
		, Quarterly = [Year] + 'Q' + convert(varchar, [Quarter])
		, SixMonthly = [Year] + 'S' + convert( varchar, (([Quarter] + 1) / 2) )
		, Yearly = [Year];

END


BEGIN

/***************************************************************************
The following section needs to be populated for defining the fiscal calendar
***************************************************************************/

DECLARE
	@dtFiscalYearStart SMALLDATETIME = 'January 01, 1980',
	@FiscalYear INT = 1980,
	@LastYear INT = 2100,
	@FirstLeapYearInPeriod INT = 1980

/*****************************************************************************************/

DECLARE
	@iTemp INT,
	@LeapWeek INT,
	@FiscalDayOfYear INT,
	@FiscalWeekOfYear INT,
	@FiscalMonth INT,
	@FiscalQuarter INT,
	@FiscalQuarterName VARCHAR(10),
	@FiscalYearName VARCHAR(7),
	@LeapYear INT,
	@FiscalFirstDayOfYear DATE,
	@FiscalFirstDayOfQuarter DATE,
	@FiscalFirstDayOfMonth DATE,
	@FiscalLastDayOfYear DATE,
	@FiscalLastDayOfQuarter DATE,
	@FiscalLastDayOfMonth DATE

/*Holds the years that have 455 in last quarter*/

DECLARE @LeapTable TABLE (leapyear INT)

/*TABLE to contain the fiscal year calendar*/

DECLARE @tb TABLE(
	PeriodDate DATETIME,
	[FiscalDayOfYear] VARCHAR(3),
	[FiscalWeekOfYear] VARCHAR(3),
	[FiscalMonth] VARCHAR(2), 
	[FiscalQuarter] VARCHAR(1),
	[FiscalQuarterName] VARCHAR(9),
	[FiscalYear] VARCHAR(4),
	[FiscalYearName] VARCHAR(7),
	[FiscalMonthYear] VARCHAR(10),
	[FiscalMMYYYY] VARCHAR(6),
	[FiscalFirstDayOfMonth] DATE,
	[FiscalLastDayOfMonth] DATE,
	[FiscalFirstDayOfQuarter] DATE,
	[FiscalLastDayOfQuarter] DATE,
	[FiscalFirstDayOfYear] DATE,
	[FiscalLastDayOfYear] DATE)

/*Populate the table with all leap years*/

SET @LeapYear = @FirstLeapYearInPeriod
WHILE (@LeapYear < @LastYear)
	BEGIN
		INSERT INTO @leapTable VALUES (@LeapYear)
		SET @LeapYear = @LeapYear + 5
	END

/*Initiate parameters before loop*/

SET @CurrentDate = @dtFiscalYearStart
SET @FiscalDayOfYear = 1
SET @FiscalWeekOfYear = 1
SET @FiscalMonth = 1
SET @FiscalQuarter = 1
SET @FiscalWeekOfYear = 1

IF (EXISTS (SELECT * FROM @LeapTable WHERE @FiscalYear = leapyear))
	BEGIN
		SET @LeapWeek = 1
	END
	ELSE
	BEGIN
		SET @LeapWeek = 0
	END

/*******************************************************************************************/

/* Loop on days in interval*/

WHILE (DATEPART(yy,@CurrentDate) <= @LastYear)
BEGIN
	
/*SET fiscal Month*/
	SELECT @FiscalMonth = CASE 
		/*Use this section for a 4-5-4 calendar.  
		Every leap year the result will be a 4-5-5*/
		WHEN @FiscalWeekOfYear BETWEEN 1 AND 4 THEN 1 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 5 AND 9 THEN 2 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 10 AND 13 THEN 3 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 14 AND 17 THEN 4 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 18 AND 22 THEN 5 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 23 AND 26 THEN 6 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 27 AND 30 THEN 7 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 31 AND 35 THEN 8 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 36 AND 39 THEN 9 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 40 AND 43 THEN 10 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 44 AND (48+@LeapWeek) THEN 11 
/*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN (49+@LeapWeek) AND (52+@LeapWeek) THEN 12 
/*4 weeks (5 weeks on leap year)*/
		
/*Use this section for a 4-4-5 calendar.  
Every leap year the result will be a 4-5-5*/
		/*
		WHEN @FiscalWeekOfYear BETWEEN 1 AND 4 THEN 1 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 5 AND 8 THEN 2 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 9 AND 13 THEN 3 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 14 AND 17 THEN 4 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 18 AND 21 THEN 5 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 22 AND 26 THEN 6 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 27 AND 30 THEN 7 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 31 AND 34 THEN 8 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 35 AND 39 THEN 9 /*5 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 40 AND 43 THEN 10 /*4 weeks*/
		WHEN @FiscalWeekOfYear BETWEEN 44 AND _
		(47+@leapWeek) THEN 11 /*4 weeks (5 weeks on leap year)*/
WHEN @FiscalWeekOfYear BETWEEN (48+@leapWeek) AND (52+@leapWeek) THEN 12 /*5 weeks*/
		*/
	END

	/*SET Fiscal Quarter*/
	SELECT @FiscalQuarter = CASE 
		WHEN @FiscalMonth BETWEEN 1 AND 3 THEN 1
		WHEN @FiscalMonth BETWEEN 4 AND 6 THEN 2
		WHEN @FiscalMonth BETWEEN 7 AND 9 THEN 3
		WHEN @FiscalMonth BETWEEN 10 AND 12 THEN 4
	END
	
	SELECT @FiscalQuarterName = CASE 
		WHEN @FiscalMonth BETWEEN 1 AND 3 THEN 'First'
		WHEN @FiscalMonth BETWEEN 4 AND 6 THEN 'Second'
		WHEN @FiscalMonth BETWEEN 7 AND 9 THEN 'Third'
		WHEN @FiscalMonth BETWEEN 10 AND 12 THEN 'Fourth'
	END
	
	/*Set Fiscal Year Name*/
	SELECT @FiscalYearName = 'FY ' + CONVERT(VARCHAR, @FiscalYear)

	INSERT INTO @tb (PeriodDate, FiscalDayOfYear, FiscalWeekOfYear, 
	fiscalMonth, FiscalQuarter, FiscalQuarterName, FiscalYear, FiscalYearName) VALUES 
	(@CurrentDate, @FiscalDayOfYear, @FiscalWeekOfYear, @FiscalMonth, 
	@FiscalQuarter, @FiscalQuarterName, @FiscalYear, @FiscalYearName)

	/*SET next day*/
	SET @CurrentDate = DATEADD(dd, 1, @CurrentDate)
	SET @FiscalDayOfYear = @FiscalDayOfYear + 1
	SET @FiscalWeekOfYear = ((@FiscalDayOfYear-1) / 7) + 1


	IF (@FiscalWeekOfYear > (52+@LeapWeek))
	BEGIN
		/*Reset a new year*/
		SET @FiscalDayOfYear = 1
		SET @FiscalWeekOfYear = 1
		SET @FiscalYear = @FiscalYear + 1
		IF ( EXISTS (SELECT * FROM @leapTable WHERE @FiscalYear = leapyear))
		BEGIN
			SET @LeapWeek = 1
		END
		ELSE
		BEGIN
			SET @LeapWeek = 0
		END
	END
END

/********************************************************************************************/

/*Set first and last days of the fiscal months*/
UPDATE @tb
SET
	FiscalFirstDayOfMonth = minmax.StartDate,
	FiscalLastDayOfMonth = minmax.EndDate
FROM
@tb t,
	(
	SELECT FiscalMonth, FiscalQuarter, FiscalYear, 
	MIN(PeriodDate) AS StartDate, MAX(PeriodDate) AS EndDate
	FROM @tb
	GROUP BY FiscalMonth, FiscalQuarter, FiscalYear
	) minmax
WHERE
	t.FiscalMonth = minmax.FiscalMonth AND
	t.FiscalQuarter = minmax.FiscalQuarter AND
	t.FiscalYear = minmax.FiscalYear 

/*Set first and last days of the fiscal quarters*/

UPDATE @tb
SET
	FiscalFirstDayOfQuarter = minmax.StartDate,
	FiscalLastDayOfQuarter = minmax.EndDate
FROM
@tb t,
	(
	SELECT FiscalQuarter, FiscalYear, min(PeriodDate) 
	as StartDate, max(PeriodDate) as EndDate
	FROM @tb
	GROUP BY FiscalQuarter, FiscalYear
	) minmax
WHERE
	t.FiscalQuarter = minmax.FiscalQuarter AND
	t.FiscalYear = minmax.FiscalYear 

/*Set first and last days of the fiscal years*/

UPDATE @tb
SET
	FiscalFirstDayOfYear = minmax.StartDate,
	FiscalLastDayOfYear = minmax.EndDate
FROM
@tb t,
	(
	SELECT FiscalYear, min(PeriodDate) as StartDate, max(PeriodDate) as EndDate
	FROM @tb
	GROUP BY FiscalYear
	) minmax
WHERE
	t.FiscalYear = minmax.FiscalYear 

/*Set FiscalYearMonth*/
UPDATE @tb
SET
	FiscalMonthYear = 
		CASE FiscalMonth
		WHEN 1 THEN 'Jan'
		WHEN 2 THEN 'Feb'
		WHEN 3 THEN 'Mar'
		WHEN 4 THEN 'Apr'
		WHEN 5 THEN 'May'
		WHEN 6 THEN 'Jun'
		WHEN 7 THEN 'Jul'
		WHEN 8 THEN 'Aug'
		WHEN 9 THEN 'Sep'
		WHEN 10 THEN 'Oct'
		WHEN 11 THEN 'Nov'
		WHEN 12 THEN 'Dec'
		END + '-' + CONVERT(VARCHAR, FiscalYear)

/*Set FiscalMMYYYY*/
UPDATE @tb
SET
	FiscalMMYYYY = RIGHT('0' + CONVERT(VARCHAR, FiscalMonth),2) + CONVERT(VARCHAR, FiscalYear)

/********************************************************************************************/

UPDATE dim.date
	SET
	FiscalDayOfYear = a.FiscalDayOfYear
	, FiscalWeekOfYear = a.FiscalWeekOfYear
	, FiscalMonth = a.FiscalMonth
	, FiscalQuarter = a.FiscalQuarter
	, FiscalQuarterName = a.FiscalQuarterName
	, FiscalYear = a.FiscalYear
	, FiscalYearName = a.FiscalYearName
	, FiscalMonthYear = a.FiscalMonthYear
	, FiscalMMYYYY = a.FiscalMMYYYY
	, FiscalFirstDayOfMonth = a.FiscalFirstDayOfMonth
	, FiscalLastDayOfMonth = a.FiscalLastDayOfMonth
	, FiscalFirstDayOfQuarter = a.FiscalFirstDayOfQuarter
	, FiscalLastDayOfQuarter = a.FiscalLastDayOfQuarter
	, FiscalFirstDayOfYear = a.FiscalFirstDayOfYear
	, FiscalLastDayOfYear = a.FiscalLastDayOfYear
FROM @tb a
	INNER JOIN dim.date b ON a.PeriodDate = b.[Date]

/********************************************************************************************/

END
END