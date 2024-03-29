USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetDhlShipmentPackagesList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetDhlShipmentPackagesList]
(    
	@AwbId BIGINT
)
AS
BEGIN
	SELECT 
		ROW_NUMBER() OVER (Order by t0.DhlPackageId) AS Number
		--,DHLPackageID AS Id
		, t0.CiplNumber AS CiplNumber
		, CaseNumber
		, 1 AS Qty
		--, CAST(ROUND(Length, 0) AS BIGINT) AS [Length]
		--, CAST(ROUND(Width, 0) AS BIGINT) AS Width
		--, CAST(ROUND(Height, 0) AS BIGINT) AS Height
		--, (Length*Width*Height)/1000000 AS Volume
		--, CAST(ROUND(Weight, 0) AS BIGINT) AS [Weight]
		--, CAST(ROUND(Insured, 0) AS BIGINT) AS InsuredValue
		, Length AS [Length]
		, Width AS Width
		, Height AS Height
		, (Length*Width*Height)/1000000 AS Volume
		, Weight AS [Weight]
		, Insured AS InsuredValue
		, CustReferences AS CustomerReferences
	FROM DHLPackage t0 
	--JOIN cipl t1 ON t0.CiplNumber = t1.id AND t1.IsDelete = 0
	WHERE DHLShipmentID = @AwbId AND t0.IsDelete = 0;
END
GO
