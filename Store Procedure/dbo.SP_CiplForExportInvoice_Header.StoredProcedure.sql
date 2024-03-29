USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_CiplForExportInvoice_Header]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CiplForExportInvoice_Header] 
	@CiplID bigint
AS
BEGIN
    select 
	ISNULL(c.CiplNo, '-') as CiplNo, ISNULL(CONVERT(VARCHAR(9), c.CreateDate, 6), '-') as CreateDate, ISNULL(c.Area, '-') as Area,e.Employee_Name as RequestorName, e.Email as RequestorEmail,
	ISNULL(c.ConsigneeName, '-') as ConsigneeName, ISNULL(c.ConsigneeAddress, '-') as ConsigneeAddress, ISNULL(c.ConsigneeTelephone, '-') as ConsigneeTelephone, ISNULL(c.ConsigneeFax, '-') as ConsigneeFax, ISNULL(c.ConsigneePic, '-') as ConsigneePic, ISNULL(c.ConsigneeEmail, '-') as ConsigneeEmail,
	ISNULL(c.NotifyName, '-') as NotifyName, ISNULL(c.NotifyAddress, '-') as NotifyAddress, ISNULL(c.NotifyTelephone, '-') as NotifyTelephone, ISNULL(c.NotifyFax, '-') as NotifyFax, ISNULL(c.NotifyPic, '-') as NotifyPic, ISNULL(c.NotifyEmail, '-') as NotifyEmail,
	ISNULL(ci.Currency, '-') as Currency, ISNULL(ci.TotalQuantity, '-') as TotalQuantity, ISNULL(ci.TotalCaseNumber, '-') as TotalCaseNumber, ISNULL(ci.TotalExtendedValue, '-') as TotalExtendedValue,
	case 
	when c.IncoTerm = 'EXW' 
		then c.IncoTerm + IIF(c.Area is not null, ' - ' + c.Area, '') 
	when c.IncoTerm = 'FCA' or c.IncoTerm = 'FAS' or c.IncoTerm = 'FOB' 
		then c.IncoTerm + IIF(c.LoadingPort is not null, ' - ' + c.LoadingPort, '')  
	when c.IncoTerm = 'CFR' or c.IncoTerm = 'CIF' or c.IncoTerm = 'CIP' or c.IncoTerm = 'CPT'or c.IncoTerm = 'DAT' 
		then c.IncoTerm + IIF(c.DestinationPort is not null, ' - ' + c.DestinationPort, '')  
	when c.IncoTerm = 'DAP' or c.IncoTerm = 'DDD' 
		then c.IncoTerm + IIF(c.ConsigneeName is not null, ' - ' + c.ConsigneeName, '') 
	else c.IncoTerm end as ShipmentTerm,
	ISNULL(c.ShippingMethod, '-') as ShippingMethod, ISNULL(c.LoadingPort, '-') as LoadingPort, ISNULL(c.DestinationPort, '-') as DestinationPort, 
	ISNULL(c.ShippingMarks, '-') as ShippingMarksDesc, ISNULL(c.Remarks, '-') as RemarksDesc
	from Cipl c
	left join (
		select c.id, MAX(ISNULL(ci.Currency, '-')) as Currency, CAST(count(ci.Id) as varchar(5)) as TotalQuantity, case
				when c.Category = 'CATERPILLAR SPAREPARTS' AND c.CategoriItem = 'SIB'
					then CAST(count(distinct ISNULL(ci.JCode, '-')) as varchar(5))
				when c.Category = 'CATERPILLAR SPAREPARTS' AND (c.CategoriItem = 'PRA' OR c.CategoriItem = 'Old Core')
					then CAST(count(distinct ISNULL(ci.CaseNumber, '-')) as varchar(5))
				else CAST(count(distinct ci.Sn) as varchar(5))
			end as TotalCaseNumber,
			CONCAT(MAX(ISNULL(ci.Currency, '-')),' ', FORMAT(sum(ISNULL(ci.ExtendedValue, 0)), '#,0.00')) as TotalExtendedValue
		from Cipl c
		left join CiplItem ci on c.id=ci.IdCipl
		group by c.id, c.Category, c.CategoriItem
	)ci on c.id = ci.id
	inner join employee e on c.CreateBy = e.AD_User
	where c.id = @CiplID
END
GO
