USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Report_Total_Export_Port]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[Sp_Report_Total_Export_Port] '2020'
CREATE PROCEDURE [dbo].[Sp_Report_Total_Export_Port] (@year NVARCHAR(4)) 
AS 
  BEGIN 
      SELECT C.PortOfLoading, 
             C.PortOfDestination, 
             ISNULL(Count(RCL.Id), 0) Total 
      FROM   dbo.RequestCl RCL 
             INNER JOIN dbo.Cargo C 
                     ON C.Id = RCL.IdCl 
					 INNER JOIN NpePeb N
					 ON C.Id = N.IdCl
      WHERE  Year(RCL.CreateDate) = @year 
             AND RCL.Status = 'Approve' 
             AND RCL.IdStep IN ( 10020, 10022 ) 
			 AND N.NpeNumber<>''
      GROUP  BY C.PortOfLoading, 
                C.PortOfDestination 
  END
GO
