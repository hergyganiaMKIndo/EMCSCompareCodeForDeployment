USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Export_Today2]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_Export_Today2] '2020-01-01', '2020-12-12', '0A07'
--EXEC [dbo].[SP_Dashboard_Export_Today2] '2020-01-01', '2020-12-12', 'XUPJ21PTR'
--EXEC [dbo].[SP_Dashboard_Export_Today2] '2020-01-01', '2020-12-12', ''
CREATE PROCEDURE [dbo].[SP_Dashboard_Export_Today2] (
	@date1 NVARCHAR(100)
	,@date2 NVARCHAR(100)
	,@user NVARCHAR(50) 
	)
AS
BEGIN
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
		SET @and = 'AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
	END
	ELSE
	BEGIN
		IF (
				@area = ''
				OR @area IS NULL
				)
		BEGIN
			SET @and = 'AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
		END
		ELSE
		BEGIN
			SET @and = 'AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
		END
	END

	--IF (@area IS NULL)
	--BEGIN
	--	IF (@user = '' OR @user IS NULL)
	--	BEGIN
	--		SET @and = 'AND C.PickUpArea IS NOT NULL AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
	--	END
	--	ELSE
	--	BEGIN
	--		SET @and = 'AND RIGHT(C.PickUpArea, 3) = RIGHT(''' + @user + ''',3) AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
	--	END 
	--END
	--ELSE
	--BEGIN
	--	SET @and = 'AND RIGHT(C.PickUpArea, 3) = RIGHT(''' + @area + ''',3) AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
	--END

	SET @sql = 'SELECT ISNULL(Count(a1.Branch),0) Branch, 
       ISNULL(a2.Shipment,0) Shipment, 
       ISNULL(a3.Cipl,0) Cipl, 
       ISNULL(a4.Port,0) LoadPort
FROM   ( 
       -- Total Branch yang request CIPL current date 
       SELECT  (select COUNT(tab0.PlantName) 
               FROM   fn_get_cipl_businessarea_list(C.Area) as tab0 
               WHERE  tab0.PlantCode = C.Area) Branch, 
              ''1''                              ID 
        FROM   CIPL C 
               INNER JOIN CargoCipl CC 
                       ON CC.IdCipl = C.id 
               INNER JOIN RequestCl RCL 
                       ON RCL.IdCl = CC.IdCargo 
			   INNER JOIN Cargo Ca ON 
							Ca.Id = CC.IdCargo
				LEFT JOIN NpePeb N on RCL.IdCl = N.IdCl
        WHERE  RCL.IdStep IN (''10019'',''10020'',''10021'',''10022'')  
               AND RCL.Status IN (''Submit'', ''Approve'',''Revise'')  
			   AND C.CreateBy <>''System''
			  AND N.NpeNumber is not null  
               ' + @and + 
		') a1 
       -- Total Shipment (based on PEB) YTD Current Year. 
       RIGHT JOIN(SELECT Count(RCL.IdCl) Shipment, 
                        ''1''             ID 
                 FROM   CIPL C 
                        INNER JOIN CargoCipl CC 
                                ON CC.IdCipl = C.id 
                        INNER JOIN RequestCl RCL 
                                ON RCL.IdCl = CC.IdCargo 
						INNER JOIN Cargo Ca ON 
							Ca.Id = CC.IdCargo
						LEFT JOIN NpePeb N on RCL.IdCl = N.IdCl
                 WHERE  RCL.IdStep IN (''10019'',''10020'',''10021'',''10022'') 
						AND RCL.Status IN (''Submit'', ''Approve'',''Revise'') 
						AND N.NpeNumber is not null 
						AND C.CreateBy <>''System''
						AND N.NpeNumber is not null  
                        ' + @and + 
		') a2 
              ON a2.ID = a1.ID 
       -- Total CIPL fully approved. YTD current Year. 
       RIGHT JOIN(SELECT Count(RCL.IdCl) Cipl, 
                        ''1''             ID 
                 FROM   CIPL C 
                        INNER JOIN CargoCipl CC 
                                ON CC.IdCipl = C.id 
                        INNER JOIN RequestCl RCL 
                                ON RCL.IdCl = CC.IdCargo 
						LEFT JOIN NpePeb N on RCL.IdCl = N.IdCl
                 WHERE  RCL.IdStep IN (''12'',''10017'',''20033'',''10032'') 
                        AND RCL.Status IN (''Approve'',''Submit'') 
						AND N.NpeNumber is not null 
						 AND C.CreateBy <>''System''
                        ' + @and + 
		') a3 
              ON a3.ID = a1.ID 
       -- Total pelabuhan yang melakukan export (berdasarkan tanggal ATD) current date 
       RIGHT JOIN(SELECT Count(CA.PortOfLoading) Port, 
                        ''1''                     ID 
                 FROM   CIPL C 
                        INNER JOIN CargoCipl CC 
                                ON CC.IdCipl = C.id 
                        INNER JOIN Cargo CA 
                                ON CA.Id = CC.IdCargo 
                        INNER JOIN RequestCl RCL 
                                ON RCL.IdCl = CC.IdCargo 
						LEFT JOIN NpePeb N on CA.Id = N.IdCl
                 WHERE  RCL.IdStep = ''10017'' 
                        AND RCL.Status = ''Submit'' 
						AND N.NpeNumber is not null 
						 AND C.CreateBy <>''System''
                        ' + @and + ') a4 
              ON a4.ID = a1.ID 
GROUP  BY a2.Shipment, 
          a3.Cipl, 
          a4.Port';

	EXECUTE (@sql);
END
GO
