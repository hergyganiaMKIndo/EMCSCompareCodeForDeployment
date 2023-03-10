USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActivityReport_TrendExport]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ActivityReport_TrendExport]
	@startYear int,
	@endYear int
AS
BEGIN

	declare @yearly_tbl table(Year int)
	declare @year int = @startYear
	WHILE @year <= @endYear
	BEGIN
	   insert into @yearly_tbl values(@year)
	   SET @year = @year + 1;
	END;
	
	select 
		y.Year, 
		ISNULL(data.TotalExport, 0) as TotalExport, 
		ISNULL(data.TotalPEB, 0) as TotalPEB 
	from @yearly_tbl y
	left join(
		select 
			YEAR(CreatedDate) as Year, 
			sum(ExtendedValue) as TotalExport, 
			count(DISTINCT AjuNumber) as TotalPEB
		from dbo.[fn_get_approved_npe_peb]()
		where (YEAR(CreatedDate) >= @startYear or @startYear = 0) and (YEAR(CreatedDate) <= @endYear or @endYear = 0)
		group by YEAR(CreatedDate)
	)data on y.Year = data.Year

END
GO
