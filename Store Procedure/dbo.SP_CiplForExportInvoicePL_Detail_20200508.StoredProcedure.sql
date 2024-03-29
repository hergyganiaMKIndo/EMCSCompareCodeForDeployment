USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_CiplForExportInvoicePL_Detail_20200508]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [dbo].[SP_CiplForExportInvoicePL_Detail] 10012
CREATE PROCEDURE [dbo].[SP_CiplForExportInvoicePL_Detail_20200508] 
	@CiplID bigint
AS
BEGIN
    select 
		ISNULL(CI.CaseNumber, '-') as CaseNumber
		, CAST(ROW_NUMBER() over (order by CI.Id) as nvarchar(5)) as ItemNo
		, IIF(CI.Name IS NULL OR LEN(CI.Name) <= 0, '-', CI.Name) as Name
		, IIF(CI.Sn IS NULL OR LEN(CI.Sn) <= 0, '-', CI.Sn) as Sn
		, IIF(CI.IdNo IS NULL OR LEN(CI.IdNo) <= 0, '-', CI.IdNo) as IdNo
		, ISNULL(CAST(CI.YearMade as varchar(4)), '-') as YearMade
		, CAST(ISNULL(CI.Quantity, 0) as varchar(5)) as Quantity
		, IIF(CI.PartNumber IS NULL OR LEN(CI.PartNumber) <= 0, '-', CI.PartNumber) as PartNumber
		, IIF(CI.JCode IS NULL OR LEN(CI.JCode) <= 0, '-', CI.JCode) as JCode
		, IIF(CI.Ccr IS NULL OR LEN(CI.Ccr) <= 0, '-', CI.Ccr) as Ccr
		, IIF(CI.Type IS NULL OR LEN(CI.Type) <= 0, '-', CI.Type) as Type
		, IIF(CI.ReferenceNo IS NULL OR LEN(CI.ReferenceNo) <= 0, '-', CI.ReferenceNo) as ReferenceNo
		, CAST(ISNULL(FORMAT(CI.Length, '#,0.00'), 0) as varchar(10)) as Length
		, CAST(ISNULL(FORMAT(CI.Width, '#,0.00'), 0) as varchar(10)) as Width
		, CAST(ISNULL(FORMAT(CI.Height, '#,0.00'), 0) as varchar(10)) as Height
		, CAST(FORMAT(CAST(ISNULL(CI.Length, 0) * ISNULL(CI.Width, 0) * ISNULL(CI.Height, 0) as decimal(18,2)), '#,0.00') as varchar(20)) as Volume
		, CAST(ISNULL(FORMAT(CI.NetWeight, '#,0.00'), 0) as varchar(10)) as NetWeight
		, CAST(ISNULL(FORMAT(CI.GrossWeight, '#,0.00'), 0) as varchar(10)) as GrossWeight
		, CONCAT(CI.Currency, ' ', FORMAT(ISNULL(CI.UnitPrice, 0), '#,0.00')) as UnitPrice
		, CONCAT(CI.Currency, ' ', FORMAT(ISNULL(CI.ExtendedValue, 0), '#,0.00')) as ExtendedValue
		, ISNULL(CI.SIBNumber, '-') as SIBNumber
		, ISNULL(CI.WONumber, '-') as WONumber
		, ISNULL(C.VesselFlight, '-') as VesselFlight
		, ISNULL(CI.CoO, '-') as CoO
		, ISNULL(CC.EdoNumber, '-') as EDINo
	from CiplItem CI 
	left join CargoCipl CC ON CC.IdCipl = CI.IdCipl
	left join Cargo C ON C.Id = CC.IdCargo
	where CI.IdCipl = @CiplID and CI.IsDelete = 0 
	order by CI.CaseNumber ASC
END
GO
