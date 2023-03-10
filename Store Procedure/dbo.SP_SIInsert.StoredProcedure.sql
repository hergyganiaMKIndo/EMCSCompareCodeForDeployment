USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_SIInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_SIInsert]
(
	@ID BIGINT,
	@IdCL BIGINT,
	@Description NVARCHAR(MAX),
	@SpecialInstruction NVARCHAR(MAX),
	@DocumentRequired NVARCHAR(MAX),
	@PicBlAwb NVARCHAR(10),
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@IsDelete BIT
)
AS
BEGIN
	DECLARE @LASTID bigint
	INSERT INTO [dbo].[ShippingInstruction]
           ([Description]
		   ,[IdCL]
           ,[SpecialInstruction]
		   ,[PicBlAwb]
		   ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
           )
     VALUES
           (@Description
		   ,@IdCL
           ,@SpecialInstruction
		   ,@PicBlAwb
           ,@CreateBy
           ,@CreateDate
           ,@UpdateBy
           ,@UpdateDate
           ,@IsDelete)

	SELECT @LASTID = CAST(SCOPE_IDENTITY() as bigint)
	EXEC dbo.GenerateShippingInstructionNumber @LASTID, @CreateBy;

	DECLARE @CIPLNO nvarchar(20)
	SELECT C.id as ID, C.SlNo as [NO], C.CreateDate as CREATEDATE FROM ShippingInstruction C WHERE C.id = @LASTID
	
	--EXEC [sp_update_request_cl] @ID, @CreateBy, 'SUBMIT', ''
	
	

END
GO
