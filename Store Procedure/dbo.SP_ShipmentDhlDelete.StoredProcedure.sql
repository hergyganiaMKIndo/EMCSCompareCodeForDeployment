USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_ShipmentDhlDelete]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ShipmentDhlDelete]
(    
	@DHLShipmentID BIGINT
)
AS
BEGIN
	DECLARE @TrackingShipmentId INT;

	SELECT @TrackingShipmentId = DHLTrackingShipmentID FROM DHLTrackingShipment where DHLShipmentID =  @DHLShipmentID;

	update DHLShipment set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLPackage set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLPerson set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLRate set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLAttachment set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLTrackingNumber set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLTrackingShipment set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLTrackingShipmentEvent set IsDelete = 1 where DHLTrackingShipmentID = @TrackingShipmentId
	update DHLTrackingShipmentPiece set IsDelete = 1 where DHLTrackingShipmentID = @TrackingShipmentId

END

GO
