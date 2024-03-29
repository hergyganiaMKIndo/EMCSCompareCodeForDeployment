USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_cargo_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_get_cargo_list] -- [dbo].[sp_get_cargo_list] '', 0
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
	DECLARE @WhereSql nvarchar(max) = '';
	DECLARE @GroupId nvarchar(100);
	DECLARE @RoleID bigint;
	DECLARE @area NVARCHAR(max);
	DECLARE @role NVARCHAR(max) = '';
	SET @sort = 't0.'+@sort;

	select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;


	SELECT @area = U.Business_Area
		,@role = U.[Role]
	FROM dbo.fn_get_employee_internal_ckb() U
	WHERE U.AD_User = @Username;

	if @role !=''
	BEGIN


	IF (@role !='EMCS IMEX' and @Username !='ict.bpm')
	BEGIN
		SET @WhereSql = ' AND t0.CreateBy='''+@Username+''' ';
	END

	SET @sql = 'SELECT ';
	IF (@isTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total '
	END 
	ELSE
	BEGIN
		SET @sql += 't0.id
						, t0.ClNo
						, t0.Consignee Consignee
						, t0.NotifyParty NotifyParty
						, t0.ExportType ExportType
						, t0.Category
						, t0.IncoTerms
						, t0.StuffingDateStarted
						, t0.StuffingDateFinished
						, t0.VesselFlight
						, t0.ConnectingVesselFlight
						, t0.VoyageVesselFlight
						, t0.VoyageConnectingVessel
						, t0.PortOfLoading
						, t0.PortOfDestination
						, t0.SailingSchedule
						, t0.ArrivalDestination
						, t0.BookingNumber
						, t0.BookingDate
						, t0.Liner
						, t0.ETA
						, t0.ETD 
						, t0.Referrence
						, t0.CreateDate
						, t0.CreateBy
						, t0.UpdateDate
						, t0.UpdateBy
						, CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Employee_Name ELSE t3.FullName END PreparedBy
						, CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Email ELSE t3.Email END Email 
						, t4.Step
						, t5.[Status]
						, t9.StatusViewByUser [StatusViewByUser]        
						, STUFF((SELECT '', ''+ISNULL(tx1.EdoNo, ''-'')
							FROM dbo.CargoItem tx0
							JOIN dbo.Cipl tx1 on tx1.id = tx0.IdCipl
							WHERE tx0.IdCargo = tx0.Id
							GROUP BY tx1.EdoNo
							FOR XML PATH(''''),type).value(''.'',''nvarchar(max)''),1,1,'''') [RefEdo]
						, t8.SlNo SiNo
						, t8.[Description] SiDescription
						, t8.DocumentRequired SiDocumentRequired
						, t8.SpecialInstruction SiSpecialInstruction '
	END
	SET @sql +='FROM Cargo t0
				JOIN dbo.RequestCl as t1 on t1.IdCl = t0.Id
				JOIN PartsInformationSystem.dbo.[UserAccess] t3 on t3.UserID = t0.CreateBy
				LEFT JOIN employee t2 on t2.AD_User = t0.CreateBy
				LEFT JOIN dbo.FlowStep t4 on t4.Id = t1.IdStep
				LEFT JOIN dbo.FlowStatus t5 on t5.[Status] = t1.[Status] AND  t5.IdStep = t1.IdStep
				LEFT JOIN dbo.ShippingInstruction t8 on t8.IdCL = t0.Id
				LEFT JOIN dbo.fn_get_cl_request_list_all() t9 on t9.IdCl = t0.Id
				WHERE 1=1 AND t0.IsDelete = 0 '+@WhereSql+' AND (t0.ClNo like ''%'+@Search+'%'' OR t0.Consignee like ''%'+@Search+'%'')';

	IF @isTotal = 0 
	BEGIN
		SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	END 

	--select @sql;
	EXECUTE(@sql);
	END
END
GO
