USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActivityReport_TotalExport]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ActivityReport_TotalExport] --'2022'    
    @year INT    
AS    
BEGIN    
    DECLARE @invoice TABLE (Month INT, COUNT INT, peb INT)    
    INSERT INTO @invoice    
    SELECT     
		Month(CreatedDate),     
		COUNT(DISTINCT IdCipl),     
		COUNT(DISTINCT NpeNumber)     
	FROM	(SELECT     
				ci.IdCargo,     
				ci.Id AS IdCargoItem,     
				cpi.Id AS IdCiplItem,     
				cp.id AS IdCipl,     
				peb.NpeNumber,     
				CONVERT(VARCHAR(10), rc.CreateDate, 120) AS CreatedDate  
			FROM fn_get_cl_request_list_all_report() rc    
				LEFT JOIN NpePeb peb ON rc.IdCl = peb.IdCl    
				LEFT JOIN CargoItem ci ON rc.IdCl = ci.IdCargo    
				LEFT JOIN CiplItem cpi ON ci.IdCiplItem = cpi.Id    
				LEFT JOIN Cipl cp ON cpi.IdCipl = cp.id      
			WHERE (YEAR(rc.CreateDate) = @year) 
				--OR rc.IdStep = 10019
				--AND ((rc.IdStep = 10020 AND rc.Status = 'Approve')
				--OR rc.IdStep = 10021   
				--OR (rc.IdStep = 10022 AND (rc.Status = 'Submit' OR rc.Status = 'Approve'))) 
				AND peb.NpeNumber IS NOT NULL  
				AND cp.IsDelete = 0)  
	DATA GROUP BY Month(CreatedDate)    
    
    DECLARE @outstanding TABLE (month int, count int)    
    INSERT INTO @outstanding    
    SELECT   
		  Month(CreatedDate),   
		  COUNT(DISTINCT IdCipl)   
	FROM (
	SELECT	rc.IdCipl,
			CASE WHEN MONTH(rc.CreateDate) <> MONTH(rc.UpdateDate) OR MONTH(rc.CreateDate) < MONTH(GETDATE()) THEN CONVERT(VARCHAR(10), rc.CreateDate, 120) ELSE CONVERT(VARCHAR(10), rc.UpdateDate, 120) END AS CreatedDate,  
			CONVERT(VARCHAR(10), rc.UpdateDate, 120) AS UpdateDate    
	FROM	[fn_ActivityReport_TotalExport_Outstanding]() rc
	WHERE	YEAR(rc.CreateDate) = @year
		  --prev version
		 -- FROM (SELECT     
			--  ci.IdCargo,     
			--  ci.Id AS IdCargoItem,     
			--  cpi.Id AS IdCiplItem,     
			--  cp.id AS IdCipl,  
			--  rc.IdCl,   
			--  rc.Status,  
			--  CONVERT(VARCHAR(10), rc.CreateDate, 120) AS CreatedDate,  
			--  CONVERT(VARCHAR(10), rc.UpdateDate, 120) AS UpdateDate    
			--  , fs.Step  
			--  , fs.Id    
			--FROM fn_get_cl_request_list_all_report() rc    
			--  --RequestCl rc     
			--  LEFT JOIN NpePeb peb ON rc.IdCl = peb.IdCl    
			--  INNER JOIN FlowStep fs ON rc.IdStep = fs.Id    
			--  LEFT JOIN CargoItem ci ON rc.IdCl = ci.IdCargo    
			--  LEFT JOIN CiplItem cpi ON ci.IdCiplItem = cpi.Id    
			--  LEFT JOIN Cipl cp ON cpi.IdCipl = cp.id    
			--  LEFT JOIN CiplHistory chis ON chis.IdCipl = cp.id   
			--WHERE (YEAR(rc.CreateDate) = @year OR @year = 0)  
			--  AND ((rc.IdStep = 10020 AND (rc.Status NOT IN ('Approve', 'Reject')))   
			--  OR (rc.IdStep NOT IN (10020, 10021, 10022) AND rc.Status <> 'Reject'))  
			--  AND ((peb.NpeNumber IS NULL OR peb.NpeNumber = '') OR (peb.NpeNumber IS NOT NULL OR peb.NpeNumber <> '' AND MONTH(rc.CreateDate) <= MONTH(GETDATE())))  
			--  AND chis.Step = 'Approval By Superior'  
			--  AND cp.IsDelete = 0  
			--  AND rc.IdCl NOT IN (SELECT npe.IdCl  
			--   FROM CargoCipl cc  
			--	 INNER JOIN NpePeb npe ON npe.IdCl = cc.Id  
			--   WHERE YEAR(npe.CreateDate) = @year)  
	)DATA GROUP BY Month(CreatedDate)    
    
    DECLARE @monthly_tbl table(MonthNumber int, MonthName nvarchar(10))    
    DECLARE @month int = 1    
    WHILE @month <= 12    
    BEGIN    
        INSERT INTO @monthly_tbl     
        SELECT @month, LEFT(DATENAME(MONTH , DATEADD(MONTH, @month , -1)), 3)    
        SET @month = @month + 1;  
    END;  
    
    SELECT  m.MonthName AS Month,     
            ISNULL(i.count, 0) AS Invoice,     
            ISNULL(i.peb, 0) AS PEB,     
            ISNULL(o.count, 0) AS Outstanding     
    FROM @monthly_tbl m    
   LEFT JOIN @invoice i ON m.MonthNumber = i.month    
   LEFT JOIN @outstanding o ON m.MonthNumber = o.month    
    
END
GO
