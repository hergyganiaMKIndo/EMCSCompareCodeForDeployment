USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Report_Total_Export_Port]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Report_Total_Export_Port] --'2022', ''
(@year NVARCHAR(4),
@filter NVARCHAR(MAX))
AS   
  BEGIN   
      SELECT	T1.PortOfLoading, T1.PortOfDestination, ISNULL(SUM(T1.Total),0) Total, ISNULL(SUM(T1.TotalSales),0) TotalSales, ISNULL(SUM(T1.TotalNonSales),0) TotalNonSales
	  FROM		( SELECT C.PortOfLoading,
						 C.PortOfDestination,   
						 ISNULL(COUNT(RCL.Id), 0) Total,
						 ISNULL(SUM(CASE WHEN C.ExportType LIKE 'Sales%' AND DATEPART(year, rcl.CreateDate) IN (@year) THEN 1 ELSE 0 END),0) [TotalSales],
						 ISNULL(SUM(CASE WHEN C.ExportType LIKE 'Non Sales%' AND DATEPART(year, rcl.CreateDate) IN (@year) THEN 1 ELSE 0 END),0) [TotalNonSales]  
				  FROM   dbo.RequestCl RCL
						 INNER JOIN dbo.Cargo C ON C.Id = RCL.IdCl
						 INNER JOIN NpePeb N ON C.Id = N.IdCl
				  WHERE  Year(RCL.CreateDate) = @year   
						 AND RCL.[Status] = 'Approve'   
						 AND RCL.IdStep IN ( 10020, 10022 )   
						 AND N.NpeNumber <> ''  
						 AND C.ExportType LIKE '' + @filter + '%'
				  GROUP  BY C.Id, C.PortOfLoading, C.PortOfDestination, C.ExportType, rcl.CreateDate) AS T1
	  GROUP BY	T1.PortOfLoading, T1.PortOfDestination
  END
GO
