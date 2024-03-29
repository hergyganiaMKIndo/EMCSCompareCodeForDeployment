USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_RPTTUBranch_Loading]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create FUNCTION [dbo].[fn_RPTTUBranch_Loading]
(	
	-- Add the parameters for the function here
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
			PortOfLoading
			, count(DISTINCT AjuNumber) as TotalPEB
			, IIF(DATEPART(MONTH, PebDateNumeric) = 1, count(DISTINCT AjuNumber), 0) as TotalPEBJan
			, IIF(DATEPART(MONTH, PebDateNumeric) = 2, count(DISTINCT AjuNumber), 0) as TotalPEBFeb
			, IIF(DATEPART(MONTH, PebDateNumeric) = 3, count(DISTINCT AjuNumber), 0) as TotalPEBMar
			, IIF(DATEPART(MONTH, PebDateNumeric) = 4, count(DISTINCT AjuNumber), 0) as TotalPEBApr
			, IIF(DATEPART(MONTH, PebDateNumeric) = 5, count(DISTINCT AjuNumber), 0) as TotalPEBMay
			, IIF(DATEPART(MONTH, PebDateNumeric) = 6, count(DISTINCT AjuNumber), 0) as TotalPEBJun
			, IIF(DATEPART(MONTH, PebDateNumeric) = 7, count(DISTINCT AjuNumber), 0) as TotalPEBJul
			, IIF(DATEPART(MONTH, PebDateNumeric) = 8, count(DISTINCT AjuNumber), 0) as TotalPEBAug
			, IIF(DATEPART(MONTH, PebDateNumeric) = 9, count(DISTINCT AjuNumber), 0) as TotalPEBSep
			, IIF(DATEPART(MONTH, PebDateNumeric) = 10, count(DISTINCT AjuNumber), 0) as TotalPEBOct
			, IIF(DATEPART(MONTH, PebDateNumeric) = 11, count(DISTINCT AjuNumber), 0) as TotalPEBNov
			, IIF(DATEPART(MONTH, PebDateNumeric) = 12, count(DISTINCT AjuNumber), 0) as TotalPEBDec	
		from [dbo].[fn_get_approved_npe_peb]() 		
		group by PortOfLoading, DATEPART(MONTH, PebDateNumeric)
)
GO
