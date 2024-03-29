USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_task_npe_peb]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_task_npe_peb] -- [dbo].[sp_get_task_npe_peb]'xupj21wdn'        
(        
 @Username nvarchar(100),        
 @isTotal bit = 0,        
 @sort nvarchar(100) = 'Id',        
 @order nvarchar(100) = 'ASC',        
 @offset nvarchar(100) = '0',        
 @limit nvarchar(100) = '100'        
)        
AS        
BEGIN        
    SET NOCOUNT ON;        
    DECLARE @sql nvarchar(max);  --select * from dbo.vw_container        
 DECLARE @GroupId nvarchar(100);         
 DECLARE @PicNpe nvarchar(100);        
 DECLARE @UserType nvarchar(100);        
 DECLARE @UserGroupNameExternal nvarchar(100) = '';        
 DECLARE @Filter nvarchar(max);        
 DECLARE @FilterAdd nvarchar(max) = '';        
        
 SELECT @UserType = UserType, @UserGroupNameExternal = Cust_Group_No from PartsInformationSystem.dbo.UserAccess where UserID = @Username;        
        
 if @UserType <> 'internal'         
 BEGIN        
  SET @GroupId = 'CKB';        
  SET @PicNpe = 'CKB';        
  SET @Filter = 'AND ((PicBlAwb = '''+@PicNpe+''' AND IdNextStep != 10020 ) OR (IdStep != 30069 AND IdStep != 30071)) '        
  SET @FilterAdd = ' OR (IdStep = 30070 AND Status = ''Approve'')'        
 END        
 ELSE        
 BEGIN        
  select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;        
  if @GroupId = 'Import Export' OR @GroupId = 'Import Export Operation' OR @GroupId = 'Import Export Operation Mgmt.'        
  BEGIN        
   SET @GroupId = 'Import Export';        
   SET @PicNpe = 'IMEX';        
   SET @Filter = 'AND ((PicBlAwb = '''+@PicNpe+''' OR IdNextStep = 10020 OR IdNextStep = 30075 OR IdNextStep = 30076 OR IdNextStep = null) OR IdStep = 30069 OR IdStep = 30071 OR IdStep = 30074 OR IdStep = 30075 OR IdStep = 30076)'        
   --SET @FilterAdd = 'AND (IdStep = 30070 AND '        
  END        
 END        
        
    SET @sql = CASE         
      WHEN @isTotal = 1         
     THEN 'SELECT COUNT(*) as total'         
      ELSE 'select tab0.* '        
      --END + ' FROM fn_get_cl_request_list('''+@Username+''', '''+ISNULL(@GroupId, 0)+''', '''+@PicNpe+''') as tab0 WHERE IdStep IN (10017,10019,10020) AND (PicBlAwb = '''+@PicNpe+''' OR IdNextStep =10020) AND Status IN(''Submit'',''Revise'')' +        
      --END + ' FROM fn_get_cl_request_list('''+@Username+''', '''+ISNULL(@GroupId, 0)+''', '''+@PicNpe+''') as tab0 WHERE IdStep IN (10017,10019,10020) '+ @Filter +' AND Status IN(''Submit'',''Revise'')' +        
      END + ' FROM fn_get_CL_request_list('''+@Username+''', '''+ISNULL(@GroupId, 0)+''', '''+@PicNpe+''') as tab0 WHERE IdStep IN (10017,10019,10020, 30069,30070, 30071, 30072,30074,30075,30076) '+ @Filter +' AND Status IN (''Submit'',''Revise'',''Ca
ncel  
    
Request'',''CancelApproval'',''Cancel'') Or IsCancelled IN (0,1,2,null)'+ @FilterAdd +'' +      
      CASE         
     WHEN @isTotal = 0         
     THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY' ELSE '' END;        
        
 --select @sql;         
 PRINT(@sql);        
 EXECUTE(@sql);        
END  
GO
