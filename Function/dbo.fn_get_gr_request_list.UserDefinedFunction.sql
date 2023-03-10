USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_gr_request_list]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_get_gr_request_list] -- select * from [fn_get_gr_request_list]('xupj21wdn', 'IMEX') 
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
