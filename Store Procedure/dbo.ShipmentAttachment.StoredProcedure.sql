USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[ShipmentAttachment]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ShipmentAttachment]
(
	@Id bigint
)
AS
BEGIN
	IF EXISTS (select DHLAttachmentID AS Id, GraphicImage from DHLAttachment Where DHLShipmentID = @Id) 
	BEGIN
	   select DHLAttachmentID AS Id, GraphicImage from DHLAttachment Where DHLShipmentID = @Id
	END
	ELSE
	BEGIN
		SELECT 1, '-'
	END
	
END
GO
