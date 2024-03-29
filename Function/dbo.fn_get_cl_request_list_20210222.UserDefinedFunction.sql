USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_cl_request_list_20210222]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fn_get_cl_request_list_20210222] -- select * from [fn_get_cl_request_list]('xupj21wdn', 'Import Export') 
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
