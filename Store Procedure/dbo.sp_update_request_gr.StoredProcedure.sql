USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_update_request_gr]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_update_request_gr] -- sp_update_request_gr(1, 'XUPJ21SAR', 'Submit', 'Testing Notes')
(
	@IdGr bigint,
	@Username nvarchar(100),
	@NewStatus nvarchar(100),
	@Notes nvarchar(100) = ''	
)
AS
BEGIN
	DECLARE @NewStepId bigint;
	DECLARE @IdFlow bigint;
	DECLARE @FlowName nvarchar(100);
	DECLARE @NextStepName nvarchar(100);
	DECLARE @Now datetime;
	DECLARE @GroupId nvarchar(100);
		
	SET @Now = GETDATE();
	select @GroupId = hce.Organization_Name from employee hce WHERE hce.AD_User = @Username;
	--select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_gr_request_list(@Username, @GroupId) t0 where t0.IdGr = @IdGr;
	select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_gr_request_list_all() t0 where t0.IdGr = @IdGr;

	UPDATE [dbo].[RequestGr]
	  SET [IdFlow] = @IdFlow
	     ,[IdStep] = @NewStepId
	     ,[Status] = @NewStatus
	     ,[Pic] = @Username
		 ,[UpdateBy] = @Username
		 ,[UpdateDate] = GETDATE()
	WHERE IdGr = @IdGr
	
	exec [dbo].[sp_insert_gr_history]@id=@IdGr, @Flow=@FlowName, @Step=@NextStepName, @Status=@NewStatus, @Notes=@Notes, @CreateBy=@Username, @CreateDate=@Now;

	IF((select Status from RequestGr where IdGr = @IdGr) <> 'DRAFT')
	BEGIN
		--EXEC [sp_send_email_notification] @IdGr, 'GoodReceive'
		EXEC [sp_proccess_email] @IdGr, 'RG'
	END
END
GO
