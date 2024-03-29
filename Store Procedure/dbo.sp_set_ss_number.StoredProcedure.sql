USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_set_ss_number]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_set_ss_number]
	@IdCl nvarchar(100)
AS
BEGIN
	DECLARE @Status nvarchar(100);
	declare @count int

	select @Status = [Status] from dbo.RequestCl where IdCl = @IdCl;
	select @count=count(*) from CargoItem where IdCargo = @IdCl

	IF ISNULL(@Status, '') = 'Submit' AND @count > 1
	BEGIN
		exec dbo.GenerateShippingSummaryNumber @IdCl, ''
	END
END
GO
