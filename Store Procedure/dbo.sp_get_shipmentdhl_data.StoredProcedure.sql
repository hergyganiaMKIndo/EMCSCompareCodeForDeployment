USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_shipmentdhl_data]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_shipmentdhl_data]
(
	@Id bigint
)
AS
BEGIN
	--DECLARE @Id bigint = 2;
	SELECT DHLShipmentID AS Id
	, PaymentInfo
	, Account
	, Currency
	, PackagesCount
	, ShipTimestamp
	, PickupLocation
	, PickupLocTime
	, SpcPickupInstruction
	, CommoditiesDesc
	, IdentifyNumber
	, IIF(ConfirmationNumber = '', '-',ISNULL(ConfirmationNumber, '-')) AS ConfirmationNumber
	, PackagesQty
	, PackagesPrice
	, m.AccountNumber + ' - ' + m.AccountName AS AccountText
	FROM DHLShipment s
	LEFT JOIN MasterAccountDhl m ON s.Account = m.AccountNumber
	WHERE 1=1 AND s.isdelete = 0 
	AND DHLShipmentID = @Id;
END
GO
