USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_request_data]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DROP PROCEDURE sp_insert_request_data;
CREATE PROCEDURE [dbo].[sp_insert_request_data] -- sp_insert_request_data '2', 'CIPL', 'PP', 'Draft', 'Create'
( 
	@ID nvarchar(100), -- CIPL or CL Id
	@FlowName nvarchar(100), -- ex : 'CIPL', 'CL'
	@Category nvarchar(100), -- ex : 'PP', 'UE', 'PS'
	@Status nvarchar(100), -- ex : 'DRAFT' OR 'SUBMIT'
	@StepName nvarchar(100) = 'CREATE' -- ex : 'CREATE'	
)
AS
BEGIN
	-- Insert By Logic Query
	DECLARE @IdFlow bigint;
	DECLARE @IdStep bigint;
	DECLARE @CreateBy nvarchar(100);
	DECLARE @CreateDate datetime;

	-- Set data to Logic Query Variable
	SELECT @IdFlow = Id FROM dbo.Flow where [Name] = @FlowName AND [Type] = @Category;
	SELECT @IdStep = Id FROM dbo.FlowStep where [IdFlow] = @IdFlow AND [Step] = @StepName;
	SET @CreateDate = GETDATE();
	
	IF (@FlowName = 'CIPL')
	BEGIN
		SELECT @CreateBy = CreateBy FROM dbo.Cipl WHERE Id = @ID;
		IF (ISNULL(@CreateBy, '0') <> '0') 
		BEGIN
			INSERT INTO [dbo].[RequestCipl]
				([IdCipl],[IdFlow],[IdStep],[Status],[Pic],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
			VALUES 
				(@ID,@IdFlow,@IdStep,@Status,@CreateBy,@CreateBy, @CreateDate,@CreateBy,GETDATE(),0)

			EXEC [dbo].[sp_insert_cipl_history]@ID, @FlowName, @StepName, @Status, '', @CreateBy, @CreateDate;	
		END
	END

	IF (@FlowName = 'CL')
	BEGIN 
		SELECT @CreateBy = CreateBy FROM dbo.Cargo WHERE Id = @ID;
		IF (ISNULL(@CreateBy, '0') <> '0')  
		BEGIN
			INSERT INTO [dbo].[RequestCl]
				([IdCl],[IdFlow],[IdStep],[Status],[Pic],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
			VALUES
				(@ID, @IdFlow, @IdStep, @Status, @CreateBy, @CreateBy, @CreateDate, @CreateBy, GETDATE(), 0)

			EXEC [dbo].[sp_insert_cargo_history]@ID, @FlowName, @StepName, @Status, '', @CreateBy, @CreateDate;	
		END
	END

	IF (@FlowName = 'GR')
	BEGIN 
		SELECT @CreateBy = CreateBy FROM dbo.GoodsReceive WHERE Id = @ID;
		IF (ISNULL(@CreateBy, '0') <> '0')  
		BEGIN
			INSERT INTO [dbo].[RequestGr]
				([IdGr],[IdFlow],[IdStep],[Status],[Pic],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
			VALUES
				(@ID, @IdFlow, @IdStep, @Status, @CreateBy, @CreateBy, @CreateDate, @CreateBy, GETDATE(), 0)

			EXEC [dbo].[sp_insert_gr_history]@ID, @FlowName, @StepName, @Status, '', @CreateBy, @CreateDate;	
		END
	END
END
GO
