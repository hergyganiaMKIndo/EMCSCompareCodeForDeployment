USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_ShipmentDhlGetList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---- Exec SP_ShipmentDhlGetList '', 'ict.bpm'

CREATE PROCEDURE [dbo].[SP_ShipmentDhlGetList]
(    
	--@ConsigneeName NVARCHAR(200),
	@AwbNo NVARCHAR(200),
	@CreateBy NVARCHAR(200)
)
AS
BEGIN
	DECLARE @Sql nvarchar(max);
	DECLARE @WhereSql nvarchar(max) = '';
	DECLARE @RoleID bigint;
	DECLARE @area NVARCHAR(max);
	DECLARE @role NVARCHAR(max);
	DECLARE @usertype NVARCHAR(max);

	SELECT @area = U.Business_Area
		,@role = U.[Role],@usertype = UserType
	FROM dbo.fn_get_employee_internal_ckb() U
	WHERE U.AD_User = @CreateBy;

	
	if @role !=''
	BEGIN
		IF (@role !='EMCS IMEX' and @CreateBy !='xupj21fig' and @CreateBy !='ict.bpm' and @usertype !='ext-imex' )
		BEGIN
			SET @WhereSql = ' AND s.CreateBy='''+@CreateBy+''' ';
		END

		IF @AwbNo <> ''
		BEGIN
			--SET @WhereSql = ' AND s.IdentifyNumber LIKE ''%'+@AwbNo+'%'' OR p.CompanyName LIKE ''%'+@AwbNo+'%'' ';
			SET @WhereSql = ' AND A.AwbNo LIKE ''%'+@AwbNo+'%'' OR A.ConsigneeName LIKE ''%'+@AwbNo+'%'' OR A.StatusViewByUser LIKE ''%'+@AwbNo+'%'' ';
		END

		SET @sql = '
			SELECT *
			FROM
			(
				Select Distinct s.DhlShipmentId As Id, 
					ISNULL(s.IdentifyNumber, ''-'') AS AwbNo
					, p.CompanyName AS ConsigneeName
					, s.ShipTimestamp AS BookingDate
					, IIF(s.IdentifyNumber = '''' OR s.IdentifyNumber = null OR s.IdentifyNumber = ''-'', ''Draft'', IIF(tse.EventCode= ''OK'', ''Finish'',''On Progress'')) AS StatusViewByUser 
				FROM DHLShipment s
				JOIN DHLPerson p ON p.DHLShipmentID = s.DHLShipmentID AND p.IsDelete = 0 AND p.PersonType = ''RECIPIENT''
				LEFT JOIN DHLTrackingShipment ts ON ts.AWBNumber = s.IdentifyNumber
				LEFT JOIN DHLTrackingShipmentEvent tse 
					ON tse.DHLTrackingShipmentID = ts.DHLTrackingShipmentID AND EventType = ''SHIPMENT'' AND EventCode = ''OK''
				-------WHERE 1=1 '+@WhereSql+'
				AND s.IsDelete = 0
			)A
			WHERE 1=1 '+@WhereSql+'
			ORDER BY A.Id DESC';

		print (@sql);
		exec(@sql);	
	END
END
GO
