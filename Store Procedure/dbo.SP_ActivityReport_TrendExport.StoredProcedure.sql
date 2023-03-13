USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActivityReport_TrendExport]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ActivityReport_TrendExport] --'2020', '2022'
	 @startYear INT,  
	 @endYear INT,
	 @filter NVARCHAR(MAX)  
AS  
BEGIN  
	DECLARE @yearly_tbl TABLE(Year INT)  
	DECLARE @year INT = @startYear  
	WHILE @year <= @endYear  
	BEGIN  
		INSERT INTO @yearly_tbl VALUES(@year)  
		SET @year = @year + 1;  
	END;  
   
	SELECT	DISTINCT y.Year,   
			ISNULL(b.TotalExportSales, 0) AS TotalExportSales, 
			ISNULL(b.TotalExportNonSales, 0) AS TotalExportNonSales, 
			ISNULL(b.TotalExport, 0) AS TotalExport,   
			ISNULL(b.TotalPEB, 0) As TotalPEB   
	FROM	@yearly_tbl y  
			LEFT JOIN (	SELECT c.Year, SUM(c.TotalExportSales) [TotalExportSales], SUM(c.TotalExportNonSales) [TotalExportNonSales], SUM(c.TotalExport) [TotalExport], SUM(c.TotalPEB) [TotalPEB]
						FROM	(	SELECT	DISTINCT YEAR(CreatedDate) AS Year, 
											CASE WHEN ExportType LIKE 'Sales%' THEN SUM(ExtendedValue) ELSE 0 END [TotalExportSales], 
											CASE WHEN ExportType LIKE 'Non Sales%' THEN SUM(ExtendedValue) ELSE 0 END [TotalExportNonSales],
											SUM(ExtendedValue) As TotalExport,   
											COUNT(DISTINCT AjuNumber) AS TotalPEB  
									FROM	dbo.[fn_get_approved_npe_peb]()  
									WHERE	(YEAR(CreatedDate) >= @startYear OR @startYear = 0) 
											AND (YEAR(CreatedDate) <= @endYear OR @endYear = 0)
											AND ExportType LIKE '' + @filter + '%'
									GROUP BY YEAR(CreatedDate), ExportType) AS c
						GROUP BY Year)b ON y.Year = b.Year
END  
GO
