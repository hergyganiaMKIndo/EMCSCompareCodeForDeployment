USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_CiplChangeHistoryGetById]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CiplChangeHistoryGetById] -- exec [dbo].[SP_CiplChangeHistoryGetById] '33433','CIPL',0,'CreateDate','asc','0','10'            
(            
 @id NVARCHAR(10),           
 @formtype NVARCHAR(100),           
 @IsTotal bit = 0,            
 @sort nvarchar(100) = 'CreateDate',            
 @order nvarchar(100) = 'DESC',            
 @offset nvarchar(100) = '0',            
 @limit nvarchar(100) = '10'            
)             
AS            
BEGIN            
 DECLARE @sql nvarchar(max);              
          
            
 SET @sql = 'SELECT ';            
 SET @sort = 'RF.'+@sort;            
            
 IF (@IsTotal <> 0)            
 BEGIN            
  SET @sql += 'count(*) total'            
 END             
 ELSE            
 BEGIN            
 SET @sql += 'R.FieldName,          
R.BeforeValue,          
R.AfterValue,      
RF.ID,      
RF.FormNo,        
RF.CreateBy,          
RF.CreateDate,          
RF.Reason'            
 END            
 SET @sql +=' FROM RequestForChange RF          
 INNER JOIN RFCItem R ON R.RFCID = RF.ID            
     WHERE  R.RFCID = '''+@id+ '''';            
 IF @isTotal = 0             
 BEGIN            
 SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';            
 END             
            
 --select @sql;            
 EXECUTE(@sql);            
 --print(@sql);            
END
GO
