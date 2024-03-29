USE [EMCS_QA]
GO
/****** Object:  StoredProcedure [dbo].[SP_getTotalVolumeCargo]    Script Date: 10/03/2023 12:07:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_getTotalVolumeCargo] -- EXEC [sp_get_reference_no] 'PP', '', 'ReferenceNo'
(
	@idcl nvarchar(100)	
)
AS
BEGIN
-- select * from dbo.Reference
	SET NOCOUNT ON;
	DECLARE @SQL nvarchar(max);

	BEGIN 
		SET @SQL = ' select sum((length*width*height)/1000000) as volume_sistem  from CargoItem where isDelete = 0 AND IdCargo ='+ @idcl  +'';
	END
	

	EXECUTE(@SQL);
END


GO
