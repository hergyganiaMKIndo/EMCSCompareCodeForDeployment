USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetDhlRateItemList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetDhlRateItemList]
(    
	@AwbId BIGINT
)
AS
BEGIN
	SELECT DHLRateID AS Id 
		, ServiceType
		, ISNULL(ChargeCode, '-') AS ChargeCode
		, ChargeType
		, ChargeAmount
	FROM DHLRate
	WHERE DHLShipmentID = @AwbId AND IsDelete = 0;
END
GO
