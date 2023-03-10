USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetDhlShipmentTrackingEvent]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_GetDhlShipmentTrackingEvent]
(    
	@AwbId BIGINT
)
AS
BEGIN

	SELECT EventDate
		, EventTime
		, EventDesc
		, SvcAreaDesc
	FROM DHLTrackingShipment ts
	JOIN DHLTrackingShipmentEvent tse ON ts.DHLTrackingShipmentID = tse.DHLTrackingShipmentID and tse.IsDelete = 0
	WHERE ts.IsDelete = 0 AND ts.DHLShipmentID = @AwbId
	AND EventType = 'SHIPMENT'
	ORDER BY EventDate, EventTime ASC
END
GO
