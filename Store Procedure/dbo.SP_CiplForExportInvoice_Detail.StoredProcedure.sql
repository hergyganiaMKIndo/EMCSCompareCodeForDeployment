USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_CiplForExportInvoice_Detail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CiplForExportInvoice_Detail]
	@CiplID bigint
AS
BEGIN
    select ISNULL(CaseNumber, '-') as CaseNumber, 
	CAST(ROW_NUMBER() over (order by Id) as varchar(5)) as ItemNo, Name, cast(1 as varchar(5)) as Quantity, PartNumber = 'PartNumber', ISNULL(JCode, '-') as JCode, 
	CONCAT(Currency,' ',FORMAT(UnitPrice, '#,0.00')) as UnitPrice, CONCAT(Currency,' ',FORMAT(ExtendedValue, '#,0.00')) as ExtendedValue
	from CiplItem where IdCipl = @CiplID order by CaseNumber
END
GO
