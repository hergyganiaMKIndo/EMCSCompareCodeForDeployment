USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_GrDocumentDelete]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[SP_GrDocumentDelete] (
	@id BIGINT
	,@UpdateBy NVARCHAR(50)
	,@UpdateDate DATETIME
	,@IsDelete BIT
	)
AS
BEGIN
	UPDATE dbo.GoodsReceiveDocument
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE Id = @id;	
END

GO
