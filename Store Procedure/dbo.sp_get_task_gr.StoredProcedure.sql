USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_task_gr]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_task_gr] -- [dbo].[sp_get_task_cipl]'xupj21wdn', 'IMEX'
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
    DECLARE @sql nvarchar(max); 
	DECLARE @GroupId nvarchar(100);
	DECLARE @UserType nvarchar(100);
	DECLARE @UserGroupNameExternal nvarchar(100) = '';
	DECLARE @UserBarea nvarchar(50) = '';

	SELECT @UserType = UserType, @UserGroupNameExternal = Cust_Group_No 
	from PartsInformationSystem.dbo.UserAccess 
	where UserID = @Username;
	
	select @UserBarea = Business_Area from dbo.fn_get_employee_internal_ckb() where AD_User = @Username;

	if @UserType <> 'internal' 
	BEGIN
		SET @GroupId = 'PPJK';
	END
	ELSE
	BEGIN
		select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;

		IF @GroupId = 'Import Export Operation' OR @GroupId = 'Import Export' OR @GroupId = 'Import Export Operation Mgmt.'
		BEGIN
			SET @GroupId = 'Import Export';
		END
	END

	IF (@GroupId = 'PPJK') 
	BEGIN
    SET @sql = CASE 
			   WHEN @isTotal = 1 
					THEN 'SELECT COUNT(*) as total' 
			   ELSE 'select tab0.* '
			   END + ' FROM fn_get_gr_request_list('''+@Username+''', '''+ISNULL(@GroupId, 0)+''') as tab0 WHERE Status NOT IN(''Draft'', ''Reject'')' +
			   CASE 
					WHEN @isTotal = 0 
					THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY' ELSE '' END;
	END
	ELSE 
	BEGIN
	SET @sql = CASE 
			   WHEN @isTotal = 1 
					THEN 'SELECT COUNT(*) as total' 
			   ELSE 'select tab0.* '
			   END + ' FROM fn_get_gr_request_list_all() as tab0 WHERE Status NOT IN(''Draft'', ''Reject'')' +
			   ' AND AssignmentType = ''AreaCipl'' AND NextAssignTo = '''+@Username+''''+
			   CASE 
					WHEN @isTotal = 0 
					THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY' ELSE '' END;
	END
	EXECUTE(@sql);
END


GO
