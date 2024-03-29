USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_update_container]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_update_container
CREATE PROCEDURE [dbo].[sp_insert_update_container] 
(
	@Id nvarchar(100),
	@CargoId nvarchar(100),
	@Number nvarchar(100),
	@Description nvarchar(200),
	@ContainerType nvarchar(200),
	@SealNumber nvarchar(200),
	@ActionBy nvarchar(100),
	@IsDelete bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	IF ISNULL(@Id, 0) = 0 
	BEGIN
	INSERT INTO [dbo].[CargoContainer]
           ([Number]
		   ,[CargoId]
           ,[Description]
		   ,[ContainerType]
		   ,[SealNumber]
           ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete])
     VALUES
           (@Number
		   ,@CargoId
           ,@Description
           ,@ContainerType
		   ,@SealNumber
           ,@ActionBy
           ,GETDATE()
           ,@ActionBy
           ,GETDATE()
           ,0)
	 SET @Id = SCOPE_IDENTITY();
	END
	ELSE 
	BEGIN
		UPDATE [dbo].[CargoContainer]
		SET [Number] = @Number
			,[Description] = @Description
			,[ContainerType] = @Description
			,[SealNumber] = @SealNumber
		    ,[UpdateBy] = @ActionBy
		    ,[UpdateDate] = GETDATE()
		    ,[IsDelete] = @IsDelete
		WHERE Id = @Id
	END

	SELECT CAST(@Id as bigint) as ID
END

GO
