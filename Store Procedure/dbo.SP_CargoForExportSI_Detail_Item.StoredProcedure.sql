USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_CargoForExportSI_Detail_Item]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[SP_CargoForExportSI_Detail_Item] -- sp_get_cargo_data 1
(
	@CargoID bigint
)
AS
BEGIN
	SELECT TOP 5 t1.name AS Name
	FROM CargoItem t0
	JOIN ciplitem t1 on t0.idciplitem = t1.id
	WHERE 1=1 AND t0.idcargo = @CargoID
	GROUP BY t1.name 
END
GO
