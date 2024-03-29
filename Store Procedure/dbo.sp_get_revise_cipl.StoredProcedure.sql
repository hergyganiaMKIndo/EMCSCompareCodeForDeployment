USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_revise_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCedure [dbo].[sp_get_revise_cipl] -- exec sp_get_revise_cipl 1
(
	@IdCipl bigint = 0,
	@isTotal bit = 0
)
as 
BEGIN
	IF @isTotal = 0
	BEGIN
		SELECT
			t1.CiplNo
			, t2.CaseNumber
			, t2.Ccr
			, t2.PartNumber
			, t2.Currency
			, t2.ExtendedValue
			, t2.JCode
			, t2.Sn
			, t2.Quantity
			, t2.Type
			, t2.UnitPrice
			, t2.Uom
			, t2.Name
			, t2.Volume
			, t2.YearMade 
			, t0.NewLength
			, t0.NewWidth
			, t0.NewHeight
			, t0.NewNetWeight
			, t0.NewGrossWeight
			, (t0.NewLength * t0.NewWidth * t0.NewHeight) NewDimension
			, t0.OldLength
			, t0.OldWidth
			, t0.OldHeight
			, t0.OldNetWeight
			, t0.OldGrossWeight 
			, (t0.OldLength * t0.OldWidth * t0.OldHeight) OldDimension
		FROM dbo.CiplItemUpdateHistory t0
		INNER JOIN dbo.Cipl as t1 on t1.id = t0.IdCipl
		INNER JOIN dbo.CiplItem t2 on t2.id = t0.IdCiplItem
		WHERE t0.IdCipl = @IdCipl
	END
	ELSE 
	BEGIN
		SELECT count(*) total
		FROM dbo.CiplItemUpdateHistory t0
		INNER JOIN dbo.Cipl as t1 on t1.id = t0.IdCipl
		INNER JOIN dbo.CiplItem t2 on t2.id = t0.IdCiplItem
		WHERE t0.IdCipl = @IdCipl
	END
END
GO
