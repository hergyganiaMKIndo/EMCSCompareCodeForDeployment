USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[ShipmentDhlReference]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ShipmentDhlReference]
(
	@Id bigint
)
AS
BEGIN
	DECLARE @reference NVARCHAR(max);
	
	SELECT @reference = Referrence from DHLShipment where IsDelete = 0 AND DHLShipmentID = @Id;

	SELECT Id, CiplNo From Cipl WHERE IsDelete = 0 AND id IN
	( select splitdata FROM fnSplitString(@reference,',') )

END
GO
