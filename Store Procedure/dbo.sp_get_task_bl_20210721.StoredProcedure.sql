USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_task_bl_20210721]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_task_bl_20210721] -- [dbo].[sp_get_task_bl]'xupj21wdn'
(
	@Username nvarchar(100),
	@isTotal bit = 0,
	@sort nvarchar(100) = 'Id',
	@order nvarchar(100) = 'ASC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @sql nvarchar(max);  --select * from dbo.vw_container
	DECLARE @PicNpe nvarchar(100);
	DECLARE @GroupId nvarchar(100);
	DECLARE @UserType nvarchar(100);
	DECLARE @UserGroupNameExternal nvarchar(100) = '';
	DECLARE @Filter nvarchar(max);

	SELECT @UserType = UserType, @UserGroupNameExternal = Cust_Group_No from PartsInformationSystem.dbo.UserAccess where UserID = @Username;

	if @UserType <> 'internal'  
	BEGIN
		SET @GroupId = 'CKB';
		SET @PicNpe = 'CKB';
		SET @Filter = 'AND (PicBlAwb = '''+@PicNpe+''' AND (IdNextStep != 30063 AND IdNextStep != 10022))'
	END
	ELSE
	BEGIN
		select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;
		if @GroupId = 'Import Export' OR @GroupId = 'Import Export Operation'
		BEGIN
			SET @GroupId = 'Import Export';
			SET @PicNpe = 'IMEX';
			SET @Filter = 'AND ((PicBlAwb = '''+@PicNpe+''' OR IdNextStep = 10022) AND IdNextStep != 30063)'
		END
	END

    SET @sql = CASE 
			   WHEN @isTotal = 1 
					THEN 'SELECT COUNT(*) as total' 
			   ELSE 'select tab0.* '
			   END + ' FROM fn_get_cl_request_list('''+@Username+''', '''+ISNULL(@GroupId, 0)+''', '''+@PicNpe+''') as tab0 WHERE IdStep IN (''10020'',''10021'',''10022'') '+ @Filter +' AND Status IN(''Approve'',''Submit'',''Revise'')'
 +
			   CASE 
					WHEN @isTotal = 0 
					THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY' ELSE '' END;

	--select @sql;
	EXECUTE(@sql);
END





GO
