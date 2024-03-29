USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_update_request_cipl_20210423]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_update_request_cipl_20210423] -- sp_update_request_cipl(1, 'XUPJ21SAR', 'Submit', 'Testing Notes')
(
	@IdCipl bigint,
	@Username nvarchar(100),
	@NewStatus nvarchar(100),
	@Notes nvarchar(100) = '',
	@NewStep nvarchar(100) = ''
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @NewStepId bigint;
	DECLARE @IdFlow bigint;
	DECLARE @FlowName nvarchar(100);
	DECLARE @NextStepName nvarchar(100);
	DECLARE @Now datetime;
	DECLARE @GroupId nvarchar(100);
	DECLARE @CurrentStepId bigint;
		
	SET @Now = GETDATE();
	--SET @IdCipl = 1;
	--SET @Username = 'XUPJ21FIG';
	--SET @GroupId = 'IMEX';
	--SET @NewStatus = 'REJECT';

	select @GroupId = hce.Organization_Name from employee hce WHERE hce.AD_User = @Username;
	--select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cipl_request_list(@Username, @GroupId) t0 where t0.IdCipl = @IdCipl;
	select @IdFlow = IdFlow, @CurrentStepId = IdStep, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cipl_request_list_all() t0 where t0.IdCipl = @IdCipl;

	-- Jika Revise Cipl
	IF ISNULL(@NewStep, '') <> ''
	BEGIN
		SET @NewStepId = @NewStep
		select @IdFlow = IdFlow, @NextStepName = Step from dbo.FlowStep where Id = @NewStepId;
	END

	UPDATE [dbo].[RequestCipl]
	  SET [IdFlow] = @IdFlow
	     ,[IdStep] = @NewStepId
	     ,[Status] = @NewStatus
	     ,[Pic] = @Username
		 ,[UpdateBy] = @Username
		 ,[UpdateDate] = GETDATE()
	WHERE IdCipl = @IdCipl

	-- Hasni Procedure Cancel CIPL
	IF  @NewStatus = 'Request Cancel'
	BEGIN
		IF @IdFlow = 1
		BEGIN 
			SET @NewStepId = 30037
		END
		ELSE IF @IdFlow = 2
		BEGIN
			SET @NewStepId = 30033
		END
		ELSE IF @IdFlow = 3
		BEGIN
			SET @NewStepId = 30044
		END

		UPDATE [dbo].[RequestCipl]
		  SET [IdFlow] = @IdFlow
			 ,[IdStep] = @NewStepId
			 ,[Status] = 'Submit'
			 ,[Pic] = @Username
			 ,[UpdateBy] = @Username
			 ,[UpdateDate] = GETDATE()
		WHERE IdCipl = @IdCipl
	END
	
	IF @NextStepName = 'Approval By Superior' AND @NewStatus = 'Approve'
	BEGIN
		EXEC [dbo].[GenerateEDONumber] @IdCipl, @Username
	END

	-- cancel CIPL
	IF @NewStepId IN (30039, 30035, 30046) AND @NewStatus = 'Approve'
	BEGIN
		exec [dbo].[sp_cipldelete] @IdCipl, @Username, GETDATE, 'ALL', 1
	END 

	-- Action CIPL Revise 
	IF (@CurrentStepId = 10032) OR (@CurrentStepId = 10033) OR (@CurrentStepId =10035) 
	BEGIN
		IF @NewStatus = 'Approve'
		BEGIN
			exec [sp_approve_req_revise_cipl] @ciplid = @IdCipl, @username = @Username
		END

		IF @NewStatus = 'Reject'
		BEGIN
			exec [sp_reject_req_revise_cipl] @ciplid = @IdCipl, @username = @Username
		END

		IF @NewStatus = 'Revise'
		BEGIN
			exec [sp_revise_req_revise_cipl] @ciplid = @IdCipl, @username = @Username
		END
	END

	IF @CurrentStepId IN (14, 10024, 10028) AND @NewStatus = 'Approve'
	BEGIN
		IF @IdFlow = 1
		BEGIN 
			SET @NewStepId = 1
		END
		ELSE IF @IdFlow = 2
		BEGIN
			SET @NewStepId = 6
		END
		ELSE IF @IdFlow = 3
		BEGIN
			SET @NewStepId = 9
		END

		UPDATE [dbo].[RequestCipl]
		  SET [IdFlow] = @IdFlow
			 ,[IdStep] = @NewStepId
			 ,[Status] = 'Draft'
			 ,[Pic] = @Username
			 ,[UpdateBy] = @Username
			 ,[UpdateDate] = GETDATE()
		WHERE IdCipl = @IdCipl
	END 

	exec [dbo].[sp_insert_cipl_history]@id=@IdCipl, @Flow=@FlowName, @Step=@NextStepName, @Status=@NewStatus, @Notes=@Notes, @CreateBy=@Username, @CreateDate=@Now;

	IF((select Status from RequestCipl where IdCipl = @IdCipl) <> 'DRAFT')
	BEGIN
		--EXEC [sp_send_email_notification] @IdCipl, 'CIPL'
		EXEC [sp_proccess_email] @IdCipl, 'CIPL'
	END
END
GO
