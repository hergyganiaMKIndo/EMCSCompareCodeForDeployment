USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_Update_BlAwb]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE [dbo].[SP_Update_BlAwb]    
(    
 @Id BIGINT,    
 @Number NVARCHAR(100),    
 @MasterBlDate datetime,    
 @HouseBlNumber NVARCHAR(200),    
 @HouseBlDate datetime,    
 @Description NVARCHAR(50),    
 @FileName NVARCHAR(max),    
 @Publisher NVARCHAR(50),    
 @UpdateBy NVARCHAR(50),    
 @UpdateDate datetime,    
 @IdCl BIGINT    
)    
AS    
BEGIN    
 DECLARE @LASTID bigint    
 UPDATE [dbo].[BlAwb]    
  SET [Number] = @Number     
     ,[MasterBlDate] = @MasterBlDate    
     ,[HouseBlNumber] = @HouseBlNumber    
     ,[HouseBlDate] = @HouseBlDate    
     ,[Description] = @Description    
     ,[FileName] = @FileName    
     ,[Publisher] = @Publisher    
  ,[UpdateBy] = @UpdateBy    
  ,[UpdateDate] = @UpdateDate    
     WHERE Id = @Id    
     SELECT C.Id as ID, CONVERT(nvarchar(5), C.IdCl) as [NO], C.CreateDate as CREATEDATE FROM BlAwb C WHERE C.id = @Id      
    
END 
GO
