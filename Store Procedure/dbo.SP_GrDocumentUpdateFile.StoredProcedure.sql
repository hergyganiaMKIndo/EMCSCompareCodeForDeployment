USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_GrDocumentUpdateFile]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[SP_GrDocumentUpdateFile]
(
	@Id BIGINT,
	@Filename NVARCHAR(MAX) = '',
	@UpdateBy NVARCHAR(MAX) = ''
)
AS
BEGIN
 
	UPDATE dbo.GoodsReceiveDocument
	SET [Filename] = @Filename,
	[UpdateBy] = @Updateby,
	[UpdateDate] = GETDATE()
	WHERE Id = @Id;

END
GO
