USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetDhlShipmentItemList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetDhlShipmentItemList]
(    
	@AwbId BIGINT
)
AS
BEGIN
	SELECT DHLPackageID AS Id
		, t1.CiplNo AS CiplNo
		, CaseNumber
		, 1 AS Qty
		, Length
		, Width
		, Height
		, (Length*Width*Height)/1000000 AS Volume
		, Weight
		, Insured
		, CustReferences 
	FROM DHLPackage t0 
	LEFT JOIN cipl t1 ON t0.CiplNumber = t1.id AND t1.IsDelete = 0
	WHERE DHLShipmentID = @AwbId AND t0.IsDelete = 0;
END


GO
