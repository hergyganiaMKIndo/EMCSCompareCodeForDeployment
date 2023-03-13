USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_cargo_document_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE PROCEDURE [dbo].[sp_get_cargo_document_list]   
(  
 @IdCargo NVARCHAR(10),  
 @IsTotal bit = 0,  
 @sort nvarchar(100) = 'Id',  
 @order nvarchar(100) = 'ASC',  
 @offset nvarchar(100) = '0',  
 @limit nvarchar(100) = '10'  
)   
AS  
BEGIN  
 DECLARE @sql nvarchar(max);    
 SET @sql = 'SELECT ';  
 SET @sort = 't0.'+@sort;  
  
 IF (@IsTotal <> 0)  
 BEGIN  
  SET @sql += 'count(*) total'  
 END   
 ELSE  
 BEGIN  
  SET @sql += 't0.Id  
      , t0.IdCargo  
      , t0.DocumentDate  
      , t0.DocumentName  
      , t0.[Filename]  
      , t0.CreateBy  
      , t0.CreateDate  
      , t0.UpdateBy  
      , t0.UpdateDate  
      , t0.IsDelete  
      , '''' as PIC '  
 END  
 SET @sql +=' FROM CargoDocument t0   
  WHERE  IsDelete = 0 AND t0.IdCargo = '+@IdCargo;  
 EXECUTE(@sql);  
 --select @sql;  
END  

GO
