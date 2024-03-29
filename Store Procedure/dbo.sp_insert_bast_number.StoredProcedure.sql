USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_bast_number]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_insert_bast_number]
AS 
INSERT INTO [EMCS_Dev].[dbo].[BastNumber] (BastNo, ReferenceNo) SELECT J_3GBELNRI, c.ReferenceNo
	FROM [EDW_PROD].[EDW_STG_SAP_ECC_DAILY].[dbo].J_3GBELK as sap
		INNER JOIN  (
			SELECT ciplitem.ReferenceNo, SUBSTRING(ciplitem.ReferenceNo, PATINDEX('%[^0]%', ciplitem.ReferenceNo+'.'), LEN(ciplitem.ReferenceNo)) as Ref
			FROM EMCS_Dev.dbo.CiplItem ciplitem
				INNER JOIN EMCS_Dev.dbo.cipl cipl ON cipl.id = ciplitem.IdCipl
			WHERE ciplitem.ReferenceNo != '' AND cipl.Category like '%CATERPILLAR USED EQUIPMENT%'
		) c ON usr02 = Ref
	WHERE NOT EXISTS (SELECT 1 FROM [EMCS_Dev].[dbo].[BastNumber] bast WHERE bast.BastNo = sap.J_3GBELNRI)
GO
