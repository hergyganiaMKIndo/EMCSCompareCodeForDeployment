USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_gr_list_20200615]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_gr_list_20200615] -- [dbo].[sp_get_gr_list] 'xupj21ech', '', 0
(
	@Username nvarchar(100),
	@Search nvarchar(100),
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
	SET @sort = 't0.'+@sort;

	select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;

	SET @sql = 'SELECT ';
	IF (@isTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total '
	END 
	ELSE
	BEGIN
		SET @sql += 't0.Id
					, t0.GrNo
					, t0.PicName
					, t0.KtpNumber
					, t0.PhoneNumber
					, t0.SimNumber
					, t0.StnkNumber
					, t0.NopolNumber
					, t0.EstimationTimePickup
					, t0.Notes
					, t2.Step
					, t1.Status
					, t0.PickupPoint
					, t3.ViewByUser StatusViewByUser '
	END
	SET @sql +='FROM dbo.GoodsReceive as t0
			    INNER JOIN dbo.RequestGr as t1 on t1.IdGr = t0.Id
			    INNER JOIN dbo.FlowStep as t2 on t2.Id = t1.IdStep
				LEFT JOIN dbo.FlowStatus as t3 on t3.IdStep = t1.IdStep AND t3.Status = t1.Status
			    where 1=1 AND t0.IsDelete=0 AND (t0.GrNo like ''%'+@Search+'%'' OR t0.PicName like ''%'+@Search+'%'')';

	IF @isTotal = 0 
	BEGIN
		SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	END 

	--select @sql;
	EXECUTE(@sql);
END
GO
