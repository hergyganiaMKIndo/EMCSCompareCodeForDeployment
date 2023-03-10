USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_total_cipl_20200612]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- ALTER date: 8 Des 2019
-- Description:	Function untuk mengambil total tiap Cipl
-- =============================================
CREATE FUNCTION [dbo].[fn_get_total_cipl_20200612]
(	
	-- Add the parameters for the function here
	@CiplId bigint = 0
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		IdCipl, 
		t1.CiplNo CiplNumber,
		SUM(Volume) TotalVolume,
		SUM(NetWeight) TotalNetWeight,
		SUM(GrossWeight) TotalGrossWeight,
		COUNT(DISTINCT 
			CASE 
			WHEN t1.CategoriItem = 'PRA' OR t1.CategoriItem = 'SIB' 
				THEN JCode 
			WHEN t1.CategoriItem = 'REMAN'
				THEN CaseNumber
			ELSE Sn END) AS TotalPackage
	FROM dbo.CiplItem t0
	LEFT JOIN dbo.Cipl t1 on t1.id = t0.IdCipl
	WHERE t0.IsDelete = 0 AND t0.IdCipl = @CiplId
	GROUP BY IdCipl, CiplNo
)
GO
