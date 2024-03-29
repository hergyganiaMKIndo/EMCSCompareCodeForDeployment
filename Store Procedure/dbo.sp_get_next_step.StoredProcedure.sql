USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_next_step]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_next_step] (
	@IDStep bigint,
	@IDStatus bigint
)
as 
BEGIN
	select 
		t0.Id, t0.IdStep, t0.IdStatus, t4.Name FlowName, t4.Type FlowType, t3.Step CurrentStep, t2.Status CurrentStatus, t1.Step NextStepName, 
		t2.ViewByUser, t1.AssignType, t1.AssignTo,
		t0.CreateBy, t0.CreateDate, t0.UpdateBy, t0.UpdateDate, t0.IsDelete
	from dbo.FlowNext t0
	join dbo.FlowStep t1 on t1.Id = t0.IdStep
	join dbo.FlowStatus t2 on t2.Id = t0.IdStatus
	join dbo.FlowStep t3 on t3.Id = t2.IdStep
	join dbo.Flow t4 on t4.Id = t3.IdFlow 
	where t0.IdStep = @IDStep AND t0.IdStatus = @IDStatus;
END
GO
