USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_Dashboard_ExchangeRate_Today]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_ExchangeRate_Today] '2022-01-01', '2015-08-08'

CREATE PROCEDURE [dbo].[SP_Dashboard_ExchangeRate_Today] (
	@date1 NVARCHAR(100)
	,@date2 NVARCHAR(100)
	
	)
AS
BEGIN	


SELECT  [ID]
      ,[Curr]
      ,[StartDate]
      ,[EndDate]
      ,[Rate]
      ,[CreateBy]
      ,[CreateDate]
      ,[UpdateBy]
      ,[UpdateDate]
  FROM [EMCS].[dbo].[MasterKurs] MK
  WHERE MK.StartDate BETWEEN CONVERT(DATETIME, @date1) AND CONVERT(DATETIME, @date2)
END
GO
