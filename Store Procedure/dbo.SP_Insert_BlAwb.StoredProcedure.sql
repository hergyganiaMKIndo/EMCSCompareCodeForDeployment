USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_Insert_BlAwb]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_Insert_BlAwb]
(
	@Id BIGINT,
	@Number NVARCHAR(100),
	@MasterBlDate datetime,
	@HouseBlNumber NVARCHAR(200),
	@HouseBlDate datetime,
	@Description NVARCHAR(50),
	@FileName NVARCHAR(max),
	@Publisher NVARCHAR(50),
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@IsDelete BIT,
	@IdCl BIGINT,
	@Status NVARCHAR(50)
)
AS
BEGIN
	DECLARE @LASTID bigint
	IF @Id <= 0
	BEGIN
	INSERT INTO [dbo].[BlAwb]
           ([Number]
		   ,[MasterBlDate]
		   ,[HouseBlNumber]
		   ,[HouseBlDate]
           ,[Description]
		   ,[FileName]
		   ,[Publisher]
		   ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
		   ,[IdCl]
           )
     VALUES
           (@Number
		   ,@MasterBlDate
		   ,@HouseBlNumber
		   ,@HouseBlDate
           ,@Description
		   ,@FileName
		   ,@Publisher
           ,@CreateBy
           ,@CreateDate
           ,@UpdateBy
           ,@UpdateDate
           ,@IsDelete
		   ,@IdCl)

	SELECT @LASTID = CAST(SCOPE_IDENTITY() as bigint)
	SELECT C.Id as ID, CONVERT(nvarchar(5), C.IdCl) as [NO], C.CreateDate as CREATEDATE FROM BlAwb C WHERE C.id = @LASTID
	END
	ELSE 
	BEGIN
	UPDATE [dbo].[BlAwb]
		SET [Number] = @Number 
		   ,[MasterBlDate] = @MasterBlDate
		   ,[HouseBlNumber] = @HouseBlNumber
		   ,[HouseBlDate] = @HouseBlDate
           ,[Description] = @Description
		   ,[FileName] = @FileName
		   ,[Publisher] = @Publisher
		   ,[CreateBy] = @CreateBy
           ,[CreateDate] = @CreateDate
           ,[UpdateBy] = @UpdateBy
           ,[UpdateDate] = @UpdateDate
		   WHERE Id = @Id
		   SELECT C.Id as ID, CONVERT(nvarchar(5), C.IdCl) as [NO], C.CreateDate as CREATEDATE FROM BlAwb C WHERE C.id = @Id
	END
	
	IF(@Status <> 'Draft') 
	BEGIN
	EXEC [sp_update_request_cl] @IdCl, @CreateBy, @Status, ''
	END

	
	
	

END
GO
