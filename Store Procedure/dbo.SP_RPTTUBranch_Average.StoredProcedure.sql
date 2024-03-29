USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_RPTTUBranch_Average]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_RPTTUBranch_Average]
	@StartPeriod nvarchar(20),
	@EndPeriod nvarchar(20)
AS
BEGIN

	declare @year int = DATEPART(YEAR, @StartPeriod)
	declare @startdate datetime = CAST(@year as nvarchar(4)) + '-01-01'
	declare @enddate datetime = CAST(@year as nvarchar(4)) + '-12-31'

	declare @tbl table (Description nvarchar(50), MonthNumber int, Value decimal(18,2))

	--============ Average per Week ============
	declare @maxweek int, @week int = 1
	set @maxweek = DATEPART(WEEK, @enddate)

	declare @weekly_tbl table(WeekNumber int, MonthNumber int)
	WHILE @week <= @maxweek
	BEGIN
		insert into @weekly_tbl 
		select @week, DATEPART(MONTH, DATEADD(WW, @week - 1, @startdate))
		SET @week = @week + 1;
	END;

	insert into @tbl
	select 'Average Per Week', w.MonthNumber, CAST(AVG(CAST(ISNULL(src.TotalPEB, 0) as float)) as decimal(18,2)) as WeeklyAVG
	from @weekly_tbl w
	left join(
		select 
			DATEPART(WK, PebDateNumeric) as WeekNumber
			, COUNT(DISTINCT AjuNumber) as TotalPEB
		from [dbo].[fn_get_approved_npe_peb]() 
		where ((DATEPART(MONTH, PebDateNumeric) >= DATEPART(MONTH, @StartPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @StartPeriod)) OR @StartPeriod = '') 
				AND ((DATEPART(MONTH, PebDateNumeric) <= DATEPART(MONTH, @EndPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @EndPeriod)) OR @EndPeriod = '')
		group by DATEPART(WK, PebDateNumeric)
	)src on w.WeekNumber = src.WeekNumber
	GROUP BY w.MonthNumber

	----============ Average per Day ============
	declare @monthly_tbl table(MonthNumber int, TotalDays int)
	declare @month int = 1

	WHILE @month <= 12
	BEGIN
		insert into @monthly_tbl (MonthNumber, TotalDays)
		select @month
		, DATEDIFF(DAY, cast(@year as char(4)) + '-' + cast(@month as char(2)) + '-01', cast(IIF(@month+1 > 12, @year + 1, @year) as char(4)) + '-' + cast(IIF(@month+1 > 12, 1, @month+1) as char(2)) + '-01')
		SET @month += 1;
	END;

	insert into @tbl
	select 'Average Per Day', m.MonthNumber, CAST(ROUND(CAST(ISNULL(src.TotalPEB, 0) as float)/m.TotalDays, 2, 1) as decimal(18,2)) as DailyAVG
	from @monthly_tbl m
	left join (
		select 
			DATEPART(MONTH, PebDateNumeric) as MonthNumber
			, COUNT(DISTINCT AjuNumber) as TotalPEB
		from [dbo].[fn_get_approved_npe_peb]() 
		where ((DATEPART(MONTH, PebDateNumeric) >= DATEPART(MONTH, @StartPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @StartPeriod)) OR @StartPeriod = '') 
				AND ((DATEPART(MONTH, PebDateNumeric) <= DATEPART(MONTH, @EndPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @EndPeriod)) OR @EndPeriod = '')
		group by DATEPART(MONTH, PebDateNumeric)
	)src on m.MonthNumber = src.MonthNumber

	select * from(
		select Description, LEFT(DATENAME(MONTH , DATEADD(MONTH, MonthNumber, -1)), 3) as MonthName, Value from @tbl
	)src
	pivot(max(Value) for MonthName in ([Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec])) pvt
	order by Description desc

END
GO
