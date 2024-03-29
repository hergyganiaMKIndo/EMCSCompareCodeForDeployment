USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_update_request_cl_20210721]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[sp_update_request_cl_20210721] -- exec sp_update_request_cl 1, 'CKB1', 'Submit', 'Testing Notes'
(
	@IdCl bigint,
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
	DECLARE @UserType nvarchar(100);
	DECLARE @NextStepIdSystem bigint;
		
	SET @Now = GETDATE();
	select @UserType = [Group] From dbo.fn_get_employee_internal_ckb() WHERE AD_User = @Username

	IF @UserType <> 'internal' AND @UserType = 'CKB'
	BEGIN
		SET @GroupId = 'CKB';
	END
	ELSE 
	BEGIN
		SELECT @GroupId = hce.Organization_Name 
		FROM employee hce 
		WHERE hce.AD_User = @Username;
	END

	--select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cl_request_list(@Username, @GroupId) t0 where t0.IdCl = @IdCl;
	--select * from dbo.fn_get_cl_request_list_all() where IdCl = 3;

	select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cl_request_list_all() t0 where t0.IdCl = @IdCl;

	UPDATE [dbo].[RequestCl]
	  SET [IdStep] = @NewStepId
	     ,[Status] = @NewStatus
	     ,[Pic] = @Username
		 ,[UpdateBy] = @Username
		 ,[UpdateDate] = GETDATE()
	WHERE IdCl = @IdCl
	
	-- Hasni Procedure Cancel PEB
	IF  @NewStatus = 'Request Cancel'
	BEGIN
		SET @NewStepId = 30041

		UPDATE [dbo].[RequestCl]
		SET [IdStep] = @NewStepId
	     ,[Status] = @NewStatus
	     ,[Pic] = @Username
		 ,[UpdateBy] = @Username
		 ,[UpdateDate] = GETDATE()
	WHERE IdCl = @IdCl
	END

	IF @NewStepId = 30042 AND @NewStatus = 'Approve'
	BEGIN
		UPDATE dbo.NpePeb SET IsDelete = 1 WHERE IdCl = @IdCl;
	END 

	--======================================================
	--- Kondisi jika cl akan melanjutkan proses ke system
	--======================================================
	IF @NewStepId = 11 AND @NewStatus = 'Submit'
	BEGIN
		select @NextStepIdSystem = x.IdNextStep from dbo.fn_get_cl_request_list_all() x where x.IdCl = @IdCl;

		UPDATE [dbo].[RequestCl]
		SET [IdStep] = @NextStepIdSystem
	     ,[Status] = @NewStatus
	     ,[Pic] = @Username
		 ,[UpdateBy] = @Username
		 ,[UpdateDate] = GETDATE()
		WHERE IdCl = @IdCl

		exec sp_set_ss_number @IdCl = @IdCl
		exec sp_update_cipl_to_revise @IdCl
	END

	IF @NewStepId = 20033 AND @NewStatus = 'Approve'
	BEGIN
		select @NextStepIdSystem = x.IdNextStep from dbo.fn_get_cl_request_list_all() x where x.IdCl = @IdCl;

		UPDATE [dbo].[RequestCl]
		SET [IdStep] = @NewStepId
	     ,[Status] = @NewStatus
	     ,[Pic] = @Username
		 ,[UpdateBy] = @Username
		 ,[UpdateDate] = GETDATE()
		WHERE IdCl = @IdCl

		exec sp_update_cipl_to_revise @IdCl
	END
	--======================================================

	exec [dbo].[sp_insert_cl_history]@id=@IdCl, @Flow=@FlowName, @Step=@NextStepName, @Status=@NewStatus, @Notes=@Notes, @CreateBy=@Username, @CreateDate=@Now;

	IF((select Status from RequestCl where IdCl = @IdCl) <> 'DRAFT')
	BEGIN
		--EXEC [sp_send_email_notification] @IdCl, 'Cargo'
		EXEC [sp_proccess_email] @IdCl, 'CL'
	END
END
GO
