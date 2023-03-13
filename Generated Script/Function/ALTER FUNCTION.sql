--Compared from DB EMCS on Development, DB EMCS_QA on QA, DB EMCS_Dev on Development on 10/03/2023
/****** Object:  UserDefinedFunction [dbo].[fn_ActivityReport_TotalExport_Outstanding]    Script Date: 10/03/2023 15:51:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_ActivityReport_TotalExport_Outstanding](
	--@year VARCHAR(7) = ''
)
RETURNS TABLE
AS
RETURN
(
	SELECT	DISTINCT a.id [IdCipl], a.CiplNo, a.ClNo, a.CreateDate, a.CreateBy, b.Step, b.[Status], b.UpdateDate
	FROM	Cipl a
			JOIN CiplHistory b ON a.id = b.IdCipl
	WHERE	a.IsDelete = 0
			AND b.IsDelete = 0
			AND b.Status = 'Approve'
			AND b.Step = 'Approval By Superior'
			AND (a.id NOT IN (SELECT	b.IdCipl
							FROM	NpePeb a
									JOIN CargoCipl b ON a.IdCl = b.IdCargo
							WHERE	a.IsDelete = 0
									AND b.IsDelete = 0
									AND b.IdCargo IN (
									SELECT	DISTINCT a.IdCargo
									FROM	CargoCipl a
											JOIN Cipl b ON a.IdCipl = b.id
									WHERE	a.IsDelete = 0
											AND b.IsDelete = 0 
											AND a.IdCipl IN (SELECT	DISTINCT a.id
														FROM	Cipl a
																JOIN CiplHistory b ON a.id = b.IdCipl
														WHERE	a.IsDelete = 0 
																AND b.IsDelete = 0
																AND b.Status = 'Approve'
																AND b.Step = 'Approval By Superior')))
			OR MONTH(a.CreateDate) < MONTH(GETDATE()))
)


GO


/****** Object:  UserDefinedFunction [dbo].[fn_get_approved_npe_peb]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_approved_npe_peb] ()
RETURNS TABLE 
AS
RETURN 
(
	select 
		CONVERT(VARCHAR(10), cp.CreateDate, 120) as CiplDate,
		ci.IdCargo, 
		ci.Id as IdCargoItem, 
		cpi.Id as IdCiplItem, 
		cp.id as IdCipl, 
		IIF(p.Value = 4, 'Sales', 'Non Sales') as ExportType,
		CONVERT(VARCHAR(10), rc.CreateDate, 120) as CreatedDate,
		c.ClNo,
		ISNULL(peb.AjuNumber, '-') as AjuNumber,
		ISNULL(peb.NpeNumber, '-') as NpeNumber,
		ISNULL(CONVERT(VARCHAR(11), peb.NpeDate, 106), '-') as NpeDate,
		IIF(cf.Attention IS NULL OR LEN(cf.Attention) <= 0, ISNULL(cf.Forwader, '-'), cf.Attention) as CustomBroker,
		IIF(cp.ShippingMethod IS NULL OR LEN(cp.ShippingMethod) <= 0, '-', cp.ShippingMethod) as ShippingMethod,
		IIF(c.CargoType IS NULL OR LEN(c.CargoType) <= 0, '-', c.CargoType) as CargoType,
		IIF(ci.ContainerNumber IS NULL OR LEN(ci.ContainerNumber) <= 0, '-', ci.ContainerNumber) as ContainerNumber,
		IIF(c.CargoType IS NULL OR LEN(c.CargoType) <= 0, '-', c.CargoType) as Name,
		ISNULL(cpi.GrossWeight, 0) as GrossWeight,
		IIF(
			LTRIM(RTRIM(CAST('<M>' + REPLACE(cp.ExportType, '-' , '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))
			IS NULL OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(cp.ExportType, '-' , '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) <= 0, IIF(CHARINDEX('Permanent', cp.ExportType) > 0, 'Permanent', '-'),--'-',
			LTRIM(RTRIM(CAST('<M>' + REPLACE(cp.ExportType, '-' , '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))
		) As PermanentTemporary,
		IIF(
			LTRIM(RTRIM(CAST('<M>' + REPLACE(cp.ExportType, '-' , '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))
			IS NULL OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(cp.ExportType, '-' , '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, '-',
			LTRIM(RTRIM(CAST('<M>' + REPLACE(cp.ExportType, '-' , '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))
		) As SalesNonSales,
		IIF(c.PortOfLoading IS NULL OR LEN(c.PortOfLoading) <= 0, '-', c.PortOfLoading) as PortOfLoading,
		IIF(c.PortOfDestination IS NULL OR LEN(c.PortOfDestination) <= 0, '-', c.PortOfDestination) as PortOfDestination,
		ISNULL(CONVERT(VARCHAR(11), c.SailingSchedule, 106), '-') as ETD,
		ISNULL(CONVERT(VARCHAR(11), c.ArrivalDestination, 106), '-') as ETA,
		IIF(bl.Number IS NULL OR LEN(bl.Number) <= 0, '-', bl.Number) as MasterBlAwbNumber,
		ISNULL(CONVERT(VARCHAR(11), bl.MasterBlDate, 106), '-') as MasterBlAwbDate,
		IIF(bl.HouseBlNumber IS NULL OR LEN(bl.HouseBlNumber) <= 0, '-', bl.HouseBlNumber) as HouseBlAwbNumber,
		ISNULL(CONVERT(VARCHAR(11), bl.HouseBlDate, 106), '-') as HouseBlAwbDate,
		IIF(c.SsNo IS NULL OR LEN(c.SsNo) <= 0, '-', c.SsNo) as SsNo,
		ISNULL(CONVERT(VARCHAR(11), peb.PebDate, 106), '-') as PebDate,		
		CONCAT(LEFT(DATENAME(MONTH, peb.PebDate), 3),'-', DATEPART(YEAR, peb.PebDate)) as PebMonth,
		CONCAT(DATEPART(YEAR, peb.PebDate), '-', DATEPART(MONTH, peb.PebDate), '-', DATEPART(DAY, peb.PebDate)) as PebDateNumeric,
		IIF(LEN(cp.IncoTerm) <= 0, '-', cp.IncoTerm) as IncoTerm,
		IIF(cpi.Currency IS NULL OR LEN(cpi.Currency) <= 0, 
			IIF(cp.Currency IS NULL OR LEN(cp.Currency) <= 0, '-', cp.Currency)
		, cpi.Currency) as Currency,
		ISNULL(cpi.UnitPrice, 0) as UnitPrice,
		ISNULL(peb.FreightPayment, 0) as FreightPayment,
		ISNULL(peb.InsuranceAmount, 0) as InsuranceAmount,
		ISNULL(cpi.UnitPrice, 0) + ISNULL(peb.FreightPayment, 0) + ISNULL(peb.InsuranceAmount, 0) as TotalAmount,
		IIF(cp.CiplNo IS NULL OR LEN(cp.CiplNo) <= 0, '-', cp.CiplNo) as CiplNo,
		IIF(a.BAreaName IS NULL OR LEN(a.BAreaName) <= 0, '-', a.BAreaName) as Branch,
		ISNULL(CONVERT(VARCHAR(11), cp.CreateDate, 106), '-') as CiplCreateDate,
		IIF(cp.Remarks IS NULL OR LEN(cp.Remarks) <= 0, '-', cp.Remarks) as Remarks,
		IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as ConsigneeName,
		IIF(cp.ConsigneeCountry IS NULL OR LEN(cp.ConsigneeCountry) <= 0, '-', cp.ConsigneeCountry) as ConsigneeCountry,
		IIF(mc.CustName IS NULL OR LEN(mc.CustName) <= 0, '-', mc.CustName) as CustomerName,
		IIF(mc.Country IS NULL OR LEN(mc.Country) <= 0, '-', mc.Country) as CustomerCountry,
		IIF(LEN(cp.Category) <= 0, '-', cp.Category) as Category, 
		IIF(cpi.CaseNumber IS NULL OR LEN(cpi.CaseNumber) <= 0, '-', cpi.CaseNumber) as CaseNumber,
		ISNULL(cpi.Quantity, 0) as Quantity,
		IIF(cpi.Uom IS NULL OR LEN(cpi.Uom) <= 0, '-', cpi.Uom) as QuantityUom,
		ISNULL(cpi.NetWeight, 0) as Weight,
		'KGS' as WeightUom,
		ISNULL(cpi.ExtendedValue, 0) as ExtendedValue, 
		ISNULL(mkUSD.Rate, 0) as USDRate,
		ISNULL(mk.Rate, 0) as CurrencyRate,
		ISNULL(cpi.ExtendedValue, 0) * IIF(mkUSD.Rate IS NULL, ISNULL(mk.Rate, 0), ISNULL(mk.Rate, 0) / mkUSD.Rate) as USDTotalExport,
		ISNULL(cpi.ExtendedValue, 0) * ISNULL(mk.Rate, 0) as IDRTotalExport,
		IIF(p.Value = 4, cpi.ExtendedValue * IIF(mkUSD.Rate IS NULL, ISNULL(mk.Rate, 0), ISNULL(mk.Rate, 0) / mkUSD.Rate), 0) as SalesValue,
		IIF(p.Value = 4, 0, cpi.ExtendedValue * IIF(mkUSD.Rate IS NULL, ISNULL(mk.Rate, 0), ISNULL(mk.Rate, 0) / mkUSD.Rate)) as NonSalesValue,
		peb.PebDate PebData

	from Temptable_cl_request_list_all rc
	--RequestCl rc 
	--inner join FlowStep fs on rc.IdStep = fs.Id
	inner join Cargo c on rc.IdCl = c.Id
	left join CargoItem ci on rc.IdCl = ci.IdCargo
	left join CiplItem cpi on ci.IdCiplItem = cpi.Id
	left join Cipl cp on cpi.IdCipl = cp.id
	left join CiplForwader cf on cp.id = cf.IdCipl 
	left join MasterArea a on right(cp.Branch,3) = right(a.BAreaCode,3)
	left join MasterParameter p on cp.ExportType = p.Name
	left join NpePeb peb on rc.IdCl = peb.IdCl 
	left join BlAwb bl on rc.IdCl = bl.IdCl 
	outer apply( 
		select top 1 * from MasterCustomer where CustNr = cpi.IdCustomer order by ID desc
	)mc
	left join MasterKurs mk on mk.Curr = ISNULL(cpi.Currency, cp.Currency) and CONVERT(VARCHAR(11), cpi.CreateDate, 23) >= mk.StartDate and CONVERT(VARCHAR(11), cpi.CreateDate, 23) <= mk.EndDate
	left join MasterKurs mkUSD on mkUSD.Curr = 'USD' and CONVERT(VARCHAR(11), cpi.CreateDate, 23) >= mkUSD.StartDate and CONVERT(VARCHAR(11), cpi.CreateDate, 23) <= mkUSD.EndDate
	where (rc.IdStep = 10020 and rc.Status = 'Approve') or rc.IdStep = 10021 or (rc.IdStep = 10022 and (rc.Status = 'Submit' or rc.Status = 'Approve'))
	AND Cp.IsDelete = 0 ANd cp.CreateBy<>'System'
	--rc.Status = 'Approve' and fs.Step = 'Approve NPE & PEB'
)


GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_cipl_businessarea_list]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[fn_get_cipl_businessarea_list]
(	
	@PlantCode nvarchar(50) = ''
)
RETURNS TABLE 
AS
RETURN 
(
		SELECT
		  MasterPlant.PlantCode
		  ,MasterPlant.PlantName
		  ,MasterArea.BAreaCode
		  ,MasterArea.BAreaName
	  FROM [EMCS].[dbo].[MasterPlant]
	  join MasterArea on MasterPlant.PlantCode = MasterArea.BAreaCode
	  WHERE PlantCode =IIF(ISNULL(@PlantCode, '') = '', PlantCode, @PlantCode )
	 
		 
)
GO


/****** Object:  UserDefinedFunction [dbo].[fn_get_cipl_request_list_all]    Script Date: 10/03/2023 11:40:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Ali Mutasal
-- ALTER date	: 2019-11
-- Description	: 
-- =============================================
ALTER FUNCTION [dbo].[fn_get_cipl_request_list_all] -- select * from [fn_get_cipl_request_list_all]() where id = 3
(	
--	-- Add the parameters for the function here
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
	  select 
			t0.[Id]		
			,t0.[IdCipl]	
			,t0.[IdFlow]	
			,t0.[IdStep]	
			,t0.[Status]	
			,t0.[Pic]		
			,t0.[CreateBy]	
			,t0.[CreateDate]	
			,t0.[UpdateBy]		
			,t0.[UpdateDate]	
			,t0.[IsDelete]		
			, t3.Name FlowName
			, t3.Type SubFlowType
			, [dbo].[fn_get_next_step_id](
					t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.Status), t0.Id
			  ) as IdNextStep 
			, [dbo].[fn_get_step_name]([dbo].[fn_get_next_step_id](
					t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.Status), t0.Id)
			  ) as NextStepName
			, [dbo].[fn_get_next_assignment_type](
					t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id
			  ) NextAssignType
			, CASE WHEN [dbo].[fn_get_next_step_id](
					t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.Status), t0.Id
			  ) IN (14, 10024, 10028) THEN 'Pickup Goods' ELSE t1.ViewByUser END NextStatusViewByUser
			--, t1.ViewByUser NextStatusViewByUser
			, t2.CiplNo
			, t2.Category
			, t2.ETD
			, t2.ETA
			, t2.LoadingPort
			, t2.DestinationPort
			, t2.ShippingMethod
			, t4.Forwader
			, t2.ConsigneeCountry
			, CASE WHEN ISNULL(t6.AssignType, '') <> '' 
			  THEN
				t6.AssignType
			  ELSE
				[dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) 
			  END 
			  as AssignmentType
			, CASE WHEN ISNULL(t6.AssignTo, '') <> '' 
			  THEN 
			  	t6.AssignTo
			  ELSE
				CASE WHEN LOWER(t1.NextAssignType) = 'user'
				THEN
					t1.NextAssignTo
				ELSE
					[dbo].[fn_get_next_approval] ([dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id), t0.Pic, t1.NextAssignTo, t0.CreateBy, '0') 			  	
				END
			  END as NextAssignTo
			 , t5.Business_Area as BAreaUser
		from dbo.RequestCipl t0
		left join (
			select 
				nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep, 
				nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep, 
				ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, 
				ns.ViewByUser,
				nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName
			from dbo.FlowNext nx
			join dbo.FlowStatus ns on ns.Id = nx.IdStatus
			join dbo.FlowStep np on np.Id = ns.IdStep
			join dbo.Flow nf on nf.Id = np.IdFlow
			join dbo.FlowStep nt on nt.Id = nx.IdStep
		) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status
		inner join dbo.Cipl t2 on t2.id = t0.IdCipl 
		inner join dbo.Flow t3 on t3.id = t0.IdFlow
		left join dbo.CiplForwader t4 on t4.IdCipl = t0.IdCipl
		left join dbo.fn_get_employee_internal_ckb() as t5 on t5.AD_User = t0.CreateBy
		left join dbo.FlowDelegation as t6 on t6.IdFlow = t0.IdFlow AND t6.IdStep = t0.IdStep AND t6.IdReq = t0.Id
	) as tab0 
	--WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)
)
GO


/****** Object:  UserDefinedFunction [dbo].[fn_get_cipl_request_list]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- ALTER date: 24 Nov 2019
-- Description:	sp untuk mengambil list task cipl
-- =============================================
ALTER FUNCTION [dbo].[fn_get_cipl_request_list] -- select * from fn_get_cipl_request_list('xupj21enk', 'Requestor') 
(	
	-- Add the parameters for the function here
	@Username nvarchar(100),
	@GroupId nvarchar(100)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
	  select 
			t0.[Id]		
			,t0.[IdCipl]	
			,t0.[IdFlow]	
			,t0.[IdStep]	
			,t0.[Status]	
			,t0.[Pic]		
			,t0.[CreateBy]	
			,t0.[CreateDate]	
			,t0.[UpdateBy]		
			,t0.[UpdateDate]	
			,t0.[IsDelete]		
			, t3.Name FlowName
			, t3.Type SubFlowType
			, [dbo].[fn_get_next_step_id](
					t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.Status), t0.Id
			  ) as IdNextStep 
			, [dbo].[fn_get_step_name]([dbo].[fn_get_next_step_id](
					t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.Status), t0.Id)
			  ) as NextStepName
			, [dbo].[fn_get_next_assignment_type](
					t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id
			  ) NextAssignType
			, CASE WHEN [dbo].[fn_get_next_step_id](
					t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.Status), t0.Id
			  ) IN (14, 10024, 10028) THEN 'Pickup Goods' ELSE t1.ViewByUser END NextStatusViewByUser
			--, t1.ViewByUser NextStatusViewByUser
			, t2.CiplNo
			, t2.Category
			, t2.ETD
			, t2.ETA
			, t2.LoadingPort
			, t2.DestinationPort
			, t2.ShippingMethod
			, t4.Forwader
			, t2.ConsigneeCountry
			, CASE WHEN ISNULL(t6.AssignType, '') <> '' 
			  THEN
				t6.AssignType
			  ELSE
				[dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) 
			  END 
			  as AssignmentType
			, CASE WHEN ISNULL(t6.AssignTo, '') <> '' 
			  THEN 
			  	t6.AssignTo
			  ELSE
			  	CASE WHEN LOWER(t1.NextAssignType) = 'user'
				THEN
					t1.NextAssignTo
				ELSE
					[dbo].[fn_get_next_approval] ([dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id), t0.Pic, t1.NextAssignTo, t0.CreateBy, '0') 			  	
				END
			  END as NextAssignTo
			, t5.Business_Area as BAreaUser
		from dbo.RequestCipl t0
		left join (
			select 
				nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep, 
				nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep, 
				ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, 
				ns.ViewByUser,
				nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName
			from dbo.FlowNext nx
			join dbo.FlowStatus ns on ns.Id = nx.IdStatus
			join dbo.FlowStep np on np.Id = ns.IdStep
			join dbo.Flow nf on nf.Id = np.IdFlow
			join dbo.FlowStep nt on nt.Id = nx.IdStep
		) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status
		inner join dbo.Cipl t2 on t2.id = t0.IdCipl 
		inner join dbo.Flow t3 on t3.id = t0.IdFlow
		left join dbo.CiplForwader t4 on t4.IdCipl = t0.IdCipl
		left join dbo.fn_get_employee_internal_ckb() as t5 on t5.AD_User = t0.CreateBy
		left join dbo.FlowDelegation as t6 on t6.IdFlow = t0.IdFlow AND t6.IdStep = t0.IdStep AND t6.IdReq = t0.Id
	) as tab0 
	WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_cl_request_list_20210222]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[fn_get_cl_request_list_20210222] -- select * from [fn_get_cl_request_list]('xupj21wdn', 'Import Export') 
(	
	-- Add the parameters for the function here
	@Username nvarchar(100),
	@GroupId nvarchar(100)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
	  select t0.[Id]		
			,t0.IdCl	
			,t0.[IdFlow]	
			,t0.[IdStep]	
			,t0.[Status]	
			,t0.[Pic]		
			,t0.[CreateBy]	
			,t0.[CreateDate]	
			,t0.[UpdateBy]		
			,t0.[UpdateDate]	
			,t0.[IsDelete]		
			,t3.Name FlowName
			,t3.Type SubFlowType
			, [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) as IdNextStep 
			, [dbo].[fn_get_step_name](
					[dbo].[fn_get_next_step_id](
						t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
					)
			  ) as NextStepName
			, [dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) NextAssignType
			, CASE WHEN t11.Step = 'System' THEN t8.ViewByUser ELSE t1.ViewByUser END as StatusViewByUser
			, t1.CurrentStep
			, t2.ClNo
			, t2.BookingNumber
			, t2.BookingDate
			, t2.PortOfLoading
			, t2.PortOfDestination
			, t2.Liner
			, t2.SailingSchedule ETD
			, t2.ArrivalDestination ETA
			, t2.VesselFlight
			, t2.Consignee
			, t2.StuffingDateStarted
			, t2.StuffingDateFinished
			, t5.AD_User
			, t4.FullName
			, t5.Employee_Name
			, CASE WHEN ISNULL(t5.AD_User, '') <> '' THEN t4.FullName ELSE CASE WHEN ISNULL(t5.Employee_Name, '') <> '' THEN t5.Employee_Name ELSE t4.FullName END END PreparedBy 
			, t7.AssignType as AssignmentType
			, [dbo].[fn_get_next_approval] (t7.AssignType, t0.Pic, t7.AssignTo, t0.CreateBy, t0.Id) as NextAssignTo
			, t6.SpecialInstruction
			, t6.SlNo
			, t6.Description
			, t6.DocumentRequired
			, t2.ShippingMethod
			, t12.AjuNumber as PebNumber
			, t2.SailingSchedule
			, t2.ArrivalDestination
			, t6.PicBlAwb
		from dbo.RequestCl t0
		left join (
			select 
				nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep, 
				nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep, 
				ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,
				nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName
			from dbo.FlowNext nx
			join dbo.FlowStatus ns on ns.Id = nx.IdStatus
			join dbo.FlowStep np on np.Id = ns.IdStep
			join dbo.Flow nf on nf.Id = np.IdFlow
			join dbo.FlowStep nt on nt.Id = nx.IdStep
		) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status
		inner join dbo.Cargo t2 on t2.id = t0.IdCl 
		inner join dbo.Flow t3 on t3.id = t0.IdFlow
		left join PartsInformationSystem.dbo.UserAccess t4 on t4.UserID = t2.CreateBy
		left join employee t5 on t5.AD_User = t2.CreateBy
		left join dbo.ShippingInstruction t6 on t6.IdCL = t0.IdCl		
		left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) and t7.IdFlow = t1.IdFlow
		left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  )
		left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep
		left join dbo.FlowNext t10 on t10.IdStatus = t9.Id
		left join dbo.FlowStep t11 on t11.Id = t10.IdStep
		left join dbo.NpePeb t12 on t12.IdCl = t2.Id
		WHERE t0.CreateBy <> 'System' and t2.CreateBy <> 'System'
	) as tab0 
	WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)
)
GO


/****** Object:  UserDefinedFunction [dbo].[fn_get_cl_request_list_20210721]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_cl_request_list_20210721] -- select * from [fn_get_cl_request_list]('xupj21wdn', 'Import Export') 
(	
	-- Add the parameters for the function here
	@Username nvarchar(100),
	@GroupId nvarchar(100),
	@Pic nvarchar(100)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
	  select t0.[Id]		
			,t0.IdCl	
			,t0.[IdFlow]	
			,t0.[IdStep]	
			,t0.[Status]	
			,t0.[Pic]		
			,t0.[CreateBy]	
			,t0.[CreateDate]	
			,t0.[UpdateBy]		
			,t0.[UpdateDate]	
			,t0.[IsDelete]		
			,t3.Name FlowName
			,t3.Type SubFlowType
			, [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) as IdNextStep 
			, [dbo].[fn_get_step_name](
					[dbo].[fn_get_next_step_id](
						t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
					)
			  ) as NextStepName
			, [dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) NextAssignType
			, CASE WHEN t11.Step = 'System' THEN t8.ViewByUser ELSE t1.ViewByUser END as StatusViewByUser
			, t1.CurrentStep
			, t2.ClNo
			, t2.BookingNumber
			, t2.BookingDate
			, t2.PortOfLoading
			, t2.PortOfDestination
			, t2.Liner
			, t2.SailingSchedule ETD
			, t2.ArrivalDestination ETA
			, t2.VesselFlight
			, t2.Consignee
			, t2.StuffingDateStarted
			, t2.StuffingDateFinished
			, t5.AD_User
			, t4.FullName
			, t5.Employee_Name
			, CASE WHEN ISNULL(t5.AD_User, '') <> '' THEN t4.FullName ELSE CASE WHEN ISNULL(t5.Employee_Name, '') <> '' THEN t5.Employee_Name ELSE t4.FullName END END PreparedBy 
			, t7.AssignType as AssignmentType
			, [dbo].[fn_get_next_approval] (t7.AssignType, t0.Pic, t7.AssignTo, t0.CreateBy, t0.Id) as NextAssignTo
			, t6.SpecialInstruction
			, t6.SlNo
			, t6.Description
			, t6.DocumentRequired
			, t2.ShippingMethod
			, t12.AjuNumber as PebNumber
			, t2.SailingSchedule
			, t2.ArrivalDestination
			, t6.PicBlAwb
		from dbo.RequestCl t0
		left join (
			select 
				nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep, 
				nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep, 
				ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,
				nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName
			from dbo.FlowNext nx
			join dbo.FlowStatus ns on ns.Id = nx.IdStatus
			join dbo.FlowStep np on np.Id = ns.IdStep
			join dbo.Flow nf on nf.Id = np.IdFlow
			join dbo.FlowStep nt on nt.Id = nx.IdStep
		) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status
		inner join dbo.Cargo t2 on t2.id = t0.IdCl 
		inner join dbo.Flow t3 on t3.id = t0.IdFlow
		left join PartsInformationSystem.dbo.UserAccess t4 on t4.UserID = t2.CreateBy
		left join employee t5 on t5.AD_User = t2.CreateBy
		left join dbo.ShippingInstruction t6 on t6.IdCL = t0.IdCl		
		left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) and t7.IdFlow = t1.IdFlow
		left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  )
		left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep
		left join dbo.FlowNext t10 on t10.IdStatus = t9.Id
		left join dbo.FlowStep t11 on t11.Id = t10.IdStep
		left join dbo.NpePeb t12 on t12.IdCl = t2.Id
		WHERE t0.CreateBy <> 'System' and t0.IsDelete = 0  and t2.CreateBy <> 'System'
	) as tab0 
	WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId OR tab0.PicBlAwb = @Pic)
)

GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_cl_request_list_all_bckp]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_cl_request_list_all_bckp] ()
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
	  select t0.[Id]		
			,t0.IdCl	
			,t0.[IdFlow]	
			,t0.[IdStep]	
			,t0.[Status]	
			,t0.[Pic]		
			,t6.SlNo
			,t0.[CreateBy]	
			,t0.[CreateDate]	
			,t0.[UpdateBy]		
			,t0.[UpdateDate]	
			,t0.[IsDelete]		
			,t3.Name FlowName
			,t3.Type SubFlowType
			, [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) as IdNextStep 
			, [dbo].[fn_get_step_name](
					[dbo].[fn_get_next_step_id](
						t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
					)
			  ) as NextStepName
			, [dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) NextAssignType
			, CASE WHEN t11.Step = 'System' THEN t8.ViewByUser ELSE t1.ViewByUser END as StatusViewByUser
			, t1.CurrentStep
			, t2.ClNo
			, t2.SailingSchedule ETD
			, t2.ArrivalDestination ETA
			, t2.BookingNumber
			, t2.BookingDate
			, t2.PortOfLoading
			, t2.PortOfDestination
			, t2.Liner
			, t2.SailingSchedule
			, t2.ArrivalDestination
			, t2.VesselFlight
			, t2.Consignee
			, t2.StuffingDateStarted
			, t2.StuffingDateFinished
			, CASE WHEN ISNULL(t5.AD_User, '') <> '' THEN t4.FullName ELSE CASE WHEN ISNULL(t5.Employee_Name, '') <> '' THEN t5.Employee_Name ELSE t4.FullName END END PreparedBy 
			, t7.AssignType as AssignmentType
			, [dbo].[fn_get_next_approval] (t7.AssignType, t0.Pic, t7.AssignTo, t0.CreateBy, t0.Id) as NextAssignTo
			, t6.SpecialInstruction
			, t6.Description
			, t6.DocumentRequired
		from dbo.RequestCl t0
		left join (
			select 
				nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep, 
				nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep, 
				ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,
				nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName
			from dbo.FlowNext nx
			join dbo.FlowStatus ns on ns.Id = nx.IdStatus
			join dbo.FlowStep np on np.Id = ns.IdStep
			join dbo.Flow nf on nf.Id = np.IdFlow
			join dbo.FlowStep nt on nt.Id = nx.IdStep
		) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status
		inner join dbo.Cargo t2 on t2.id = t0.IdCl 
		inner join dbo.Flow t3 on t3.id = t0.IdFlow
		left join PartsInformationSystem.dbo.UserAccess t4 on t4.UserID = t2.CreateBy
		left join [LS_PROD].[MDS].[HC].employee t5 on t5.AD_User = t2.CreateBy
		left join dbo.ShippingInstruction t6 on t6.IdCL = t0.IdCl		
		left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) and t7.IdFlow = t1.IdFlow
		left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  )
		left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep
		left join dbo.FlowNext t10 on t10.IdStatus = t9.Id
		left join dbo.FlowStep t11 on t11.Id = t10.IdStep
	) as tab0 
	--WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_cl_request_list_all_report]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_cl_request_list_all_report] ()          
RETURNS TABLE           
AS          
RETURN           
(          
 -- Add the SELECT statement with parameter references here          
 select * from (          
   select t0.[Id]            
   ,t0.IdCl           
   ,t0.[IdFlow]           
   ,t0.[IdStep]           
   ,t0.[Status]           
   ,t0.[Pic]            
   ,t6.SlNo          
   ,t0.[CreateBy]           
   ,t0.[CreateDate]           
   ,t0.[UpdateBy]            
   ,t0.[UpdateDate]           
   ,t0.[IsDelete]            
   ,t3.Name FlowName          
   ,t3.Type SubFlowType          
   , [dbo].[fn_get_next_step_id](          
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id          
     ) as IdNextStep           
   , [dbo].[fn_get_step_name](          
     [dbo].[fn_get_next_step_id](          
      t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id          
     )          
     ) as NextStepName          
   , [dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) NextAssignType          
   , CASE WHEN t0.IdStep= 30076 THEN 'Cancelled'        
   WHEN t0.IdStep= 30075 THEN 'waiting for beacukai approval'        
   WHEN t0.IdStep= 30074 THEN 'Request Cancel'       
   WHEN t0.IdStep = 30071 Then 'Waiting approval NPE'      
   WHEN t11.Step = 'System' THEN t8.ViewByUser ELSE t1.ViewByUser END as StatusViewByUser          
   , t1.CurrentStep          
   , t2.ClNo          
   , t2.SailingSchedule ETD          
   , t2.ArrivalDestination ETA          
   , t2.BookingNumber          
   , t2.BookingDate          
   , t2.PortOfLoading          
   , t2.PortOfDestination          
   , t2.Liner          
   , t2.SailingSchedule          
   , t2.ArrivalDestination          
   , t2.VesselFlight          
   , t2.Consignee          
   , t2.StuffingDateStarted          
   , t2.StuffingDateFinished          
   , CASE WHEN ISNULL(t5.AD_User, '') <> '' THEN t4.FullName ELSE CASE WHEN ISNULL(t5.Employee_Name, '') <> '' THEN t5.Employee_Name ELSE t4.FullName END END PreparedBy           
   , t7.AssignType as AssignmentType          
   , t7.AssignTo as AssignTo      
   , [dbo].[fn_get_next_approval] (t7.AssignType, t0.Pic, t7.AssignTo, t0.CreateBy, t0.Id) as NextAssignTo          
   , t6.SpecialInstruction          
   , t6.Description          
   , t6.DocumentRequired          
  from dbo.RequestCl t0          
  left join (          
   select           
    nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep,           
    nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep,           
    ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,          
    nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName          
   from dbo.FlowNext nx          
   join dbo.FlowStatus ns on ns.Id = nx.IdStatus          
   join dbo.FlowStep np on np.Id = ns.IdStep          
   join dbo.Flow nf on nf.Id = np.IdFlow          
   join dbo.FlowStep nt on nt.Id = nx.IdStep          
  ) as t1 on     
  t1.IdFlow = t0.IdFlow AND     
  t1.IdCurrentStep = t0.IdStep     
  AND t1.Status = t0.Status          
  inner join dbo.Cargo t2 on t2.id = t0.IdCl           
  inner join dbo.Flow t3 on t3.id = t0.IdFlow          
  left join PartsInformationSystem.dbo.UserAccess t4 on t4.UserID = t2.CreateBy          
  left join employee t5 on t5.AD_User = t2.CreateBy          
  left join dbo.ShippingInstruction t6 on t6.IdCL = t0.IdCl            
  left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](          
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id          
     ) and t7.IdFlow = t1.IdFlow          
  left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](          
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id          
     )          
  left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep          
  left join dbo.FlowNext t10 on t10.IdStatus = t9.Id          
  left join dbo.FlowStep t11 on t11.Id = t10.IdStep         
  --LEFT JOIN CargoCipl t12 ON t0.Id = t12.IdCargo     
  --LEFT JOIN RequestCipl t13 ON t12.IdCipl = t13.Id     
  WHERE t2.CreateBy <> 'System'    AND t0.CreateBy <> 'System'     
 ) as tab0           
 --WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)          
) 
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_cl_request_list_all]    Script Date: 10/03/2023 11:40:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_cl_request_list_all] ()
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
	  select t0.[Id]		
			,t0.IdCl	
			,t0.[IdFlow]	
			,t0.[IdStep]	
			,t0.[Status]	
			,t0.[Pic]		
			,t6.SlNo
			,t0.[CreateBy]	
			,t0.[CreateDate]	
			,t0.[UpdateBy]		
			,t0.[UpdateDate]	
			,t0.[IsDelete]		
			,t3.Name FlowName
			,t3.Type SubFlowType
			, [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) as IdNextStep 
			, [dbo].[fn_get_step_name](
					[dbo].[fn_get_next_step_id](
						t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
					)
			  ) as NextStepName
			, [dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) NextAssignType
			, CASE WHEN t11.Step = 'System' THEN t8.ViewByUser ELSE t1.ViewByUser END as StatusViewByUser
			, t1.CurrentStep
			, t2.ClNo
			, t2.SailingSchedule ETD
			, t2.ArrivalDestination ETA
			, t2.BookingNumber
			, t2.BookingDate
			, t2.PortOfLoading
			, t2.PortOfDestination
			, t2.Liner
			, t2.SailingSchedule
			, t2.ArrivalDestination
			, t2.VesselFlight
			, t2.Consignee
			, t2.StuffingDateStarted
			, t2.StuffingDateFinished
			, CASE WHEN ISNULL(t5.AD_User, '') <> '' THEN t4.FullName ELSE CASE WHEN ISNULL(t5.Employee_Name, '') <> '' THEN t5.Employee_Name ELSE t4.FullName END END PreparedBy 
			, t7.AssignType as AssignmentType
			, [dbo].[fn_get_next_approval] (t7.AssignType, t0.Pic, t7.AssignTo, t0.CreateBy, t0.Id) as NextAssignTo
			, t6.SpecialInstruction
			, t6.Description
			, t6.DocumentRequired
		from dbo.RequestCl t0
		left join (
			select 
				nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep, 
				nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep, 
				ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,
				nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName
			from dbo.FlowNext nx
			join dbo.FlowStatus ns on ns.Id = nx.IdStatus
			join dbo.FlowStep np on np.Id = ns.IdStep
			join dbo.Flow nf on nf.Id = np.IdFlow
			join dbo.FlowStep nt on nt.Id = nx.IdStep
		) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status
		inner join dbo.Cargo t2 on t2.id = t0.IdCl 
		inner join dbo.Flow t3 on t3.id = t0.IdFlow
		left join PartsInformationSystem.dbo.UserAccess t4 on t4.UserID = t2.CreateBy
		left join employee t5 on t5.AD_User = t2.CreateBy
		left join dbo.ShippingInstruction t6 on t6.IdCL = t0.IdCl		
		left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) and t7.IdFlow = t1.IdFlow
		left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  )
		left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep
		left join dbo.FlowNext t10 on t10.IdStatus = t9.Id
		left join dbo.FlowStep t11 on t11.Id = t10.IdStep
		WHERE t2.CreateBy <> 'System' AND t0.CreateBy <> 'System'
	) as tab0 
	--WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_cl_request_list]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_cl_request_list] -- select * from [fn_get_cl_request_list]('xupj21wdn', 'Import Export','xupj21wdn') 
( 
	-- Add the parameters for the function here
	@Username nvarchar(100),
	@GroupId nvarchar(100),
	@Pic nvarchar(100)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
	  select t0.[Id]  
			,t0.IdCl 
			,t0.[IdFlow] 
			,t0.[IdStep] 
			,t0.[Status] 
			,t0.[Pic]  
			,t0.[CreateBy] 
			,t0.[CreateDate] 
			,t0.[UpdateBy]  
			,t0.[UpdateDate] 
			,t0.[IsDelete]  
			,t12.IsCancelled  
			,CASE WHEN t12.Id Is null Then 0 else t12.Id end AS IdNpePeb
			,t3.Name FlowName
			,t3.Type SubFlowType
			, CASE 
				WHEN t0.[IdStep] = 30074 THEN 30075  
				WHEN t0.[IdStep] = 30075 THEN 30076  
				WHEN t0.[IdStep] = 30076 THEN Null  
				WHEN t0.[IdStep] = 30070 THEN 30071 ELSE [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) END as IdNextStep 
			, CASE WHEN t0.[IdStep] = 30069 THEN 'Approve draft NPE & PEB' 
				WHEN t0.[IdStep] = 30070 THEN 'Create NPE'  
				WHEN t0.[IdStep] = 30074 THEN 'waiting for beacukai approval'  
				WHEN t0.[IdStep] = 30075 THEN 'Cancelled'  
				WHEN t0.[IdStep] = 30076 THEN ''  
    WHEN t0.[IdStep] = 30071 THEN 'Approve NPE' ELSE [dbo].[fn_get_step_name](
	    [dbo].[fn_get_next_step_id](
	     t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
	    )
	    ) END as NextStepName
	  , [dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) NextAssignType
	  , CASE WHEN t0.[IdStep] = 30069 THEN 'Waiting approval draft PEB' 
	   WHEN (t0.[IdStep] = 30070 AND t0.[Status] = 'Approve') THEN 'Waiting NPE document' 
	   WHEN ((t0.[IdStep] = 30070 OR t0.[IdStep] = 30072) AND t0.[Status] = 'Revise') THEN 'Need revision review by imex' 
	   when t12.IsCancelled = 0 then 'Request Cancel Only PebNpe'  
    when t12.IsCancelled = 1 then 'waiting for beacukai approval'  
    when t12.IsCancelled = 2 then 'Cancelled'  
    WHEN t0.[IdStep] = 30071 THEN 'Waiting approval NPE'  
    WHEN t0.[IdStep] = 30074 THEN 'Request Cancel'  
    WHEN t0.[IdStep] = 30075 THEN 'waiting for beacukai approval'  
    WHEN t0.[IdStep] = 30076 THEN 'Cancelled'  
    ELSE CASE WHEN t11.Step = 'System' THEN t8.ViewByUser ELSE t1.ViewByUser END END as StatusViewByUser
			, t1.CurrentStep
			, t2.ClNo
			, t2.BookingNumber
			, t2.BookingDate
			, t2.PortOfLoading
			, t2.PortOfDestination
			, t2.Liner
			, t2.SailingSchedule ETD
			, t2.ArrivalDestination ETA
			, t2.VesselFlight
			, t2.Consignee
			, t2.StuffingDateStarted
			, t2.StuffingDateFinished
			, t5.AD_User
			, t4.FullName
			, t5.Employee_Name
			, CASE WHEN ISNULL(t5.AD_User, '') <> '' THEN t4.FullName ELSE CASE WHEN ISNULL(t5.Employee_Name, '') <> '' THEN t5.Employee_Name ELSE t4.FullName END END PreparedBy 
			, t7.AssignType as AssignmentType
			, CASE   
  --WHEN (t0.[IdStep] = 30069 OR t0.[IdStep] = 30071 )   
   -- THEN 'XUPJ21WDN'   
    --WHEN (t0.[IdStep] = 30074)  
    --then 'IMEX'  
    WHEN (t0.[IdStep] = 30070)   
     THEN t6.PicBlAwb  
    when (((select RoleID from PartsInformationSystem.[dbo].UserAccess where UserID = @Username) = 8 and t0.[IdStep] = 30069 OR t0.[IdStep] = 30071 or t0.IdStep = 30074 or t0.IdStep = 30075 or t0.IdStep = 30076  or t12.IsCancelled = 0 or t12.IsCancelled =
 1 or t12.IsCancelled = 2) or  
    ((select RoleID from PartsInformationSystem.[dbo].UserAccess where UserID = @Username) = 24 and t0.[IdStep] = 30069 OR t0.[IdStep] = 30071 or t0.IdStep = 30074 or t0.IdStep = 30075 or t0.IdStep = 30076 or t12.IsCancelled = 0 or t12.IsCancelled = 1 or 
t12.IsCancelled = 2))  
    then @Username  
    ELSE   
     [dbo].[fn_get_next_approval] (t7.AssignType, t0.Pic, t7.AssignTo, t0.CreateBy, t0.Id)   
     END AS NextAssignTo  
			, t6.SpecialInstruction
			, t6.SlNo
			, t6.Description
			, t6.DocumentRequired
			, t2.ShippingMethod
			, t12.AjuNumber as PebNumber
			, t2.SailingSchedule
			, t2.ArrivalDestination
			, t6.PicBlAwb
		from dbo.RequestCl t0
		left join (
			select 
				nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep, 
				nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep, 
				ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,
				nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName
			from dbo.FlowNext nx
			join dbo.FlowStatus ns on ns.Id = nx.IdStatus
			join dbo.FlowStep np on np.Id = ns.IdStep
			join dbo.Flow nf on nf.Id = np.IdFlow
			join dbo.FlowStep nt on nt.Id = nx.IdStep
		) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status
		inner join dbo.Cargo t2 on t2.id = t0.IdCl 
		inner join dbo.Flow t3 on t3.id = t0.IdFlow
		left join PartsInformationSystem.dbo.UserAccess t4 on t4.UserID = t2.CreateBy
		left join employee t5 on t5.AD_User = t2.CreateBy
		left join dbo.ShippingInstruction t6 on t6.IdCL = t0.IdCl AND t6.isdelete = 0
		left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  ) and t7.IdFlow = t1.IdFlow
		left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id
			  )
		left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep
		left join dbo.FlowNext t10 on t10.IdStatus = t9.Id
		left join dbo.FlowStep t11 on t11.Id = t10.IdStep
		left join dbo.NpePeb t12 on t12.IdCl = t2.Id
		WHERE t0.CreateBy <> 'System' and t0.IsDelete = 0  and t2.CreateBy <> 'System'
	) as tab0 
	WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId OR tab0.PicBlAwb = @Pic)
)


GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_date_data]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_date_data]
(
	-- Add the parameters for the function here
	@data nvarchar(200)
)
RETURNS nvarchar(200)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(200)
	-- Add the T-SQL statements to compute the return value here

	 SET @Result = LTRIM(
				RTRIM(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(RIGHT(@data, 14), ':', '')
						, 'MAY', '-05-')
						, 'APRIL', '-04-')
						, 'JULI' , '-07-')
						, 'MARET' , '-03-')
						, 'JUN' , '-06-')
						, 'APR', '-04-')
						, 'KPP.MP', '') 
						, 'GGAL', '') 
						, 'GAL', '') 
						, 'AL', '') 
						, 'L', '') 
						, '.', '')
						, 'BD', '') 
						, '/', '-') 
						, '-18', '-2018') 
						, '-I', '-') 
						, 'JU', '-07-') 
						, 'JAN', '-01-') 
						, 'DEC', '-12-') 
						, 'FEB', '-02-') 
						, 'MAR', '-03-')
						, 'SEP', '-09-')
						, 'AUG', '-08-')
						, 'OCT', '-10-')
						, 'COT', '-10-')
						, 'NOV', '-11-')
						, 'N', '')
						, 'EP', '-09-')
						, ' -', '-') 
						, '- ', '-') 
						, ' - ', '-')
						, '-012018', '01-2018')
						, '-18', '-2018')
						, '-19', '-2019')
						, '-KPPBC02-2019', '02-2019')
						, '73-KPU01-2019', '01-2019')
						, '77-KPU03-2019', '03-2019')
						, 'A 4-12-2019', '04-12-2019')
						,'PB-KPU02-2019', '02-2019')
						,'E--KPU02-2019', '02-2019')
						,'12 MOV 19', '12 NOV 2019')
						,'PE-KPU02-2019', '02-2019')
						,'A 4-09-2019', '04-09-2019')
						,'02-BO02-2019', '02-2019')
						,'90-KPU01-2019', '01-2019')
						,'38-KPU03-2019', '03-2019')
						,'ya tidak jeas', '')
						,'0200228-306100', '')
						,'K 11-07-2018', '11-07-2018')
						)
					) 

	IF (LEN(@Result) = 7)
	BEGIN
		SET @Result = '01-'+ @Result;
	END

	IF (LEN(@Result) = 8)
	BEGIN
		IF (RIGHT(@Result, 3) = '-18')
		BEGIN
			SET @Result = LEFT(@Result, 5)+REPLACE(RIGHT(@Result, 3), '-18', '-2018');
		END		

		IF (RIGHT(@Result, 3) = '-19')
		BEGIN
			SET @Result = LEFT(@Result, 5)+REPLACE(RIGHT(@Result, 3), '-19', '-2019');
		END

		IF (RIGHT(@Result, 3) = '-20') 
		BEGIN 
			SET @Result = LEFT(@Result, 5)+REPLACE(RIGHT(@Result, 3), '-20', '-2020');
		END
	END

	IF (LEN(@Result) = 9)
	BEGIN
		SET @Result = '0'+ @Result;
	END

	-- Conver data to date format
	
	IF (@Result IS NOT NULL)
	BEGIN
	--	SET @Result = CONVERT(date, @Result, 105);
		SET @Result = @Result;
	END
	ELSE
	BEGIN
		SET @Result = '01-01-1900';
	END
	
	IF (RTRIM(LTRIM(@Result)) = '')
	BEGIN
		SET @Result = '01-01-1900';
	END

	SET @Result = CONVERT(date, '01-01-1900', 105);
	-- Return the result of the function
	RETURN @Result

END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_email_body]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_email_body]
(
	@RequestID int,-- = 2, 
	@Module nvarchar(20),--='Cargo', 
	@Status nvarchar(20),-- = 'Revise', 
	@RecipientType nvarchar(20),-- = 'Approver', 
	@AssignType nvarchar(20),-- = 'Approver', 
	@AssignTo nvarchar(20),-- = 'rouli.a.siregar', 
	@MobileLink nvarchar(200),-- = '#', 
	@DesktopLink nvarchar(200)-- = '#'
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @EmailBody nvarchar(MAX)
	select @EmailBody = Message from EmailTemplate where Module = @Module and Status = @Status and RecipientType = @RecipientType

	declare @RequestNo nvarchar(20), @AD_User nvarchar(20), @RequestorEmpID int, @RequestorName nvarchar(200), @CreatedDate nvarchar(20), 
	@SuperiorEmpID nvarchar(20), @SuperiorName nvarchar(200), @ApproverName nvarchar(200)

	IF @Module = 'Cargo'
	BEGIN
		select @RequestNo = ClNo, @AD_User = CreateBy, @CreatedDate = RIGHT('0' + DATENAME(DAY, CreateDate), 2) + ' ' + DATENAME(MONTH, CreateDate)+ ' ' + DATENAME(YEAR, CreateDate) 
		from Cargo where id = @RequestID
	END

	select @RequestorEmpID = e.Employee_ID, @RequestorName = e.Employee_Name, @SuperiorEmpID = spv.Employee_ID, @SuperiorName = spv.Employee_Name from Employee e
	inner join Employee spv on e.Superior_ID = spv.Employee_ID
	where e.AD_User = @AD_User and e.employee_status = 'Active'

	IF @Status = 'Submit'
	BEGIN
		set @ApproverName = IIF(@AssignType = 'Group' , @AssignTo + ' Group', @SuperiorName)
	END
	ELSE
	BEGIN
		select @ApproverName = Employee_Name from Employee where AD_User = @AssignTo
	END

	set @EmailBody = 
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											@EmailBody, '@RequestorName', @RequestorName
										), '@RequestNo', @RequestNo
									), '@CreatedDate', @CreatedDate
								), '@SuperiorEmpID', @SuperiorEmpID
							), '@SuperiorName', @SuperiorName
						), '@MobileLink', @MobileLink
					), '@DesktopLink', @DesktopLink
				), '@ApproverName', @ApproverName
			), '@RequestorEmpID', @RequestorEmpID
		)

		--select @EmailBody

	return @EmailBody
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_employee_internal_ckb_Bckp_20200330]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_employee_internal_ckb_Bckp_20200330] ()
RETURNS TABLE 
AS
RETURN 
(
	select 
		Employee_ID
		, AD_User
		, Employee_Name
		, Email
		, Superior_Name
		, Organization_Name
		, Position_Name
		, Job_Name
		, Business_Area
		, t1.BAreaName
		, 'internal' UserType
		, CASE 
					WHEN Job_Name = 'Sales Manager' AND Position_Name like '%Area%' THEN 'Area Manager'
					WHEN Job_Name = 'Sales Manager' AND Position_Name like '%Region%' THEN 'Region Manager' 
					ELSE 
						CASE 
						WHEN Organization_Name = 'Import Export' THEN 'IMEX'
						ELSE '-'
					END
		  END AS [Group] 
		, '[unset]' [Role] 
		, t0.Superior_ID
	from employee t0 
	join EMCS.dbo.MasterArea t1 on t1.BAreaCode = t0.Business_Area
	where t0.employee_Status  != 'Withdrawn' AND t0.AD_User NOT IN (select UserID from PartsInformationSystem.dbo.UserAccess)
	union
	select 
		ISNULL(t2.Employee_ID, '') Employee_ID
		, t1.UserID AD_User
		, t1.FullName Employee_Name
		, ISNULL(t2.Email, t1.Email) Email
		, ISNULl(t2.Superior_Name, '') Superior_Name
		, ISNULL(t2.Organization_Name, '') Organization_Name
		, ISNULL(t2.Position_Name, '') Position_Name
		, ISNULL(t2.Job_Name, '') Job_Name
		, ISNULL(t2.Business_Area, '') Business_Area
		, ISNULL(t4.BAreaName, '') BAreaName
		, t1.UserType
		, CASE 
		  WHEN Job_Name = 'Sales Manager' AND Position_Name like '%Area%' THEN 'Area Manager'
		  WHEN Job_Name = 'Sales Manager' AND Position_Name like '%Region%' THEN 'Region Manager' 
		  ELSE 
		  	CASE 
		  	WHEN Organization_Name = 'Import Export' THEN 'IMEX'
			WHEN UserType = 'ext-imex' THEN 'CKB' 
		  	ELSE  '-'
			END
		  END AS [Group]
		, ISNULL(t3.Description, '[unset]') [Role] 
		, t2.Superior_ID
	from PartsInformationSystem.dbo.UserAccess t1
	left join employee t2 on t2.AD_User = t1.UserID AND t2.Employee_Status != 'Withdrawn'
	left join PartsInformationSystem.dbo.RoleAccess t3 on t3.RoleID = t1.RoleID
	left join dbo.MasterArea t4 on t4.BAreaCode = t2.Business_Area
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_employee_internal_ckb]    Script Date: 10/03/2023 11:40:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_employee_internal_ckb] ()
RETURNS TABLE 
AS
RETURN 
(
	select 
		Employee_ID
		, AD_User
		, Employee_Name
		, Email
		, Superior_Name
		, Organization_Name
		, Position_Name
		, Job_Name
		, Business_Area
		, t1.BAreaName
		, 'internal' UserType
		, CASE 
					WHEN Job_Name = 'Sales Manager' AND Position_Name like '%Area%' THEN 'Area Manager'
					WHEN Job_Name = 'Sales Manager' AND Position_Name like '%Region%' THEN 'Region Manager' 
					ELSE 
						CASE 
						WHEN Organization_Name = 'Import Export' THEN 'IMEX'
						ELSE '-'
					END
			END AS [Group] 
		, '[unset]' [Role] 
		, t0.Superior_ID
	from employee t0 
	left join EMCS.dbo.MasterArea t1 on t1.BAreaCode = t0.Business_Area
	where t0.employee_Status  != 'Withdrawn' AND t0.AD_User NOT IN (select UserID from PartsInformationSystem.dbo.UserAccess) AND t0.AD_User not like '000%' AND t0.AD_User not like 'EMP%' 
	union
	select 
		ISNULL(t2.Employee_ID, '') Employee_ID
		, t1.UserID AD_User
		, t1.FullName Employee_Name
		, ISNULL(t2.Email, t1.Email) Email
		, ISNULl(t2.Superior_Name, '') Superior_Name
		, ISNULL(t2.Organization_Name, '') Organization_Name
		, ISNULL(t2.Position_Name, '') Position_Name
		, ISNULL(t2.Job_Name, '') Job_Name
		, CASE WHEN t1.UserID ='XUPJ21FIG' THEN ''
		ELSE
		ISNULL(t2.Business_Area, '')
		END Business_Area
		, ISNULL(t4.BAreaName, '') BAreaName
		, t1.UserType
		, CASE 
			WHEN Job_Name = 'Sales Manager' AND Position_Name like '%Area%' THEN 'Area Manager'
			WHEN Job_Name = 'Sales Manager' AND Position_Name like '%Region%' THEN 'Region Manager' 
			ELSE 
			CASE 
			WHEN Organization_Name = 'Import Export' THEN 'IMEX'
			ELSE  t5.[Name]
			END
			END AS [Group]
		, CASE WHEN t1.UserID ='XUPJ21FIG' THEN 'EMCS IMEX'
		ELSE
		ISNULL(t3.Description, '[unset]')
		END  [Role] 
		, t2.Superior_ID
	from PartsInformationSystem.dbo.UserAccess t1
	left join employee t2 on t2.AD_User = t1.UserID AND t2.Employee_Status != 'Withdrawn' --AND t2.AD_User not like '000%'-- AND t2.AD_User not like 'EMP%'
	left join PartsInformationSystem.dbo.RoleAccess t3 on t3.RoleID = t1.RoleID
	left join dbo.MasterArea t4 on t4.BAreaCode = t2.Business_Area
	left join PartsInformationSystem.dbo.Master_Group t5 on t5.ID = t1.GroupID
	WHERE t1.UserID not like '000%' AND UserID not like 'EMP%'
)

GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_gr_request_list_all_30032021]    Script Date: 10/03/2023 11:40:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_gr_request_list_all_30032021] -- select * from fn_get_gr_request_list('xupj21wdn', 'IMEX') 
(	
	-- Add the parameters for the function here
	--@Username nvarchar(100),
	--@GroupId nvarchar(100)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
	  select 
			t0.[Id]		
			,t0.IdGr	
			,t0.[IdFlow]	
			,t0.[IdStep]	
			,t0.[Status]	
			,t0.[Pic]		
			,t0.[CreateBy]	
			,t0.[CreateDate]	
			,t0.[UpdateBy]		
			,t0.[UpdateDate]	
			,t0.[IsDelete]		
			, t3.Name FlowName
			, t3.Type SubFlowType
			, [dbo].[fn_get_next_step_id](
				t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, 
				[dbo].fn_get_status_id(
					t0.IdStep, t0.Status
				), t0.Id
			) as IdNextStep 
			, [dbo].[fn_get_step_name](
				[dbo].[fn_get_next_step_id](
					t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, 
					[dbo].fn_get_status_id(
						t0.IdStep, t0.Status
					), t0.Id
				)
			) as NextStepName
			, [dbo].[fn_get_next_assignment_type](
				t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id
			) NextAssignType
			, t1.ViewByUser NextStatusViewByUser
			, t2.GrNo
			, t2.PicName
			, t2.PhoneNumber
			, t2.SimNumber
			, t2.StnkNumber
			, t2.NopolNumber
			, t2.EstimationTimePickup
			, [dbo].[fn_get_next_assignment_type](
				t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id
			) as AssignmentType
			, [dbo].[fn_get_next_approval] (
				[dbo].[fn_get_next_assignment_type](
					t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id
				), t0.Pic, t1.NextAssignTo, t0.CreateBy, t0.Id) as NextAssignTo
		from dbo.RequestGr t0
		left join (
			select 
				nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep, 
				nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep, 
				ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,
				nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName
			from dbo.FlowNext nx
			join dbo.FlowStatus ns on ns.Id = nx.IdStatus
			join dbo.FlowStep np on np.Id = ns.IdStep
			join dbo.Flow nf on nf.Id = np.IdFlow
			join dbo.FlowStep nt on nt.Id = nx.IdStep
		) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status
		inner join dbo.GoodsReceive t2 on t2.id = t0.IdGr
		inner join dbo.Flow t3 on t3.id = t0.IdFlow
	) as tab0 
	--WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_gr_request_list_all]    Script Date: 10/03/2023 15:51:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_gr_request_list_all] -- select * from [fn_get_gr_request_list_all]('xupj21jpd', 'IMEX')     
(     
 -- Add the parameters for the function here    
 --@Username nvarchar(100),    
 --@GroupId nvarchar(100)    
)    
RETURNS TABLE     
AS    
RETURN     
(    
 -- Add the SELECT statement with parameter references here    
 select * from (    
   select     
   t0.[Id]      
   ,t0.IdGr     
   ,t0.[IdFlow]     
   ,t0.[IdStep]     
   ,CASE         
     WHEN t0.[Status] = 'Submit'    
     --THEN t0.[Status]  
  THEN 'Waiting Approval'    
     ELSE t0.[Status]     
   END AS [Status]    
   --,t0.[Status]     
   ,t0.[Pic]      
   ,t0.[CreateBy]     
   ,t0.[CreateDate]     
   ,t0.[UpdateBy]      
   ,t0.[UpdateDate]     
   ,t0.[IsDelete]      
   , t3.Name FlowName    
   , t3.Type SubFlowType    
   , [dbo].[fn_get_next_step_id](    
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep,     
    [dbo].fn_get_status_id(    
     t0.IdStep, t0.Status    
    ), t0.Id    
   ) as IdNextStep     
   , [dbo].[fn_get_step_name](    
    [dbo].[fn_get_next_step_id](    
     t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep,     
     [dbo].fn_get_status_id(    
      t0.IdStep, t0.Status    
     ), t0.Id    
    )    
   ) as NextStepName    
   , [dbo].[fn_get_next_assignment_type](    
    t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id    
   ) NextAssignType    
   , t1.ViewByUser NextStatusViewByUser    
   , t2.GrNo    
   , (select top 1 s.PicName from Shippingfleet s where  s.IdGr =  t0.IdGr)as PicName  
   , (select top 1 s.PhoneNumber from Shippingfleet s where  s.IdGr =  t0.IdGr)as PhoneNumber    
   , (select top 1 s.SimNumber from Shippingfleet s where  s.IdGr =  t0.IdGr)as SimNumber    
   , (select top 1 s.StnkNumber from Shippingfleet s where  s.IdGr =  t0.IdGr)as StnkNumber    
   , (select top 1 s.NopolNumber from Shippingfleet s where  s.IdGr =  t0.IdGr)as NopolNumber    
   , (select top 1 s.EstimationTimePickup from Shippingfleet s where  s.IdGr =  t0.IdGr)as EstimationTimePickup    
   , [dbo].[fn_get_next_assignment_type](    
    t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id    
   ) as AssignmentType    
   , [dbo].[fn_get_next_approval] (    
    [dbo].[fn_get_next_assignment_type](    
     t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id    
    ), t0.Pic, t1.NextAssignTo, t0.CreateBy, t0.Id) as NextAssignTo    
  from dbo.RequestGr t0    
  left join (    
   select     
    nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep,     
    nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep,     
    ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,    
    nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName    
   from dbo.FlowNext nx    
   join dbo.FlowStatus ns on ns.Id = nx.IdStatus    
   join dbo.FlowStep np on np.Id = ns.IdStep    
   join dbo.Flow nf on nf.Id = np.IdFlow    
   join dbo.FlowStep nt on nt.Id = nx.IdStep    
  ) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status    
  inner join dbo.GoodsReceive t2 on t2.id = t0.IdGr    
  inner join dbo.Flow t3 on t3.id = t0.IdFlow    
 ) as tab0     
 --WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)    
) 
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_gr_request_list]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_gr_request_list] -- select * from [fn_get_gr_request_list]('xupj21jpd', 'IMEX')   
(   
 -- Add the parameters for the function here  
 @Username nvarchar(100),  
 @GroupId nvarchar(100)  
)  
RETURNS TABLE   
AS  
RETURN   
(  
 -- Add the SELECT statement with parameter references here  
 select * from (  
   select   
   t0.[Id]    
   ,t0.IdGr
   ,t0.[IdFlow]   
   ,t0.[IdStep]   
   ,CASE       
     WHEN t0.[Status] = 'Submit'  
     THEN 'Waiting Approval'  
     ELSE t0.[Status]   
   END AS [Status]   
   ,t0.[Pic]    
   ,t0.[CreateBy]   
   ,t0.[CreateDate]   
   ,t0.[UpdateBy]    
   ,t0.[UpdateDate]   
   ,t0.[IsDelete]    
   , t3.Name FlowName  
   , t3.Type SubFlowType  
   , [dbo].[fn_get_next_step_id](  
     t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep,   
     [dbo].fn_get_status_id(t0.IdStep, t0.Status), t0.Id  
     ) as IdNextStep   
   , [dbo].[fn_get_step_name](  
     [dbo].[fn_get_next_step_id](  
      t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep,   
      [dbo].fn_get_status_id(  
       t0.IdStep, t0.Status  
      ), t0.Id  
     )  
     ) as NextStepName  
   , [dbo].[fn_get_next_assignment_type](  
     t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id  
     ) NextAssignType  
   , t1.ViewByUser NextStatusViewByUser  
   , t2.GrNo  
   , (select top 1 s.PicName from Shippingfleet s where  s.IdGr =  t0.IdGr )as PicName
   , (select top 1 s.PhoneNumber from Shippingfleet s where  s.IdGr =  t0.IdGr )as PhoneNumber  
   , (select top 1 s.SimNumber from Shippingfleet s where  s.IdGr =  t0.IdGr )as SimNumber  
   , (select top 1 s.StnkNumber from Shippingfleet s where  s.IdGr =  t0.IdGr )as StnkNumber  
   , (select top 1 s.NopolNumber from Shippingfleet s where  s.IdGr =  t0.IdGr )as NopolNumber  
   , (select top 1 s.EstimationTimePickup from Shippingfleet s where  s.IdGr =  t0.IdGr )as EstimationTimePickup     
   , [dbo].[fn_get_next_assignment_type](  
     t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id  
     ) as AssignmentType  
   , [dbo].[fn_get_next_approval] (  
    [dbo].[fn_get_next_assignment_type](  
     t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id  
    ), t0.Pic, t1.NextAssignTo, t0.CreateBy, t0.Id  
    ) as NextAssignTo  
  from dbo.RequestGr t0  
  left join (  
   select   
    nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep,   
    nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep,   
    ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,  
    nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName  
   from dbo.FlowNext nx  
   join dbo.FlowStatus ns on ns.Id = nx.IdStatus  
   join dbo.FlowStep np on np.Id = ns.IdStep  
   join dbo.Flow nf on nf.Id = np.IdFlow  
   join dbo.FlowStep nt on nt.Id = nx.IdStep  
  ) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status  
  inner join dbo.GoodsReceive t2 on t2.id = t0.IdGr  
  inner join dbo.Flow t3 on t3.id = t0.IdFlow  
 ) as tab0   
 WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId)  
)    
  

GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_next_approval]    Script Date: 10/03/2023 15:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_next_approval]  
(    
 -- Add the parameters for the function here    
 @Type nvarchar(100),    
 @LastUser nvarchar(100),    
 @GroupID nvarchar(100),    
 @Creator nvarchar(100),    
 @IdRequest nvarchar(100) = '0'    
)    
RETURNS nvarchar(100)    
AS    
BEGIN    
 -- Declare the return variable here    
 DECLARE @Result nvarchar(100);    
 DECLARE @BArea nvarchar(100);    
 DECLARE @SuperiorUsername nvarchar(500);    
 SELECT @BArea = Business_Area FROM employee WHERE AD_User = @LastUser;    
    
 -- Add the T-SQL statements to compute the return value here    
 IF @Type = 'Superior'     
 BEGIN    
  SELECT @SuperiorUsername = SuperiorUsername FROM mastersuperior WHERE IsDeleted = 0 AND employeeUsername = @Creator;    
  IF ISNULL(@SuperiorUsername, '') = ''    
  BEGIN    
   SELECT @Result = t1.AD_User from employee as t0    
   inner join employee as t1 on t1.Employee_Id = t0.Superior_ID    
   WHERE t0.AD_User = @Creator    
  END    
  ELSE    
  BEGIN    
   SET @Result = @SuperiorUsername;    
  END    
      
 END     
     
 IF @Type = 'Group'     
 BEGIN    
	SELECT @SuperiorUsername = SuperiorUsername FROM mastersuperior WHERE IsDeleted = 0 AND employeeUsername = @Creator;    
	IF ISNULL(@SuperiorUsername, '') = ''   
	BEGIN
		IF EXISTS	(SELECT	TOP	1 *
					FROM	employee
					WHERE	Organization_Name LIKE '%' + @GroupID +'%'
							AND Employee_Name LIKE '%Asmat%')
			BEGIN
				SELECT	@Result = AD_User 
				FROM	employee
				WHERE	Organization_Name LIKE '%Import Export%'
						AND Employee_Name LIKE '%Asmat%' 
			END
		ELSE
			BEGIN
			SET @Result = @GroupID 
			END
	END  
 END    
    
 IF @Type = 'Requestor'     
 BEGIN    
  SET @Result = @Creator    
 END    
    
 IF @Type IN ('Region Manager', 'Area Manager')    
 BEGIN    
  SET @Result = @BArea;    
 END    
    
 IF @Type = 'PPJK'    
 BEGIN    
  DECLARE @UserName nvarchar(100);    
  SELECT TOP 1 @UserName = Username FROM dbo.MasterAreaUserCKB where BAreaCode = @BArea AND IsActive = 1;    
  SELECT @Result = @UserName FROM PartsInformationSystem.dbo.UserAccess where UserID =  @UserName;    
 END     
    
 IF @Type = 'AreaCipl'    
 BEGIN    
  DECLARE @RequestorName nvarchar(50);    
  DECLARE @DataId bigint;    
  select @DataId = IdGr from dbo.RequestGr where Id = @IdRequest    
  select @Result = PickupPic FROM dbo.GoodsReceive where Id = @DataId;    
 END     
    
 RETURN @Result;    
    
END 

GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_next_assignment_type]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_next_assignment_type] -- select dbo.fn_get_next_assignment_type('System', 'xupj21ech', '3') NextApproval
(
	-- Add the parameters for the function here
	@Type nvarchar(100),
	@Username nvarchar(100),
	@IdNextStep nvarchar(100) = '0',
	@IdReq bigint = 0
)
RETURNS nvarchar(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(100);
	DECLARE @BArea nvarchar(100);
	SELECT @BArea = Business_Area FROM employee WHERE AD_User = @Username;

	IF ISNULL(@Type, '') <> 'System'
	BEGIN
		SET @Result = @Type;
	END

	IF ISNULL(@Type, '') = 'System'
	BEGIN
		IF (@IdNextStep = 10037)
		BEGIN
			-- cek apakah cargo memiliki history perubahan item 
			DECLARE @total_update_item int;
			
			-- ambil data request dan id cargo
			DECLARE @IdCargo bigint;
			SELECT @IdCargo = IdCl FROM dbo.RequestCl WHERE Id = @IdReq;
			
			-- ambil total perubahan
			SELECT @total_update_item = count(*) from dbo.CiplItemUpdateHistory t0 where t0.IdCargo = @IdCargo;

			IF (@total_update_item <> 0)
			BEGIN
				-- get cipl list yang harus diupdate
				DECLARE @totalWaitingApprove int = 0;

				SELECT @totalWaitingApprove = count(*) 
				FROM dbo.RequestCipl where IdStep IN (10032, 10033, 10035) AND [Status] = 'Draft'
				AND IdCipl IN (
					SELECT DISTINCT IdCipl 
					FROM dbo.CiplItemUpdateHistory 
					WHERE IdCargo = @IdCargo
				)
			
				IF (@totalWaitingApprove = 0)
				BEGIN
					SET @Result = 'Group';
				END 
				ELSE 
				BEGIN
					SET @Result = '-';
				END 
			END 
			ELSE 
			BEGIN
				SET @Result = 'Group';
			END 
		END
	END

	RETURN @Result;
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_next_step_id_20211223]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_next_step_id_20211223]  -- SELECT fn_get_next_step_id ('System','xupj21ech','2','3','', 1) test
(
	-- Add the parameters for the function here
	@StepType nvarchar(100),
	@LastPic nvarchar(100),
	@IdFlow bigint,
	@StepId bigint,
	@IdStatus bigint,
	-- tambahan
	@IdReq bigint
)
RETURNS bigint
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(100);
	DECLARE @BArea nvarchar(100);
	SELECT @BArea = Business_Area FROM employee WHERE AD_User = @LastPic;

	IF ISNULL(@StepType, '') <> 'System'
	BEGIN
		SELECT @Result = IdStep FROM dbo.FlowNext WHERE IdStatus = @IdStatus;
	END
	
	IF ISNULL(@StepType, '') = 'System'
	BEGIN
		IF (@StepId IN (3, 10034, 10036))
		BEGIN
			-- Get Last Step
			DECLARE @LastStep nvarchar(100);
			select @LastStep = IdStep from dbo.RequestCipl where Id = @IdReq;

			IF (@IdStatus = 10064)
			BEGIN
				SET @Result = 14;
			END
			
			IF (@LastStep = 20065)
			BEGIN
				SET @Result = 10024;
			END

			IF (@LastStep = 20067)
			BEGIN
				SET @Result = 10028;
			END
		END

		-- tambahan
		IF (@StepId = 10037)
		BEGIN
			-- cek apakah cargo memiliki history perubahan item 
			DECLARE @total_update_item int = 0;
			
			-- ambil data request dan id cargo
			DECLARE @IdCargo bigint;
			SELECT @IdCargo = IdCl FROM dbo.RequestCl WHERE Id = @IdReq;
			
			-- ambil total perubahan
			SELECT @total_update_item = count(*) from dbo.CiplItemUpdateHistory t0 where t0.IdCargo = @IdCargo AND IsApprove = 0;

			IF (@total_update_item <> 0)
			BEGIN
				IF (@total_update_item = 0)
				BEGIN
					SET @Result = 10017;
				END 
				ELSE 
				BEGIN
					SET @Result = 20033;
				END 
			END 
			ELSE 
			BEGIN
				SET @Result = 12;
			END 
		END
	END

	RETURN @Result;
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_next_step_id_bckp]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_next_step_id_bckp]  -- SELECT fn_get_next_step_id ('System','xupj21ech','2','3','', 1) test
(
	-- Add the parameters for the function here
	@StepType nvarchar(100),
	@LastPic nvarchar(100),
	@IdFlow bigint,
	@StepId bigint,
	@IdStatus bigint,
	-- tambahan
	@IdReq bigint
)
RETURNS bigint
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(100);
	DECLARE @BArea nvarchar(100);
	SELECT @BArea = Business_Area FROM [LS_PROD].MDS.HC.employee WHERE AD_User = @LastPic;

	IF ISNULL(@StepType, '') <> 'System'
	BEGIN
		SELECT @Result = IdStep FROM dbo.FlowNext WHERE IdStatus = @IdStatus;
	END
	
	IF ISNULL(@StepType, '') = 'System'
	BEGIN
		IF (@StepId IN (3, 10034, 10036))
		BEGIN
			-- Get Last Step
			DECLARE @LastStep nvarchar(100);
			select @LastStep = IdStep from dbo.RequestCipl where Id = @IdReq;

			IF (@IdStatus = 10064)
			BEGIN
				SET @Result = 14;
			END
			
			IF (@LastStep = 20065)
			BEGIN
				SET @Result = 10024;
			END

			IF (@LastStep = 20067)
			BEGIN
				SET @Result = 10028;
			END
		END

		-- tambahan
		IF (@StepId = 10037)
		BEGIN
			-- cek apakah cargo memiliki history perubahan item 
			DECLARE @total_update_item int = 0;
			
			-- ambil data request dan id cargo
			DECLARE @IdCargo bigint;
			SELECT @IdCargo = IdCl FROM dbo.RequestCl WHERE Id = @IdReq;
			
			-- ambil total perubahan
			SELECT @total_update_item = count(*) from dbo.CiplItemUpdateHistory t0 where t0.IdCargo = @IdCargo AND IsApprove = 0;

			IF (@total_update_item <> 0)
			BEGIN
				IF (@total_update_item = 0)
				BEGIN
					SET @Result = 10017;
				END 
				ELSE 
				BEGIN
					SET @Result = 20033;
				END 
			END 
			ELSE 
			BEGIN
				SET @Result = 12;
			END 
		END
	END

	RETURN @Result;
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_next_step_id]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_next_step_id]  -- SELECT fn_get_next_step_id ('System','xupj21ech','2','3','', 1) test
(
	-- Add the parameters for the function here
	@StepType nvarchar(100),
	@LastPic nvarchar(100),
	@IdFlow bigint,
	@StepId bigint,
	@IdStatus bigint,
	-- tambahan
	@IdReq bigint
)
RETURNS bigint
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(100);
	DECLARE @BArea nvarchar(100);
	SELECT @BArea = Business_Area FROM employee WHERE AD_User = @LastPic;

	IF ISNULL(@StepType, '') <> 'System'
	BEGIN
		SELECT @Result = IdStep FROM dbo.FlowNext WHERE IdStatus = @IdStatus;
	END
	
	IF ISNULL(@StepType, '') = 'System'
	BEGIN
		IF (@StepId IN (3, 10034, 10036))
		BEGIN
			-- Get Last Step
			DECLARE @LastStep nvarchar(100);
			select @LastStep = IdStep from dbo.RequestCipl where Id = @IdReq;

			IF (@IdStatus = 10064)
			BEGIN
				SET @Result = 14;
			END
			
			IF (@LastStep = 20065)
			BEGIN
				SET @Result = 10024;
			END

			IF (@LastStep = 20067)
			BEGIN
				SET @Result = 10028;
			END

			IF (@LastStep = 10035)
			BEGIN
				SELECT @Result = IdStep FROM dbo.FlowNext WHERE IdStatus = @IdStatus;
			END
		END

		-- tambahan
		IF (@StepId = 10037)
		BEGIN
			-- cek apakah cargo memiliki history perubahan item 
			DECLARE @total_update_item int = 0;
			
			-- ambil data request dan id cargo
			DECLARE @IdCargo bigint;
			SELECT @IdCargo = IdCl FROM dbo.RequestCl WHERE Id = @IdReq;
			
			-- ambil total perubahan
			SELECT @total_update_item = count(*) from dbo.CiplItemUpdateHistory t0 where t0.IdCargo = @IdCargo AND IsApprove = 0;

			IF (@total_update_item <> 0)
			BEGIN
				IF (@total_update_item = 0)
				BEGIN
					SET @Result = 10017;
				END 
				ELSE 
				BEGIN
					SET @Result = 20033;
				END 
			END 
			ELSE 
			BEGIN
				SET @Result = 12;
			END 
		END
	END

	RETURN @Result;
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_npepeb_request_list]    Script Date: 10/03/2023 15:51:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_npepeb_request_list] -- select * from [fn_get_npepeb_request_list]('xupj21wdn', 'Import Export','xupj21wdn')         
(         
 -- Add the parameters for the function here        
 @Username nvarchar(100),        
 @GroupId nvarchar(100),        
 @Pic nvarchar(100)        
)        
RETURNS TABLE         
AS        
RETURN         
(        
 -- Add the SELECT statement with parameter references here        
 select * from (        
   select distinct t0.[Id]          
   ,t0.IdCl         
   ,t0.[IdFlow]         
   ,t0.[IdStep]         
   ,t0.[Status]         
   ,t0.[Pic]          
   ,t0.[CreateBy]         
   ,t0.[CreateDate]         
   ,t0.[UpdateBy]          
   ,t0.[UpdateDate]         
   ,t0.[IsDelete]          
   ,t12.IsCancelled      
   ,CASE WHEN t12.Id Is null Then 0    
   else t12.Id end AS IdNpePeb    
   ,t3.Name FlowName        
   ,t3.Type SubFlowType        
   , CASE      
    WHEN t0.[IdStep] = 30074 THEN 30075      
 WHEN t0.[IdStep] = 30075 THEN 30076      
 WHEN t0.[IdStep] = 30076 THEN Null      
 WHEN t0.[IdStep] = 30070 THEN 30071 ELSE [dbo].[fn_get_next_step_id](        
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id        
     ) END as IdNextStep         
   , CASE WHEN t0.[IdStep] = 30069 THEN 'Approve draft NPE & PEB'         
   WHEN t0.[IdStep] = 30070 THEN 'Create NPE'      
 WHEN t0.[IdStep] = 30074 THEN 'waiting for beacukai approval'      
 WHEN t0.[IdStep] = 30075 THEN 'Cancelled'      
 WHEN t0.[IdStep] = 30076 THEN ''      
    WHEN t0.[IdStep] = 30071 THEN 'Approve NPE' ELSE [dbo].[fn_get_step_name](        
     [dbo].[fn_get_next_step_id](        
      t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id        
     )        
     ) END as NextStepName        
   , [dbo].[fn_get_next_assignment_type](t1.NextAssignType, t0.Pic, t1.IdNextStep, t0.Id) NextAssignType        
   , CASE WHEN t0.[IdStep] = 30069 THEN 'Waiting approval draft PEB'         
    WHEN (t0.[IdStep] = 30070 AND t0.[Status] = 'Approve') THEN 'Waiting NPE document'         
    WHEN ((t0.[IdStep] = 30070 OR t0.[IdStep] = 30072) AND t0.[Status] = 'Revise') THEN 'Need revision review by imex'         
    when t12.IsCancelled = 0 then 'Request Cancel Only PebNpe'      
    when t12.IsCancelled = 1 then 'waiting for beacukai approval'      
    when t12.IsCancelled = 2 then 'Cancelled'      
    WHEN t0.[IdStep] = 30071 THEN 'Waiting approval NPE'      
    WHEN t0.[IdStep] = 30074 THEN 'Request Cancel'      
    WHEN t0.[IdStep] = 30075 THEN 'waiting for beacukai approval'      
    WHEN t0.[IdStep] = 30076 THEN 'Cancelled'      
    ELSE CASE WHEN t11.Step = 'System' THEN t8.ViewByUser ELSE t1.ViewByUser END END as StatusViewByUser        
   , t1.CurrentStep        
   , t2.ClNo        
   , t2.BookingNumber        
   , t2.BookingDate        
   , t2.PortOfLoading        
   , t2.PortOfDestination        
   , t2.Liner        
   , t2.SailingSchedule ETD        
   , t2.ArrivalDestination ETA        
   , t2.VesselFlight        
   , t2.Consignee        
   , t2.StuffingDateStarted        
   , t2.StuffingDateFinished        
   , t5.AD_User        
   , t4.FullName        
   , t5.Employee_Name        
   , CASE WHEN ISNULL(t5.AD_User, '') <> '' THEN t4.FullName ELSE CASE WHEN ISNULL(t5.Employee_Name, '') <> '' THEN t5.Employee_Name ELSE t4.FullName END END PreparedBy         
   , t7.AssignType as AssignmentType        
   , CASE       
  --WHEN (t0.[IdStep] = 30069 OR t0.[IdStep] = 30071 )       
   -- THEN 'XUPJ21WDN'       
    --WHEN (t0.[IdStep] = 30074)      
    --then 'IMEX'      
    WHEN (t0.[IdStep] = 30070)       
     THEN t6.PicBlAwb      
    when (((select RoleID from PartsInformationSystem.[dbo].UserAccess where UserID = @Username) = 8 and t0.[IdStep] = 30069 OR t0.[IdStep] = 30071 or t0.IdStep = 30074 or t0.IdStep = 30075 or t0.IdStep = 30076  or t12.IsCancelled = 0 or t12.IsCancelled =
  
    
 1 or t12.IsCancelled = 2) or      
   ((select RoleID from PartsInformationSystem.[dbo].UserAccess where UserID = @Username) = 24 and t0.[IdStep] = 30069 OR t0.[IdStep] = 30071 or t0.IdStep = 30074 or t0.IdStep = 30075 or t0.IdStep = 30076 or t12.IsCancelled = 0 or t12.IsCancelled = 1 or  
 
    
t12.IsCancelled = 2))      
    then @Username      
    ELSE       
     [dbo].[fn_get_next_approval] (t7.AssignType, t0.Pic, t7.AssignTo, t0.CreateBy, t0.Id)       
     END AS NextAssignTo      
  , t6.SpecialInstruction        
   , t6.SlNo        
   , t6.Description        
   , t6.DocumentRequired        
   , t2.ShippingMethod        
   , t12.AjuNumber as PebNumber        
   , t2.SailingSchedule        
   , t2.ArrivalDestination        
   , t6.PicBlAwb        
  from dbo.NpePeb t12     
  left join dbo.RequestCl t0 on   t0.IdCl = t12.IdCl    
  left join (        
   select         
    nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep,         
    nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep,         
    ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,        
    nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName        
   from dbo.FlowNext nx        
   join dbo.FlowStatus ns on ns.Id = nx.IdStatus        
   join dbo.FlowStep np on np.Id = ns.IdStep        
   join dbo.Flow nf on nf.Id = np.IdFlow        
   join dbo.FlowStep nt on nt.Id = nx.IdStep        
  ) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status        
  inner join dbo.Cargo t2 on t2.id = t0.IdCl        
  inner join dbo.Flow t3 on t3.id = t0.IdFlow        
  left join PartsInformationSystem.dbo.UserAccess t4 on t4.UserID = t2.CreateBy        
  left join employee t5 on t5.AD_User = t2.CreateBy        
  left join dbo.ShippingInstruction t6 on t6.IdCL = t0.IdCl          
  left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](        
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id        
     ) and t7.IdFlow = t1.IdFlow        
  left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](        
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id        
     )        
  left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep        
  left join dbo.FlowNext t10 on t10.IdStatus = t9.Id        
  left join dbo.FlowStep t11 on t11.Id = t10.IdStep        
      
  WHERE t0.CreateBy <> 'System' and t0.IsDelete = 0  and t2.CreateBy <> 'System'        
 ) as tab0         
 WHERE (tab0.NextAssignTo = @Username OR tab0.NextAssignTo = @GroupId OR tab0.PicBlAwb = @Pic)        
) 

GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_pic_email]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_pic_email]
(
	-- Add the parameters for the function here
	@AssignmentType nvarchar(100),
	@AssignmentTo nvarchar(100)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(MAX);
	
	IF @AssignmentType = 'Group' 
	BEGIN
		IF @AssignmentTo = 'CKB' 
		BEGIN
			SET @Result = STUFF(
				(SELECT ';' + CAST(Email as NVARCHAR) 
					FROM PartsInformationSystem.[dbo].[UserAccess] where UserType='ext-imex' GROUP BY Email
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')
		END ELSE
		BEGIN	
			SET @Result = STUFF(
				(SELECT ';' + CAST(Email as NVARCHAR) 
					FROM employee where LTRIM(RTRIM(organization_name)) like LTRIM(RTRIM(@AssignmentTo)) GROUP BY Email
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @Result = Email FROM employee 
		WHERE AD_User = @AssignmentTo 
		AND Employee_Status = 'Active' 
	END

	-- Return the result of the function
	RETURN @Result;
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_plant_barea_user]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_get_plant_barea_user] ()
RETURNS TABLE 
AS
RETURN 
(
	select t1.AD_User, t1.Employee_Name, t1.Email, t3.PlantCode, t2.BAreaCode, t2.BAreaName 
	from dbo.fn_get_employee_internal_ckb() t1
	join dbo.MasterArea t2 on t2.BAreaCode = t1.Business_Area
	join dbo.MasterPlant t3 on RIGHT(t3.PlantCode, 3) = RIGHT(t2.BAreaCode, 3)
)


GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_RDheBI]    Script Date: 10/03/2023 11:40:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[fn_get_RDheBI]
(	
	-- Add the parameters for the function here
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
SELECT 
		--t1.NpeDate,
	    '' as NomorIdentifikasi, 
		t1.NPWP as NPWP,
		t1.ReceiverName as NamaPenerimaDHE,
		t1.PassPabeanOffice as SandiKantorPabean,
		t1.NpeNumber as NomorPendaftaranPEB,
		ISNULL(CONVERT(VARCHAR(11), t1.NpeDate, 106), '-') as TanggalPEB,
		t1.Valuta as JenisValutaDHE,
		CAST(t1.Dhe as varchar(18)) as NilaiDHE,
		CAST(t1.PebFob as varchar(18)) as NilaiPEB,
		CASE
			WHEN t1.DocumentComplete = 1 THEN 'Yes'
			
			ELSE 'No'
		END KelengkapanDokumen,
		t1.DescriptionPassword as SandiKeterangan,
		--t1.DocumentComplete as KelengkapanDokumen,
		t1.Valuta as JenisValutaPEB,
		t0.Category,t0.ExportType,
		t1.NpeDate
	FROM
		Cargo t0
	JOIN NpePeb t1 on t1.IdCl = t0.Id
	JOIN BlAwb t2 on t2.IdCl = t0.Id 
	JOIN RequestCl t3 on t3.IdCl = t0.Id
	WHERE t3.IdStep = 10022
		and t3.[Status] = 'Approve'
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_status_id]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Ali Mutasal
-- ALTER date	: 2019 Sep 04
-- Description	: Get Next Status Id
-- =============================================
ALTER FUNCTION [dbo].[fn_get_status_id]
(
	-- Add the parameters for the function here
	@IdStep nvarchar(100),
	@Status nvarchar(100)
)
RETURNS bigint
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(100);
	SELECT @Result = Id FROM [dbo].[FlowStatus] where IdStep = @IdStep AND [Status] = @Status 

	RETURN @Result;
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_step_name]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Ali Mutasal
-- ALTER date	: 2019 Sep 04
-- Description	: Get Next Step Id When The Step Name is System
-- =============================================
ALTER FUNCTION [dbo].[fn_get_step_name]
(
	-- Add the parameters for the function here
	@StepId bigint
)
RETURNS nvarchar(100)
AS
BEGIN
	DECLARE @Result nvarchar(100)
	select @Result = Step from dbo.FlowStep where Id = @StepId;
	RETURN @Result;
END
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
ALTER FUNCTION [dbo].[fn_get_total_cipl_20200612]
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

/****** Object:  UserDefinedFunction [dbo].[fn_get_total_cipl_all_20200612]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- ALTER date: 8 Des 2019
-- Description:	Function untuk mengambil total tiap Cipl
-- =============================================
ALTER FUNCTION [dbo].[fn_get_total_cipl_all_20200612]
(	
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
	WHERE t0.IsDelete = 0
	GROUP BY IdCipl, CiplNo
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_total_cipl_all]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- ALTER date: 8 Des 2019
-- Description:	Function untuk mengambil total tiap Cipl
-- =============================================
ALTER FUNCTION [dbo].[fn_get_total_cipl_all]
(	
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
			WHEN t1.CategoriItem = 'SIB' 
				THEN JCode 
			WHEN t1.CategoriItem = 'PRA' OR t1.CategoriItem = 'REMAN'
				THEN CaseNumber
			ELSE Sn END) AS TotalPackage
	FROM dbo.CiplItem t0
	LEFT JOIN dbo.Cipl t1 on t1.id = t0.IdCipl
	WHERE t0.IsDelete = 0
	GROUP BY IdCipl, CiplNo
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_total_cipl]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Ali Mutasal
-- ALTER date: 8 Des 2019
-- Description:	Function untuk mengambil total tiap Cipl
-- =============================================
ALTER FUNCTION [dbo].[fn_get_total_cipl]
(	
	-- Add the parameters for the function here
	@CiplId bigint = 0
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		t0.Id AS IdCipl, 
		t0.CiplNo CiplNumber,
		ISNULL(SUM(Volume),0) TotalVolume,
		ISNULL(SUM(NetWeight),0) TotalNetWeight,
		ISNULL(SUM(GrossWeight),0) TotalGrossWeight,
		ISNULL(COUNT(DISTINCT 
			CASE 
			WHEN t0.CategoriItem = 'SIB' 
				THEN JCode 
			WHEN t0.CategoriItem = 'PRA' OR t0.CategoriItem = 'REMAN'
				THEN CaseNumber
			ELSE Sn END),0) AS TotalPackage
	FROM dbo.Cipl t0
	LEFT JOIN dbo.CiplItem t1 on t0.id = t1.IdCipl
		AND t1.IsDelete = 0
	WHERE --t0.IsDelete = 0 AND 
	t0.Id = @CiplId
	GROUP BY t0.Id, CiplNo
)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetReportDetailTracking_20201217]    Script Date: 10/03/2023 11:40:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_GetReportDetailTracking_20201217] ()
RETURNS TABLE
AS
RETURN (
		SELECT CONCAT (
				LEFT(DATENAME(MONTH, t0.UpdateDate), 3)
				,'-'
				,DATEPART(YEAR, t0.UpdateDate)
				) PebMonth
			,CAST(ROW_NUMBER() OVER (
					PARTITION BY CONCAT (
						LEFT(DATENAME(MONTH, t0.UpdateDate), 3)
						,'-'
						,DATEPART(YEAR, t0.UpdateDate)
						) ORDER BY t0.UpdateDate
					) AS VARCHAR(5)) RowNumber
			,IIF(t0.ReferenceNo = '', '-', t0.ReferenceNo) ReferenceNo
			,t0.CiplNo
			,t0.EdoNo AS EDINo
			,IIF(t0.PermanentTemporary = 'Repair Return (Temporary)', 'Temporary', IIF(t0.PermanentTemporary = 'Return (Permanent)', 'Permanent', IIF(t0.PermanentTemporary = 'Personal Effect (Permanent)', 'Permanent', 'Permanent'))) AS PermanentTemporary
			,IIF(t0.SalesNonSales <> 'Non Sales', IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, ' ', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))), t0.SalesNonSales) AS SalesNonSales
			,t0.Remarks
			,t0.ConsigneeName
			,t0.ConsigneeAddress
			,t0.ConsigneeCountry
			,t0.ConsigneeTelephone
			,t0.ConsigneeFax
			,t0.ConsigneePic
			,t0.ConsigneeEmail
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyName ELSE '' END AS NotifyName
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyAddress ELSE '' END AS NotifyAddress
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyCountry ELSE '' END AS NotifyCountry
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyTelephone ELSE '' END AS NotifyTelephone
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyFax ELSE '' END AS NotifyFax
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyPic ELSE '' END AS NotifyPic
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyEmail ELSE '' END AS NotifyEmail
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToName ELSE '' END AS SoldToName
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToAddress ELSE '' END AS SoldToAddress
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToCountry ELSE '' END AS SoldToCountry
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToTelephone ELSE '' END AS SoldToTelephone
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToFax ELSE '' END AS SoldToFax
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToPic ELSE '' END AS SoldToPic
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToEmail ELSE '' END AS SoldToEmail
			,t2.ShippingMethod
			,t2.Incoterms AS IncoTerms
			,IIF(t0.Category = 'MISCELLANEOUS', t0.CategoriItem, t0.Category) AS DescGoods
			,IIF(t0.Category = 'MISCELLANEOUS', t0.Category, IIF(t0.Category = 'CATERPILLAR SPAREPARTS', 'SPAREPARTS', t0.CategoriItem)) AS Category
			,IIF(t0.Category = 'MISCELLANEOUS'
				OR t0.Category = 'CATERPILLAR USED EQUIPMENT'
				OR t0.Category = 'CATERPILLAR UNIT', '-', t0.CategoriItem) AS SubCategory
			,IIF(t0.ExportType = 'Sales (Permanent)', '-', IIF(t0.ExportType = 'Non Sales - Repair Return (Temporary)', 'RR', IIF(t0.ExportType = 'Non Sales - Return (Permanent)', 'R', IIF(t0.ExportType = 'Non Sales - Personal Effect (Permanent)', 'PE', '-')))) AS [Type]
			,t0.UpdateDate AS CiplDate
			,CONCAT (
				CONVERT(VARCHAR(9), t0.UpdateDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t0.UpdateDate, 8)
				) CiplCreateDate
			,t0.CiplApprovalDate
			,t0.PICName
			,t0.PICApproverName
			,t0.GrNo AS RGNo
			,t0.RGDate
			,t0.RGApprovalDate
			,t0.RGApproverName
			,t0.CategoriItem
			,CONCAT (
				CONVERT(VARCHAR(18), t2.CreateDate, 6)
				,' '
				,CONVERT(VARCHAR(20), t2.CreateDate, 8)
				) ClDate
			,t2.ClNo
			,CONVERT(VARCHAR(11), t2.SailingSchedule, 106) AS ETD
			,CONVERT(VARCHAR(11), t2.ArrivalDestination, 106) AS ETA
			,t2.PortOfLoading
			,t2.PortOfDestination
			,t2.CargoType
			,ContainerNumber = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.ContainerNumber
						FROM CargoItem CI
						WHERE CI.IdCargo = t2.Id
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,Seal = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.ContainerSealNumber
						FROM CargoItem CI
						WHERE CI.IdCargo = t2.Id
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,'-' AS ContainerType
			,t7.TotalCaseNumber AS TotalColly
			,t2.Liner
			,IIF(t2.ShippingMethod = 'Sea', t2.VesselFlight, '') VesselName
			,IIF(t2.ShippingMethod = 'Air', t2.VesselFlight, '') FlightName
			,IIF(t2.ShippingMethod = 'Sea', t2.VoyageVesselFlight, '') VesselVoyNo
			,IIF(t2.ShippingMethod = 'Air', t2.VoyageVesselFlight, '') FlightVoyNo
			,t2.SsNo AS SSNo
			,t2.ClApprovalDate AS CLApprovalDate
			,t2.ClApproverName
			,t3.SlNo AS SINo
			,CONCAT (
				CONVERT(VARCHAR(9), t3.CreateDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t3.CreateDate, 8)
				) AS SIDate
			,CONCAT (
				CONVERT(VARCHAR(9), t4.AjuDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.AjuDate, 8)
				) AS AjuDate
			,t4.AjuNumber
			,CONCAT (
				CONVERT(VARCHAR(9), t4.NpeDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.NpeDate, 8)
				) AS NpeDate
			,t4.NpeNumber
			,t4.RegistrationNumber AS NOPEN
			,FORMAT(t4.PebFob, '#,0.00') PebFob
			,FORMAT(t4.FreightPayment, '#,0.00') FreightPyment
			,FORMAT(t4.InsuranceAmount, '#,0.00') InsuranceAmount
			,CONCAT (
				CONVERT(VARCHAR(9), t4.PEBApprovalDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.PEBApprovalDate, 8)
				) AS PEBApprovalDate
			,t4.PEBApproverName
			,t5.Number AS MasterBlAwbNumber
			,CONVERT(VARCHAR(10), t5.MasterBlDate, 120) AS MasterBlAwbDate
			,t5.HouseBlNumber HouseBlAwbNumber
			,CONVERT(VARCHAR(10), t5.HouseBlDate, 120) AS HouseBlAwbDate
			,FORMAT(t4.PebFob + t4.FreightPayment + t4.InsuranceAmount, '#,0.00') AS TotalPEB
			,'-' AS InvoiceNoServiceCharges
			,'-' AS CurrencyServiceCharges
			,'-' AS TotalServiceCharges
			,'-' AS InvoiceNoConsignee
			,'-' AS CurrencyValueConsignee
			,'-' AS TotalValueConsignee
			,'-' AS ValueBalanceConsignee
			,'-' AS [Status1]
			,Uom = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.Uom
						FROM CiplItem CI
						WHERE CI.IdCipl = t0.Id
							AND CI.Uom <> ''
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,t7.Quantity TotalUom
			,t7.TotalExtendedValue TotalExtendedValue
			,t4.Rate
			,t4.Valuta
			,t8.Gross
			,t8.Net
			,t8.Volume
			,CASE 
				WHEN fnReqCl.StatusViewByUser IS NOT NULL
					AND fnReqCl.StatusViewByUser != 'Draft'
					THEN fnReqCl.StatusViewByUser
				WHEN fnReqGr.NextStatusViewByUser IS NOT NULL
					AND fnReqGr.NextStatusViewByUser != 'Draft'
					THEN fnReqGr.NextStatusViewByUser
				ELSE fnReq.NextStatusViewByUser
				END AS [Status]
		FROM (
			SELECT DISTINCT t0.CiplNo
				,t0.ReferenceNo
				,t0.Category
				,t0.CategoriItem
				,IIF(t0.UpdateBy IS NOT NULL, t0.UpdateDate, t0.CreateDate) UpdateDate
				,IIF(t0.UpdateBy IS NOT NULL, t0.UpdateBy, t0.CreateBy) PICName
				,t0.id
				,t0.EdoNo
				,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) <= 0, IIF(CHARINDEX('Permanent', t0.ExportType) > 0, 'Permanent', '-'), --'-',
					LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) AS PermanentTemporary
				,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, '-', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) AS SalesNonSales
				,t0.ExportType
				,t0.Remarks
				,t0.ConsigneeName
				,t0.ConsigneeAddress
				,t0.ConsigneeCountry
				,t0.ConsigneeTelephone
				,t0.ConsigneeFax
				,t0.ConsigneePic
				,t0.ConsigneeEmail
				,t0.NotifyName
				,t0.NotifyAddress
				,t0.NotifyCountry
				,t0.NotifyTelephone
				,t0.NotifyFax
				,t0.NotifyPic
				,t0.NotifyEmail
				,t0.SoldToName
				,t0.SoldToAddress
				,t0.SoldToCountry
				,t0.SoldToTelephone
				,t0.SoldToFax
				,t0.SoldToPic
				,t0.SoldToEmail
				,t0.ShippingMethod
				,
				--t0.IncoTerm,
				CONCAT (
					CONVERT(VARCHAR(9), t4.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t4.UpdateDate, 8)
					) AS CiplApprovalDate
				,t6.Employee_Name AS PICApproverName
				,t3.GrNo
				,CONCAT (
					CONVERT(VARCHAR(9), t3.CreateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t3.CreateDate, 8)
					) AS RGDate
				,CONCAT (
					CONVERT(VARCHAR(9), t5.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t5.UpdateDate, 8)
					) AS RGApprovalDate
				,t7.Employee_Name AS RGApproverName
				,t3.Id IdGr
				,t0.ShipDelivery
			FROM Cipl t0
			JOIN CiplItem t1 ON t0.id = t1.idCipl
			LEFT JOIN RequestCipl t4 ON t4.IdCipl = t0.id
				AND t4.STATUS = 'Approve'
			LEFT JOIN GoodsReceiveItem t2 ON t2.IdCipl = t0.id
			LEFT JOIN GoodsReceive t3 ON t3.Id = t2.IdGr
			LEFT JOIN RequestGr t5 ON t5.IdGr = t2.IdGr
				AND t5.STATUS = 'Approve'
			LEFT JOIN Employee t6 ON t6.AD_User = t4.UpdateBy
			LEFT JOIN Employee t7 ON t7.AD_User = t5.UpdateBy
			) t0
		LEFT JOIN CargoCipl t1 ON t1.IdCipl = t0.id
		LEFT JOIN (
			SELECT t0.*
				,t2.Employee_Name ClApproverName
				,
				--t1.UpdateBy ClApproverName, 
				CONCAT (
					CONVERT(VARCHAR(9), t1.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t1.UpdateDate, 8)
					) ClApprovalDate
			FROM Cargo t0
			--left join RequestCl t1 on t0.Id = t1.IdCl and t1.Status = 'Approve' and t1.IdStep = 12
			LEFT JOIN CargoHistory t1 ON t0.Id = t1.IdCargo
				AND t1.Step NOT IN (
					'Approve NPE & PEB'
					,'Approve BL or AWB'
					)
				AND t1.STATUS = 'Approve'
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			) t2 ON t2.Id = t1.IdCargo
		LEFT JOIN ShippingInstruction t3 ON t3.IdCL = t2.Id
		LEFT JOIN (
			SELECT t0.*
				,t2.Employee_Name AS PEBApproverName
				,t1.UpdateDate AS PEBApprovalDate
			FROM NpePeb t0
			LEFT JOIN CargoHistory t1 ON t0.IdCl = t1.IdCargo
				AND t1.Step = 'Approve NPE & PEB'
				AND t1.STATUS = 'Approve'
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			) t4 ON t4.IdCl = t2.Id
		LEFT JOIN BlAwb t5 ON t5.IdCl = t2.Id
		LEFT JOIN (
			SELECT c.id
				,MAX(ISNULL(ci.Currency, '-')) AS Currency
				,CASE 
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'SIB'
						THEN CAST(count(DISTINCT ISNULL(ci.Id, '-')) AS VARCHAR(5))
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'PRA'
						THEN CAST(count(DISTINCT ISNULL(ci.ASNNumber, '-')) AS VARCHAR(5))
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'Old Core'
						THEN CAST(count(DISTINCT ISNULL(ci.CaseNumber, '-')) AS VARCHAR(5))
					ELSE CAST(count(DISTINCT ci.Sn) AS VARCHAR(5))
					END AS TotalCaseNumber
				,FORMAT(sum(ISNULL(ci.ExtendedValue, 0)), '#,0.00') AS TotalExtendedValue
				,FORMAT(sum(ISNULL(ci.Quantity, 0)), '#,0.00') AS Quantity
			FROM Cipl c
			INNER JOIN CiplItem ci ON c.id = ci.IdCipl
			INNER JOIN CargoItem cai ON cai.IdCiplItem = ci.Id
			GROUP BY c.id
				,c.Category
				,c.CategoriItem
			) t7 ON t7.id = t0.id
		LEFT JOIN (
			SELECT FORMAT(sum(ISNULL(c.Gross, 0)), '#,0.00') Gross
				,FORMAT(sum(ISNULL(c.Net, 0)), '#,0.00') Net
				,FORMAT(sum(ISNULL(c.Width * c.Height * c.Length, 0)), '#,0.00') AS Volume
				,c.IdCargo
			FROM CargoItem c
			GROUP BY c.IdCargo
			) t8 ON t8.IdCargo = t2.Id
		LEFT JOIN dbo.[fn_get_cipl_request_list_all]() AS fnReq ON fnReq.IdCipl = t0.id
		LEFT JOIN dbo.[fn_get_gr_request_list_all]() AS fnReqGr ON fnReqGr.IdGr = t0.IdGr
		LEFT JOIN dbo.[fn_get_cl_request_list_all]() AS fnReqCl ON fnReqCl.IdCl = t2.Id
		GROUP BY t0.id
			,t0.UpdateDate
			,t0.CiplNo
			,t0.EdoNo
			,t0.ReferenceNo
			,t0.PICName
			,t0.PermanentTemporary
			,t0.SalesNonSales
			,t0.Remarks
			,t0.ConsigneeName
			,t0.ConsigneeAddress
			,t0.ConsigneeCountry
			,t0.ConsigneeTelephone
			,t0.ConsigneeFax
			,t0.ConsigneePic
			,t0.ConsigneeEmail
			,t0.NotifyName
			,t0.NotifyAddress
			,t0.NotifyCountry
			,t0.NotifyTelephone
			,t0.NotifyFax
			,t0.NotifyPic
			,t0.NotifyEmail
			,t0.SoldToName
			,t0.SoldToAddress
			,t0.SoldToCountry
			,t0.SoldToTelephone
			,t0.SoldToFax
			,t0.SoldToPic
			,t0.SoldToEmail
			,t0.PICApproverName
			,t0.GrNo
			,t2.ClNo
			,t2.SsNo
			,t3.SlNo
			,t4.AjuDate
			,t4.AjuNumber
			,t4.NpeDate
			,t4.NpeNumber
			,t5.Number
			,t5.MasterBlDate
			,t5.HouseBlNumber
			,t5.HouseBlDate
			,t2.SailingSchedule
			,t2.ArrivalDestination
			,t2.PortOfLoading
			,t2.PortOfDestination
			,t2.ShippingMethod
			,t2.CargoType
			,t2.Incoterms
			,t4.PebFob
			,t4.FreightPayment
			,t4.InsuranceAmount
			,t0.Category
			,t0.CategoriItem
			,t0.CiplApprovalDate
			,t0.RGApprovalDate
			,t0.RGDate
			,t2.CreateDate
			,t0.ExportType
			,t2.ClApprovalDate
			,t2.ClApproverName
			,t0.RGApproverName
			,t3.CreateDate
			,t4.RegistrationNumber
			,t4.PEBApproverName
			,t4.PEBApprovalDate
			,t2.VesselFlight
			,t2.VoyageVesselFlight
			,t2.Liner
			,t2.Id
			,t7.Quantity
			,t7.TotalCaseNumber
			,TotalExtendedValue
			,t4.Rate
			,t4.Valuta
			,t8.Gross
			,t8.Net
			,t8.Volume
			,fnReq.NextStatusViewByUser
			,fnReqGr.NextStatusViewByUser
			,fnReqCl.StatusViewByUser
			,t0.ShipDelivery
		)
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetReportDetailTracking_20210730]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_GetReportDetailTracking_20210730] ()
RETURNS TABLE
AS
RETURN (
		SELECT CONCAT (
				LEFT(DATENAME(MONTH, t0.UpdateDate), 3)
				,'-'
				,DATEPART(YEAR, t0.UpdateDate)
				) PebMonth
			,CAST(ROW_NUMBER() OVER (
					PARTITION BY CONCAT (
						LEFT(DATENAME(MONTH, t0.UpdateDate), 3)
						,'-'
						,DATEPART(YEAR, t0.UpdateDate)
						) ORDER BY t0.UpdateDate
					) AS VARCHAR(5)) RowNumber
			,IIF(t0.ReferenceNo = '', '-', t0.ReferenceNo) ReferenceNo
			,t0.CiplNo
			,t0.EdoNo AS EDINo
			,IIF(t0.PermanentTemporary = 'Repair Return (Temporary)', 'Temporary', IIF(t0.PermanentTemporary = 'Return (Permanent)', 'Permanent', IIF(t0.PermanentTemporary = 'Personal Effect (Permanent)', 'Permanent', 'Permanent'))) AS PermanentTemporary
			,IIF(t0.SalesNonSales <> 'Non Sales', IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, ' ', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))), t0.SalesNonSales) AS SalesNonSales
			,t0.Remarks
			,t0.ConsigneeName
			,t0.ConsigneeAddress
			,t0.ConsigneeCountry
			,t0.ConsigneeTelephone
			,t0.ConsigneeFax
			,t0.ConsigneePic
			,t0.ConsigneeEmail
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyName ELSE '' END AS NotifyName
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyAddress ELSE '' END AS NotifyAddress
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyCountry ELSE '' END AS NotifyCountry
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyTelephone ELSE '' END AS NotifyTelephone
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyFax ELSE '' END AS NotifyFax
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyPic ELSE '' END AS NotifyPic
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyEmail ELSE '' END AS NotifyEmail
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToName ELSE '' END AS SoldToName
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToAddress ELSE '' END AS SoldToAddress
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToCountry ELSE '' END AS SoldToCountry
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToTelephone ELSE '' END AS SoldToTelephone
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToFax ELSE '' END AS SoldToFax
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToPic ELSE '' END AS SoldToPic
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToEmail ELSE '' END AS SoldToEmail
			,t2.ShippingMethod
			,t2.Incoterms AS IncoTerms
			,IIF(t0.Category = 'MISCELLANEOUS', t0.CategoriItem, t0.Category) AS DescGoods
			,IIF(t0.Category = 'MISCELLANEOUS', t0.Category, IIF(t0.Category = 'CATERPILLAR SPAREPARTS', 'SPAREPARTS', t0.CategoriItem)) AS Category
			,IIF(t0.Category = 'MISCELLANEOUS'
				OR t0.Category = 'CATERPILLAR USED EQUIPMENT'
				OR t0.Category = 'CATERPILLAR UNIT', '-', t0.CategoriItem) AS SubCategory
			,IIF(t0.ExportType = 'Sales (Permanent)', '-', IIF(t0.ExportType = 'Non Sales - Repair Return (Temporary)', 'RR', IIF(t0.ExportType = 'Non Sales - Return (Permanent)', 'R', IIF(t0.ExportType = 'Non Sales - Personal Effect (Permanent)', 'PE', '-')))) AS [Type]
			,t0.UpdateDate AS CiplDate
			,CONCAT (
				CONVERT(VARCHAR(9), t0.UpdateDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t0.UpdateDate, 8)
				) CiplCreateDate
			,t0.CiplApprovalDate
			,t0.PICName
			,t0.Department
			,t0.Branch
			,t0.PICApproverName
			,t0.GrNo AS RGNo
			,t0.RGDate
			,t0.RGApprovalDate
			,t0.RGApproverName
			,t0.CategoriItem
			,CONCAT (
				CONVERT(VARCHAR(18), t2.CreateDate, 6)
				,' '
				,CONVERT(VARCHAR(20), t2.CreateDate, 8)
				) ClDate
			,t2.ClNo
			,CONVERT(VARCHAR(11), t2.SailingSchedule, 106) AS ETD
			,CONVERT(VARCHAR(11), t2.ArrivalDestination, 106) AS ETA
			,t2.PortOfLoading
			,t2.PortOfDestination
			,t2.CargoType
			,ContainerNumber = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.ContainerNumber
						FROM CargoItem CI
						WHERE CI.IdCargo = t2.Id
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,Seal = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.ContainerSealNumber
						FROM CargoItem CI
						WHERE CI.IdCargo = t2.Id
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,'-' AS ContainerType
			,t7.TotalCaseNumber AS TotalColly
			,t2.Liner
			,IIF(t2.ShippingMethod = 'Sea', t2.VesselFlight, '') VesselName
			,IIF(t2.ShippingMethod = 'Air', t2.VesselFlight, '') FlightName
			,IIF(t2.ShippingMethod = 'Sea', t2.VoyageVesselFlight, '') VesselVoyNo
			,IIF(t2.ShippingMethod = 'Air', t2.VoyageVesselFlight, '') FlightVoyNo
			,t2.SsNo AS SSNo
			,t2.ClApprovalDate AS CLApprovalDate
			,t2.ClApproverName
			,t3.SlNo AS SINo
			,CONCAT (
				CONVERT(VARCHAR(9), t3.CreateDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t3.CreateDate, 8)
				) AS SIDate
			,CONCAT (
				CONVERT(VARCHAR(9), t4.AjuDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.AjuDate, 8)
				) AS AjuDate
			,t4.AjuNumber
			,CONCAT (
				CONVERT(VARCHAR(9), t4.NpeDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.NpeDate, 8)
				) AS NpeDate
			,t4.NpeNumber
			,t4.RegistrationNumber AS NOPEN
			,FORMAT(t4.PebFob, '#,0.00') PebFob
			,FORMAT(t4.FreightPayment, '#,0.00') FreightPyment
			,FORMAT(t4.InsuranceAmount, '#,0.00') InsuranceAmount
			,CONCAT (
				CONVERT(VARCHAR(9), t4.PEBApprovalDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.PEBApprovalDate, 8)
				) AS PEBApprovalDate
			,t4.PEBApproverName
			,t5.Number AS MasterBlAwbNumber
			,CONVERT(VARCHAR(10), t5.MasterBlDate, 120) AS MasterBlAwbDate
			,t5.HouseBlNumber HouseBlAwbNumber
			,CONVERT(VARCHAR(10), t5.HouseBlDate, 120) AS HouseBlAwbDate
			,FORMAT(t4.PebFob + t4.FreightPayment + t4.InsuranceAmount, '#,0.00') AS TotalPEB
			,'-' AS InvoiceNoServiceCharges
			,'-' AS CurrencyServiceCharges
			,'-' AS TotalServiceCharges
			,'-' AS InvoiceNoConsignee
			,'-' AS CurrencyValueConsignee
			,'-' AS TotalValueConsignee
			,'-' AS ValueBalanceConsignee
			,'-' AS [Status1]
			,Uom = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.Uom
						FROM CiplItem CI
						WHERE CI.IdCipl = t0.Id
							AND CI.Uom <> ''
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,t7.Quantity TotalUom
			,t7.TotalExtendedValue TotalExtendedValue
			,FORMAT(sum(ISNULL(t4.Rate, 0)), '#,0.00') Rate
			,t4.Valuta
			,t8.Gross
			,t8.Net
			,t8.Volume
			,CASE 
				WHEN fnReqCl.StatusViewByUser IS NOT NULL
					AND fnReqCl.StatusViewByUser != 'Draft'
					THEN fnReqCl.StatusViewByUser
				WHEN fnReqGr.NextStatusViewByUser IS NOT NULL
					AND fnReqGr.NextStatusViewByUser != 'Draft'
					THEN fnReqGr.NextStatusViewByUser
				ELSE fnReq.NextStatusViewByUser
				END AS [Status]
		FROM (
			SELECT DISTINCT t0.CiplNo
				,t0.ReferenceNo
				,t0.Category
				,t0.CategoriItem
				,IIF(t0.UpdateBy IS NOT NULL, t0.UpdateDate, t0.CreateDate) UpdateDate
				,t8.Employee_name PICName
				,t8.Dept_Name Department
				,t8.Division_Name Branch
				,t0.id
				,t0.EdoNo
				,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) <= 0, IIF(CHARINDEX('Permanent', t0.ExportType) > 0, 'Permanent', '-'), --'-',
					LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) AS PermanentTemporary
				,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, '-', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) AS SalesNonSales
				,t0.ExportType
				,t0.Remarks
				,t0.ConsigneeName
				,t0.ConsigneeAddress
				,t0.ConsigneeCountry
				,t0.ConsigneeTelephone
				,t0.ConsigneeFax
				,t0.ConsigneePic
				,t0.ConsigneeEmail
				,t0.NotifyName
				,t0.NotifyAddress
				,t0.NotifyCountry
				,t0.NotifyTelephone
				,t0.NotifyFax
				,t0.NotifyPic
				,t0.NotifyEmail
				,t0.SoldToName
				,t0.SoldToAddress
				,t0.SoldToCountry
				,t0.SoldToTelephone
				,t0.SoldToFax
				,t0.SoldToPic
				,t0.SoldToEmail
				,t0.ShippingMethod
				,
				--t0.IncoTerm,
				CONCAT (
					CONVERT(VARCHAR(9), t4.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t4.UpdateDate, 8)
					) AS CiplApprovalDate
				,t6.Employee_Name AS PICApproverName
				,t3.GrNo
				,CONCAT (
					CONVERT(VARCHAR(9), t3.CreateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t3.CreateDate, 8)
					) AS RGDate
				,CONCAT (
					CONVERT(VARCHAR(9), t5.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t5.UpdateDate, 8)
					) AS RGApprovalDate
				,t7.Employee_Name AS RGApproverName
				,t3.Id IdGr
				,t0.ShipDelivery
			FROM Cipl t0
			JOIN CiplItem t1 ON t0.id = t1.idCipl AND t1.isdelete = 0
			LEFT JOIN RequestCipl t4 ON t4.IdCipl = t0.id
				AND t4.STATUS = 'Approve' and t4.isdelete = 0
			LEFT JOIN GoodsReceiveItem t2 ON t2.IdCipl = t0.id AND t2.isdelete = 0
			LEFT JOIN GoodsReceive t3 ON t3.Id = t2.IdGr AND t3.isdelete = 0
			LEFT JOIN RequestGr t5 ON t5.IdGr = t2.IdGr
				AND t5.STATUS = 'Approve' AND t5.isdelete = 0
			LEFT JOIN Employee t6 ON t6.AD_User = t4.UpdateBy
			LEFT JOIN Employee t7 ON t7.AD_User = t5.UpdateBy	
			LEFT JOIN Employee t8 ON t8.AD_User = t0.UpdateBy
			WHERE t0.isdelete = 0
			) t0
		LEFT JOIN CargoCipl t1 ON t1.IdCipl = t0.id AND t1.isdelete = 0
		LEFT JOIN (
			SELECT t0.*
				,t2.Employee_Name ClApproverName
				,
				--t1.UpdateBy ClApproverName, 
				CONCAT (
					CONVERT(VARCHAR(9), t1.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t1.UpdateDate, 8)
					) ClApprovalDate
			FROM Cargo t0
			--left join RequestCl t1 on t0.Id = t1.IdCl and t1.Status = 'Approve' and t1.IdStep = 12
			LEFT JOIN CargoHistory t1 ON t0.Id = t1.IdCargo
				AND t1.Step NOT IN (
					'Approve NPE & PEB'
					,'Approve BL or AWB'
					)
				AND t1.STATUS = 'Approve' AND t1.isdelete = 0
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			WHERE t0.isdelete = 0
			) t2 ON t2.Id = t1.IdCargo
		LEFT JOIN ShippingInstruction t3 ON t3.IdCL = t2.Id AND t3.isdelete = 0
		LEFT JOIN (
			SELECT t0.*
				,t2.Employee_Name AS PEBApproverName
				,t1.UpdateDate AS PEBApprovalDate
			FROM NpePeb t0
			LEFT JOIN CargoHistory t1 ON t0.IdCl = t1.IdCargo
				AND t1.Step = 'Approve NPE & PEB'
				AND t1.STATUS = 'Approve' AND t1.isdelete = 0
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			WHERE t0.isdelete = 0
			) t4 ON t4.IdCl = t2.Id
		LEFT JOIN BlAwb t5 ON t5.IdCl = t2.Id AND t5.isdelete = 0
		LEFT JOIN (
			SELECT c.id
				,MAX(ISNULL(ci.Currency, '-')) AS Currency
				,CASE 
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'SIB'
						THEN CAST(count(DISTINCT ISNULL(ci.Id, '-')) AS VARCHAR(5))
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'PRA'
						THEN CAST(count(DISTINCT ISNULL(ci.ASNNumber, '-')) AS VARCHAR(5))
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'Old Core'
						THEN CAST(count(DISTINCT ISNULL(ci.CaseNumber, '-')) AS VARCHAR(5))
					ELSE CAST(count(DISTINCT ci.Sn) AS VARCHAR(5))
					END AS TotalCaseNumber
				,FORMAT(sum(ISNULL(ci.ExtendedValue, 0)), '#,0.00') AS TotalExtendedValue
				,FORMAT(sum(ISNULL(ci.Quantity, 0)), '#,0.00') AS Quantity
			FROM Cipl c
			INNER JOIN CiplItem ci ON c.id = ci.IdCipl
			INNER JOIN CargoItem cai ON cai.IdCiplItem = ci.Id
			GROUP BY c.id
				,c.Category
				,c.CategoriItem
			) t7 ON t7.id = t0.id
		LEFT JOIN (
			SELECT FORMAT(sum(ISNULL(c.Gross, 0)), '#,0.00') Gross
				,FORMAT(sum(ISNULL(c.Net, 0)), '#,0.00') Net
				--,FORMAT(sum(ISNULL(c.Width * c.Height * c.Length, 0))/100, '#,0.00') AS Volume
				,FORMAT((SUM(ISNULL(c.Height,0))/100) * (SUM(ISNULL(c.Width,0))/100) * (SUM(ISNULL(c.Length,0))/100), '#,0.00') AS Volume
				,c.IdCargo
			FROM CargoItem c
			GROUP BY c.IdCargo
			) t8 ON t8.IdCargo = t1.IdCargo 
		LEFT JOIN dbo.[fn_get_cipl_request_list_all]() AS fnReq ON fnReq.IdCipl = t0.id
		LEFT JOIN dbo.[fn_get_gr_request_list_all]() AS fnReqGr ON fnReqGr.IdGr = t0.IdGr
		LEFT JOIN dbo.[fn_get_cl_request_list_all]() AS fnReqCl ON fnReqCl.IdCl = t2.Id
		GROUP BY t0.id
			,t0.UpdateDate
			,t0.CiplNo
			,t0.EdoNo
			,t0.ReferenceNo
			,t0.PICName
			,t0.Department
			,t0.Branch
			,t0.PermanentTemporary
			,t0.SalesNonSales
			,t0.Remarks
			,t0.ConsigneeName
			,t0.ConsigneeAddress
			,t0.ConsigneeCountry
			,t0.ConsigneeTelephone
			,t0.ConsigneeFax
			,t0.ConsigneePic
			,t0.ConsigneeEmail
			,t0.NotifyName
			,t0.NotifyAddress
			,t0.NotifyCountry
			,t0.NotifyTelephone
			,t0.NotifyFax
			,t0.NotifyPic
			,t0.NotifyEmail
			,t0.SoldToName
			,t0.SoldToAddress
			,t0.SoldToCountry
			,t0.SoldToTelephone
			,t0.SoldToFax
			,t0.SoldToPic
			,t0.SoldToEmail
			,t0.PICApproverName
			,t0.GrNo
			,t2.ClNo
			,t2.SsNo
			,t3.SlNo
			,t4.AjuDate
			,t4.AjuNumber
			,t4.NpeDate
			,t4.NpeNumber
			,t5.Number
			,t5.MasterBlDate
			,t5.HouseBlNumber
			,t5.HouseBlDate
			,t2.SailingSchedule
			,t2.ArrivalDestination
			,t2.PortOfLoading
			,t2.PortOfDestination
			,t2.ShippingMethod
			,t2.CargoType
			,t2.Incoterms
			,t4.PebFob
			,t4.FreightPayment
			,t4.InsuranceAmount
			,t0.Category
			,t0.CategoriItem
			,t0.CiplApprovalDate
			,t0.RGApprovalDate
			,t0.RGDate
			,t2.CreateDate
			,t0.ExportType
			,t2.ClApprovalDate
			,t2.ClApproverName
			,t0.RGApproverName
			,t3.CreateDate
			,t4.RegistrationNumber
			,t4.PEBApproverName
			,t4.PEBApprovalDate
			,t2.VesselFlight
			,t2.VoyageVesselFlight
			,t2.Liner
			,t2.Id
			,t7.Quantity
			,t7.TotalCaseNumber
			,TotalExtendedValue
			,t4.Rate
			,t4.Valuta
			,t8.Gross
			,t8.Net
			,t8.Volume
			,fnReq.NextStatusViewByUser
			,fnReqGr.NextStatusViewByUser
			,fnReqCl.StatusViewByUser
			,t0.ShipDelivery
		)


GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetReportDetailTracking_RDetails]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_GetReportDetailTracking_RDetails] ()        
RETURNS TABLE        
AS        
RETURN (        
  SELECT 
	CONCAT (        
    LEFT(DATENAME(MONTH, t0.UpdateDate), 3)        
    ,'-'        
    ,DATEPART(YEAR, t0.UpdateDate)        
    ) PebMonth
    --CONVERT(VARCHAR(11), t0.UpdateDate, 106) AS PebMonth  
   ,CAST(ROW_NUMBER() OVER (        
     PARTITION BY CONCAT (        
      LEFT(DATENAME(MONTH, t0.UpdateDate), 3)        
      ,'-'        
      ,DATEPART(YEAR, t0.UpdateDate)        
      ) ORDER BY t0.UpdateDate        
     ) AS VARCHAR(5)) RowNumber        
   ,IIF(t0.ReferenceNo = '', '-', t0.ReferenceNo) ReferenceNo        
   ,t0.CiplNo        
   ,t0.EdoNo AS EDINo        
   ,IIF(t0.PermanentTemporary = 'Repair Return (Temporary)', 'Temporary', IIF(t0.PermanentTemporary = 'Return (Permanent)', 'Permanent', IIF(t0.PermanentTemporary = 'Personal Effect (Permanent)', 'Permanent', 'Permanent'))) AS PermanentTemporary        
   ,IIF(t0.SalesNonSales <> 'Non Sales', IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL        
     OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, ' ', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))), t0.SalesNonSales) AS SalesNonSales        
   ,t0.Remarks        
   ,t0.ConsigneeName        
   ,t0.ConsigneeAddress        
   ,t0.ConsigneeCountry        
   ,t0.ConsigneeTelephone        
   ,t0.ConsigneeFax        
   ,t0.ConsigneePic        
   ,t0.ConsigneeEmail        
   ,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyName ELSE '' END AS NotifyName        
   ,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyAddress ELSE '' END AS NotifyAddress        
   ,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyCountry ELSE '' END AS NotifyCountry        
   ,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyTelephone ELSE '' END AS NotifyTelephone        
   ,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyFax ELSE '' END AS NotifyFax        
   ,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyPic ELSE '' END AS NotifyPic        
   ,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyEmail ELSE '' END AS NotifyEmail        
   ,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToName ELSE '' END AS SoldToName        
   ,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToAddress ELSE '' END AS SoldToAddress        
   ,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToCountry ELSE '' END AS SoldToCountry        
   ,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToTelephone ELSE '' END AS SoldToTelephone        
   ,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToFax ELSE '' END AS SoldToFax        
   ,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToPic ELSE '' END AS SoldToPic        
   ,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToEmail ELSE '' END AS SoldToEmail        
   ,t2.ShippingMethod        
   ,t2.Incoterms AS IncoTerms        
   ,IIF(t0.Category = 'MISCELLANEOUS', t0.CategoriItem, t0.Category) AS DescGoods        
   ,IIF(t0.Category = 'MISCELLANEOUS', t0.Category, IIF(t0.Category = 'CATERPILLAR SPAREPARTS', 'SPAREPARTS', t0.CategoriItem)) AS Category        
   ,IIF(t0.Category = 'MISCELLANEOUS'        
    OR t0.Category = 'CATERPILLAR USED EQUIPMENT'        
    OR t0.Category = 'CATERPILLAR UNIT', '-', t0.CategoriItem) AS SubCategory        
   ,IIF(t0.ExportType = 'Sales (Permanent)', '-', IIF(t0.ExportType = 'Non Sales - Repair Return (Temporary)', 'RR', IIF(t0.ExportType = 'Non Sales - Return (Permanent)', 'R', IIF(t0.ExportType = 'Non Sales - Personal Effect (Permanent)', 'PE', '-')))) AS
	[Type]        
   ,t0.UpdateDate AS CiplDate        
   ,CONCAT (        
    CONVERT(VARCHAR(9), t0.UpdateDate, 6)        
    ,' '        
    ,CONVERT(VARCHAR(9), t0.UpdateDate, 8)        
    ) CiplCreateDate        
   ,CONCAT (        
    CONVERT(VARCHAR(9), t0.CiplApprovalDate, 6)        
    ,' '        
    ,CONVERT(VARCHAR(9), t0.CiplApprovalDate, 8)        
    ) As CiplApprovalDate        
   ,t0.PICName        
   ,t0.Department        
   ,t0.Branch        
   ,t0.PICApproverName        
   ,t0.GrNo AS RGNo        
   ,CONCAT (        
    CONVERT(VARCHAR(10), t0.RGDate)        
    ,' '        
    ,CONVERT(VARCHAR(10), t0.RGDate)        
    )as RGDate         
   ,CONCAT (        
    CONVERT(VARCHAR(9), t0.RGApprovalDate, 6)        
    ,' '        
    ,CONVERT(VARCHAR(9), t0.RGApprovalDate, 8)        
    )as RGApprovalDate        
   ,t0.RGApproverName        
   ,t0.CategoriItem        
   ,CONCAT (        
    CONVERT(VARCHAR(18), t2.CreateDate, 6)        
    ,' '        
    ,CONVERT(VARCHAR(20), t2.CreateDate, 8)        
    ) ClDate        
   ,t2.ClNo        
   ,CONVERT(VARCHAR(11), t2.SailingSchedule, 106) AS ETD        
   ,CONVERT(VARCHAR(11), t2.ArrivalDestination, 106) AS ETA        
   ,t2.PortOfLoading        
   ,t2.PortOfDestination        
   ,t2.CargoType    
   ,ContainerNumber = COALESCE(STUFF((        
      SELECT DISTINCT ',' + CI.ContainerNumber        
      FROM CargoItem CI        
      WHERE CI.IdCargo = t2.Id        
      FOR XML PATH('')        
       ,TYPE        
      ).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')        
   ,Seal = COALESCE(STUFF((        
      SELECT DISTINCT ',' + CI.ContainerSealNumber        
      FROM CargoItem CI        
      WHERE CI.IdCargo = t2.Id        
      FOR XML PATH('')        
       ,TYPE        
      ).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')        
   ,'-' AS ContainerType        
   ,t7.TotalCaseNumber AS TotalColly        
   ,t2.Liner        
   ,IIF(t2.ShippingMethod = 'Sea', t2.VesselFlight, '') VesselName        
   ,IIF(t2.ShippingMethod = 'Air', t2.VesselFlight, '') FlightName        
   ,IIF(t2.ShippingMethod = 'Sea', t2.VoyageVesselFlight, '') VesselVoyNo        
   ,IIF(t2.ShippingMethod = 'Air', t2.VoyageVesselFlight, '') FlightVoyNo        
   ,t2.SsNo AS SSNo        
   ,CONCAT (        
    CONVERT(VARCHAR(9), t2.CLApprovalDate, 6)        
    ,' '        
    ,CONVERT(VARCHAR(9), t2.CLApprovalDate, 8)        
    )AS CLApprovalDate        
   ,t2.ClApproverName        
   ,t3.SlNo AS SINo        
   ,CONCAT (        
    CONVERT(VARCHAR(9), t3.CreateDate, 6)        
    ,' '        
    ,CONVERT(VARCHAR(9), t3.CreateDate, 8)        
    ) AS SIDate        
   ,CONCAT (        
    CONVERT(VARCHAR(9), t4.AjuDate, 6)        
    ,' '        
    ,CONVERT(VARCHAR(9), t4.AjuDate, 8)        
    ) AS AjuDate        
   ,t4.AjuNumber        
   ,CONCAT (        
    CONVERT(VARCHAR(9), t4.NpeDate, 6)        
    ,' '        
    ,CONVERT(VARCHAR(9), t4.NpeDate, 8)        
    ) AS NpeDate        
   ,t4.NpeNumber        
   ,t4.RegistrationNumber AS NOPEN        
   ,FORMAT(t4.PebFob, '#,0.00') PebFob        
   ,FORMAT(t4.FreightPayment, '#,0.00') FreightPyment        
   ,FORMAT(t4.InsuranceAmount, '#,0.00') InsuranceAmount        
   ,CONCAT (        
    CONVERT(VARCHAR(9), t4.PEBApprovalDate, 6)        
    ,' '        
    ,CONVERT(VARCHAR(9), t4.PEBApprovalDate, 8)        
    ) AS PEBApprovalDate        
   ,t4.PEBApproverName        
   ,t5.Number AS MasterBlAwbNumber        
   ,CONVERT(VARCHAR(10), t5.MasterBlDate, 120) AS MasterBlAwbDate        
   ,t5.HouseBlNumber HouseBlAwbNumber        
   ,CONVERT(VARCHAR(10), t5.HouseBlDate, 120) AS HouseBlAwbDate        
   ,FORMAT(t4.PebFob + t4.FreightPayment + t4.InsuranceAmount, '#,0.00') AS TotalPEB        
   ,'-' AS InvoiceNoServiceCharges        
   ,'-' AS CurrencyServiceCharges        
   ,'-' AS TotalServiceCharges        
   ,'-' AS InvoiceNoConsignee        
   ,'-' AS CurrencyValueConsignee        
   ,'-' AS TotalValueConsignee        
   ,'-' AS ValueBalanceConsignee        
   ,'-' AS [Status1]        
   ,Uom = COALESCE(STUFF((        
      SELECT DISTINCT ',' + CI.Uom        
      FROM CiplItem CI        
    WHERE CI.IdCipl = t0.Id        
       AND CI.Uom <> ''        
      FOR XML PATH('')        
       ,TYPE        
      ).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')        
   ,t7.Quantity TotalUom        
   ,t7.TotalExtendedValue TotalExtendedValue        
   ,FORMAT(sum(ISNULL(t4.Rate, 0)), '#,0.00') Rate        
   ,t4.Valuta        
   ,t8.Gross        
   ,t8.Net        
   ,t8.Volume    
   ,t0.CustomsFacilityArea    
   ,CASE         
    WHEN fnReqCl.StatusViewByUser IS NOT NULL        
     AND fnReqCl.StatusViewByUser != 'Draft'        
     THEN fnReqCl.StatusViewByUser        
    WHEN fnReqGr.NextStatusViewByUser IS NOT NULL        
     AND fnReqGr.NextStatusViewByUser != 'Draft'        
     THEN fnReqGr.NextStatusViewByUser        
    ELSE fnReq.NextStatusViewByUser        
    END AS [Status]     
     
  FROM (        
   SELECT DISTINCT t0.CiplNo        
    ,t0.ReferenceNo        
 ,t0.Category        
    ,t0.CategoriItem        
    ,IIF(t0.UpdateBy IS NOT NULL, t0.UpdateDate, t0.CreateDate) UpdateDate        
    ,t8.Employee_name PICName        
    ,t8.Dept_Name Department        
    ,t8.Division_Name Branch        
    ,t0.id        
    ,t0.EdoNo    
     
    ,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)'))) IS NULL        
     OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) <= 0, IIF(CHARINDEX('Permanent', t0.ExportType) > 0, 'Permanent', '-'), --'-',        
     LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) AS PermanentTemporary        
    ,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL        
     OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, '-', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) AS SalesNonSales        
    ,t0.ExportType        
    ,t0.Remarks        
    ,t0.ConsigneeName        
    ,t0.ConsigneeAddress        
    ,t0.ConsigneeCountry        
    ,t0.ConsigneeTelephone        
    ,t0.ConsigneeFax        
    ,t0.ConsigneePic        
    ,t0.ConsigneeEmail        
    ,t0.NotifyName        
    ,t0.NotifyAddress        
    ,t0.NotifyCountry        
    ,t0.NotifyTelephone        
    ,t0.NotifyFax        
    ,t0.NotifyPic        
    ,t0.NotifyEmail        
    ,t0.SoldToName        
    ,t0.SoldToAddress        
    ,t0.SoldToCountry        
    ,t0.SoldToTelephone        
    ,t0.SoldToFax        
    ,t0.SoldToPic        
    ,t0.SoldToEmail        
    ,t0.ShippingMethod        
    ,        
    --t0.IncoTerm,        
    CONCAT (        
     CONVERT(VARCHAR(9), t4.UpdateDate, 6)        
     ,' '        
     ,CONVERT(VARCHAR(9), t4.UpdateDate, 8)        
     ) AS CiplApprovalDate        
    ,t6.Employee_Name AS PICApproverName        
    ,t3.GrNo        
    ,CONCAT (        
     --CONVERT(VARCHAR(9), , 6)   
  CONVERT(VARCHAR(23), t3.CreateDate, 110)  
     ,' '        
   ,CONVERT(VARCHAR(23), t3.CreateDate, 110)  
     --,CONVERT(VARCHAR(9), t3.CreateDate, 8)        
     ) AS RGDate          
    ,CONCAT (        
     CONVERT(VARCHAR(9), t5.UpdateDate, 6)        
     ,' '        
     ,CONVERT(VARCHAR(9), t5.UpdateDate, 8)        
     ) AS RGApprovalDate        
    ,t7.Employee_Name AS RGApproverName        
    ,t3.Id IdGr        
    ,t0.ShipDelivery      
 ,cf.[Type] as CustomsFacilityArea     
   FROM Cipl t0        
   JOIN CiplItem t1 ON t0.id = t1.idCipl AND t1.isdelete = 0     
   left join CiplForwader cf on cf.IdCipl = t0.id and cf.IsDelete = 0    
   LEFT JOIN RequestCipl t4 ON t4.IdCipl = t0.id        
    AND t4.STATUS = 'Approve' and t4.isdelete = 0        
   LEFT JOIN ShippingFleetRefrence t2 ON t2.IdCipl = t0.id        
   LEFT JOIN GoodsReceive t3 ON t3.Id = t2.IdGr AND t3.isdelete = 0     
   LEFT JOIN RequestGr t5 ON t5.IdGr = t2.IdGr        
    AND t5.STATUS = 'Approve' AND t5.isdelete = 0        
   LEFT JOIN Employee t6 ON t6.AD_User = t4.UpdateBy        
   LEFT JOIN Employee t7 ON t7.AD_User = t5.UpdateBy         
   LEFT JOIN Employee t8 ON t8.AD_User = t0.UpdateBy        
   WHERE t0.isdelete = 0        
   ) t0        
  LEFT JOIN CargoCipl t1 ON t1.IdCipl = t0.id AND t1.isdelete = 0        
  LEFT JOIN (        
   SELECT t0.*        
    ,t2.Employee_Name ClApproverName        
    ,        
    --t1.UpdateBy ClApproverName,         
    CONCAT (        
     CONVERT(VARCHAR(9), t1.UpdateDate, 6)        
     ,' '        
     ,CONVERT(VARCHAR(9), t1.UpdateDate, 8)        
     ) ClApprovalDate        
   FROM Cargo t0        
   --left join RequestCl t1 on t0.Id = t1.IdCl and t1.Status = 'Approve' and t1.IdStep = 12        
   LEFT JOIN CargoHistory t1 ON t0.Id = t1.IdCargo        
    AND t1.Step NOT IN (        
     'Approve NPE & PEB'        
     ,'Approve BL or AWB'        
     ,'Create NPE & PEB'        
     )        
    AND t1.STATUS = 'Approve' AND t1.isdelete = 0        
   LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User        
   WHERE t0.isdelete = 0        
   ) t2 ON t2.Id = t1.IdCargo        
  LEFT JOIN ShippingInstruction t3 ON t3.IdCL = t2.Id AND t3.isdelete = 0        
  LEFT JOIN (        
   SELECT t0.*        
    ,t2.Employee_Name AS PEBApproverName        
    ,t1.UpdateDate AS PEBApprovalDate        
   FROM NpePeb t0        
   LEFT JOIN CargoHistory t1 ON t0.IdCl = t1.IdCargo        
    AND t1.Step = 'Approve NPE & PEB'        
    AND t1.STATUS = 'Approve' AND t1.isdelete = 0        
   LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User        
   WHERE t0.isdelete = 0        
   ) t4 ON t4.IdCl = t2.Id        
  LEFT JOIN BlAwb t5 ON t5.IdCl = t2.Id AND t5.isdelete = 0        
  LEFT JOIN (        
   SELECT c.id        
    ,MAX(ISNULL(ci.Currency, '-')) AS Currency        
    ,CASE         
     WHEN c.Category = 'CATERPILLAR SPAREPARTS'        
      AND c.CategoriItem = 'SIB'        
      THEN CAST(count(DISTINCT ISNULL(ci.Id, '-')) AS VARCHAR(5))        
     WHEN c.Category = 'CATERPILLAR SPAREPARTS'        
      AND c.CategoriItem = 'PRA'        
      THEN CAST(count(DISTINCT ISNULL(ci.ASNNumber, '-')) AS VARCHAR(5))        
     WHEN c.Category = 'CATERPILLAR SPAREPARTS'        
      AND c.CategoriItem = 'Old Core'        
      THEN CAST(count(DISTINCT ISNULL(ci.CaseNumber, '-')) AS VARCHAR(5))        
     ELSE CAST(count(DISTINCT ci.Sn) AS VARCHAR(5))        
     END AS TotalCaseNumber        
    ,FORMAT(sum(ISNULL(ci.ExtendedValue, 0)), '#,0.00') AS TotalExtendedValue        
    ,FORMAT(sum(ISNULL(ci.Quantity, 0)), '#,0.00') AS Quantity        
   FROM Cipl c        
   INNER JOIN CiplItem ci ON c.id = ci.IdCipl        
   INNER JOIN CargoItem cai ON cai.IdCiplItem = ci.Id        
   GROUP BY c.id        
    ,c.Category        
    ,c.CategoriItem        
   ) t7 ON t7.id = t0.id        
  LEFT JOIN (        
   SELECT FORMAT(sum(ISNULL(c.Gross, 0)), '#,0.00') Gross        
    ,FORMAT(sum(ISNULL(c.Net, 0)), '#,0.00') Net        
    --,FORMAT(sum(ISNULL(c.Width * c.Height * c.Length, 0))/100, '#,0.00') AS Volume        
    ,FORMAT((SUM(ISNULL(c.Height,0))/100) * (SUM(ISNULL(c.Width,0))/100) * (SUM(ISNULL(c.Length,0))/100), '#,0.00') AS Volume        
    ,c.IdCargo        
   FROM CargoItem c        
   GROUP BY c.IdCargo        
   ) t8 ON t8.IdCargo = t1.IdCargo         
  LEFT JOIN dbo.[fn_get_cipl_request_list_all]() AS fnReq ON fnReq.IdCipl = t0.id        
  LEFT JOIN dbo.[fn_get_gr_request_list_all]() AS fnReqGr ON fnReqGr.IdGr = t0.IdGr        
  LEFT JOIN dbo.[fn_get_cl_request_list_all]() AS fnReqCl ON fnReqCl.IdCl = t2.Id        
  GROUP BY t0.id        
   ,t0.UpdateDate        
   ,t0.CiplNo        
   ,t0.EdoNo        
   ,t0.ReferenceNo        
   ,t0.PICName        
   ,t0.Department        
   ,t0.Branch        
   ,t0.PermanentTemporary        
   ,t0.SalesNonSales        
   ,t0.Remarks     
   ,t0.ConsigneeName        
   ,t0.ConsigneeAddress        
   ,t0.ConsigneeCountry        
   ,t0.ConsigneeTelephone        
   ,t0.ConsigneeFax        
   ,t0.ConsigneePic        
   ,t0.ConsigneeEmail        
   ,t0.NotifyName        
   ,t0.NotifyAddress        
   ,t0.NotifyCountry        
   ,t0.NotifyTelephone        
   ,t0.NotifyFax        
   ,t0.NotifyPic        
   ,t0.NotifyEmail        
   ,t0.SoldToName        
   ,t0.SoldToAddress        
   ,t0.SoldToCountry        
   ,t0.SoldToTelephone        
   ,t0.SoldToFax        
   ,t0.SoldToPic        
   ,t0.SoldToEmail        
   ,t0.PICApproverName        
   ,t0.GrNo        
   ,t2.ClNo        
   ,t2.SsNo        
   ,t3.SlNo        
   ,t4.AjuDate        
   ,t4.AjuNumber        
   ,t4.NpeDate        
   ,t4.NpeNumber        
   ,t5.Number        
   ,t5.MasterBlDate        
   ,t5.HouseBlNumber        
   ,t5.HouseBlDate        
   ,t2.SailingSchedule        
   ,t2.ArrivalDestination        
   ,t2.PortOfLoading        
   ,t2.PortOfDestination        
   ,t2.ShippingMethod        
   ,t2.CargoType        
   ,t2.Incoterms        
   ,t4.PebFob        
   ,t4.FreightPayment        
   ,t4.InsuranceAmount        
   ,t0.Category        
   ,t0.CategoriItem        
   ,t0.CiplApprovalDate        
   ,t0.RGApprovalDate        
   ,t0.RGDate        
   ,t2.CreateDate        
   ,t0.ExportType        
   ,t2.ClApprovalDate        
   ,t2.ClApproverName        
   ,t0.RGApproverName        
   ,t3.CreateDate        
   ,t4.RegistrationNumber        
   ,t4.PEBApproverName        
   ,t4.PEBApprovalDate        
   ,t2.VesselFlight        
   ,t2.VoyageVesselFlight        
   ,t2.Liner        
   ,t2.Id        
   ,t7.Quantity        
   ,t7.TotalCaseNumber        
   ,TotalExtendedValue        
   ,t4.Rate        
   ,t4.Valuta        
   ,t8.Gross        
   ,t8.Net        
   ,t8.Volume        
   ,fnReq.NextStatusViewByUser        
   ,fnReqGr.NextStatusViewByUser        
   ,fnReqCl.StatusViewByUser        
   ,t0.ShipDelivery    
   ,t0.CustomsFacilityArea    
        
  )        
    
GO

/****** Object:  UserDefinedFunction [dbo].[fn_GetReportDetailTracking]    Script Date: 10/03/2023 12:07:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_GetReportDetailTracking] ()
RETURNS TABLE
AS
RETURN (
		SELECT CONCAT (
				LEFT(DATENAME(MONTH, t0.UpdateDate), 3)
				,'-'
				,DATEPART(YEAR, t0.UpdateDate)
				) PebMonth
			,CAST(ROW_NUMBER() OVER (
					PARTITION BY CONCAT (
						LEFT(DATENAME(MONTH, t0.UpdateDate), 3)
						,'-'
						,DATEPART(YEAR, t0.UpdateDate)
						) ORDER BY t0.UpdateDate
					) AS VARCHAR(5)) RowNumber
			,IIF(t0.ReferenceNo = '', '-', t0.ReferenceNo) ReferenceNo
			, CCRNumber = STUFF((
			 SELECT ',' + tt.Ccr
				From ciplitem tt where tt.IdCipl = t0.id AND tt.IsDelete ='0' and tt.Ccr <> ''
				FOR XML PATH('')
			 ), 1, 1, '')
			,t0.CiplNo
			,t0.EdoNo AS EDINo
			,IIF(t0.PermanentTemporary = 'Repair Return (Temporary)', 'Temporary', IIF(t0.PermanentTemporary = 'Return (Permanent)', 'Permanent', IIF(t0.PermanentTemporary = 'Personal Effect (Permanent)', 'Permanent', 'Permanent'))) AS PermanentTemporary
			,IIF(t0.SalesNonSales <> 'Non Sales', IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, ' ', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.SalesNonSales, ' ', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))), t0.SalesNonSales) AS SalesNonSales
			,t0.Remarks
			,t0.ConsigneeName
			,t0.ConsigneeAddress
			,t0.ConsigneeCountry
			,t0.ConsigneeTelephone
			,t0.ConsigneeFax
			,t0.ConsigneePic
			,t0.ConsigneeEmail
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyName ELSE '' END AS NotifyName
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyAddress ELSE '' END AS NotifyAddress
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyCountry ELSE '' END AS NotifyCountry
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyTelephone ELSE '' END AS NotifyTelephone
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyFax ELSE '' END AS NotifyFax
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyPic ELSE '' END AS NotifyPic
			,CASE WHEN t0.ShipDelivery = 'Notify' THEN t0.NotifyEmail ELSE '' END AS NotifyEmail
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToName ELSE '' END AS SoldToName
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToAddress ELSE '' END AS SoldToAddress
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToCountry ELSE '' END AS SoldToCountry
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToTelephone ELSE '' END AS SoldToTelephone
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToFax ELSE '' END AS SoldToFax
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToPic ELSE '' END AS SoldToPic
			,CASE WHEN t0.ShipDelivery = 'Ship To / Delivery To' THEN t0.SoldToEmail ELSE '' END AS SoldToEmail
			,t2.ShippingMethod
			,t2.Incoterms AS IncoTerms
			,IIF(t0.Category = 'MISCELLANEOUS', t0.CategoriItem, t0.Category) AS DescGoods
			,IIF(t0.Category = 'MISCELLANEOUS', t0.Category, IIF(t0.Category = 'CATERPILLAR SPAREPARTS', 'SPAREPARTS', t0.CategoriItem)) AS Category
			,IIF(t0.Category = 'MISCELLANEOUS'
				OR t0.Category = 'CATERPILLAR USED EQUIPMENT'
				OR t0.Category = 'CATERPILLAR UNIT', '-', t0.CategoriItem) AS SubCategory
			,IIF(t0.ExportType = 'Sales (Permanent)', '-', IIF(t0.ExportType = 'Non Sales - Repair Return (Temporary)', 'RR', IIF(t0.ExportType = 'Non Sales - Return (Permanent)', 'R', IIF(t0.ExportType = 'Non Sales - Personal Effect (Permanent)', 'PE', '-')))) AS
 [Type]
			,t0.UpdateDate AS CiplDate
			,CONCAT (
				CONVERT(VARCHAR(9), t0.UpdateDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t0.UpdateDate, 8)
				) CiplCreateDate
			,t0.CiplApprovalDate
			,t0.PICName
			,t0.Department
			,t0.Branch
			,t0.PICApproverName
			,t0.GrNo AS RGNo
			,t0.RGDate
			,t0.RGApprovalDate
			,t0.RGApproverName
			,t0.CategoriItem
			,CONCAT (
				CONVERT(VARCHAR(18), t2.CreateDate, 6)
				,' '
				,CONVERT(VARCHAR(20), t2.CreateDate, 8)
				) ClDate
			,t2.ClNo
			,CONVERT(VARCHAR(11), t2.SailingSchedule, 106) AS ETD
			,CONVERT(VARCHAR(11), t2.ArrivalDestination, 106) AS ETA
			,t2.PortOfLoading
			,t2.PortOfDestination
			,t2.CargoType
			,ContainerNumber = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.ContainerNumber
						FROM CargoItem CI
						WHERE CI.IdCargo = t2.Id
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,Seal = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.ContainerSealNumber
						FROM CargoItem CI
						WHERE CI.IdCargo = t2.Id
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,'-' AS ContainerType
			,t7.TotalCaseNumber AS TotalColly
			,t2.Liner
			,IIF(t2.ShippingMethod = 'Sea', t2.VesselFlight, '') VesselName
			,IIF(t2.ShippingMethod = 'Air', t2.VesselFlight, '') FlightName
			,IIF(t2.ShippingMethod = 'Sea', t2.VoyageVesselFlight, '') VesselVoyNo
			,IIF(t2.ShippingMethod = 'Air', t2.VoyageVesselFlight, '') FlightVoyNo
			,t2.SsNo AS SSNo
			,t2.ClApprovalDate AS CLApprovalDate
			,t2.ClApproverName
			,t3.SlNo AS SINo
			,CONCAT (
				CONVERT(VARCHAR(9), t3.CreateDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t3.CreateDate, 8)
				) AS SIDate
			,CONCAT (
				CONVERT(VARCHAR(9), t4.AjuDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.AjuDate, 8)
				) AS AjuDate
			,t4.AjuNumber
			,CONCAT (
				CONVERT(VARCHAR(9), t4.NpeDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.NpeDate, 8)
				) AS NpeDate
			,t4.NpeNumber
			,t4.RegistrationNumber AS NOPEN
			,FORMAT(t4.PebFob, '#,0.00') PebFob
			,FORMAT(t4.FreightPayment, '#,0.00') FreightPyment
			,FORMAT(t4.InsuranceAmount, '#,0.00') InsuranceAmount
			,CONCAT (
				CONVERT(VARCHAR(9), t4.PEBApprovalDate, 6)
				,' '
				,CONVERT(VARCHAR(9), t4.PEBApprovalDate, 8)
				) AS PEBApprovalDate
			,t4.PEBApproverName
			,t5.Number AS MasterBlAwbNumber
			,CONVERT(VARCHAR(10), t5.MasterBlDate, 120) AS MasterBlAwbDate
			,t5.HouseBlNumber HouseBlAwbNumber
			,CONVERT(VARCHAR(10), t5.HouseBlDate, 120) AS HouseBlAwbDate
			,FORMAT(t4.PebFob + t4.FreightPayment + t4.InsuranceAmount, '#,0.00') AS TotalPEB
			,'-' AS InvoiceNoServiceCharges
			,'-' AS CurrencyServiceCharges
			,'-' AS TotalServiceCharges
			,'-' AS InvoiceNoConsignee
			,'-' AS CurrencyValueConsignee
			,'-' AS TotalValueConsignee
			,'-' AS ValueBalanceConsignee
			,'-' AS [Status1]
			,Uom = COALESCE(STUFF((
						SELECT DISTINCT ',' + CI.Uom
						FROM CiplItem CI
						WHERE CI.IdCipl = t0.Id
							AND CI.Uom <> ''
						FOR XML PATH('')
							,TYPE
						).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), N'')
			,t7.Quantity TotalUom
			,t7.TotalExtendedValue TotalExtendedValue
			,FORMAT(sum(ISNULL(t4.Rate, 0)), '#,0.00') Rate
			,t4.Valuta
			,t8.Gross
			,t8.Net
			,t8.Volume
			,CASE 
				WHEN fnReqCl.StatusViewByUser IS NOT NULL
					AND fnReqCl.StatusViewByUser != 'Draft'
					THEN fnReqCl.StatusViewByUser
				WHEN fnReqGr.NextStatusViewByUser IS NOT NULL
					AND fnReqGr.NextStatusViewByUser != 'Draft'
					THEN fnReqGr.NextStatusViewByUser
				ELSE fnReq.NextStatusViewByUser
				END AS [Status]
		FROM (
			SELECT DISTINCT t0.CiplNo
				,t0.ReferenceNo
				,t0.Category
				,t0.CategoriItem
				,IIF(t0.UpdateBy IS NOT NULL, t0.UpdateDate, t0.CreateDate) UpdateDate
				,t8.Employee_name PICName
				,t8.Dept_Name Department
				,t8.Division_Name Branch
				,t0.id
				,t0.EdoNo
				,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) <= 0, IIF(CHARINDEX('Permanent', t0.ExportType) > 0, 'Permanent', '-'), --'-',
					LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[2]', 'varchar(50)')))) AS PermanentTemporary
				,IIF(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)'))) IS NULL
					OR LEN(LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) <= 0, '-', LTRIM(RTRIM(CAST('<M>' + REPLACE(t0.ExportType, '-', '</M><M>') + '</M>' AS XML).value('/M[1]', 'varchar(50)')))) AS SalesNonSales
				,t0.ExportType
				,t0.Remarks
				,t0.ConsigneeName
				,t0.ConsigneeAddress
				,t0.ConsigneeCountry
				,t0.ConsigneeTelephone
				,t0.ConsigneeFax
				,t0.ConsigneePic
				,t0.ConsigneeEmail
				,t0.NotifyName
				,t0.NotifyAddress
				,t0.NotifyCountry
				,t0.NotifyTelephone
				,t0.NotifyFax
				,t0.NotifyPic
				,t0.NotifyEmail
				,t0.SoldToName
				,t0.SoldToAddress
				,t0.SoldToCountry
				,t0.SoldToTelephone
				,t0.SoldToFax
				,t0.SoldToPic
				,t0.SoldToEmail
				,t0.ShippingMethod
				,
				--t0.IncoTerm,
				CONCAT (
					CONVERT(VARCHAR(9), t4.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t4.UpdateDate, 8)
					) AS CiplApprovalDate
				,t6.Employee_Name AS PICApproverName
				,t3.GrNo
				,CONCAT (
					CONVERT(VARCHAR(9), t3.CreateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t3.CreateDate, 8)
					) AS RGDate
				,CONCAT (
					CONVERT(VARCHAR(9), t5.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t5.UpdateDate, 8)
					) AS RGApprovalDate
				,t7.Employee_Name AS RGApproverName
				,t3.Id IdGr
				,t0.ShipDelivery
			FROM Cipl t0
			JOIN CiplItem t1 ON t0.id = t1.idCipl AND t1.isdelete = 0
			LEFT JOIN RequestCipl t4 ON t4.IdCipl = t0.id
				AND t4.STATUS = 'Approve' and t4.isdelete = 0
			LEFT JOIN GoodsReceiveItem t2 ON t2.IdCipl = t0.id AND t2.isdelete = 0
			LEFT JOIN GoodsReceive t3 ON t3.Id = t2.IdGr AND t3.isdelete = 0
			LEFT JOIN RequestGr t5 ON t5.IdGr = t2.IdGr
				AND t5.STATUS = 'Approve' AND t5.isdelete = 0
			LEFT JOIN Employee t6 ON t6.AD_User = t4.UpdateBy
			LEFT JOIN Employee t7 ON t7.AD_User = t5.UpdateBy	
			LEFT JOIN Employee t8 ON t8.AD_User = t0.UpdateBy
			WHERE t0.isdelete = 0
			) t0
		LEFT JOIN CargoCipl t1 ON t1.IdCipl = t0.id AND t1.isdelete = 0
		LEFT JOIN (
			SELECT t0.*
				,t2.Employee_Name ClApproverName
				,
				--t1.UpdateBy ClApproverName, 
				CONCAT (
					CONVERT(VARCHAR(9), t1.UpdateDate, 6)
					,' '
					,CONVERT(VARCHAR(9), t1.UpdateDate, 8)
					) ClApprovalDate
			FROM Cargo t0
			--left join RequestCl t1 on t0.Id = t1.IdCl and t1.Status = 'Approve' and t1.IdStep = 12
			LEFT JOIN CargoHistory t1 ON t0.Id = t1.IdCargo
				AND t1.Step NOT IN (
					'Approve NPE & PEB'
					,'Approve BL or AWB'
					,'Create NPE & PEB'
					)
				AND t1.STATUS = 'Approve' AND t1.isdelete = 0
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			WHERE t0.isdelete = 0
			) t2 ON t2.Id = t1.IdCargo
		LEFT JOIN ShippingInstruction t3 ON t3.IdCL = t2.Id AND t3.isdelete = 0
		LEFT JOIN (
			SELECT t0.*
				,t2.Employee_Name AS PEBApproverName
				,t1.UpdateDate AS PEBApprovalDate
			FROM NpePeb t0
			LEFT JOIN CargoHistory t1 ON t0.IdCl = t1.IdCargo
				AND t1.Step = 'Approve NPE & PEB'
				AND t1.STATUS = 'Approve' AND t1.isdelete = 0
			LEFT JOIN Employee t2 ON t1.CreateBy = t2.AD_User
			WHERE t0.isdelete = 0
			) t4 ON t4.IdCl = t2.Id
		LEFT JOIN BlAwb t5 ON t5.IdCl = t2.Id AND t5.isdelete = 0
		LEFT JOIN (
			SELECT c.id
				,MAX(ISNULL(ci.Currency, '-')) AS Currency
				,CASE 
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'SIB'
						THEN CAST(count(DISTINCT ISNULL(ci.Id, '-')) AS VARCHAR(5))
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'PRA'
						THEN CAST(count(DISTINCT ISNULL(ci.ASNNumber, '-')) AS VARCHAR(5))
					WHEN c.Category = 'CATERPILLAR SPAREPARTS'
						AND c.CategoriItem = 'Old Core'
						THEN CAST(count(DISTINCT ISNULL(ci.CaseNumber, '-')) AS VARCHAR(5))
					ELSE CAST(count(DISTINCT ci.Sn) AS VARCHAR(5))
					END AS TotalCaseNumber
				,FORMAT(sum(ISNULL(ci.ExtendedValue, 0)), '#,0.00') AS TotalExtendedValue
				,FORMAT(sum(ISNULL(ci.Quantity, 0)), '#,0.00') AS Quantity
			FROM Cipl c
			INNER JOIN CiplItem ci ON c.id = ci.IdCipl
			INNER JOIN CargoItem cai ON cai.IdCiplItem = ci.Id
			GROUP BY c.id
				,c.Category
				,c.CategoriItem
			) t7 ON t7.id = t0.id
		LEFT JOIN (
			SELECT FORMAT(sum(ISNULL(c.Gross, 0)), '#,0.00') Gross
				,FORMAT(sum(ISNULL(c.Net, 0)), '#,0.00') Net
				--,FORMAT(sum(ISNULL(c.Width * c.Height * c.Length, 0))/100, '#,0.00') AS Volume
				,FORMAT((SUM(ISNULL(c.Height,0))/100) * (SUM(ISNULL(c.Width,0))/100) * (SUM(ISNULL(c.Length,0))/100), '#,0.00') AS Volume
				,c.IdCargo
			FROM CargoItem c
			GROUP BY c.IdCargo
			) t8 ON t8.IdCargo = t1.IdCargo 
		LEFT JOIN dbo.[fn_get_cipl_request_list_all]() AS fnReq ON fnReq.IdCipl = t0.id
		LEFT JOIN dbo.[fn_get_gr_request_list_all]() AS fnReqGr ON fnReqGr.IdGr = t0.IdGr
		LEFT JOIN dbo.[fn_get_cl_request_list_all]() AS fnReqCl ON fnReqCl.IdCl = t2.Id
		GROUP BY t0.id
			,t0.UpdateDate
			,t0.CiplNo
			,t0.EdoNo
			,t0.ReferenceNo
			,t0.PICName
			,t0.Department
			,t0.Branch
			,t0.PermanentTemporary
			,t0.SalesNonSales
			,t0.Remarks
			,t0.ConsigneeName
			,t0.ConsigneeAddress
			,t0.ConsigneeCountry
			,t0.ConsigneeTelephone
			,t0.ConsigneeFax
			,t0.ConsigneePic
			,t0.ConsigneeEmail
			,t0.NotifyName
			,t0.NotifyAddress
			,t0.NotifyCountry
			,t0.NotifyTelephone
			,t0.NotifyFax
			,t0.NotifyPic
			,t0.NotifyEmail
			,t0.SoldToName
			,t0.SoldToAddress
			,t0.SoldToCountry
			,t0.SoldToTelephone
			,t0.SoldToFax
			,t0.SoldToPic
			,t0.SoldToEmail
			,t0.PICApproverName
			,t0.GrNo
			,t2.ClNo
			,t2.SsNo
			,t3.SlNo
			,t4.AjuDate
			,t4.AjuNumber
			,t4.NpeDate
			,t4.NpeNumber
			,t5.Number
			,t5.MasterBlDate
			,t5.HouseBlNumber
			,t5.HouseBlDate
			,t2.SailingSchedule
			,t2.ArrivalDestination
			,t2.PortOfLoading
			,t2.PortOfDestination
			,t2.ShippingMethod
			,t2.CargoType
			,t2.Incoterms
			,t4.PebFob
			,t4.FreightPayment
			,t4.InsuranceAmount
			,t0.Category
			,t0.CategoriItem
			,t0.CiplApprovalDate
			,t0.RGApprovalDate
			,t0.RGDate
			,t2.CreateDate
			,t0.ExportType
			,t2.ClApprovalDate
			,t2.ClApproverName
			,t0.RGApproverName
			,t3.CreateDate
			,t4.RegistrationNumber
			,t4.PEBApproverName
			,t4.PEBApprovalDate
			,t2.VesselFlight
			,t2.VoyageVesselFlight
			,t2.Liner
			,t2.Id
			,t7.Quantity
			,t7.TotalCaseNumber
			,TotalExtendedValue
			,t4.Rate
			,t4.Valuta
			,t8.Gross
			,t8.Net
			,t8.Volume
			,fnReq.NextStatusViewByUser
			,fnReqGr.NextStatusViewByUser
			,fnReqCl.StatusViewByUser
			,t0.ShipDelivery
		)



GO

/****** Object:  UserDefinedFunction [dbo].[fn_proccess_email_template_20210218]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- Author:                            Ali Mutasal
-- ALTER date: 09 Des 2019
-- Description:    Function untuk melakukan proses email
-- =============================================
ALTER FUNCTION [dbo].[fn_proccess_email_template_20210218]
(
                -- Add the parameters for the function here
                @requestType nvarchar(100) = 'CIPL',
                @requestId nvarchar(100) = '',
                @template nvarchar(max) = '',
				@typeDoc nvarchar(max) = ''
)
RETURNS nvarchar(max)
AS
BEGIN
                ------------------------------------------------------------------
                -- 1. Melakukan Declare semua variable yang dibutuhkan
                ------------------------------------------------------------------
                BEGIN
                                -- ini hanya sample silahkan comment jika akan digunakan
                                --SET @template = 'Ini adalah email dari [requestor_name], dan ini adalah email untuk [last_pic_name]. selanjutnya akan dikirim ke [next_pic_name]';
                                DECLARE @variable_table TABLE (
                                    key_data VARCHAR(MAX) NULL,
                                    val_data VARCHAR(MAX) NULL
                                );

                                DECLARE 
                                                @key NVARCHAR(MAX), 
                                                @flow NVARCHAR(MAX), 
                                                @val NVARCHAR(MAX),
                                                @requestor_name NVARCHAR(MAX),
                                                @requestor_id NVARCHAR(MAX),
                                                @requestor_username NVARCHAR(MAX),
                                                @last_pic_name NVARCHAR(MAX),
                                                @last_pic_id NVARCHAR(MAX),
                                                @last_pic_username NVARCHAR(MAX),
                                                @next_pic_name NVARCHAR(MAX),
                                                @next_pic_id NVARCHAR(MAX),
                                                @next_pic_username NVARCHAR(MAX),
                                                @si_number NVARCHAR(MAX) = '',
                                                @ss_number NVARCHAR(MAX) = '',
                                                @req_number NVARCHAR(MAX) = '',
                                                @npe_number NVARCHAR(MAX) = '',
                                                @peb_number NVARCHAR(MAX) = '',
                                                @bl_awb_number NVARCHAR(MAX) = '',
                                                @req_date NVARCHAR(MAX) = '',
                                                @superior_req_name nvarchar(max) = '',
                                                @superior_req_id nvarchar(max) = ''
                END
                
                ------------------------------------------------------------------
                -- 2. Query untuk mengisi data ke variable variable yang dibutuhkan
                ------------------------------------------------------------------
                BEGIN
                                -- Mengambil data dari fn request per flow
                                BEGIN
                                                IF (@requestType = 'CIPL')
                                                BEGIN
                                                                SET @flow = 'CIPL';
                   SELECT 
                                                                                @requestor_id = t1.Employee_ID,
                                                                                @requestor_name = t1.Employee_Name,
																				@superior_req_name = t1.Superior_Name,
                                                                                @superior_req_id = t1.Superior_ID,
                                                                                @requestor_username = t1.AD_User,
                                                                                @last_pic_id = t2.Employee_ID,
                                                                                @last_pic_name = t2.Employee_Name,
                                                                                @last_pic_username = t2.AD_User,
                                                                                @next_pic_id = t3.Employee_ID,
                                                                                @next_pic_name = 
                                                                                                CASE
                                                                                                                WHEN t0.Status = 'Revise' OR t0.Status = 'Reject' OR (t0.Status = 'Approve' AND t0.NextAssignType IS NULL) THEN t5.Employee_Name
                                                                                                                WHEN t0.NextAssignType = 'Group' THEN t0.NextAssignTo
                                                                                                                ELSE t3.Employee_Name
                                                                                                END,
                                                                                @next_pic_username = t3.AD_User,
                                                                                @req_number = IIF(@typeDoc = 'CKB', ISNULL(t4.EdoNo,''), t4.CiplNo),
                                                                                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)
                                                                FROM 
                                                                                dbo.fn_get_cipl_request_list_all() t0 
                                                                                INNER JOIN dbo.Cipl t4 on t4.id = t0.IdCipl
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.UpdateBy
                                                                WHERE 
                                                                                t0.IdCipl = @requestId;
                                                END

                                                --IF (@requestType IN ('CL', 'BLAWB', 'PEB_NPE'))
												IF (@requestType = 'CL') OR (@requestType = 'BLAWB') OR (@requestType = 'PEB_NPE') 
                                                BEGIN
                                                                SET @flow = @requestType;
                                                                SELECT 
                                                                                @requestor_id = t5.Employee_ID,
                                                                                @requestor_name = t5.Employee_Name,
                                                                                @superior_req_name = t5.Superior_Name,
                                                                       @superior_req_id = t5.Superior_ID,
                                                                                @requestor_username = t5.AD_User,
                                                                                @last_pic_id = t6.Employee_ID,
                                                                                @last_pic_name = t6.Employee_Name,
                                                                                @last_pic_username = t6.AD_User,
                                                                                @next_pic_id = t7.Employee_ID,
                                                                                @next_pic_name = t7.Employee_Name,
                                                                                @next_pic_username = t7.AD_User,
                                                                                @req_number = t1.ClNo,
                                                                                @ss_number = t1.SsNo,
                                                                                @si_number = t2.SlNo,
                                                                                @npe_number = t3.NpeNumber,
                                                                                @peb_number = t3.PebNumber,
                                                                                @bl_awb_number = t4.Number,
                                                                                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)
                                                                FROM 
                                                                                dbo.fn_get_cl_request_list_all() t0 
                                                                                INNER JOIN dbo.Cargo t1 on t1.id = t0.IdCl
                                                                                INNER JOIN dbo.ShippingInstruction t2 on t2.IdCL = t0.IdCl
                                                                                INNER JOIN dbo.NpePeb t3 on t3.IdCL = t0.IdCl
                                                                                INNER JOIN dbo.BlAwb t4 on t4.IdCL = t0.IdCl
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.CreateBy
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t6 on t6.AD_User = t0.Pic
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t7 on t7.AD_User = t0.NextAssignTo
                                                                WHERE 
                                                                                t0.IdCl = @requestId;                                                                     
                                                END

                                                IF (@requestType = 'RG')
                                                BEGIN
                                                                SET @flow = 'Receive Goods';
                                                                SELECT 
                                                                                @requestor_id = t1.Employee_ID,
                                                                                @requestor_name = t1.Employee_Name,
                                                                                @superior_req_name = t1.Superior_Name,
                                                                                @superior_req_id = t1.Superior_ID,
                                                                          @requestor_username = t1.AD_User,
                                                                                @last_pic_id = t2.Employee_ID,
                                                                                @last_pic_name = t2.Employee_Name,
                                                                                @last_pic_username = t2.AD_User,
                                                                                @next_pic_id = t3.Employee_ID,
                                                                                @next_pic_name = t3.Employee_Name,
                                                                                @next_pic_username = t3.AD_User,
                                                                                @req_number = t4.GrNo,
                                                                                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)
                                                                FROM 
                                                                                dbo.fn_get_gr_request_list_all() t0 
                                                                                INNER JOIN dbo.GoodsReceive t4 on t4.id = t0.IdGr
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo
                                                                WHERE 
                                                                                t0.IdGr = @requestId;
                                                END

                                                IF (@requestType = 'DELEGATION')
                                                BEGIN
                                                                SET @flow = 'Delegation';
                                                                --SELECT * FROM dbo.fn_get_gr_request_list_all() t0 where t0.Id = @requestId;
                                                END

                                                INSERT 
                                                                INTO 
                                                                                @variable_table 
                                                                VALUES 
                                                                                 ('@RequestorName', ISNULL(@requestor_name, '-'))
                                                                                ,('@RequestNo', ISNULL(@req_number, '-'))
                                                                                ,('@CreatedDate', ISNULL(@req_date, '-'))
                                                                                ,('@SuperiorEmpID', ISNULL(@superior_req_id, '-'))
                                                                                ,('@SuperiorName', ISNULL(@superior_req_name, '-'))
                                                                                ,('@MobileLink', 'http://pis.trakindo.co.id')
                                                                                ,('@DesktopLink', 'http://pis.trakindo.co.id')
                                                                                ,('@ApproverPosition', ISNULL(@flow, '-'))
                                                                                ,('@ApproverName', ISNULL(@next_pic_name, '-'))
                                                                                ,('@RequestorEmpID', ISNULL(@requestor_id, '-'))
                                                                                ,('@flow', ISNULL(@flow, '-'))
                                                                                ,('@requestor_name', ISNULL(@requestor_name, '-'))
                                                                                ,('@requestor_id', ISNULL(@requestor_id, '-'))
                                                                                ,('@last_pic_name', ISNULL(@last_pic_name, '-'))
                                                                                ,('@last_pic_id', ISNULL(@last_pic_id, '-'))
                                                                                ,('@next_pic_name', ISNULL(@next_pic_name, '-'))
                                                                                ,('@next_pic_id', ISNULL(@next_pic_id, '-'))
                                                                                ,('@si_number', ISNULL(@si_number, '-'))
                                                                                ,('@ss_number', ISNULL(@ss_number, '-'))
                                                                                ,('@req_number', ISNULL(@req_number, '-'))
                                                                                ,('@npe_number', ISNULL(@npe_number, '-'))
                                                                                ,('@peb_number', ISNULL(@peb_number, '-'))
                                                                                ,('@bl_awb_number', ISNULL(@bl_awb_number, '-'))
                                                                                ,('@req_date', ISNULL(@req_date, '-'))
                                                                                ,('@superior_req_name', ISNULL(@superior_req_name, '-'))
                                                                                ,('@superior_req_id', ISNULL(@superior_req_id, '-'))
                                END
                END
                
                ------------------------------------------------------------------
                -- 3. Melakukan Replace terhadap data yang di petakan di template dgn menggunakan perulangan
                ------------------------------------------------------------------
                BEGIN
                                DECLARE cursor_variable CURSOR
                                FOR 
                                                SELECT 
                                                                key_data, 
                                                                val_data 
                                                FROM 
                                                                @variable_table;
                                                                                                
                                OPEN cursor_variable; 
                                FETCH NEXT FROM cursor_variable INTO @key, @val; 
                                WHILE @@FETCH_STATUS = 0
                                    BEGIN
                                                                -- Melakukan Replace terhadap variable di template dengan value dari hasil pencarian data diata.
                                                                IF ISNULL(@key, '') <> ''
                                                                BEGIN
                                                                                SET @template = REPLACE(@template, @key, @val);
                                                                END

                                                                FETCH NEXT FROM cursor_variable INTO 
                                            @key, 
                                           @val;
                                    END;
                                
                                CLOSE cursor_variable; 
                                DEALLOCATE cursor_variable;
                END
                
                ------------------------------------------------------------------
                -- 4. Menampilkan hasil dari proses replace
                ------------------------------------------------------------------
                BEGIN
                                RETURN @template;
                END
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_proccess_email_template_20210722]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:                            Ali Mutasal
-- ALTER date: 09 Des 2019
-- Description:    Function untuk melakukan proses email
-- =============================================
ALTER FUNCTION [dbo].[fn_proccess_email_template_20210722]
(
                -- Add the parameters for the function here
                @requestType nvarchar(100) = 'CIPL',
                @requestId nvarchar(100) = '',
                @template nvarchar(max) = '',
				@typeDoc nvarchar(max) = '',
				@lastPIC nvarchar(max) = ''
)
RETURNS nvarchar(max)
AS
BEGIN
	
	
                ------------------------------------------------------------------
                -- 1. Melakukan Declare semua variable yang dibutuhkan
                ------------------------------------------------------------------
                BEGIN
								
                                -- ini hanya sample silahkan comment jika akan digunakan
                                --SET @template = 'Ini adalah email dari [requestor_name], dan ini adalah email untuk [last_pic_name]. selanjutnya akan dikirim ke [next_pic_name]';
                                DECLARE @variable_table TABLE (
                                    key_data VARCHAR(MAX) NULL,
                                    val_data VARCHAR(MAX) NULL
                                );

                                DECLARE 
                                                @key NVARCHAR(MAX), 
                                                @flow NVARCHAR(MAX), 
                                                @val NVARCHAR(MAX),
                                                @requestor_name NVARCHAR(MAX),
                                                @requestor_id NVARCHAR(MAX),
                                                @requestor_username NVARCHAR(MAX),
                                                @last_pic_name NVARCHAR(MAX),
                                                @last_pic_id NVARCHAR(MAX),
                                                @last_pic_username NVARCHAR(MAX),
                                                @next_pic_name NVARCHAR(MAX),
                                                @next_pic_id NVARCHAR(MAX),
                                                @next_pic_username NVARCHAR(MAX),
                                                @si_number NVARCHAR(MAX) = '',
                                                @ss_number NVARCHAR(MAX) = '',
                                                @req_number NVARCHAR(MAX) = '',
                                                @npe_number NVARCHAR(MAX) = '',
                                                @peb_number NVARCHAR(MAX) = '',
                                                @bl_awb_number NVARCHAR(MAX) = '',
                                                @req_date NVARCHAR(MAX) = '',
                                                @superior_req_name nvarchar(max) = '',
                                                @superior_req_id nvarchar(max) = '',
												@employee_name nvarchar(max) = ''
												
								IF (@lastPIC <> '')
								BEGIN
									SELECT @employee_name = employee_name 
									FROM dbo.fn_get_employee_internal_ckb() 
									WHERE AD_User = @lastPIC;
								END
                END
                
                ------------------------------------------------------------------
                -- 2. Query untuk mengisi data ke variable variable yang dibutuhkan
                ------------------------------------------------------------------
                BEGIN
                                -- Mengambil data dari fn request per flow
                                BEGIN
                                                IF (@requestType = 'CIPL')
                                                BEGIN
                                                                SET @flow = 'CIPL';
                   SELECT 
                                                                                @requestor_id = t1.Employee_ID,
                                                                                @requestor_name = t1.Employee_Name,
																				@superior_req_name = t1.Superior_Name,
                                                                                @superior_req_id = t1.Superior_ID,
                                                                                @requestor_username = t1.AD_User,
                                                                                @last_pic_id = t2.Employee_ID,
                                                                                @last_pic_name = t2.Employee_Name,
                                                                                @last_pic_username = t2.AD_User,
                                                                                @next_pic_id = t3.Employee_ID,
                                                                                @next_pic_name = 
                                                                                                CASE
                                                                                                                WHEN t0.Status = 'Revise' OR t0.Status = 'Reject' OR (t0.Status = 'Approve' AND t0.NextAssignType IS NULL) THEN t5.Employee_Name
                                                                                                                WHEN t0.NextAssignType = 'Group' THEN t0.NextAssignTo
                                                                                                                ELSE t3.Employee_Name
                                                                                                END,
                                                                                @next_pic_username = t3.AD_User,
                                                                                @req_number = IIF(@typeDoc = 'CKB', ISNULL(t4.EdoNo,''), t4.CiplNo),
                                                                                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)
                                                                FROM 
                                                                                dbo.fn_get_cipl_request_list_all() t0 
                                                                                INNER JOIN dbo.Cipl t4 on t4.id = t0.IdCipl
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.UpdateBy
                                                                WHERE 
                                                                                t0.IdCipl = @requestId;
                                                END

                                                --IF (@requestType IN ('CL', 'BLAWB', 'PEB_NPE'))
												IF (@requestType = 'CL') OR (@requestType = 'BLAWB') OR (@requestType = 'PEB_NPE') 
                                                BEGIN
                                                                SET @flow = @requestType;
                                                                SELECT 
                                                                                @requestor_id = t5.Employee_ID,
                                                                                @requestor_name = t5.Employee_Name,
                                                                                @superior_req_name = t5.Superior_Name,
                                                                       @superior_req_id = t5.Superior_ID,
                                                                                @requestor_username = t5.AD_User,
                                                                                @last_pic_id = t6.Employee_ID,
                                                                                @last_pic_name = t6.Employee_Name,
                                                                                @last_pic_username = t6.AD_User,
                                                                                @next_pic_id = t7.Employee_ID,
                                                                                @next_pic_name = t7.Employee_Name,
                                                                                @next_pic_username = t7.AD_User,
                                                                                @req_number = t1.ClNo,
                                                                                @ss_number = t1.SsNo,
                                                                                @si_number = t2.SlNo,
                                                                                @npe_number = t3.NpeNumber,
                                                                                @peb_number = t3.PebNumber,
                                                                                @bl_awb_number = t4.Number,
                                                                                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)
                                                                FROM 
                                                                                dbo.fn_get_cl_request_list_all() t0 
                                                                                INNER JOIN dbo.Cargo t1 on t1.id = t0.IdCl
                                                                                INNER JOIN dbo.ShippingInstruction t2 on t2.IdCL = t0.IdCl
                                                                                INNER JOIN dbo.NpePeb t3 on t3.IdCL = t0.IdCl
                                                                                INNER JOIN dbo.BlAwb t4 on t4.IdCL = t0.IdCl
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.CreateBy
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t6 on t6.AD_User = t0.Pic
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t7 on t7.AD_User = t0.NextAssignTo
                                                                WHERE 
                                                                                t0.IdCl = @requestId;                                                                     
                                                END

                                                IF (@requestType = 'RG')
                                                BEGIN
                                                                SET @flow = 'Receive Goods';
                                                                SELECT 
                                                                                @requestor_id = t1.Employee_ID,
                                                                                @requestor_name = t1.Employee_Name,
                                                                                @superior_req_name = t1.Superior_Name,
                                                                                @superior_req_id = t1.Superior_ID,
                                                                          @requestor_username = t1.AD_User,
                                                                                @last_pic_id = t2.Employee_ID,
                                                                                @last_pic_name = t2.Employee_Name,
                                                                                @last_pic_username = t2.AD_User,
                                                                                @next_pic_id = t3.Employee_ID,
                                                                                @next_pic_name = t3.Employee_Name,
                                                                                @next_pic_username = t3.AD_User,
                                                                                @req_number = t4.GrNo,
                                                                                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)
                                                                FROM 
                                                                                dbo.fn_get_gr_request_list_all() t0 
                                                                                INNER JOIN dbo.GoodsReceive t4 on t4.id = t0.IdGr
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo
                                                                WHERE 
                                                                                t0.IdGr = @requestId;
                                                END

                                                IF (@requestType = 'DELEGATION')
                                                BEGIN
                                                                SET @flow = 'Delegation';
                                                                --SELECT * FROM dbo.fn_get_gr_request_list_all() t0 where t0.Id = @requestId;
                                                END

                                                INSERT 
                                                                INTO 
                                                                                @variable_table 
                                                                VALUES 
                                                                                 ('@RequestorName', ISNULL(@requestor_name, '-'))
                                                                                ,('@RequestNo', ISNULL(@req_number, '-'))
                                                                                ,('@CreatedDate', ISNULL(@req_date, '-'))
                                                                                ,('@SuperiorEmpID', ISNULL(@superior_req_id, '-'))
                                                                                ,('@SuperiorName', ISNULL(@superior_req_name, '-'))
                                                                                ,('@MobileLink', 'http://pis.trakindo.co.id')
                                                                                ,('@DesktopLink', 'http://pis.trakindo.co.id')
                                                                                ,('@ApproverPosition', ISNULL(@flow, '-'))
                                                                                ,('@ApproverName', ISNULL(@next_pic_name, ISNULL(@employee_name,'-')))
                                                                                ,('@RequestorEmpID', ISNULL(@requestor_id, '-'))
                                                                                ,('@flow', ISNULL(@flow, '-'))
                                                                                ,('@requestor_name', ISNULL(@requestor_name, '-'))
                                                                                ,('@requestor_id', ISNULL(@requestor_id, '-'))
                                                                                ,('@last_pic_name', ISNULL(@last_pic_name, '-'))
                                                                                ,('@last_pic_id', ISNULL(@last_pic_id, '-'))
                                                                                ,('@next_pic_name', ISNULL(@next_pic_name, '-'))
                                                                                ,('@next_pic_id', ISNULL(@next_pic_id, '-'))
                                                                                ,('@si_number', ISNULL(@si_number, '-'))
                                                                                ,('@ss_number', ISNULL(@ss_number, '-'))
                                                                                ,('@req_number', ISNULL(@req_number, '-'))
                                                                                ,('@npe_number', ISNULL(@npe_number, '-'))
                                                                                ,('@peb_number', ISNULL(@peb_number, '-'))
                                                                                ,('@bl_awb_number', ISNULL(@bl_awb_number, '-'))
                                                                                ,('@req_date', ISNULL(@req_date, '-'))
                                                                                ,('@superior_req_name', ISNULL(@superior_req_name, '-'))
                                                                                ,('@superior_req_id', ISNULL(@superior_req_id, '-'))
                                END
                END
                
                ------------------------------------------------------------------
                -- 3. Melakukan Replace terhadap data yang di petakan di template dgn menggunakan perulangan
                ------------------------------------------------------------------
                BEGIN
                                DECLARE cursor_variable CURSOR
                                FOR 
                                                SELECT 
                                                                key_data, 
                                                                val_data 
                                                FROM 
                                                                @variable_table;
                                                                                                
                                OPEN cursor_variable; 
                                FETCH NEXT FROM cursor_variable INTO @key, @val; 
                                WHILE @@FETCH_STATUS = 0
                                    BEGIN
                                                                -- Melakukan Replace terhadap variable di template dengan value dari hasil pencarian data diata.
                                                                IF ISNULL(@key, '') <> ''
                                                                BEGIN
                                                                                SET @template = REPLACE(@template, @key, @val);
                                                                END

                                                                FETCH NEXT FROM cursor_variable INTO 
                                            @key, 
                                           @val;
                                    END;
                                
                                CLOSE cursor_variable; 
                                DEALLOCATE cursor_variable;
                END
                
                ------------------------------------------------------------------
                -- 4. Menampilkan hasil dari proses replace
                ------------------------------------------------------------------
                BEGIN
                                RETURN @template;
                END
END


GO

/****** Object:  UserDefinedFunction [dbo].[fn_proccess_email_template_RFC]    Script Date: 10/03/2023 15:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_proccess_email_template_RFC]    
(        
                @RFCId INT = '',        
                @Template nvarchar(max) = ''       
)        
RETURNS NVARCHAR(MAX)    
AS    
BEGIN    
    
DECLARE @RequestNo NVARCHAR(MAX)    
DECLARE @CreatedDate DATETIME    
DECLARE @DocumentType NVARCHAR(MAX)    
DECLARE @DocumentNo NVARCHAR(MAX)    
DECLARE @RequestReason NVARCHAR(MAX)    
DECLARE @SuperiorName NVARCHAR(MAX)    
DECLARE @SuperiorEmpID NVARCHAR(MAX)    
DECLARE @MobileLink NVARCHAR(MAX)    
DECLARE @DesktopLink NVARCHAR(MAX)    
DECLARE @RequestorName NVARCHAR(MAX)    
DECLARE @RequestorEmpID NVARCHAR(MAX)    
DECLARE @ApproverName NVARCHAR(MAX)    
DECLARE @ReasonIfRejected NVARCHAR(MAx)    
DECLARE @UpdatedDate Datetime    
    
    
SET @MobileLink = 'http://pis.trakindo.co.id'    
SET @DesktopLink = 'http://pis.trakindo.co.id'    
    
SELECT @RequestNo = RFC.RFCNumber    
,@DocumentType = RFC.FormType    
,@DocumentNo = RFC.FormNo    
,@RequestReason = RFC.Reason    
,@RequestorEmpID = RFC.CreateBy    
,@CreatedDate = RFC.CreateDate    
,@SuperiorEmpID = RFC.Approver    
,@UpdatedDate = RFC.UpdateDate    
,@ReasonIfRejected = RFC.ReasonIfRejected    
,@ApproverName = t2.Employee_Name    
,@RequestorName = t1.Employee_Name    
,@SuperiorName = t2.Employee_Name    
FROM RequestForChange RFC     
LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = RFC.CreateBy      
LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User =RFC.Approver    
WHERE ID = @RFCId    
    
BEGIN    
 DECLARE @variable_table TABLE (        
                                    key_data VARCHAR(MAX) NULL,        
                                    val_data VARCHAR(MAX) NULL        
                                );        
           DECLARE @key NVARCHAR(MAX),         
                                                @flow NVARCHAR(MAX),         
                                                @val NVARCHAR(MAX)    
INSERT         
    INTO         
      @variable_table         
      VALUES         
      ('@RequestNo', ISNULL(@RequestNo, '-'))        
      ,('@DocumentType', ISNULL(@DocumentType, '-'))     
   ,('@DocumentNo', ISNULL(@DocumentNo, '-'))     
   ,('@RequestReason', ISNULL(@RequestReason, '-'))     
   ,('@RequestorEmpID', ISNULL(@RequestorEmpID, '-'))     
   ,('@CreatedDate', ISNULL(CONVERT(nvarchar(10), @CreatedDate, 103), '-'))     
   ,('@SuperiorEmpID', ISNULL(@SuperiorEmpID, '-'))     
   ,('@UpdatedDate', ISNULL(CONVERT(nvarchar(10), @UpdatedDate, 103), '-'))     
   ,('@ReasonIfRejected', ISNULL(@ReasonIfRejected, '-'))     
   ,('@ApproverName', ISNULL(@ApproverName, '-'))     
   ,('@RequestorName', ISNULL(@RequestorName, '-'))     
   ,('@SuperiorName', ISNULL(@SuperiorName, '-'))     
      
              
    
    
    BEGIN        
                                DECLARE cursor_variable CURSOR        
                                FOR         
                                                SELECT         
                                                                key_data,         
                                                                val_data         
                                                FROM         
                                                                @variable_table;        
                                                                                                        
                                OPEN cursor_variable;         
                                FETCH NEXT FROM cursor_variable INTO @key, @val;         
                                WHILE @@FETCH_STATUS = 0        
                                    BEGIN        
                                                                -- Melakukan Replace terhadap variable di template dengan value dari hasil pencarian data diata.        
                                                                IF ISNULL(@key, '') <> ''        
                                                                BEGIN        
          SET @Template = REPLACE(@Template, @key, @val);        
                                                   END        
        
                                                                FETCH NEXT FROM cursor_variable INTO         
       @key,         
                                           @val;        
                                    END;        
                                        
                                CLOSE cursor_variable;         
                                DEALLOCATE cursor_variable;        
                END        
        
        
    
END    
Return @Template    
    
END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_proccess_email_template]    Script Date: 10/03/2023 15:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================                      
-- Author:                            Ali Mutasal                      
-- ALTER date: 09 Des 2019                      
-- Description:    Function untuk melakukan proses email                      
-- =============================================                      
ALTER FUNCTION [dbo].[fn_proccess_email_template]                      
(                      
    -- Add the parameters for the function here                      
    @requestType nvarchar(100) = '',                      
    @requestId nvarchar(100) = '',                      
    @template nvarchar(max) = '',                      
    @typeDoc nvarchar(max) = '',                      
    @lastPIC nvarchar(max) = ''                      
)                      
RETURNS nvarchar(max)                      
AS                      
BEGIN                      
    ------------------------------------------------------------------                      
    -- 1. Melakukan Declare semua variable yang dibutuhkan                      
    ------------------------------------------------------------------                      
    BEGIN                     
    -- ini hanya sample silahkan comment jika akan digunakan                      
    --SET @template = 'Ini adalah email dari [requestor_name], dan ini adalah email untuk [last_pic_name]. selanjutnya akan dikirim ke [next_pic_name]';                      
    DECLARE @variable_table TABLE (                      
        key_data VARCHAR(MAX) NULL,                      
        val_data VARCHAR(MAX) NULL                      
    );                      
                      
    DECLARE                       
  @key NVARCHAR(MAX),                       
  @flow NVARCHAR(MAX),                       
  @val NVARCHAR(MAX),                      
  @requestor_name NVARCHAR(MAX),                      
  @requestor_id NVARCHAR(MAX),                      
  @requestor_username NVARCHAR(MAX),                      
  @last_pic_name NVARCHAR(MAX),                      
  @last_pic_id NVARCHAR(MAX),                      
  @last_pic_username NVARCHAR(MAX),                      
  @next_pic_name NVARCHAR(MAX),                      
  @next_pic_id NVARCHAR(MAX),                      
  @next_pic_username NVARCHAR(MAX),                      
  @si_number NVARCHAR(MAX) = '',                      
  @ss_number NVARCHAR(MAX) = '',                      
  @req_number NVARCHAR(MAX) = '',                      
  @CiplNo NVARCHAR(MAX) = '',                      
  @DO NVARCHAR(MAX) = '',                      
  @DA NVARCHAR(MAX) = '',                      
  @NoReference NVARCHAR(MAX) = '',                      
  @CIPLBranchName NVARCHAR(MAX) = '',                      
  @PICPickupPoints NVARCHAR(MAX) = '',                      
  @PickupPointsArea NVARCHAR(MAX) = '',                      
  @npe_number NVARCHAR(MAX) = '',      
  @npe_date NVARCHAR(MAX) = '',                  
  @peb_number NVARCHAR(MAX) = '',                      
  @bl_awb_number NVARCHAR(MAX) = '',                      
  @req_date NVARCHAR(MAX) = '',                      
  @superior_req_name nvarchar(max) = '',             
  @superior_req_id nvarchar(max) = '',                
  @Note nvarchar(max) = '',                
  @employee_name nvarchar(max) = '',  
  @AJU_Number NVARCHAR(MAX) = ''                      
                                  
    IF (@lastPIC <> '')                   
    BEGIN                      
        SELECT @employee_name = employee_name                       
        FROM dbo.fn_get_employee_internal_ckb()                       
        WHERE AD_User = @lastPIC;                      
    END                      
END                      
                                      
------------------------------------------------------------------                      
-- 2. Query untuk mengisi data ke variable variable yang dibutuhkan                      
------------------------------------------------------------------              
BEGIN                      
    -- Mengambil data dari fn request per flow                      
    BEGIN                      
  IF (@requestType = 'CIPL')                      
   BEGIN                      
   SET @flow = 'CIPL';                      
   SELECT                       
    @requestor_id = t1.Employee_ID,                      
    @requestor_name = t1.Employee_Name,                      
    @superior_req_name = t1.Superior_Name,                      
    @superior_req_id = t1.Superior_ID,                      
    @requestor_username = t1.AD_User,                      
    @last_pic_id = t2.Employee_ID,                      
    @last_pic_name = t2.Employee_Name,                      
    @last_pic_username = t2.AD_User,                      
    @next_pic_id = t3.Employee_ID,                      
    @DO = t4.EdoNo,              
    @CiplNo = t4.CiplNo,                      
    @DA = t4.Da ,                
    @Note = ISNULL((select TOP 1 notes from CiplHistory where IdCipl = t0.IdCipl order by id desc),''),            
    @NoReference = t4.ReferenceNo,                      
    @CIPLBranchName = (SELECT C.Branch+' - '+MA.BAreaName FROM MasterArea MA inner join Cipl C ON C.Branch = MA.BAreaCode WHERE C.id=t0.IdCipl ),                      
    @PICPickupPoints = t6.Employee_Name,                      
    @PickupPointsArea = t4.PickUpArea+'-'+(SELECT MA.BAreaName FROM MasterArea MA inner join Cipl C ON C.Branch = MA.BAreaCode WHERE C.id=t0.IdCipl ),                      
    @next_pic_name = CASE WHEN t0.Status = 'Revise' OR t0.Status = 'Reject' OR (t0.Status = 'Approve' AND t0.NextAssignType IS NULL) THEN t5.Employee_Name     
    WHEN t0.NextAssignType = 'Group' THEN t0.NextAssignTo  ELSE t3.Employee_Name END,                      
                @next_pic_username = t3.AD_User,                      
    @req_number = IIF(@typeDoc = 'CKB', ISNULL(t4.EdoNo,''), t4.CiplNo),                      
                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)                      
            FROM                       
    dbo.fn_get_cipl_request_list_all() t0                       
    INNER JOIN dbo.Cipl t4 on t4.id = t0.IdCipl                      
    LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy                      
                LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic                      
                LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo                      
                LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.UpdateBy                
                LEFT JOIN dbo.fn_get_employee_internal_ckb() t6 on t6.AD_User = t4.PickUpPic                
            WHERE                       
                t0.IdCipl = @requestId;                      
   END                      
                      
        --IF (@requestType IN ('CL', 'BLAWB', 'PEB_NPE'))                      
  IF (@requestType = 'CL') OR (@requestType = 'BLAWB') OR (@requestType = 'PEB_NPE')                       
   BEGIN                      
   SET @flow = @requestType;                      
   SELECT                       
        @requestor_id = t5.Employee_ID,                      
        @requestor_name = t5.Employee_Name,                      
        @superior_req_name = t5.Superior_Name,                      
        @superior_req_id = t5.Superior_ID,                      
        @requestor_username = t5.AD_User,                      
        @last_pic_id = t6.Employee_ID,                      
        @last_pic_name = t6.Employee_Name,                      
  @last_pic_username = t6.AD_User,                      
  @next_pic_id = t7.Employee_ID,                      
  @next_pic_name = t7.Employee_Name,                      
  @next_pic_username = t7.AD_User,                      
  @req_number = t1.ClNo,                      
        @ss_number = t1.SsNo,                      
        @si_number = t2.SlNo,                      
        @npe_number = t3.NpeNumber,                      
        @peb_number = t3.PebNumber,       
        @NoReference = (SELECT        
    STUFF((        
    SELECT DISTINCT ', ' + ReferenceNo        
    FROM Cipl WHERE id                       
     in (SELECT IdCipl FROM CargoCipl                       
     where IdCargo = t0.IdCl)        
    FOR XML PATH('')), 1, 1, '')),      
    --          @DO = (SELECT        
    --STUFF((        
    --SELECT ', ' + EdoNumber        
    --FROM CargoCipl WHERE IdCargo = t0.IdCl        
    --FOR XML PATH('')), 1, 1, '')),        
  @DO = (SELECT              
     STUFF((              
     SELECT ', ' + DoNo           
     FROM ShippingFleetRefrence WHERE IdCipl                               
   in (SELECT IdCipl FROM CargoCipl                             
   where IdCargo = t0.IdCl)              
     FOR XML PATH('')), 1, 1, '')),                     
        @CIPLBranchName = (SELECT STUFF((        
    SELECT DISTINCT', ' + C.Branch+' - '+MA.BAreaName FROM MasterArea MA       
    inner join Cipl C ON C.Branch = MA.BAreaCode       
    WHERE C.id in (SELECT IdCipl FROM CargoCipl                       
    where IdCargo = t0.IdCl)        
    FOR XML PATH('')), 1, 1, '')),                      
    --DA = (SELECT        
    --STUFF((        
    --SELECT ', ' + Da        
    --FROM Cipl WHERE id                       
    -- in (SELECT IdCipl FROM CargoCipl                       
    -- where IdCargo = t0.IdCl)        
    --FOR XML PATH('')), 1, 1, '')),       
  @DA = (SELECT              
   STUFF((SELECT ', ' + sf.DaNo from shippingfleet sf      
   Inner join ShippingFleetRefrence sfr on sfr.IdShippingFleet = sf.Id      
   inner join CargoCipl cc on cc.IdCipl = sfr.IdCipl      
   where cc.IdCargo = t0.IdCl      
   FOR XML PATH('')), 1, 1, '')),                  
        @CiplNo = (SELECT        
    STUFF((        
      SELECT ', ' + CiplNo        
      FROM Cipl WHERE id                       
    in (SELECT IdCipl FROM CargoCipl                       
    where IdCargo = t0.IdCl)        
      FOR XML PATH('')), 1, 1, '')),                      
  @bl_awb_number = t4.Number,                      
        @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate),  
  @AJU_Number = t3.AjuNumber,  
  @npe_date = t3.NpeDate  
    FROM                       
        dbo.fn_get_cl_request_list_all() t0                       
        INNER JOIN dbo.Cargo t1 on t1.id = t0.IdCl                
        LEFT JOIN dbo.ShippingInstruction t2 on t2.IdCL = t0.IdCl                      
        LEFT JOIN dbo.NpePeb t3 on t3.IdCL = t0.IdCl                      
        LEFT JOIN dbo.BlAwb t4 on t4.IdCL = t0.IdCl                
  LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.CreateBy                      
  LEFT JOIN dbo.fn_get_employee_internal_ckb() t6 on t6.AD_User = t0.Pic                      
  LEFT JOIN dbo.fn_get_employee_internal_ckb() t7 on t7.AD_User = t0.NextAssignTo                      
   WHERE                       
                t0.IdCl = @requestId;                                                                                           
            END                      
                      
        IF (@requestType = 'RG')                      
   BEGIN                      
            SET @flow = 'Receive Goods';                      
            SELECT                    
   --@DO = (SELECT        
   --  STUFF((        
   --  SELECT ', ' + EdoNo        
   --  FROM Cipl WHERE id= gt.IdCipl        
   --  FOR XML PATH('')), 1, 1, '')),       
   @DO = (SELECT        
     STUFF((        
     SELECT ', ' + DoNo     
     FROM ShippingFleet WHERE IdGr = t0.IdGr        
     FOR XML PATH('')), 1, 1, '')),                 
   --@CIPLBranchName = (SELECT C.Branch+' - '+MA.BAreaName FROM MasterArea MA inner join Cipl C ON C.Branch = MA.BAreaCode WHERE C.id = gt.IdCipl),      
   @CIPLBranchName = (SELECT C.Branch+' - '+MA.BAreaName     
    FROM MasterArea MA     
    inner join Cipl C ON C.Branch = MA.BAreaCode     
    WHERE EdoNo IN (    
    SELECT DoNo    
    FROM ShippingFleet    
    WHERE IdGr = sf.IdGr)),                    
   @DA = (SELECT        
     STUFF((        
     SELECT ', ' + DaNo     
     FROM ShippingFleet WHERE IdGr = t0.IdGr     
     FOR XML PATH('')), 1, 1, '')),    
   --@DA = (SELECT        
   --  STUFF((        
   --  SELECT ', ' + Da        
   --  FROM Cipl     
   --  WHERE id = gt.IdCipl        
   --  FOR XML PATH('')), 1, 1, '')),                      
   @CiplNo = (SELECT        
      STUFF((        
      SELECT DISTINCT ', ' + CiplNo        
      FROM Cipl WHERE EdoNo IN (    
      SELECT DoNo    
      FROM ShippingFleet    
      WHERE IdGr = sf.IdGr)    
      FOR XML PATH('')), 1, 1, '')),       
   @NoReference = (SELECT        
    STUFF((        
    SELECT DISTINCT ', ' + ReferenceNo        
    FROM Cipl WHERE EdoNo IN (    
    SELECT DoNo    
    FROM ShippingFleet    
    WHERE IdGr = sf.IdGr)    
    FOR XML PATH('')), 1, 1, '')),    
   @requestor_id = t1.Employee_ID,                      
   @requestor_name = t1.Employee_Name,                      
   @superior_req_name = t1.Superior_Name,                      
   @superior_req_id = t1.Superior_ID,                      
   @requestor_username = t1.AD_User,                      
   @last_pic_id = t2.Employee_ID,                      
   @last_pic_name = t2.Employee_Name,                      
   @last_pic_username = t2.AD_User,                      
   @next_pic_id = t3.Employee_ID,                      
   @next_pic_name = t3.Employee_Name,                      
   @next_pic_username = t3.AD_User,                      
   @req_number = t4.GrNo,                      
   @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)                      
  FROM                       
            dbo.fn_get_gr_request_list_all() t0                       
   INNER JOIN dbo.GoodsReceive t4 on t4.id = t0.IdGr           
   --LEFT JOIN GoodsReceiveItem gt on gt.IdGr = t0.IdGr       
   LEFT JOIN ShippingFleet sf on sf.IdGr = t0.IdGr       
   LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy                      
   LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic                      
   LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo                   
  WHERE                
   t0.IdGr = @requestId;                      
        END                      
                      
        IF (@requestType = 'DELEGATION')                      
  BEGIN                      
    SET @flow = 'Delegation';                                                                  --SELECT * FROM dbo.fn_get_gr_request_list_all() t0 where t0.Id = @requestId;                      
  END                      
                      
            INSERT INTO  @variable_table                       
            VALUES                       
            ('@RequestorName', ISNULL(@requestor_name, '-'))                      
            ,('@RequestNo', ISNULL(@req_number, '-'))                      
            ,('@CreatedDate', ISNULL(@req_date, '-'))                      
            ,('@CiplNo', ISNULL(@CiplNo, '-'))                      
            ,('@CIPLBranchName', ISNULL(@CIPLBranchName, '-'))                      
            ,('@PICPickupPoints', ISNULL(@PICPickupPoints, '-'))                      
            ,('@DO', ISNULL(@DO, '-'))                      
            ,('@DA', ISNULL(@DA, '-'))                      
            ,('@PickupPointsArea', ISNULL(@PickupPointsArea, '-'))                      
   ,('@SuperiorEmpID', ISNULL(@superior_req_id, '-'))                      
   ,('@SuperiorName', ISNULL(@superior_req_name, '-'))                      
   ,('@MobileLink', 'http://pis.trakindo.co.id')                    
   ,('@DesktopLink', 'http://pis.trakindo.co.id')                      
   ,('@ApproverPosition', ISNULL(@flow, '-'))                      
   ,('@ApproverName', ISNULL(@next_pic_name, ISNULL(@employee_name,'-')))        
   ,('@RequestorEmpID', ISNULL(@requestor_id, '-'))                      
   ,('@flow', ISNULL(@flow, '-'))                      
            ,('@NoReference', ISNULL(@NoReference, '-'))                      
   ,('@requestor_name', ISNULL(@requestor_name, '-'))                      
            ,('@requestor_id', ISNULL(@requestor_id, '-'))                      
            ,('@last_pic_name', ISNULL(@last_pic_name, '-'))                      
            ,('@last_pic_id', ISNULL(@last_pic_id, '-'))                      
            ,('@next_pic_name', ISNULL(@next_pic_name, '-'))                      
            ,('@next_pic_id', ISNULL(@next_pic_id, '-'))                      
            ,('@si_number', ISNULL(@si_number, '-'))                      
   ,('@ss_number', ISNULL(@ss_number, '-'))                      
            ,('@req_number', ISNULL(@req_number, '-'))                      
            ,('@npe_number', ISNULL(@npe_number, '-'))    
   ,('@npe_date', ISNULL(@npe_date, '-'))                    
            ,('@peb_number', ISNULL(@peb_number, '-'))                      
            ,('@bl_awb_number', ISNULL(@bl_awb_number, '-'))                      
            ,('@req_date', ISNULL(@req_date, '-'))                      
            ,('@superior_req_name', ISNULL(@superior_req_name, '-'))                      
            ,('@superior_req_id', ISNULL(@superior_req_id, '-'))            
            ,('@Note', ISNULL(@Note, '-'))  
   ,('@AJU_Number', ISNULL(@AJU_Number, '-'))   
 END                      
END                      
                                      
------------------------------------------------------------------                      
-- 3. Melakukan Replace terhadap data yang di petakan di template dgn menggunakan perulangan                      
------------------------------------------------------------------                      
BEGIN                      
    DECLARE cursor_variable CURSOR                      
    FOR                       
    SELECT                       
        key_data,              
        val_data                       
    FROM                       
        @variable_table;                      
                                                                                                                      
    OPEN cursor_variable;                       
    FETCH NEXT FROM cursor_variable INTO @key, @val;                       
    WHILE @@FETCH_STATUS = 0                      
        BEGIN                      
        -- Melakukan Replace terhadap variable di template dengan value dari hasil pencarian data diata.                      
        IF ISNULL(@key, '') <> ''                      
        BEGIN                      
  SET @template = REPLACE(@template, @key, @val);                      
        END                      
                      
    FETCH NEXT FROM cursor_variable INTO                       
                @key,                       
                @val;                      
        END;                      
                                                      
    CLOSE cursor_variable;                       
    DEALLOCATE cursor_variable;                      
END                      
                                      
------------------------------------------------------------------                      
-- 4. Menampilkan hasil dari proses replace                      
------------------------------------------------------------------                      
BEGIN                      
    RETURN @template;                      
END                      
END 
GO

/****** Object:  UserDefinedFunction [dbo].[fn_RPTTUBranch_Branch]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[fn_RPTTUBranch_Branch]
(	
	-- Add the parameters for the function here
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select 
			Branch
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
		group by Branch, DATEPART(MONTH, PebDateNumeric)
)
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
ALTER FUNCTION [dbo].[fn_RPTTUBranch_Loading]
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

/****** Object:  UserDefinedFunction [dbo].[Fn_RSailingEstimation]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[Fn_RSailingEstimation]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT DISTINCT t3.ClNo,
		ISNULL(t0.ConsigneeCountry, t0.SoldToCountry) [DestinationCountry] 
		, t4.AreaName [OriginCity]
		, t3.[PortOfLoading] [PortOrigin]
		, t0.[ShippingMethod]
		, t3.[PortOfDestination] [PortDestination]
		, ISNULL(CONVERT(VARCHAR(9), t3.ArrivalDestination, 6), '-') ETA
		, ISNULL(CONVERT(VARCHAR(9), t3.SailingSchedule, 6), '-') ETD
		, CAST(DATEDIFF(day, t3.SailingSchedule, t3.ArrivalDestination) as varchar(18)) [Estimation] 
    FROM Cipl t0
	JOIN CargoCipl t2 on t2.IdCipl = t0.id
	JOIN Cargo t3 on t3.Id = t2.IdCargo   
	JOIN MasterArea t4 ON Right(t0.Area,3) = RighT(t4.BAreaCode,3)
	WHERE 
		t0.IsDelete = 0
		And t3.IsDelete = 0
		AND t0.CreateBy<>'System'
		AND  t3.ArrivalDestination is not null
)
GO

/****** Object:  UserDefinedFunction [dbo].[FN_SplitStringDelimiter]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[FN_SplitStringDelimiter]
(
    @Text VARCHAR(MAX),
    @Delimiter VARCHAR(100),
    @Index INT
)
RETURNS VARCHAR(MAX)
AS 
BEGIN
    DECLARE @A TABLE (ID INT IDENTITY, V VARCHAR(MAX));
    DECLARE @R VARCHAR(MAX);
    WITH CTE AS
    (
		SELECT 0 A, 1 B
		UNION ALL
		SELECT B, CONVERT(INT,CHARINDEX(@Delimiter, @Text, B) + LEN(@Delimiter))
		FROM CTE
		WHERE B > A
    )
    INSERT @A(V)
    SELECT SUBSTRING(@Text,A,CASE WHEN B > LEN(@Delimiter) THEN B-A-LEN(@Delimiter) ELSE LEN(@Text) - A + 1 END) VALUE      
    FROM CTE WHERE A >0

    SELECT @R = V
    FROM @A
    WHERE ID = @Index + 1
    RETURN @R
END
GO

/****** Object:  UserDefinedFunction [dbo].[FN_SplitStringToRows]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[FN_SplitStringToRows]
(
    @List       NVARCHAR(MAX),
    @Delimiter  NVARCHAR(255)
)
RETURNS TABLE
AS
    RETURN (
		SELECT Number = ROW_NUMBER() OVER (ORDER BY Number), Item 
		FROM (
			SELECT Number, Item = LTRIM(RTRIM(SUBSTRING(@List, Number, CHARINDEX(@Delimiter, @List + @Delimiter, Number) - Number)))
			FROM (
					SELECT ROW_NUMBER() OVER (ORDER BY s1.[object_id])
					FROM sys.all_objects AS s1 CROSS APPLY sys.all_objects
			) AS n(Number)
			WHERE Number <= CONVERT(INT, LEN(@List)) AND SUBSTRING(@Delimiter + @List, Number, 1) = @Delimiter
		) AS y
	);
GO

/****** Object:  UserDefinedFunction [dbo].[fnSplitString]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fnSplitString] 
( 
    @string NVARCHAR(MAX), 
    @delimiter CHAR(1) 
) 
RETURNS @output TABLE(splitdata NVARCHAR(MAX) 
) 
BEGIN 
    DECLARE @start INT, @end INT 
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string) 
    WHILE @start < LEN(@string) + 1 BEGIN 
        IF @end = 0  
            SET @end = LEN(@string) + 1
       
        INSERT INTO @output (splitdata)  
        VALUES(SUBSTRING(@string, @start, @end - @start)) 
        SET @start = @end + 1 
        SET @end = CHARINDEX(@delimiter, @string, @start)
        
    END 
    RETURN 
END
GO

/****** Object:  UserDefinedFunction [dbo].[fnSplitStringRFC]    Script Date: 10/03/2023 15:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
ALTER FUNCTION [dbo].[fnSplitStringRFC](  
    @RowData varchar(8000),  
    @SplitOn nvarchar(5)  
) RETURNS @RtnValue table (  
    Id int identity(1,1),  
    Data nvarchar(100)  
)   
AS    
BEGIN   
    Declare @Cnt int  
    Set @Cnt = 1  
  
    While (Charindex(@SplitOn,@RowData)>0)  
    Begin  
        Insert Into @RtnValue (data)
        Select   
            Data = ltrim(rtrim(Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))  

        Set @RowData = Substring(@RowData,Charindex(@SplitOn,@RowData)+1,len(@RowData))  
        Set @Cnt = @Cnt + 1  
    End  
  
    Insert Into @RtnValue (data)  
    Select Data = ltrim(rtrim(@RowData))  
  
    Return  
END
GO

/****** Object:  UserDefinedFunction [dbo].[get_status]    Script Date: 10/03/2023 12:07:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[get_status] -- select * from [fn_get_cl_request_list]('xupj21wdn', 'Import Export') 
(	
	-- Add the parameters for the function here
	@idcipl int
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	select * from (
					 Select Distinct RC.IdCipl,  CASE					
									WHEN fnreq.NextStatusViewByUser ='Pickup Goods'
									 THEN
										  CASE WHEN 
										  (fnReqGr.Status='DRAFT') OR (fnReq.Status='APPROVE' AND (fnReqGr.Status is null OR fnReqGr.Status = 'Waiting Approval') AND RC.Status ='APPROVE') 
												THEN 'Waiting for Pickup Goods'
											WHEN (fnReqGr.IdFlow = 14 AND (fnReqGr.Status ='Submit' OR fnReqGr.Status ='APPROVE' ) AND (fnReqCl.Status is Null OR (fnReqCl.Status='Submit' AND fnReqCl.IdStep != 10017)))
												THEN 'On process Pickup Goods'
											WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep not in (10022))
												THEN 'Preparing for export'
											WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep = 10022)
												THEN 'Finish'	
											END			
											WHEN fnReq.Status ='Reject'
											THEN 'Reject'
									WHEN fnReq.NextStatusViewByUser = 'Waiting for superior approval'
										THEN fnReq.NextStatusViewByUser +' ('+ emp.Employee_Name +')'
									WHEN fnReq.Status ='Reject'
									THEN 'Reject'
									ELSE fnReq.NextStatusViewByUser 
									 END AS [StatusViewByUser]
									FROM dbo.Cipl C		
						INNER JOIN dbo.RequestCipl RC ON RC.IdCipl = C.id 
						--INNER JOIN PartsInformationSystem.dbo.UserAccess PIS on PIS.UserID = c.CreateBy
						INNER JOIN dbo.[fn_get_cipl_request_list_all]() as fnReq on fnReq.IdCipl = C.id 
						LEFT JOIN GoodsReceiveItem as GR on GR.IdCipl = C.id AND GR.isdelete = 0
						LEFT JOIN CargoCipl as CC on CC.IdCipl = C.id AND CC.Isdelete = 0
						LEFT JOIN dbo.[fn_get_gr_request_list_all]() as fnReqGr on fnReqGr.IdGr = GR.IdGr
						LEFT JOIN dbo.[fn_get_cl_request_list_all]() as fnReqCl on fnReqCl.IdCl = CC.IdCargo
						left join employee emp on emp.AD_User = fnReq.NextAssignTo 
		
	
	) as tab0 
	WHERE (tab0.IdCipl = @idcipl)
)
GO

/****** Object:  UserDefinedFunction [dbo].[SDF_SplitString]    Script Date: 10/03/2023 15:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[SDF_SplitString]
(
    @sString nvarchar(2048),
    @cDelimiter nchar(1)
)
RETURNS @tParts TABLE ( part nvarchar(2048) )
AS
BEGIN
    if @sString is null return
    declare @iStart int,
            @iPos int
    if substring( @sString, 1, 1 ) = @cDelimiter 
    begin
        set @iStart = 2
        insert into @tParts
        values( null )
    end
    else 
        set @iStart = 1
    while 1=1
    begin
        set @iPos = charindex( @cDelimiter, @sString, @iStart )
        if @iPos = 0
            set @iPos = len( @sString )+1
        if @iPos - @iStart > 0          
            insert into @tParts
            values  ( substring( @sString, @iStart, @iPos-@iStart ))
        else
            insert into @tParts
            values( null )
        set @iStart = @iPos+1
        if @iStart > len( @sString ) 
            break
    end
    RETURN

END

GO