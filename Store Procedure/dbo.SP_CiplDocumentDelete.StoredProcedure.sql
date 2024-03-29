USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_CiplDocumentDelete]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CiplDocumentDelete] (
	@id BIGINT
	,@UpdateBy NVARCHAR(50)
	,@UpdateDate DATETIME
	,@IsDelete BIT
	)
AS
BEGIN
	UPDATE dbo.CiplDocument
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE id = @id;	
END

GO
