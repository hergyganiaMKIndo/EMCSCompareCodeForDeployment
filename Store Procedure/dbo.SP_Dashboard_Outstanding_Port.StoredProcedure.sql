USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Outstanding_Port]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_Outstanding_Port] '1', '10', ''
CREATE PROCEDURE [dbo].[SP_Dashboard_Outstanding_Port] (
	@Page NVARCHAR(10)
	,@Row NVARCHAR(10)
	,@user NVARCHAR(50)
	)
AS
BEGIN
	DECLARE @RowspPage AS NVARCHAR(10)
	DECLARE @sql NVARCHAR(max);
	DECLARE @and NVARCHAR(max);
	DECLARE @area NVARCHAR(max);
	DECLARE @role NVARCHAR(max);

	SELECT @area = U.Business_Area
		,@role = U.[Role]
	FROM dbo.fn_get_employee_internal_ckb() U
	WHERE U.AD_User = @user;

	IF (
			@role = 'EMCS Warehouse'
			OR @role = 'EMCS IMEX'
			OR @role = 'EMCS PPJK'
			)
	BEGIN
		SET @and = 'AND C.PickUpArea IS NOT NULL';
	END
	ELSE
	BEGIN
		IF (
				@area = ''
				OR @area IS NULL
				)
		BEGIN
			SET @and = 'AND RIGHT(C.PickUpArea, 3) = RIGHT(''' + @user + ''',3)';
		END
		ELSE
		BEGIN
			SET @and = 'AND RIGHT(C.PickUpArea, 3) = RIGHT(''' + @area + ''',3)';
		END
	END

	SET @RowspPage = @Row
	SET @sql = 'SELECT Distinct  CAST(NP.AjuNumber as NVARCHAR) AS No, 
         (select tab0.PlantName FROM fn_get_cipl_businessarea_list(C.Area) as tab0  WHERE tab0.PlantCode = C.Area) Branch,
               CO.PortOfLoading, 
               CO.PortOfDestination, 
               CO.SailingSchedule ETD, 
               CO.ArrivalDestination ETA,
         FS.ViewByUser
    FROM       CIPL C 
    INNER JOIN CargoCipl CC 
    ON          CC.IdCipl = C.id
    INNER JOIN Cargo CO 
    ON         CO.Id = CC.IdCargo
    INNER JOIN RequestCl RCL 
    ON         RCL.IdCl = CC.IdCargo
    INNER JOIN FlowStatus FS 
    ON         FS.IdStep = RCL.IdStep
    AND        FS.Status = RCL.Status 
	LEFT JOIN NpePeb NP
	ON       NP.IdCl = RCL.IdCl
	WHERE    RCL.IdStep IN (10019,10020,30041,30042,10021,10022)
	AND      RCL.Status IN (''Draft'',''Submit'',''Approve'',''Revise'')
	AND YEAR(RCL.CreateDate) = YEAR(GETDATE())
	AND NP.NpeNumber is not null
	
	' + @and + '
	ORDER BY 1,2 OFFSET(('+@Page+' - 1) * '+@RowspPage+') ROWS

	FETCH NEXT '+@RowspPage+' ROWS ONLY';
	
	--AND NP.NpeNumber is null';
	
	--print @sql;
	EXECUTE (@sql);
END
GO
