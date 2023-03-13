USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_CargoDocumentUpdateFile]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[SP_CargoDocumentUpdateFile]
(
	@Id BIGINT,
	@Filename NVARCHAR(MAX) = '',
	@UpdateBy NVARCHAR(MAX) = ''
)
AS
BEGIN
 
	UPDATE dbo.CargoDocument
	SET [Filename] = @Filename,
	[UpdateBy] = @Updateby,
	[UpdateDate] = GETDATE()
	WHERE Id = @Id;

END

GO
