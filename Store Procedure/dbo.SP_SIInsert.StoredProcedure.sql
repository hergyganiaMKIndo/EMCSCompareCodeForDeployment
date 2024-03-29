USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_SIInsert]    Script Date: 10/03/2023 15:51:31 ******/
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
 @IsDelete BIT,    
 @ExportType NVARCHAR(10)    
)    
AS    
BEGIN    
DECLARE @LASTID bigint    
 IF @Id <= 0    
 BEGIN    
 INSERT INTO [dbo].[ShippingInstruction]    
           ([Description]    
     ,[IdCL]    
           ,[SpecialInstruction]  
		   ,[DocumentRequired]
     ,[PicBlAwb]    
     ,[CreateBy]    
           ,[CreateDate]    
           ,[UpdateBy]    
           ,[UpdateDate]    
           ,[IsDelete]    
     ,[ExportType]    
           )    
     VALUES    
           (@Description    
     ,@IdCL    
           ,@SpecialInstruction 
		   ,@DocumentRequired
     ,@PicBlAwb    
           ,@CreateBy    
           ,@CreateDate    
           ,@UpdateBy    
           ,@UpdateDate    
           ,@IsDelete    
     ,@ExportType)    
    
 SELECT @LASTID = CAST(SCOPE_IDENTITY() as bigint)    
 EXEC dbo.GenerateShippingInstructionNumber @LASTID, @CreateBy;    
  
 SELECT @LASTID = CAST(SCOPE_IDENTITY() as bigint)    
SELECT C.id as ID, C.SlNo as [NO], C.CreateDate as CREATEDATE FROM ShippingInstruction C WHERE C.id = @LASTID     
 END    
 ELSE     
 BEGIN    
 UPDATE [ShippingInstruction] SET  
 [Description] = @Description,  
 [SpecialInstruction] = @SpecialInstruction, 
 [DocumentRequired] = @DocumentRequired,
 PicBlAwb = @PicBlAwb,  
 [UpdateBy] = @UpdateBy,  
 [UpdateDate] = @UpdateDate  
 WHERE Id = @ID  
     SELECT C.id as ID, C.SlNo as [NO], C.CreateDate as CREATEDATE FROM ShippingInstruction C WHERE C.id = @ID      
 END    
END 

GO
