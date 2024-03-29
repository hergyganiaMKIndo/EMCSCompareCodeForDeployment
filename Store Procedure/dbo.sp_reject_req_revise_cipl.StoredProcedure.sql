USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_reject_req_revise_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- Create date: 24 Nov 2019
-- Description:	sp jika requestor cipl tidak setuju dengan perubahan dimension di cargo
-- =============================================
CREATE PROCEDURE [dbo].[sp_reject_req_revise_cipl] 
	-- Add the parameters for the stored procedure here
	@ciplid bigint, 
	@username nvarchar = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @totalwaiting int, @clid bigint;

	-- Set Nomor Id Cargo
	select @clid = IdCargo from dbo.CiplItemUpdateHistory where IdCipl = @ciplid;

    -- Insert statements for procedure here
	-- SELECT @ciplid, @ciplitemid
	
	-- Hapus semua data cipl di table update item history
	DELETE FROM dbo.CiplItemUpdateHistory WHERE IdCipl = @ciplid;

	-- Hapus cipl dari cargo dengan menggunakan deletion flag
	--UPDATE dbo.CargoCipl SET IsDelete = 1 WHERE IdCipl = @ciplid;
	--UPDATE dbo.CargoItem SET isDelete = 1 WHERE IdCipl = @ciplid;

	DELETE FROM dbo.CargoCipl WHERE IdCipl = @ciplid;
	DELETE FROM dbo.CargoItem WHERE IdCipl = @ciplid;

	-- Update status req cargo ke next step dengan mengecek ke data update history cipl
	SELECT @totalwaiting = COUNT(*) FROM dbo.CiplItemUpdateHistory WHERE IdCargo = @clid;
	IF @totalwaiting = 0
	BEGIN
		UPDATE dbo.RequestCl 
		SET IdStep = 12,[Status] = 'Approve', Pic = @username, UpdateBy = @username, UpdateDate = GETDATE()
		WHERE IdCl = @clid
	END

	-- kembalikan status cipl menjadi pickup kembali
	--EXEC sp_update_request_cipl @IdCipl = @ciplid, @Username = @username, @NewStatus = 'Reject', @Notes = '', @NewStep = ''
END
GO
