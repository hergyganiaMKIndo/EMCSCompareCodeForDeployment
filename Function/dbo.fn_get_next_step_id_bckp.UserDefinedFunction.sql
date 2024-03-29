USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_next_step_id_bckp]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_get_next_step_id_bckp]  -- SELECT fn_get_next_step_id ('System','xupj21ech','2','3','', 1) test
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
