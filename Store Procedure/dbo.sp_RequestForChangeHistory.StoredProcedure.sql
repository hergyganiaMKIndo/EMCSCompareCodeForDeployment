USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_RequestForChangeHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_RequestForChangeHistory] --[dbo].[sp_RequestForChangeHistory] 0,'CreateDate','DESC' ,'1','10','xupj21dxd'                      
(                          
                        
 @IsTotal bit = 0,                          
 @sort nvarchar(100) = 'CreateDate',                          
 @order nvarchar(100) = 'DESC',                          
 @offset nvarchar(100) = '0',                          
 @limit nvarchar(100) = '10',          
 @Approver nvarchar(100) = 'xupj21dxd'        
)                           
AS                              
BEGIN                          
 DECLARE @sql nvarchar(max);                            
       DECLARE @WhereSql nvarchar(max) = '';          
    SET @WhereSql = '  RF.Approver='''+@Approver+''' ';          
                          
 SET @sql = 'SELECT ';                          
 SET @sort = 'RF.'+@sort;                          
                          
 IF (@IsTotal <> 0)                          
 BEGIN                          
  SET @sql += 'count(*) total'            
 END                           
 ELSE                          
 BEGIN                          
 SET @sql += '                   
RF.ID,                 
RF.FormId,               
RF.RFCNumber,              
RF.FormType,              
RF.FormNo,                      
RF.CreateBy,                        
RF.CreateDate,                        
RF.Reason,            
RF.[Status]'                          
 END                          
 SET @sql +=' FROM RequestForChange RF WHERE RF.Status Not In (1,2) And '+@WhereSql+' ';                           
 IF @isTotal = 0                           
 BEGIN                          
 SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';                          
 END                           
                          
 --select @sql;                          
 EXECUTE(@sql);                          
 print(@sql);                          
END 


GO
