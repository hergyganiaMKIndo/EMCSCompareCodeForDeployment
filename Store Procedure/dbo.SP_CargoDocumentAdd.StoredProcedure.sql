USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_CargoDocumentAdd]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create	PROCEDURE [dbo].[SP_CargoDocumentAdd]
(
	@Id BIGINT,
	@IdCargo BIGINT,
	@DocumentDate datetime,
	@DocumentName NVARCHAR(MAX) = '',
	@Filename NVARCHAR(MAX) = '',
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@IsDelete BIT
)
AS
BEGIN
	IF @Id <= 0
	BEGIN
	INSERT INTO [dbo].[CargoDocument]
           ([IdCargo]
		   ,[DocumentDate]
		   ,[DocumentName]
		   ,[Filename]
           ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
           )
     VALUES
           (@IdCargo
			,@DocumentDate
			,@DocumentName
			,@Filename
			,@CreateBy
			,@CreateDate
			,@UpdateBy
			,@UpdateDate
			,@IsDelete
		   )

	END
	ELSE 
	BEGIN
	UPDATE dbo.CargoDocument
	SET [DocumentDate] = @DocumentDate
		   ,[DocumentName] = @DocumentName
	WHERE Id = @Id;
	END

END

GO
