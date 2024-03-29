USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_Report_Total_Export_Monthly]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[Sp_Report_Total_Export_Monthly] '2019'
CREATE PROCEDURE [dbo].[SP_Report_Total_Export_Monthly] (@year NVARCHAR(7)) 
AS 
  BEGIN 
      SELECT CAST(1 AS BIGINT) Id, ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 1 THEN 1 
                   ELSE 0 
                 END),0) AS 'January', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 2 THEN 1 
                   ELSE 0 
                 END),0) AS 'February', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 3 THEN 1 
                   ELSE 0 
                 END),0) AS 'March', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 4 THEN 1 
                   ELSE 0 
                 END),0) AS 'April', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 5 THEN 1 
                   ELSE 0 
                 END),0) AS 'May', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 6 THEN 1 
                   ELSE 0 
                 END),0) AS 'June', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 7 THEN 1 
                   ELSE 0 
                 END),0) AS 'July', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 8 THEN 1 
                   ELSE 0 
                 END),0) AS 'August', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 9 THEN 1 
                   ELSE 0 
                 END),0) AS 'September', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 10 THEN 1 
                   ELSE 0 
                 END),0) AS 'October', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 11 THEN 1 
                   ELSE 0 
                 END),0) AS 'November', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 12 THEN 1 
                   ELSE 0 
                 END),0) AS 'December', 
             ISNULL(Sum(CASE Datepart(year, CreateDate) 
                   WHEN @year THEN 1 
                   ELSE 0 
                 END),0) AS 'TOTAL' 
      FROM   dbo.RequestCl 
      WHERE  Year(CreateDate) = @year 
	  AND Status = 'Approve'
	  AND IdStep IN (10020, 10022)
  END 

GO
