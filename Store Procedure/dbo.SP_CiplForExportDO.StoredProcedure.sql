USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_CiplForExportDO]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CiplForExportDO]
	@CiplID bigint
AS
BEGIN
    select 
		ISNULL(c.EdoNo, '-') as EdoNo
		, ISNULL(CONVERT(VARCHAR(9), ch.UpdateDate, 6), '-') as ApprovedDate
		, ISNULL(c.CiplNo, '-') as CiplNo
		--, 'PT. Trakindo Utama' + IIF(c.Area IS NULL OR LEN(RTRIM(LTRIM(c.Area))) <= 0, '', ' - ' + c.Area) as Area
		, 'PT. Trakindo Utama' + IIF(pl.PlantName IS NOT NULL, ' ' + pl.PlantName, '') as Area
		, e.Employee_Name as RequestorName
		, e.Email as RequestorEmail
		, IIF(c.ConsigneeName IS NULL OR LEN(c.ConsigneeName) <= 0, '-', c.ConsigneeName) as ConsigneeName
		, IIF(c.ConsigneeAddress IS NULL OR LEN(c.ConsigneeAddress) <= 0, '-', c.ConsigneeAddress) as ConsigneeAddress
		, IIF(c.ConsigneePic IS NULL OR LEN(c.ConsigneePic) <= 0, '-', c.ConsigneePic) as ConsigneePic
		, IIF(c.ConsigneeEmail IS NULL OR LEN(c.ConsigneeEmail) <= 0, '-', c.ConsigneeEmail) as ConsigneeEmail
		, IIF(c.NotifyName IS NULL OR LEN(c.NotifyName) <= 0, '-', c.NotifyName) as NotifyName
		, IIF(c.NotifyAddress IS NULL OR LEN(c.NotifyAddress) <= 0, '-', c.NotifyAddress) as NotifyAddress
		, IIF(c.NotifyPic IS NULL OR LEN(c.NotifyPic) <= 0, '-', c.NotifyPic) as NotifyPic
		, IIF(c.NotifyEmail IS NULL OR LEN(c.NotifyEmail) <= 0, '-', c.NotifyEmail) as NotifyEmail
			--, ISNULL(sm.Name, '-') as ShippingMethod		
		, IIF(c.ShippingMethod IS NULL OR LEN(c.ShippingMethod) <= 0, '-', c.ShippingMethod) as ShippingMethod
			--, ISNULL(et.Name, '-') as ExportType
		, IIF(c.ExportType IS NULL OR LEN(c.ExportType) <= 0, '-', c.ExportType) as ExportType
		, IIF(c.IncoTerm IS NULL OR LEN(c.IncoTerm) <= 0, '-', c.IncoTerm) as TermOfDelivery
			--, ISNULL(fp.Name, '-') as FreightPayment
		, IIF(c.FreightPayment IS NULL OR LEN(c.FreightPayment) <= 0, '-', c.FreightPayment) as FreightPayment
		, IIF(c.LoadingPort IS NULL OR LEN(c.LoadingPort) <= 0, '-', c.LoadingPort) as LoadingPort
		, IIF(c.DestinationPort IS NULL OR LEN(c.DestinationPort) <= 0, '-', c.DestinationPort) as DestinationPort
		, ISNULL(ci.TotalQuantity, '-') as TotalQuantity
		, ISNULL(ci.TotalVolume, '0') as TotalVolume
		, ISNULL(ci.NetWeight, '0') as TotalNetWeight
		, ISNULL(ci.GrossWeight, '0') as TotalGrossWeight
		, ISNULL(ci.TotalCaseNumber, '0') as TotalCaseNumber
		, IIF(c.SpecialInstruction IS NULL OR LEN(c.SpecialInstruction) <= 0, '-', c.SpecialInstruction) as SpecialInstruction		
			--c.ExportType + ' - ' + c.Remarks as CargoDescription
		, c.Category + IIF(p.Value = 4, ' (NCV) ', ' ') + 'WITH' as CargoDescription
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
	from Cipl c
	left join (
		select 
			c.id
			, CAST(FORMAT(SUM(ISNULL(ci.Quantity, 0)), '#,0') as varchar(20)) as TotalQuantity
			, CAST(count(ci.Id) as varchar(5)) as TotalCaseNumber
			--, CAST(count(distinct ISNULL(CaseNumber, '-')) as varchar(5)) as TotalCaseNumber
			, CAST(FORMAT(SUM(CAST(ISNULL(ci.Width,0) * ISNULL(ci.Length, 0) * ISNULL(ci.Height,0) as decimal(18,2))), '#,0.00') as varchar(20)) as TotalVolume
			, CAST(FORMAT(SUM(ISNULL(ci.NetWeight, 0)) , '#,0.00') as varchar(20)) as NetWeight
			, CAST(FORMAT(SUM(CAST(ISNULL(ci.GrossWeight, 0)  as decimal(18,2))) , '#,0.00') as varchar(20))  as GrossWeight			
		from Cipl c
		left join CiplItem ci on c.id=ci.IdCipl
		group by c.id
	)ci on c.id = ci.id
	outer apply(
		select top 1 * from CiplHistory where IdCipl = c.id order by id desc
	) ch
	left join (select Value, Name from MasterParameter where [Group] like 'ShippingMethod') sm on c.ShippingMethod = sm.Value
	left join (select Value, Name from MasterParameter where [Group] like 'ExportType') et on c.ShippingMethod = et.Value
	left join (select Value, Name from MasterParameter where [Group] like 'FreightPayment') fp on c.ShippingMethod = fp.Value
	inner join fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join MasterParameter p on c.ExportType = p.Name
	left join MasterPlant pl on right(pl.PlantCode, 3) = right(c.Area, 3)
	left join fn_get_cipl_request_list_all() r on c.id = r.IdCipl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	where c.id = @CiplID
END
GO
