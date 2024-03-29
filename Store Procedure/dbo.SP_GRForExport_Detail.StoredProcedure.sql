USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_GRForExport_Detail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[SP_GRForExport_Detail]
	@GRID bigint
AS
BEGIN
SELECT CAST(ROW_NUMBER() OVER (
			ORDER BY GoodsName
		)as varchar(max)) RowNo,
		GoodsName,
		DoNo,
		DaNo
FROM(
	SELECT DISTINCT
		
		t2.Name as GoodsName,
		t0.DoNo,
		''''+t0.DaNo as DaNo
	FROM GoodsReceiveItem t0
	JOIN Cipl t1 on t1.EdoNo = t0.DoNo
	JOIN CiplItem t2 on t2.IdCipl = t1.id
	WHERE t0.IdGr = @GRID
)t0
END
GO
