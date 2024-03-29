USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_CargoForExport_Header_20210208]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE [dbo].[SP_CargoForExport_Header_20210208]
	@CargoID bigint
AS
BEGIN

	declare @CiplNos nvarchar(MAX) = STUFF(
		(SELECT ', ' + CAST(cp.CiplNo as NVARCHAR) 
			FROM Cargo c
			left join CargoItem ci on c.Id = ci.IdCargo
			left join CiplItem cpi on ci.IdCiplItem = cpi.Id
			left join Cipl cp on cpi.IdCipl = cp.id
			where c.Id = '988' and ci.isDelete = 0 and cpi.IsDelete = 0
			GROUP BY cp.CiplNo
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')

    select 
		c.ClNo, ISNULL(CONVERT(VARCHAR(11) , ch.CreateDate, 106), '-') as SubmitDate
		, @CiplNos as Reference
		, IIF(cp.Forwader IS NOT NULL AND LEN(cp.Forwader) > 0, cp.Forwader + IIF(cp.Area IS NOT NULL AND LEN(cp.Area) > 0, ' - ' + cp.Area, ''), '-') as ConsolidatorWithArea
		, e.Employee_Name as RequestorName
		, e.Email as RequestorEmail
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as ConsigneeName
		, IIF(cp.ConsigneeAddress IS NULL OR LEN(cp.ConsigneeAddress) <= 0, '-', cp.ConsigneeAddress) as ConsigneeAddress
		, IIF(cp.ConsigneePic IS NULL OR LEN(cp.ConsigneePic) <= 0, '-', cp.ConsigneePic) as ConsigneePic
		, IIF(cp.ConsigneeEmail IS NULL OR LEN(cp.ConsigneeEmail) <= 0, '-', cp.ConsigneeEmail) as ConsigneeEmail
		, IIF(cp.NotifyName IS NULL OR LEN(cp.NotifyName) <= 0, '-', cp.NotifyName) as NotifyName
		, IIF(cp.NotifyAddress IS NULL OR LEN(cp.NotifyAddress) <= 0, '-', cp.NotifyAddress) as NotifyAddress
		, IIF(cp.NotifyPic IS NULL OR LEN(cp.NotifyPic) <= 0, '-', cp.NotifyPic) as NotifyPic
		, IIF(cp.NotifyEmail IS NULL OR LEN(cp.NotifyEmail) <= 0, '-', cp.NotifyEmail) as NotifyEmail
		, CAST(ISNULL(ct.TotalCaseNumber, 0) as varchar(20)) as TotalCaseNumber
		, CAST(ISNULL(FORMAT(ct.TotalVolume, '#,0.00'), 0) as varchar(20)) as TotalVolume
		, CAST(ISNULL(ct.TotalNetWeight, 0) as varchar(20)) as TotalNetWeight
		, CAST(ISNULL(ct.TotalGrossWeight, 0) as varchar(20)) as TotalGrossWeight
		, IIF(cp.IncoTerm IS NULL OR LEN(cp.IncoTerm) <= 0, '-', cp.IncoTerm) as Incoterms
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateStarted, 106), '-') as StuffingDateStarted
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateFinished, 106), '-') as StuffingDateFinished
		, IIF(c.VesselFlight IS NULL OR LEN(c.VesselFlight) <= 0, '-', c.VesselFlight) as VesselFlight
		, IIF(c.ConnectingVesselFlight IS NULL OR LEN(c.ConnectingVesselFlight) <= 0, '-', c.ConnectingVesselFlight) as ConnectingVesselFlight
		, IIF(c.PortOfLoading IS NULL OR LEN(c.PortOfLoading) <= 0, '-', c.PortOfLoading) as LoadingPort
		, IIF(c.PortOfDestination IS NULL OR LEN(c.PortOfDestination) <= 0, '-', c.PortOfDestination) as DestinationPort
		, ISNULL(CONVERT(VARCHAR(11), c.SailingSchedule, 106), '-') as SailingSchedule
		, ISNULL(CONVERT(VARCHAR(11), c.ArrivalDestination, 106), '-') as ETA
		, IIF(c.BookingNumber IS NULL OR LEN(c.BookingNumber) <= 0, '-', c.BookingNumber) as BookingNumber
		, ISNULL(CONVERT(VARCHAR(11), c.BookingDate, 106), '-') as BookingDate
		, IIF(c.Liner IS NULL OR LEN(c.Liner) <= 0, '-', c.Liner) as Liner
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
		, ISNULL(cp.ShipDelivery, '-') as ShipDelivery
	from Cargo c
	outer apply(
		select top 1* from CargoHistory where IdCargo = c.id and Step = 'Create' and Status = 'Submit' order by Id desc
	) ch
	left join (
		select 
			CargoID
			, COUNT(CaseNumber) as TotalCaseNumber
			, FORMAT(SUM(NetWeight), '#,0.00') as TotalNetWeight
			, FORMAT(SUM(GrossWeight), '#,0.00') as TotalGrossWeight
			, SUM(Volume) as TotalVolume
			, SUM(Amount) as TotalAmount 
		from (
			select 
				master.CargoID, master.CiplID
				,cpi.CaseNumber as CaseNumber
				--, COUNT(cpi.CaseNumber) as CaseNumber
				, (SUM(ci.Width * ci.Length * ci.Height) / 1000000) as Volume
				, SUM(ci.Net) as NetWeight
				, SUM(ci.Gross) as GrossWeight
				, SUM(cpi.UnitPrice) as Amount 
			from
			(
				select 
					ci.Id as CargoItemID
					, ci.IdCargo as CargoID
					, cpi.Id AS CiplItemID
					, cp.id as CiplID
				from CargoItem ci
				inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
				inner join Cipl cp on cpi.IdCipl=cp.id
			) master
			inner join CargoItem ci on master.CargoItemID = ci.Id
			inner join CiplItem cpi on master.CiplItemID = cpi.Id
			where master.CargoID = '988' and ci.isDelete = 0 and cpi.IsDelete = 0
			group by master.CargoID, master.CiplID, cpi.CaseNumber
		) data
		group by CargoID
	) ct on c.Id = ct.CargoID
	left join (
		select ci.IdCargo, max(cpi.IdCipl) as IdCipl from CargoItem ci
		inner join CiplItem cpi on ci.IdCiplItem = cpi.Id
		group by ci.IdCargo
	) cpi on c.Id = cpi.IdCargo
	outer apply(
		select top 1* from Cipl where id= cpi.IdCipl order by Id desc
	) cp
	inner join dbo.fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join fn_get_cl_request_list_all() r on c.id = r.IdCl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	where c.Id = '988'

END



GO
