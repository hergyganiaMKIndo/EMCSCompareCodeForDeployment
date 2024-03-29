USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingShipmentCheckStatus]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[SP_DHLTrackingShipmentCheckStatus]
@DHLShipmentID bigint
, @UserId varchar(50)

As
Set Nocount on

Declare @TrackingStat varchar(20)
Set @TrackingStat = 'PROCESS'

IF EXISTS (Select top 1 * From DHLShipment Where DHLShipmentID = @DHLShipmentID)
BEGIN
	IF EXISTS (
		Select Top 1 *
		From DHLTrackingShipment a
		Left Join DHLTrackingShipmentEvent c on a.DHLTrackingShipmentID = c.DHLTrackingShipmentID and c.EventType = 'SHIPMENT'
		Where a.DHLShipmentID = @DHLShipmentID and c.EventCode = 'OK'
	)
	BEGIN
		Exec [SP_DHLUpdStatusCipl] @DHLShipmentID, 'FINISH', @UserId

		Set @TrackingStat = 'FINISH'
	END
END
ELSE
BEGIN
	Set @TrackingStat = 'NOTFOUND'
END


SELECT @TrackingStat 'TrackingStat'
GO
