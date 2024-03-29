USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_approve_req_revise_cipl_20210423]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- Create date: 24 Nov 2019
-- Description:	sp jika superior melakukan approval terhadap perubahan dimensi di cargo
-- =============================================
Create PROCEDURE [dbo].[sp_approve_req_revise_cipl_20210423] -- sp_approve_req_revise_cipl 50, 'xupj21njb'
	-- Add the parameters for the stored procedure here
	@ciplid bigint,
	@username nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE 
	@IdUpdate bigint
	, @newciplitemid bigint
	, @clId bigint
	, @NewHeight decimal
	, @NewWidth decimal
	, @NewLength decimal
	, @NewNetWeight decimal
	, @NewGrossWeight decimal
	, @TotalWaiting decimal

	-- mengupdate semua perubahan
	-- ambil semua history perubahan cipl di cargo	
	DECLARE cursor_update CURSOR
	FOR 
		SELECT Id IdUpdate, IdCiplItem, NewHeight, NewWidth, NewLength, NewNetWeight, NewGrossWeight, IdCargo
		FROM dbo.CiplItemUpdateHistory 
		WHERE IdCipl = @ciplid AND IsApprove = 0;
		 
	OPEN cursor_update;
	 
	FETCH NEXT FROM cursor_update INTO @IdUpdate, @newciplitemid, @NewHeight, @NewWidth, @NewLength, @NewNetWeight, @NewGrossWeight, @clId;
	 
	WHILE @@FETCH_STATUS = 0
	    BEGIN
			-- Update cipl item history
			UPDATE dbo.CiplItemUpdateHistory 
			SET IsApprove = 1, UpdateBy = @username, UpdateDate = GETDATE() 
			WHERE Id = @IdUpdate;

			-- Apply perubahan ke table cipl item
			UPDATE dbo.CiplItem 
			SET Height = @NewHeight, Width = @NewWidth, NetWeight = @NewNetWeight, GrossWeight = @NewGrossWeight
			WHERE Id = @newciplitemid;

	        FETCH NEXT FROM cursor_update INTO @IdUpdate, @newciplitemid, @NewHeight, @NewWidth, @NewLength, @NewNetWeight, @NewGrossWeight, @clId;
	    END;	 
	CLOSE cursor_update;	 
	DEALLOCATE cursor_update;

	-- get total waiting approval
	SELECT @totalwaiting = COUNT(*) 
	FROM dbo.CiplItemUpdateHistory 
	WHERE IdCargo = @clId AND IsApprove = 0;

	-- jika sudah tidak ada lagi approval di ciplupitem update history maka update data cl
	-- update status cl jika sudah tidak ada lagi waiting approval
	IF @totalwaiting = 0
	BEGIN
		EXEC sp_update_request_cl @clId, @username, 'Approve', ''
	END

	-- update status cipl
	--EXEC sp_update_request_cipl @IdCipl = @ciplid, @Username = @username, @NewStatus = 'Approve', @Notes = '', @NewStep = ''

END
GO
