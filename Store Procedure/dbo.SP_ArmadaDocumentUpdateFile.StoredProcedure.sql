USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_ArmadaDocumentUpdateFile]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ArmadaDocumentUpdateFile]
(
	@Id BIGINT,
	@Filename NVARCHAR(MAX) = ''
)
AS
BEGIN
 
	UPDATE dbo.ShippingFleet
	SET [FileName] = @Filename	
	WHERE Id = @Id;

END

GO
