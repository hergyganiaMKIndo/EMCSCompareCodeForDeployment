/****** Object:  StoredProcedure [dbo].[SP_ActivityReport_TotalExport]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_ActivityReport_TotalExport] --'2022'    
    @year INT    
AS    
BEGIN    
    DECLARE @invoice TABLE (Month INT, COUNT INT, peb INT)    
    INSERT INTO @invoice    
    SELECT     
		Month(CreatedDate),     
		COUNT(DISTINCT IdCipl),     
		COUNT(DISTINCT NpeNumber)     
	FROM	(SELECT     
				ci.IdCargo,     
				ci.Id AS IdCargoItem,     
				cpi.Id AS IdCiplItem,     
				cp.id AS IdCipl,     
				peb.NpeNumber,     
				CONVERT(VARCHAR(10), rc.CreateDate, 120) AS CreatedDate  
			FROM fn_get_cl_request_list_all_report() rc    
				LEFT JOIN NpePeb peb ON rc.IdCl = peb.IdCl    
				LEFT JOIN CargoItem ci ON rc.IdCl = ci.IdCargo    
				LEFT JOIN CiplItem cpi ON ci.IdCiplItem = cpi.Id    
				LEFT JOIN Cipl cp ON cpi.IdCipl = cp.id      
			WHERE (YEAR(rc.CreateDate) = @year) 
				--OR rc.IdStep = 10019
				--AND ((rc.IdStep = 10020 AND rc.Status = 'Approve')
				--OR rc.IdStep = 10021   
				--OR (rc.IdStep = 10022 AND (rc.Status = 'Submit' OR rc.Status = 'Approve'))) 
				AND peb.NpeNumber IS NOT NULL  
				AND cp.IsDelete = 0)  
	DATA GROUP BY Month(CreatedDate)    
    
    DECLARE @outstanding TABLE (month int, count int)    
    INSERT INTO @outstanding    
    SELECT   
		  Month(CreatedDate),   
		  COUNT(DISTINCT IdCipl)   
	FROM (
	SELECT	rc.IdCipl,
			CASE WHEN MONTH(rc.CreateDate) <> MONTH(rc.UpdateDate) OR MONTH(rc.CreateDate) < MONTH(GETDATE()) THEN CONVERT(VARCHAR(10), rc.CreateDate, 120) ELSE CONVERT(VARCHAR(10), rc.UpdateDate, 120) END AS CreatedDate,  
			CONVERT(VARCHAR(10), rc.UpdateDate, 120) AS UpdateDate    
	FROM	[fn_ActivityReport_TotalExport_Outstanding]() rc
	WHERE	YEAR(rc.CreateDate) = @year
		  --prev version
		 -- FROM (SELECT     
			--  ci.IdCargo,     
			--  ci.Id AS IdCargoItem,     
			--  cpi.Id AS IdCiplItem,     
			--  cp.id AS IdCipl,  
			--  rc.IdCl,   
			--  rc.Status,  
			--  CONVERT(VARCHAR(10), rc.CreateDate, 120) AS CreatedDate,  
			--  CONVERT(VARCHAR(10), rc.UpdateDate, 120) AS UpdateDate    
			--  , fs.Step  
			--  , fs.Id    
			--FROM fn_get_cl_request_list_all_report() rc    
			--  --RequestCl rc     
			--  LEFT JOIN NpePeb peb ON rc.IdCl = peb.IdCl    
			--  INNER JOIN FlowStep fs ON rc.IdStep = fs.Id    
			--  LEFT JOIN CargoItem ci ON rc.IdCl = ci.IdCargo    
			--  LEFT JOIN CiplItem cpi ON ci.IdCiplItem = cpi.Id    
			--  LEFT JOIN Cipl cp ON cpi.IdCipl = cp.id    
			--  LEFT JOIN CiplHistory chis ON chis.IdCipl = cp.id   
			--WHERE (YEAR(rc.CreateDate) = @year OR @year = 0)  
			--  AND ((rc.IdStep = 10020 AND (rc.Status NOT IN ('Approve', 'Reject')))   
			--  OR (rc.IdStep NOT IN (10020, 10021, 10022) AND rc.Status <> 'Reject'))  
			--  AND ((peb.NpeNumber IS NULL OR peb.NpeNumber = '') OR (peb.NpeNumber IS NOT NULL OR peb.NpeNumber <> '' AND MONTH(rc.CreateDate) <= MONTH(GETDATE())))  
			--  AND chis.Step = 'Approval By Superior'  
			--  AND cp.IsDelete = 0  
			--  AND rc.IdCl NOT IN (SELECT npe.IdCl  
			--   FROM CargoCipl cc  
			--	 INNER JOIN NpePeb npe ON npe.IdCl = cc.Id  
			--   WHERE YEAR(npe.CreateDate) = @year)  
	)DATA GROUP BY Month(CreatedDate)    
    
    DECLARE @monthly_tbl table(MonthNumber int, MonthName nvarchar(10))    
    DECLARE @month int = 1    
    WHILE @month <= 12    
    BEGIN    
        INSERT INTO @monthly_tbl     
        SELECT @month, LEFT(DATENAME(MONTH , DATEADD(MONTH, @month , -1)), 3)    
        SET @month = @month + 1;  
    END;  
    
    SELECT  m.MonthName AS Month,     
            ISNULL(i.count, 0) AS Invoice,     
            ISNULL(i.peb, 0) AS PEB,     
            ISNULL(o.count, 0) AS Outstanding     
    FROM @monthly_tbl m    
   LEFT JOIN @invoice i ON m.MonthNumber = i.month    
   LEFT JOIN @outstanding o ON m.MonthNumber = o.month    
    
END
GO

/****** Object:  StoredProcedure [dbo].[SP_ActivityReport_TrendExport]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_ActivityReport_TrendExport] --'2020', '2022'
	 @startYear INT,  
	 @endYear INT,
	 @filter NVARCHAR(MAX)  
AS  
BEGIN  
	DECLARE @yearly_tbl TABLE(Year INT)  
	DECLARE @year INT = @startYear  
	WHILE @year <= @endYear  
	BEGIN  
		INSERT INTO @yearly_tbl VALUES(@year)  
		SET @year = @year + 1;  
	END;  
   
	SELECT	DISTINCT y.Year,   
			ISNULL(b.TotalExportSales, 0) AS TotalExportSales, 
			ISNULL(b.TotalExportNonSales, 0) AS TotalExportNonSales, 
			ISNULL(b.TotalExport, 0) AS TotalExport,   
			ISNULL(b.TotalPEB, 0) As TotalPEB   
	FROM	@yearly_tbl y  
			LEFT JOIN (	SELECT c.Year, SUM(c.TotalExportSales) [TotalExportSales], SUM(c.TotalExportNonSales) [TotalExportNonSales], SUM(c.TotalExport) [TotalExport], SUM(c.TotalPEB) [TotalPEB]
						FROM	(	SELECT	DISTINCT YEAR(CreatedDate) AS Year, 
											CASE WHEN ExportType LIKE 'Sales%' THEN SUM(ExtendedValue) ELSE 0 END [TotalExportSales], 
											CASE WHEN ExportType LIKE 'Non Sales%' THEN SUM(ExtendedValue) ELSE 0 END [TotalExportNonSales],
											SUM(ExtendedValue) As TotalExport,   
											COUNT(DISTINCT AjuNumber) AS TotalPEB  
									FROM	dbo.[fn_get_approved_npe_peb]()  
									WHERE	(YEAR(CreatedDate) >= @startYear OR @startYear = 0) 
											AND (YEAR(CreatedDate) <= @endYear OR @endYear = 0)
											AND ExportType LIKE '' + @filter + '%'
									GROUP BY YEAR(CreatedDate), ExportType) AS c
						GROUP BY Year)b ON y.Year = b.Year
END  
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExport_Detail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CargoForExport_Detail]  -- exec [SP_CargoForExport_Detail] 41784
 @CargoID bigint  
AS  
BEGIN  
  
 SELECT   
 CAST(ROW_NUMBER() over (order by a.CaseNumber) as varchar(5)) as ItemNo   
 , a.ContainerNumber  
 , a.SealNumber  
 , a.ContainerType  
 , CAST(ISNULL(COUNT(a.TotalCaseNumber), 0) as varchar(5)) AS TotalCaseNumber  
 , a.CaseNumber  
 , a.Do  
 , a.InBoundDa  
 , a.[Description]  
 , CAST(FORMAT(ISNULL(SUM(a.NetWeight), 0), '#,0.00') as varchar(20))  AS NetWeight  
 , CAST(FORMAT(ISNULL(SUM(GrossWeight), 0), '#,0.00') as varchar(20))  AS GrossWeight  
 FROM  
 ( select   
   ISNULL(ci.ContainerNumber, '-') as ContainerNumber  
   , ISNULL(ci.ContainerSealNumber, '-') as SealNumber  
   , ISNULL(ct.Name, '-') as ContainerType  
   , CAST(ISNULL(container.CaseNumber, 0) as varchar(5)) as TotalCaseNumber  
   , cpi.CaseNumber  
   , ISNULL(cp.EdoNo, '-') as Do  
   , ISNULL(ci.InBoundDa, '-') as InBoundDa  
   , ISNULL(cp.Category, '-') as Description  
   , ISNULL(ci.NewNet, ci.Net) as NetWeight  
  , ISNULL(ci.NewGross, ci.Gross) as GrossWeight  
  from Cargo c   
  --left join CargoContainer cc on c.Id = cc.CargoId  
  left join CargoItem ci on c.Id = ci.IdCargo  
  left join CiplItem cpi on ci.IdCiplItem = cpi.Id  
  left join Cipl cp on cpi.IdCipl = cp.id  
  left join (  
   select c.Id as CargoID, cpi.IdCipl, count(ISNULL(cpi.CaseNumber, 0)) as CaseNumber  
   from Cargo c   
   left join CargoItem ci on c.Id = ci.IdCargo  
   left join CiplItem cpi on ci.IdCiplItem = cpi.Id  
   where ci.isDelete = 0 and cpi.IsDelete = 0  
   group by c.Id, cpi.IdCipl  
  ) container on c.Id = container.CargoID and cp.id = container.IdCipl  
  left join (select Value, Name from MasterParameter where [Group] = 'ContainerType') ct on ci.ContainerType = ct.Value  
  outer apply(  
   select top 1 * from CargoHistory where IdCargo = c.id order by id desc  
  ) ch  
  where c.Id = @CargoID and ci.isDelete = 0 and cpi.IsDelete = 0  
 ) a  
 GROUP BY a.casenumber, a.ContainerNumber, a.SealNumber, a.ContainerType, a.Do, a.InBoundDa, a.[Description]  
 order by a.CaseNumber  
END  

GO

/****** Object:  StoredProcedure [dbo].[SP_CiplDelete]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_CiplDelete] (
	@id BIGINT
	,@UpdateBy NVARCHAR(50)
	,@UpdateDate DATETIME
	,@Status NVARCHAR(50)
	,@IsDelete BIT
	,@RFC nvarchar(max)
	)
AS
BEGIN
	UPDATE R
	SET R.AvailableQuantity = R.AvailableQuantity + CI.Quantity
	FROM Reference R
	INNER JOIN (
		SELECT CI.IdReference
			,SUM(CI.Quantity) Quantity
		FROM CiplItem CI
		WHERE CI.IdCipl = @id
			AND CI.IsDelete = 0
		GROUP BY CI.IdReference
		) CI ON CI.IdReference = R.Id

	IF (@Status = 'ALL')
	BEGIN
		UPDATE dbo.Cipl
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE id = @id;

		UPDATE dbo.RequestCipl
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE IdCipl = @id;

		UPDATE dbo.CiplForwader
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE IdCipl = @id;

		UPDATE dbo.CiplItem
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE IdCipl = @id
	END
	ELSE IF (@Status = 'CIPLITEM')
	BEGIN
		UPDATE dbo.CiplItem
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE IdCipl = @id
	END
	ELSE IF (@Status = 'CIPLITEMID')
	BEGIN
	if(@RFC = 'true')

	begin
		declare @OID Nvarchar(max);
	set @OID = (select IdCiplItem from CiplItem_Change where IdCiplItem = @id)
	if(@OID Is Null)
	begin
	INSERT INTO [dbo].[CiplItem_Change](IdCiplItem,[IdCipl],[IdReference],[ReferenceNo],[IdCustomer],[Name],[Uom],[PartNumber],[Sn],[JCode],[Ccr],[CaseNumber],[Type],[IdNo],[YearMade],[Quantity]
           ,[UnitPrice],[ExtendedValue],[Length],[Width],[Height],[Volume],[GrossWeight],[NetWeight],[Currency],[CoO],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete]
		   ,[IdParent],[SIBNumber],[WONumber],[Claim],[ASNNumber],[Status]
           )
   select [Id],[IdCipl],[IdReference],[ReferenceNo],[IdCustomer],[Name],[Uom],[PartNumber],[Sn],[JCode],[Ccr],[CaseNumber],[Type],[IdNo],[YearMade],[Quantity]
           ,[UnitPrice],[ExtendedValue],[Length],[Width],[Height],[Volume],[GrossWeight],[NetWeight],[Currency],[CoO],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete]
		   ,[IdParent],[SIBNumber],[WONumber],[Claim],[ASNNumber],'Deleted' from CiplItem where Id = @id
	end
	else	
	begin
	UPDATE dbo.CiplItem_Change
	SET [Status] = 'Deleted',
	IsDelete = 'true'
	WHERE IdCiplItem = @id;
	end
	
	end
	else
	begin
		UPDATE dbo.CiplItem
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE Id = @id

		UPDATE dbo.CiplItem
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE IdParent = @id
	end

		
	END
END


GO

/****** Object:  StoredProcedure [dbo].[SP_CiplForExportInvoicePL_Detail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplForExportInvoicePL_Detail] 
	@CiplID bigint
AS
BEGIN
    select 
		ISNULL(CI.CaseNumber, '-') as CaseNumber
		, CAST(ROW_NUMBER() over (order by CI.Id) as nvarchar(5)) as ItemNo
		, IIF(CI.Name IS NULL OR LEN(CI.Name) <= 0, '-', CI.Name) as Name
		, IIF(CI.Sn IS NULL OR LEN(CI.Sn) <= 0, '-', CI.Sn) as Sn
		, IIF(CI.IdNo IS NULL OR LEN(CI.IdNo) <= 0, '-', CI.IdNo) as IdNo
		, ISNULL(CAST(CI.YearMade as varchar(4)), '-') as YearMade
		, CAST(ISNULL(CI.Quantity, 0) as varchar(5)) as Quantity
		, IIF(CI.PartNumber IS NULL OR LEN(CI.PartNumber) <= 0, '-', CI.PartNumber) as PartNumber
		, IIF(CI.JCode IS NULL OR LEN(CI.JCode) <= 0, '-', CI.JCode) as JCode
		, IIF(CI.Ccr IS NULL OR LEN(CI.Ccr) <= 0, '-', CI.Ccr) as Ccr
		, IIF(CI.Type IS NULL OR LEN(CI.Type) <= 0, '-', CI.Type) as Type
		, IIF(CI.ReferenceNo IS NULL OR LEN(CI.ReferenceNo) <= 0, '-', CI.ReferenceNo) as ReferenceNo
		, CAST(ISNULL(FORMAT(CI.Length, '#,0.00'), 0) as varchar(10)) as Length
		, CAST(ISNULL(FORMAT(CI.Width, '#,0.00'), 0) as varchar(10)) as Width
		, CAST(ISNULL(FORMAT(CI.Height, '#,0.00'), 0) as varchar(10)) as Height
		, CAST(ISNULL(CI.Volume, 0) as varchar(20)) as Volume
		, CAST(ISNULL(FORMAT(CI.NetWeight, '#,0.00'), 0) as varchar(10)) as NetWeight
		, CAST(ISNULL(FORMAT(CI.GrossWeight, '#,0.00'), 0) as varchar(10)) as GrossWeight
		, CONCAT(CI.Currency, ' ', FORMAT(ISNULL(CI.UnitPrice, 0), '#,0.00')) as UnitPrice
		, CONCAT(CI.Currency, ' ', FORMAT(ISNULL(CI.ExtendedValue, 0), '#,0.00')) as ExtendedValue
		, ISNULL(CI.SIBNumber, '-') as SibNumber
		, ISNULL(CI.WONumber, '-') as WoNumber
		--, ISNULL(C.VesselFlight, '-') as VesselFlight
		, ISNULL(CI.CoO, '-') as CoO
		, ISNULL(CL.EdoNo, '-') as EdiNo
		, ISNULL(CI.ASNNumber, '-') as ASNNumber
	from CiplItem CI 
	--left join CargoCipl CC ON CC.IdCipl = CI.IdCipl AND CC.isdelete = 0
	--left join Cargo C ON C.Id = CC.IdCargo AND C.Isdelete = 0
	left join Cipl CL ON CL.id = CI.IdCipl AND CL.isdelete = 0
		--and CI.IsDelete = 0 
	where CI.IdCipl = @CiplID 
	and CI.IsDelete = 0 
	order by CI.CaseNumber ASC
END


GO

/****** Object:  StoredProcedure [dbo].[SP_CiplGetById]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE  [dbo].[SP_CiplGetById]    -- [dbo].[SP_CiplGetById]   63600
(    
  @id BIGINT    
)    
AS    
BEGIN    
  SELECT distinct C.id    
        , C.CiplNo    
        , C.ClNo    
        , C.EdoNo    
        , C.Category    
        , C.CategoriItem    
        , C.ExportType    
        , C.ExportTypeItem    
  --, (SELECT C.CategoryReference+'-'+MP.Name FROM MasterParameter MP inner join Cipl C ON C.CategoryReference = MP.Value WHERE C.id=@id) AS CategoryReference    
        , C.CategoryReference    
  , C.SoldConsignee    
        , C.SoldToName    
        , C.SoldToAddress    
        , C.SoldToCountry    
        , C.SoldToTelephone    
        , C.SoldToFax    
        , C.SoldToPic    
        , C.SoldToEmail    
        , C.ShipDelivery    
        , C.ConsigneeName    
        , C.ConsigneeAddress    
        , C.ConsigneeCountry    
        , C.ConsigneeTelephone    
        , C.ConsigneeFax    
        , C.ConsigneePic    
        , C.ConsigneeEmail    
        , C.NotifyName    
        , C.NotifyAddress    
        , C.NotifyCountry    
        , C.NotifyTelephone    
        , C.NotifyFax    
        , C.NotifyPic    
        , C.NotifyEmail    
        , C.ConsigneeSameSoldTo    
        , C.NotifyPartySameConsignee    
        , (SELECT C.Area+' - '+MP.PlantName FROM MasterPlant MP inner join Cipl C ON left(C.Area,4) = left(MP.PlantCode,4) WHERE C.id=@id) AS Area    
        , (SELECT C.Branch+' - '+MA.BAreaName FROM MasterArea MA inner join Cipl C ON left(C.Branch,4) = left(MA.BAreaCode,4) WHERE C.id=@id) AS Branch    
  , C.Currency    
  , C.Rate    
        , C.PaymentTerms    
        , C.ShippingMethod    
        , C.CountryOfOrigin    
        , C.Da    
        , C.LcNoDate    
        , C.IncoTerm    
        , C.FreightPayment    
        , C.ShippingMarks    
        , C.Remarks    
        , C.SpecialInstruction    
        , C.LoadingPort    
        , C.DestinationPort    
  , (SELECT DISTINCT Fn.BAreaCode+' - '+Fn.BAreaName FROM [dbo].fn_get_cipl_businessarea_list('') Fn    
 INNER JOIN Cipl C ON IIF(C.PickUpArea = '', NULL, left(C.PickUpArea,4)) = left(Fn.BAreaCode ,4) WHERE C.id=@id) AS PickUpArea    
  --, (SELECT DISTINCT Fn.Business_Area+' - '+Fn.BAreaName FROM [dbo].[fn_get_employee_internal_ckb]() Fn INNER JOIN Cipl C ON IIF(C.PickUpArea = '', NULL, C.PickUpArea) = Fn.Business_Area WHERE C.id=@id) AS PickUpArea    
  --, (SELECT Fn.BAreaCode+' - '+Fn.BAreaName FROM [dbo].[fn_get_plant_barea_user]() Fn INNER JOIN Cipl C ON RIGHT(C.PickUpPic,3) = RIGHT(Fn.UserID, 3) WHERE C.id=@id) AS PickUpArea    
  --, (SELECT Fn.AD_User+'-'+Fn.Employee_Name+ '-'+Fn.BAreaName FROM [dbo].[fn_get_employee_internal_ckb]() Fn INNER JOIN Cipl C ON C.PickUpPic = Fn.AD_User WHERE C.id=@id) AS PickUpPic    
  , (SELECT Fn.AD_User+'-'+Fn.Employee_Name+ '-'+Fn.BAreaName FROM [dbo].[fn_get_employee_internal_ckb]() Fn INNER JOIN Cipl C ON  (select top 1 * from dbo.fnSplitString(C.PickUpPic,'-')) = Fn.AD_User WHERE C.id=@id) AS PickUpPic    
  , C.ETD    
        , C.ETA    
        , C.CreateBy    
        , C.CreateDate    
        , C.UpdateBy    
        , C.UpdateDate    
        , C.IsDelete    
  , C.ReferenceNo    
  , ISNULL(C.Consolidate, 0) Consolidate    
  FROM dbo.Cipl C    
  WHERE C.id = @id    
END 

GO

/****** Object:  StoredProcedure [dbo].[SP_CiplGetList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SP_CiplGetList]      
(          
 @ConsigneeName NVARCHAR(200),      
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
  SET @WhereSql = ' AND c.CreateBy='''+@CreateBy+''' ';      
 END      
      
 IF @ConsigneeName <> ''      
 BEGIN      
SET @WhereSql = ' AND (C.CiplNo LIKE ''%'+@ConsigneeName+'%'' OR C.ConsigneeName LIKE ''%'+@ConsigneeName+'%'' OR C.Id LIKE ''%'+@ConsigneeName+'%'')';   
 END      
 IF @usertype ='ext-imex'      
 BEGIN      
  SET @WhereSql = @WhereSql + ' AND ((fnReqCl.IdNextStep is NULL  AND RC.[Status]=''Approve'')  OR (fnReqCl.IdNextStep = 10021 AND RC.[Status]=''Approve'')) ';      
 END      
      
 SET @sql = 'SELECT DISTINCT C.id,C.EdoNo      
    , C.CiplNo      
    , C.Category      
    , C.ConsigneeName      
    , C.ShippingMethod      
    , CF.Forwader      
    , C.CreateDate      
    ,ISNULL((Select SUM(CI.GrossWeight) FROM dbo.CiplItem CI WHERE CI.idcipl = C.id),0) GrossWeight      
    , RC.[Status]      
    ,  CASE    
 WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep = 30074)  
 THEN ''Request Cancel''  
 WHEN (fnReqCl.IdStep = 30075)  
 THEN ''waiting for beacukai approval''  
 WHEN (fnReqCl.IdStep = 30076)  
 THEN ''Cancelled''  
     WHEN fnreq.NextStatusViewByUser =''Pickup Goods''      
      THEN      
        CASE WHEN       
        (fnReqGr.Status=''DRAFT'') OR (fnReq.Status=''APPROVE'' AND (fnReqGr.Status is null OR fnReqGr.Status = ''Waiting Approval'') AND RC.Status =''APPROVE'')       
        THEN ''Waiting for Pickup Goods''      
       WHEN (fnReqGr.IdFlow = 14 AND (fnReqGr.Status =''Submit'' OR fnReqGr.Status =''APPROVE'' ) AND (fnReqCl.Status is Null OR (fnReqCl.Status=''Submit'' AND fnReqCl.IdStep != 10017)))      
        THEN ''On process Pickup Goods''      
       WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep not in (10022))      
        THEN ''Preparing for export''      
       WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep = 10022)      
        THEN ''Finish''       
       END         
       WHEN fnReq.Status =''Reject''      
       THEN ''Reject''      
     WHEN fnReq.NextStatusViewByUser = ''Waiting for superior approval''      
      THEN fnReq.NextStatusViewByUser +'' (''+ emp.Employee_Name +'')''      
     WHEN fnReq.Status =''Reject''      
     THEN ''Reject''      
     ELSE fnReq.NextStatusViewByUser      
      END AS [StatusViewByUser]
	  ,'''+@role+''' As RoleName
  FROM dbo.Cipl C        
  INNER JOIN dbo.RequestCipl RC ON RC.IdCipl = C.id      
  INNER JOIN dbo.CiplForwader CF ON CF.IdCipl = C.id      
  INNER JOIN dbo.FlowStatus FS on FS.IdStep = RC.IdStep AND FS.[Status] = RC.Status      
  INNER JOIN PartsInformationSystem.dbo.UserAccess PIS on PIS.UserID = c.CreateBy      
  INNER JOIN dbo.[fn_get_cipl_request_list_all]() as fnReq on fnReq.Id = rc.Id       
  --LEFT JOIN GoodsReceiveItem as GR on GR.IdCipl = C.id AND GR.isdelete = 0      
  LEFT JOIN ShippingFleetRefrence as sfr on sfr.IdCipl = C.id      
  LEFT JOIN CargoCipl as CC on CC.IdCipl = C.id AND CC.Isdelete = 0      
  LEFT JOIN dbo.[fn_get_gr_request_list_all]() as fnReqGr on fnReqGr.IdGr = sfr.IdGr      
  LEFT JOIN dbo.[fn_get_cl_request_list_all]() as fnReqCl on fnReqCl.IdCl = CC.IdCargo      
  left join employee emp on emp.AD_User = fnReq.NextAssignTo      
  WHERE 1=1 '+@WhereSql+'      
  AND C.IsDelete = 0       
  ORDER BY C.id DESC';      
  print (@WhereSql);      
  print (@sql);      
 exec(@sql);       
 END      
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplInsert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplInsert]
(
  @Category NVARCHAR(100),
  @CategoryItem NVARCHAR(50),
  @ExportType NVARCHAR(100),
  @ExportTypeItem NVARCHAR(100),
  @SoldConsignee NVARCHAR(30),
  @SoldToName NVARCHAR(200),
  @SoldToAddress NVARCHAR(MAX),
  @SoldToCountry NVARCHAR(100),
  @SoldToTelephone NVARCHAR(100),
  @SoldToFax NVARCHAR(100),
  @SoldToPic NVARCHAR(200),
  @SoldToEmail NVARCHAR(200),
  @ShipDelivery NVARCHAR(30),
  @ConsigneeName NVARCHAR(200),
  @ConsigneeAddress NVARCHAR(MAX),
  @ConsigneeCountry NVARCHAR(100),
  @ConsigneeTelephone NVARCHAR(100),
  @ConsigneeFax NVARCHAR(100),
  @ConsigneePic NVARCHAR(200),
  @ConsigneeEmail NVARCHAR(200),
  @NotifyName NVARCHAR(200),
  @NotifyAddress NVARCHAR(MAX),
  @NotifyCountry NVARCHAR(100),
  @NotifyTelephone NVARCHAR(100),
  @NotifyFax NVARCHAR(100),
  @NotifyPic NVARCHAR(200),
  @NotifyEmail NVARCHAR(200),
  @ConsigneeSameSoldTo BIGINT,
  @NotifyPartySameConsignee BIGINT,
  @Area NVARCHAR(100),
  @Branch NVARCHAR(100),
  @Currency NVARCHAR(20),
  @Rate DECIMAL(18,2),
  @PaymentTerms NVARCHAR(50),
  @ShippingMethod NVARCHAR(30),
  @CountryOfOrigin NVARCHAR(200),
  @LcNoDate NVARCHAR(200),
  @IncoTerm NVARCHAR(50),
  @FreightPayment NVARCHAR(30),
  @ShippingMarks NVARCHAR(MAX),
  @Remarks NVARCHAR(200),
  @SpecialInstruction NVARCHAR(MAX),
  @CreateBy NVARCHAR(50),
  @CreateDate datetime,
  @UpdateBy NVARCHAR(50),
  @UpdateDate datetime,
  @Status NVARCHAR(10),
  @IsDelete BIT,
  @LoadingPort NVARCHAR(200),
  @DestinationPort NVARCHAR(200),
  @PickUpPic NVARCHAR(200),
  @PickUpArea NVARCHAR(200),
  @CategoryReference NVARCHAR(50),
  @ReferenceNo NVARCHAR(50),
  @Consolidate NVARCHAR(10),
  @Forwader NVARCHAR(200),
  @BranchForwarder NVARCHAR(200),
  @Attention NVARCHAR(200),
  @Company NVARCHAR(200),
  @SubconCompany NVARCHAR(200),
  @Address NVARCHAR(MAX),
  @AreaForwarder NVARCHAR(100),
  @City NVARCHAR(100),
  @PostalCode NVARCHAR(100),
  @Contact NVARCHAR(200),
  @FaxNumber NVARCHAR(200),
  @Forwading NVARCHAR(200),
  @Email NVARCHAR(200),
  @Type NVARCHAR(10),
  @ExportShipmentType NVARCHAR(Max),
  @Vendor NVARCHAR(Max)

  --@LASTCIPLID bigint output
)
AS
BEGIN
  DECLARE @LASTID bigint
  INSERT INTO [dbo].[Cipl]
           ([Category]
           ,[CategoriItem]
           ,[ExportType]
           ,[ExportTypeItem]
		   ,[SoldConsignee]
           ,[SoldToName]
           ,[SoldToAddress]
           ,[SoldToCountry]
           ,[SoldToTelephone]
           ,[SoldToFax]
           ,[SoldToPic]
           ,[SoldToEmail]
           ,[ShipDelivery]
           ,[ConsigneeName]
           ,[ConsigneeAddress]
           ,[ConsigneeCountry]
           ,[ConsigneeTelephone]
           ,[ConsigneeFax]
           ,[ConsigneePic]
           ,[ConsigneeEmail]
           ,[NotifyName]
           ,[NotifyAddress]
           ,[NotifyCountry]
           ,[NotifyTelephone]
           ,[NotifyFax]
           ,[NotifyPic]
           ,[NotifyEmail]
           ,[ConsigneeSameSoldTo]
           ,[NotifyPartySameConsignee]
       ,[Area]
       ,[Branch]
	   ,[Currency]
	   ,[Rate]
           ,[PaymentTerms]
           ,[ShippingMethod]
           ,[CountryOfOrigin]
           ,[LcNoDate]
           ,[IncoTerm]
           ,[FreightPayment]
           ,[ShippingMarks]
           ,[Remarks]
           ,[SpecialInstruction]
           ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
		   ,[LoadingPort]
		   ,[DestinationPort]
		   ,[PickUpPic]
       ,[PickUpArea]
	   ,[CategoryReference]
	   ,[ReferenceNo]
	   ,[Consolidate]
           )
     VALUES
           (@Category
           ,@CategoryItem
           ,@ExportType
           ,@ExportTypeItem
       ,@SoldConsignee
           ,@SoldToName
           ,@SoldToAddress
           ,@SoldToCountry
           ,@SoldToTelephone
           ,@SoldToFax
           ,@SoldToPic
           ,@SoldToEmail
       ,@ShipDelivery
           ,@ConsigneeName
           ,@ConsigneeAddress
           ,@ConsigneeCountry
           ,@ConsigneeTelephone
           ,@ConsigneeFax
           ,@ConsigneePic
           ,@ConsigneeEmail
           ,@NotifyName
           ,@NotifyAddress
           ,@NotifyCountry
           ,@NotifyTelephone
           ,@NotifyFax
           ,@NotifyPic
           ,@NotifyEmail
           ,@ConsigneeSameSoldTo
           ,@NotifyPartySameConsignee
       ,@Area
       ,@Branch
	   ,@Currency
	   ,@Rate
           ,@PaymentTerms
           ,@ShippingMethod
           ,@CountryOfOrigin
           ,@LcNoDate
           ,@IncoTerm
           ,@FreightPayment
           ,@ShippingMarks
           ,@Remarks
           ,@SpecialInstruction
           ,@CreateBy
           ,@CreateDate
           ,@UpdateBy
           ,@UpdateDate
           ,@IsDelete
		   ,@LoadingPort
		   ,@DestinationPort
		   ,@PickUpPic
       ,@PickUpArea
	   ,@CategoryReference
	   ,@ReferenceNo
	   ,@Consolidate)

  SET @LASTID = CAST(SCOPE_IDENTITY() as bigint)
  --SET @LASTCIPLID =@LASTID
  INSERT INTO [dbo].[CiplForwader]
           ([IdCipl]
       ,[Forwader]
	   ,[Branch]
	   ,[Attention]
       ,[Company]
	   ,[SubconCompany]
       ,[Address]
	   ,[Area]
	   ,[City]
	   ,[PostalCode]
       ,[Contact]
	   ,[FaxNumber]
	   ,[Forwading]
       ,[Email]
           ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
		   ,[Type]
		   ,[ExportShipmentType]
		   ,[Vendor]
           )
     VALUES
           (@LASTID
       ,@Forwader
	   ,@BranchForwarder
	   ,@Attention
       ,@Company
	   ,@SubconCompany
       ,@Address
	   ,@AreaForwarder
	   ,@City
	   ,@PostalCode	
       
       ,@Contact
	   ,@FaxNumber
	   ,@Forwading
       ,@Email
           ,@CreateBy
           ,@CreateDate
           ,@UpdateBy
           ,@UpdateDate
           ,@IsDelete
		   ,@Type
		   ,@ExportShipmentType
		   ,@Vendor)



  EXEC dbo.GenerateCiplNumber @LASTID, @CreateBy;

  DECLARE @CIPLNO nvarchar(20), @GETCATEGORY nvarchar(2)
  
  SELECT @GETCATEGORY = 
    CASE
      WHEN C.Category = 'CATERPILLAR NEW EQUIPMENT' THEN 'PP'
      WHEN C.Category = 'CATERPILLAR SPAREPARTS' THEN 'SP'
      WHEN C.Category = 'CATERPILLAR USED EQUIPMENT' THEN 'UE'
	  WHEN C.Category = 'MISCELLANEOUS' THEN 'MC'
    ELSE Null
    END 
    FROM Cipl C WHERE C.id = @LASTID
    
  EXEC dbo.sp_insert_request_data @LASTID, 'CIPL', @GETCATEGORY, @Status, 'CREATE';

END


GO

/****** Object:  StoredProcedure [dbo].[SP_CiplItemGetById]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SP_CiplItemGetById]   
(  
  @id BIGINT  
)  
AS  
BEGIN  
  SELECT distinct CI.Id  
    , CI.IdCipl  
    , CI.IdReference  
    , (SELECT CASE  
        WHEN CI.ReferenceNo = '-' THEN CI.CaseNumber   
        ELSE CI.ReferenceNo  
        END) AS ReferenceNo  
    , CI.IdCustomer  
    , CI.Name  
    ,(SELECT [Name] FROM MasterParameter WHERE [Group] = 'UOMType' AND [Value]= CI.Uom) AS UnitUom  
    , CI.PartNumber  
    , CI.Sn  
    , CI.JCode  
    , CI.Ccr  
    , CI.CaseNumber  
    , CI.Type  
    , CI.IdNo  
    , CI.YearMade  
    , CI.Quantity  
    , CI.UnitPrice  
    , CI.ExtendedValue  
    , CI.Length  
    , CI.Width  
    , CI.Height  
    , CI.Volume  
    , CI.GrossWeight  
    , CI.NetWeight  
    , CI.Currency  
 , CI.CoO  
 , CI.IdParent  
 , CI.WONumber  
 , CI.SIBNumber  
    , CI.CreateBy  
    , CI.CreateDate  
    , CI.UpdateBy  
    , CI.UpdateDate  
    , CI.IsDelete  
 , CI.Claim  
 , CI.ASNNumber  
  FROM dbo.CiplItem CI  
  WHERE CI.IdCipl = @id  
  AND CI.IsDelete = 0  
  ORDER BY IdReference, Id  
END  
  
  
  
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplItemInsert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXEC [dbo].[SP_CiplItemInsert] 6, 97
ALTER PROCEDURE [dbo].[SP_CiplItemInsert]
(
	@IdCipl BIGINT,
	@IdReference BIGINT = '',
	@ReferenceNo NVARCHAR(50) = '',
	@IdCustomer NVARCHAR(50) = '',
	@Name NVARCHAR(200) = '',
	@Uom NVARCHAR(50) = '',
	@PartNumber NVARCHAR(50) = '',
	@Sn NVARCHAR(50) = '',
	@JCode NVARCHAR(50) = '',
	@Ccr NVARCHAR(50) = '',
	@CaseNumber NVARCHAR(50) = '',
	@Type NVARCHAR(100) = '',
	@IdNo NVARCHAR(200) = '',
	@YearMade NVARCHAR(200) = '',
	@Quantity INT = 0,
	@UnitPrice DECIMAL(20, 2) = 0,
	@ExtendedValue DECIMAL(20, 2) = 0,
	@Length DECIMAL(18, 2) = 0,
	@Width DECIMAL(18, 2) = 0,
	@Height DECIMAL(18, 2) = 0,
	@Volume DECIMAL(18, 6) = 0,
	@GrossWeight DECIMAL(20,2) = 0,
	@NetWeight DECIMAL(20,2) = 0,
	@Currency NVARCHAR(200) = '',
	@CoO NVARCHAR(200) = '',
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@IsDelete BIT,
	@IdItem BIGINT,
	@IdParent BIGINT,
	@SIBNumber NVARCHAR(200),
	@WONumber NVARCHAR(200),
	@Claim NVARCHAR(200),
	@ASNNumber NVARCHAR(50) = ''
)
AS
BEGIN
    DECLARE @LASTID bigint
	DECLARE @Country NVARCHAR(100);

	-- SELECT TOP 1 @Country = MC.CountryCode from MasterCountry MC WHERE MC.CountryCode = IIF(ISNULL(@CoO, '') = '', MC.CountryCode, @CoO ) OR MC.Description = IIF(ISNULL(@CoO, '') = '', MC.CountryCode, @CoO )

	SELECT TOP 1 @Country = MC.CountryCode from MasterCountry MC WHERE MC.CountryCode = ISNULL(@CoO, '') OR MC.Description = ISNULL(@CoO, '')
 
IF CHARINDEX(':AA',@PartNumber) > 0
 BEGIN
 SET @PartNumber = LEFT(@PartNumber+':AA', CHARINDEX(':AA',@PartNumber+':AA')-1)
 END
	
	IF @IdItem <= 0
	BEGIN
	INSERT INTO [dbo].[CiplItem]
           ([IdCipl]
		   ,[IdReference]
           ,[ReferenceNo]
		   ,[IdCustomer]
           ,[Name]
           ,[Uom]
           ,[PartNumber]
           ,[Sn]
           ,[JCode]
           ,[Ccr]
           ,[CaseNumber]
           ,[Type]
           ,[IdNo]
           ,[YearMade]
		   ,[Quantity]
           ,[UnitPrice]
           ,[ExtendedValue]
           ,[Length]
           ,[Width]
           ,[Height]
		   ,[Volume]
		   ,[GrossWeight]
		   ,[NetWeight]
           ,[Currency]
		   ,[CoO]
           ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
		   ,[IdParent]
		   ,[SIBNumber]
		   ,[WONumber]
		   ,[Claim]
		   ,[ASNNumber]
           )
     VALUES
           (@IdCipl
		   ,@IdReference
           ,@ReferenceNo
		   ,@IdCustomer
           ,@Name
           ,@Uom
           ,@PartNumber
           ,@Sn
           ,@JCode
           ,@Ccr
           ,@CaseNumber
           ,@Type
           ,@IdNo
           ,@YearMade
		   ,@Quantity
           ,@UnitPrice
           ,@ExtendedValue
           ,@Length
           ,@Width
           ,@Height
		   ,@Volume
		   ,@GrossWeight
		   ,@NetWeight
           ,@Currency
		   ,@Country
           ,@CreateBy
           ,@CreateDate
           ,@UpdateBy
           ,@UpdateDate
           ,@IsDelete
		   ,@IdParent
		   ,@SIBNumber
		   ,@WONumber
		   ,@Claim
		   ,@ASNNumber)

	END
	ELSE 
	BEGIN
	UPDATE dbo.CiplItem
	SET [Name] = @Name
		   ,[Uom] = @Uom
		   ,[Quantity] = @Quantity
           ,[CaseNumber] = @CaseNumber
		   ,[Sn] = @Sn
		   ,[PartNumber] = @PartNumber
           ,[Type] = @Type
           ,[ExtendedValue] = @ExtendedValue
           ,[Length] = @Length
           ,[Width] = @Width
           ,[Height] = @Height
		   ,[Volume] = @Volume
		   ,[GrossWeight] = @GrossWeight
		   ,[NetWeight] = @NetWeight
           ,[Currency] = @Currency
		   ,[CoO] = @Country
		   ,[YearMade] = @YearMade
		   ,[IdParent] = @IdParent
		   ,[SIBNumber] = @SIBNumber
		   ,[WONumber] = @WONumber
		   ,[Claim] = @Claim
		   ,[ASNNumber] = @ASNNumber
           ,[UnitPrice] = @UnitPrice
	WHERE Id = @IdItem;
	END

END

GO

/****** Object:  StoredProcedure [dbo].[SP_CiplUpdate]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplUpdate]
(
	@id bigint,
	@Category NVARCHAR(100),
	@CategoryItem NVARCHAR(50),
	@ExportType NVARCHAR(100),
	@ExportTypeItem NVARCHAR(50),
	@SoldConsignee NVARCHAR(30),
	@SoldToName NVARCHAR(200),
	@SoldToAddress NVARCHAR(MAX),
	@SoldToCountry NVARCHAR(100),
	@SoldToTelephone NVARCHAR(100),
	@SoldToFax NVARCHAR(100),
	@SoldToPic NVARCHAR(200),
	@SoldToEmail NVARCHAR(200),
	@ShipDelivery NVARCHAR(30),
	@ConsigneeName NVARCHAR(200),
	@ConsigneeAddress NVARCHAR(MAX),
	@ConsigneeCountry NVARCHAR(100),
	@ConsigneeTelephone NVARCHAR(100),
	@ConsigneeFax NVARCHAR(100),
	@ConsigneePic NVARCHAR(200),
	@ConsigneeEmail NVARCHAR(200),
	@NotifyName NVARCHAR(200),
	@NotifyAddress NVARCHAR(MAX),
	@NotifyCountry NVARCHAR(100),
	@NotifyTelephone NVARCHAR(100),
	@NotifyFax NVARCHAR(100),
	@NotifyPic NVARCHAR(200),
	@NotifyEmail NVARCHAR(200),
	@ConsigneeSameSoldTo BIGINT,
	@NotifyPartySameConsignee BIGINT,
	@Area NVARCHAR(100),
	@Branch NVARCHAR(100),
	@Currency NVARCHAR(20),
	@Rate DECIMAL(18,2),
	@PaymentTerms NVARCHAR(50),
	@ShippingMethod NVARCHAR(30),
	@CountryOfOrigin NVARCHAR(30),
	@LcNoDate NVARCHAR(30),
	@IncoTerm NVARCHAR(50),
	@FreightPayment NVARCHAR(30),
	@ShippingMarks NVARCHAR(MAX),
	@Remarks NVARCHAR(200),
	@SpecialInstruction NVARCHAR(MAX),
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@Status NVARCHAR(10),
	@IsDelete BIT,
	@LoadingPort NVARCHAR(200),
    @DestinationPort NVARCHAR(200),
	@PickUpPic NVARCHAR(200),
	@PickUpArea NVARCHAR(200),
	@CategoryReference NVARCHAR(50),
	@ReferenceNo NVARCHAR(50),
	@Consolidate NVARCHAR(20),
	@Forwader NVARCHAR(200),
	@BranchForwarder NVARCHAR(200),
	@Attention NVARCHAR(200),
	@Company NVARCHAR(200),
	@SubconCompany NVARCHAR(200),
	@Address NVARCHAR(MAX),
	@AreaForwarder NVARCHAR(100),
	@City NVARCHAR(100),
	@PostalCode NVARCHAR(100),
	@Contact NVARCHAR(200),
	@FaxNumber NVARCHAR(200),
	@Forwading NVARCHAR(200),
	@Email NVARCHAR(200),
	@Type VARCHAR(10),
	@ExportShipmentType NVARCHAR(Max),
	@Vendor NVARCHAR(MAX)
)
AS
BEGIN
	UPDATE dbo.Cipl 
		SET Category = @Category 
           ,CategoriItem = @CategoryItem
           ,ExportType = @ExportType
           ,ExportTypeItem = @ExportTypeItem
		   ,SoldConsignee = @SoldConsignee
           ,SoldToName = @SoldToName
           ,SoldToAddress = @SoldToAddress
           ,SoldToCountry = @SoldToCountry
           ,SoldToTelephone = @SoldToTelephone
           ,SoldToFax = @SoldToFax
           ,SoldToPic = @SoldToPic
           ,SoldToEmail = @SoldToEmail
		   ,ShipDelivery = @ShipDelivery
           ,ConsigneeName = @ConsigneeName
           ,ConsigneeAddress = @ConsigneeAddress
           ,ConsigneeCountry = @ConsigneeCountry
           ,ConsigneeTelephone = @ConsigneeTelephone
           ,ConsigneeFax = @ConsigneeFax
           ,ConsigneePic = @ConsigneePic
           ,ConsigneeEmail = @ConsigneeEmail
           ,NotifyName = @NotifyName
           ,NotifyAddress = @NotifyAddress
           ,NotifyCountry = @NotifyCountry
           ,NotifyTelephone = @NotifyTelephone
           ,NotifyFax = @NotifyFax
           ,NotifyPic = @NotifyPic
           ,NotifyEmail = @NotifyEmail
           ,ConsigneeSameSoldTo = @ConsigneeSameSoldTo
           ,NotifyPartySameConsignee = @NotifyPartySameConsignee
		   ,Area = @Area
		   ,Branch = @Branch
		   ,Currency = @Currency
           ,PaymentTerms = @PaymentTerms
           ,ShippingMethod = @ShippingMethod
           ,CountryOfOrigin = @CountryOfOrigin
           ,LcNoDate = @LcNoDate
           ,IncoTerm = @IncoTerm
           ,FreightPayment = @FreightPayment
           ,ShippingMarks = @ShippingMarks
           ,Remarks = @Remarks
           ,SpecialInstruction = @SpecialInstruction
           ,UpdateBy = @UpdateBy
           ,UpdateDate = @UpdateDate
           ,IsDelete = @IsDelete
		   ,LoadingPort = @LoadingPort
		   ,DestinationPort = @DestinationPort
		   ,PickUpPic = @PickUpPic
		   ,PickUpArea = @PickUpArea
		   ,CategoryReference = @CategoryReference
		   ,ReferenceNo = @ReferenceNo
		   ,Consolidate = @Consolidate
	WHERE id = @id;

	UPDATE dbo.CiplForwader
	SET Forwader = @Forwader
		,Branch = @BranchForwarder
		,Attention = @Attention
		,Company = @Company
		,SubconCompany = @SubconCompany
		,Address = @Address
		,Area = @AreaForwarder
		,City = @City
		,PostalCode = @PostalCode
		,Contact = @Contact
		,FaxNumber = @FaxNumber
		,Forwading = @Forwading
		,Email = @Email
		,UpdateBy = @UpdateBy
		,UpdateDate = @UpdateDate
        ,IsDelete = @IsDelete
		,[Type]=@Type
		,ExportShipmentType=@ExportShipmentType 
		,Vendor=@Vendor

	WHERE IdCipl = @id;

	DECLARE @GETCATEGORY nvarchar(2)
	
	SELECT @GETCATEGORY = 
		CASE
			WHEN C.Category = 'CATERPILLAR NEW EQUIPMENT' THEN 'PP'
			WHEN C.Category = 'CATERPILLAR SPAREPARTS' THEN 'SP'
			WHEN C.Category = 'CATERPILLAR USED EQUIPMENT' THEN 'UE'
			WHEN C.Category = 'MISCELLANEOUS' THEN 'MC'
		ELSE Null
		END 
		FROM Cipl C WHERE C.id = @id
	EXEC [dbo].[sp_update_request_cipl] @id, @UpdateBy, @Status, ''

END

GO

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Map_Branch]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Dashboard_Map_Branch] (@user NVARCHAR(50))
AS
BEGIN
	DECLARE @sql NVARCHAR(max);
	DECLARE @and NVARCHAR(max);
	DECLARE @area NVARCHAR(max);
	DECLARE @role NVARCHAR(max);

	SELECT @area = U.Business_Area
		,@role = U.[Role]
	FROM dbo.fn_get_employee_internal_ckb() U
	WHERE U.AD_User = @user;;

	IF (
			@role = 'EMCS Warehouse'
			OR @role = 'EMCS IMEX'
			OR @role = 'EMCS PPJK'
			)
	BEGIN
		SET @and = 'AND C.PickUpArea IS NOT NULL';
	END
	--ELSE
	--BEGIN
	--	IF (
	--			@area = ''
	--			OR @area IS NULL
	--			)
	--	BEGIN
	--		SET @and = 'AND RIGHT(C.PickUpArea, 3) = RIGHT(''' + @user + ''',3)';
	--	END
	--	ELSE
	--	BEGIN
	--		SET @and = 'AND RIGHT(C.PickUpArea, 3) = RIGHT(''' + @area + ''',3)';
	--	END
	--END

	SET @sql = 
	'SELECT C.CiplNo [no]
		,E.Employee_Name employee
		,CONVERT(NVARCHAR, HP.latitude) lat
		,CONVERT(NVARCHAR, HP.longitude) lon
		,HP.[name] provinsi	
		,isnull((SELECT Distinct MASP.Name  FROM  MasterAirSeaPort MASP LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id
		LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo
		  WHERE  MASP.Code = LEFT(CA.PortOfLoading, 5)),''-'') area
		,(SELECT COUNT (CC.Id) From CargoCIPL CC WHERE CC.IdCipl = C.id ) total
	FROM Highchartprovince HP
	INNER JOIN MasterArea MA ON MA.ProvinsiCode = HP.id
	INNER JOIN Cipl C ON RIGHT(C.Area, 3) = RIGHT(MA.BAreaCode, 3)
	--LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id
	INNER JOIN RequestCipl RC ON RC.IdCipl = C.id
	--LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo AND  RCL.IdStep IN (
			--11
			--,12
			--,10017
			--,20033
			--,10020
			--,10022
			--) AND RCL.STATUS IN (
			--''Submit''
			--,''Approve''
			--,''Revise''
			--)
		
	--LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo
	--INNER JOIN MasterAirSeaPort MASP ON MASP.Code = LEFT(CA.PortOfLoading, 5)
	INNER JOIN employee E ON E.AD_User = C.CreateBy
	WHERE
		  RC.STATUS IN (			
			''Submit''
			,''Approve''
			,''Revise''
			)
		
		AND YEAR(RC.CreateDate) = YEAR(GETDATE())
		AND C.CreateBy <>''System''
	--GROUP BY C.CiplNo
	--	,E.Employee_Name
	--	,MA.BAreaName
	--	,HP.latitude
	--	,HP.longitude
	--	,HP.name
	--	,C.id
		--,MASP.Name
	ORDER BY C.id DESC';
	--	'SELECT C.CiplNo [no]
	--	,E.Employee_Name employee
	--	,CONVERT(NVARCHAR, HP.latitude) lat
	--	,CONVERT(NVARCHAR, HP.longitude) lon
	--	,HP.[name] provinsi
	--	,MASP.Name area
	--	,COUNT(CC.Id) total
	--FROM Highchartprovince HP
	--INNER JOIN MasterArea MA ON MA.ProvinsiCode = HP.id
	--INNER JOIN Cipl C ON RIGHT(C.Area, 3) = RIGHT(MA.BAreaCode, 3)
	--LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id
	--LEFT JOIN RequestCipl RC ON RC.IdCipl = C.id
	--LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo
	--LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo
	--INNER JOIN MasterAirSeaPort MASP ON MASP.Code = LEFT(CA.PortOfLoading, 5)
	--INNER JOIN employee E ON E.AD_User = C.CreateBy
	--WHERE RCL.IdStep IN (
	--		11
	--		,12
	--		,10017
	--		,20033
	--		,10020
	--		,10022
	--		)
	--	AND RCL.STATUS IN (
	--		''Submit''
	--		,''Approve''
	--		,''Revise''
	--		)
	--	AND RC.STATUS IN (			
	--		''Submit''
	--		,''Approve''
	--		,''Revise''
	--		)
	--	AND YEAR(RCL.CreateDate) = YEAR(GETDATE())
	--	AND C.CreateBy <>''System''
	--GROUP BY C.CiplNo
	--	,E.Employee_Name
	--	,MA.BAreaName
	--	,HP.latitude
	--	,HP.longitude
	--	,HP.name
	--	,C.id
	--	,MASP.Name
	--ORDER BY C.id DESC';
	--Print  @sql
	--PRINT 'masuk'
	EXECUTE (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_data]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cargo_data] -- sp_get_cargo_data 1
(
	@Id bigint
)
AS
BEGIN
	--DECLARE @Id bigint = 2;
	SELECT 
		t0.Id        
		, t0.ClNo        
		, t0.Consignee        
		, t0.NotifyParty        
		, t0.ExportType        
		, t0.Category        
		, t0.IncoTerms
		, CONCAT(t0.IncoTerms, ' - ', t6.[Name]) [IncotermsDesc]        
		, t0.StuffingDateStarted        
		, t0.StuffingDateFinished     
		, t0.TotalPackageBy
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
		, t5.ViewByUser [StatusViewByUser]
		, t0.CargoType
		, t0.ShippingMethod		
		, t7.[Name] CargoTypeName
		, STUFF((SELECT ', '+ISNULL(tx1.EdoNo, '-')
			FROM dbo.CargoItem tx0
			JOIN dbo.Cipl tx1 on tx1.id = tx0.IdCipl
			WHERE tx0.IdCargo = @Id
			GROUP BY tx1.EdoNo
			FOR XML PATH(''),type).value('.','nvarchar(max)'),1,1,'') [RefEdo]
		, t8.SlNo Si_No
		, t8.[Description] Si_Description
		, t8.DocumentRequired Si_DocumentRequired
		, t8.SpecialInstruction Si_SpecialInstruction
	FROM Cargo t0      
	JOIN dbo.RequestCl as t1 on t1.IdCl = t0.Id
	JOIN PartsInformationSystem.dbo.[UserAccess] t3 on t3.UserID = t0.CreateBy
	LEFT JOIN employee t2 on t2.AD_User = t0.CreateBy
	JOIN dbo.FlowStep t4 on t4.Id = t1.IdStep
	JOIN dbo.FlowStatus t5 on t5.[Status] = t1.[Status] AND t5.IdStep = t1.IdStep
	LEFT JOIN dbo.MasterIncoTerms t6 on t6.Number = t0.Incoterms
	LEFT JOIN dbo.MasterParameter t7 on t7.[Group] = 'CargoType' AND t7.Value = ISNULL(t0.CargoType,0)
	LEFT JOIN dbo.ShippingInstruction t8 on t8.IdCL = t0.Id
	WHERE 1=1 AND t0.Id = @Id;
END

GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
ALTER PROCEDURE [dbo].[sp_get_cargo_item_list] -- [dbo].[sp_get_cargo_item_list] '', 1    
(    
 @Search nvarchar(100),    
 @IdCargo nvarchar(100),    
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
 SET @sort = 't0.'+@sort;   
 SET @sql = 'SELECT ';    
 IF (@isTotal <> 0)    
  BEGIN    
   SET @sql += 'count(*) total '    
  END     
 ELSE    
  BEGIN   
	SET @sql = 'WITH CTE AS ( SELECT '
	SET @sql += 'DISTINCT
		  t0.Id ID
		  ,t0.IdCipl                     
		  ,t3.CiplNo                     
		  ,t2.Incoterms IncoTerm                     
		  ,t2.Incoterms IncoTermNumber                     
		  ,t1.CaseNumber                     
		  ,t3.EdoNo                     
		  --,t6.DaNo InboundDa 
		  ,(SELECT STUFF((SELECT '','' + DaNo FROM ShippingFleet WHERE IdCargo = t0.IdCargo AND DoNo = t4.DoNo FOR XML PATH('''')), 1, 1, '''')) as InboundDa                      
		  ,ISNULL(t0.NewLength, t0.Length) Length                    
		  ,ISNULL(t0.NewWidth,t0.Width) Width                     
		  ,ISNULL(t0.NewHeight,t0.Height) Height                    
		  ,ISNULL(t0.NewNet,t0.Net) NetWeight                
		  ,ISNULL(t0.NewGross,t0.Gross) GrossWeight                     
		  ,t0.NewLength                     
		  ,t0.NewWidth                     
		  ,t0.NewHeight                    
		  ,t0.NewNet NewNetWeight                  
		  ,t0.NewGross NewGrossWeight                   
		  ,t1.Sn            
		  ,t1.PartNumber            
		  ,t1.Ccr            
		  ,t1.Quantity            
		  ,t1.Name ItemName            
		  ,t1.JCode            
		  ,t1.ReferenceNo                    
		  ,CAST(1 as bit) state            
		  ,t2.Category CargoDescription            
		  ,t0.ContainerNumber    
		  ,t5.Description ContainerType    
		  ,t0.ContainerSealNumber'
  END    
   SET @sql +='    
     FROM dbo.CargoItem t0    
     JOIN dbo.CiplItem t1 on t1.Id = t0.IdCiplItem AND t1.isdelete = 0     
     JOIN dbo.Cargo t2 on t2.Id = t0.IdCargo AND t2.isdelete = 0    
     JOIN dbo.Cipl t3 on t3.id = t1.IdCipl AND t3.isdelete = 0    
    LEFT JOIN dbo.ShippingFleetRefrence t4 on t4.DoNo = t3.EdoNo  
 Left JOIN dbo.ShippingFleet t6 on t6.Id = t4.IdShippingFleet  
 -- LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo AND t4.isdelete = 0    
     LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''    
     WHERE 1=1 AND t0.isdelete = 0 AND t0.IdCargo='+@IdCargo+''; 
	SET @sql += ' ) SELECT	ROW_NUMBER() OVER ( ORDER BY CTE.ID ) RowNo, CTE.*
			FROM	CTE'   
 --IF @isTotal = 0     
 --BEGIN    
 -- SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';    
 --END     
 --select @sql;    
 EXEC(@sql);    
END    
    
    
    
GO

/****** Object:  StoredProcedure [dbo].[SP_get_cipl_available]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_get_cipl_available] -- SP_get_cipl_available '', '1', '1' select * from dbo.Cipl    
(    
 @Search nvarchar(100) = '',    
 @CargoId nvarchar(10) = '0',    
 @CiplList nvarchar(max) = '',    
 @Consignee nvarchar(max) = '',    
 @Notify nvarchar(max) = '',    
 @ExportType nvarchar(max) = '',    
 @Category nvarchar(max) = '',    
 @Incoterms nvarchar(max) = '',    
 @ShippingMethod nvarchar(max) = ''    
)    
AS    
BEGIN    
 SET NOCOUNT ON;    
 DECLARE @sql nvarchar(max);    
    
 SET @sql = 'SELECT     
     --t0.*    
  distinct t0.IdCipl As Id  
  ,t0.DoNo  
  ,t0.IdGr  
  ,null As DaNo  
  ,null As FileName  
  ,t1.CreateDate  
  ,t1.CreateBy  
  ,t1.UpdateDate  
  ,t1.UpdateBy  
  ,t1.IsDelete  
  , t1.CiplNo    
     , t1.Category    
     , t1.CategoriItem    
     , t1.ExportType    
     , t1.ExportTypeItem    
     , t1.ConsigneeName    
     , t1.ConsigneeCountry    
     , t1.NotifyName    
     , t1.IncoTerm    
     , t1.ShippingMethod    
     , t1.id CiplId    
     , t2.[Status] RequestStatus   
    --FROM dbo.ShippingFleet t0  
 FROM dbo.ShippingFleetRefrence t0    
    JOIN dbo.Cipl t1 ON t1.id = t0.IdCipl    
    JOIN dbo.RequestGr t2 ON t2.IdGr = t0.IdGr    
    WHERE     
    --t0.isdelete = 0 AND    
    t2.Status = ''Approve'' ';    
 SET @sql = @sql + CASE WHEN ISNULL(@Consignee, '') <> '' THEN 'AND t1.ConsigneeName like ''%'+@Consignee+'%''' ELSE '' END +     
    CASE WHEN ISNULL(@Consignee, '') <> '' THEN 'AND t1.NotifyName like ''%'+@Notify+'%''' ELSE '' END +      
    CASE WHEN ISNULL(@Consignee, '') <> '' THEN 'AND t1.ExportType like ''%'+@ExportType+'%''' ELSE '' END +     
    CASE WHEN ISNULL(@Consignee, '') <> '' THEN 'AND UPPER(RTRIM(LTRIM(t1.Category))) like ''%'+UPPER(RTRIM(LTRIM(@Category)))+'%''' ELSE '' END +    
    CASE WHEN ISNULL(@Consignee, '') <> '' THEN 'AND UPPER(RTRIM(LTRIM(t1.IncoTerm))) like ''%'+UPPER(RTRIM(LTRIM(@Incoterms)))+'%''' ELSE '' END +    
    CASE WHEN ISNULL(@Consignee, '') <> '' THEN 'AND UPPER(RTRIM(LTRIM(t1.ShippingMethod))) like ''%'+UPPER(RTRIM(LTRIM(@ShippingMethod)))+'%''' ELSE '' END +    
    ' AND t1.id NOT IN (    
     SELECT IdCipl FROM dbo.cargocipl WHERE 1=1 AND isDelete = 0 '+ CASE WHEN @CargoId <> '0' THEN 'AND IdCargo <> '+@CargoId ELSE '' END +    
    ')' +    
    'AND (t1.CiplNo like ''%'+@Search+'%'' OR   
 --t0.DaNo like ''%'+@Search+'%'' OR  
 t0.DoNo like ''%'+@Search+'%'') ' +    
    CASE WHEN ISNULL(@CiplList, '') <> '' THEN 'AND t1.id NOT IN ('+@CiplList+')' ELSE '' END;    
 --SELECT @sql;    
 EXECUTE(@sql);    
END    
GO

/****** Object:  StoredProcedure [dbo].[SP_get_cipl_item_available]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SP_get_cipl_item_available] -- SP_get_cipl_item_available 6, 1  
(  
 @idCipl nvarchar(max) = '',  
 @idCargo nvarchar(100) = ''  
)  
AS  
BEGIN  
 SET NOCOUNT ON;  
 DECLARE @SQL nvarchar(max);  
 DECLARE @WHERE nvarchar(max) = '';  
 IF ISNULL(@idCipl, '') <> ''   
 BEGIN  
  SET @WHERE = ' AND t0.IdCipl IN ('+@idCipl+') AND t0.Id NOT IN (select IdCiplItem from dbo.CargoItem where IdCargo = '+@idCargo+' and isDelete = 0)';   
 END  
  
 SET @SQL = 'SELECT t0.*  
    FROM dbo.CiplItem as t0  
    JOIN dbo.Cipl as t1 on t1.id = t0.IdCipl  
    WHERE 1=1 AND t0.IsDelete = 0 '+ @WHERE;   
  
 --PRINT @SQL;  
 EXECUTE(@SQL);  
END  

GO

/****** Object:  StoredProcedure [dbo].[sp_get_consignee_name]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_consignee_name]
	(
	@ReferenceNo NVARCHAR(100) = ''
	,@Category NVARCHAR(100) = ''
	,@CategoryReference NVARCHAR(100) = ''
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(max);

	IF @CategoryReference = 'Other'
		BEGIN
			SET @CategoryReference = 'Email'
		END


	SET @sql = 'SELECT ';
	BEGIN
		SET @sql += 'DISTINCT ConsigneeName 
		,IdCustomer
		,Street 
		,City 
		,PIC
		,Fax 
		,Telephone 
		,Email 
		,Currency';
	END

	SET @sql += ' FROM Reference'

		--SET @SQL = @SQL + ' WHERE '+@Column+' = '''+@ColumnValue+''' AND Category = '''+@Category+'''  AND AvailableQuantity > 0';
		SET @SQL = @SQL + ' WHERE '+@CategoryReference+' IN (SELECT F.splitdata FROM [dbo].[fnSplitString](''' + @ReferenceNo + ''', '','') F)  AND Category = ''' + @Category + '''  AND AvailableQuantity > 0';

	EXECUTE (@sql);
END


GO

/****** Object:  StoredProcedure [dbo].[sp_get_edi_available]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[sp_get_edi_available] -- [dbo].[sp_get_edi_available] '1241', 'xupj21hbk'      
(      
       @area nvarchar(100),      
       @pic nvarchar(100) = '',
	   @IdGr bigint = 0
)      
AS  

select        
       t0.[id] Id   
      ,t0.[CiplNo]      
      ,t0.[ClNo]      
      ,t0.[EdoNo]      
      ,t0.[Category]      
      ,t0.[CategoriItem]      
      ,t0.[ExportType]      
      ,t0.[ExportTypeItem]      
      ,t0.[SoldToName]      
      ,t0.[SoldToAddress]      
      ,t0.[SoldToCountry]      
      ,t0.[SoldToTelephone]      
      ,t0.[SoldToFax]      
      ,t0.[SoldToPic]      
      ,t0.[SoldToEmail]      
      ,t0.[ConsigneeName]      
      ,t0.[ConsigneeAddress]      
      ,t0.[ConsigneeCountry]      
      ,t0.[ConsigneeTelephone]      
      ,t0.[ConsigneeFax]      
      ,t0.[ConsigneePic]      
      ,t0.[ConsigneeEmail]      
      ,t0.[NotifyName]      
      ,t0.[NotifyAddress]      
      ,t0.[NotifyCountry]      
      ,t0.[NotifyTelephone]      
      ,t0.[NotifyFax]      
      ,t0.[NotifyPic]      
      ,t0.[NotifyEmail]      
      ,t0.[ConsigneeSameSoldTo]      
      ,t0.[NotifyPartySameConsignee]      
      ,t0.[Area]      
      ,t0.[Branch]      
      ,t0.[PaymentTerms]      
      ,t0.[ShippingMethod]      
      ,t0.[CountryOfOrigin]      
      ,t0.[Da]      
      ,t0.[LcNoDate]      
      ,t0.[IncoTerm]      
      ,t0.[FreightPayment]      
      ,t0.[Forwader]      
      ,t0.[ShippingMarks]      
      ,t0.[Remarks]      
      ,t0.[SpecialInstruction]      
      ,t0.[LoadingPort]      
      ,t0.[DestinationPort]      
      ,t0.[ETD]      
      ,t0.[ETA]      
      ,t0.[CreateBy]      
      ,t0.[CreateDate]      
      ,t0.[UpdateBy]      
      ,t0.[UpdateDate]      
      ,t0.[IsDelete]      
      ,t0.[SoldConsignee]      
      ,t0.[ShipDelivery]      
      ,t0.[Rate]      
      ,t0.[Currency]      
      ,t0.[PickUpPic]      
      ,t0.[PickUpArea]      
      ,t0.[CategoryReference]      
      ,t0.[ReferenceNo]      
      ,t0.[Consolidate]      
from dbo.Cipl t0      
left join dbo.RequestCipl t1 on t1.IdCipl = t0.id AND t1.IsDelete = 0       
left join dbo.fn_get_cipl_request_list_all() t2 on t2.IdCipl = t0.id   

where       
t2.IdNextStep IN (14, 10024, 10028, 30057)       
AND RIGHT(t0.PickUpArea,3) = RIGHT(@area,3)      
--AND t0.PickUpPic = @pic      
--AND t2.BAreaUser = @area      
AND t1.[Status] = 'Approve'       
AND EdoNo IS NOT NULL    
AND t0.Id not  IN (      
    select gi.IdCipl       
 from dbo.ShippingFleetRefrence gi      
 join RequestGr rg ON gi.idgr = rg.idgr 
  and gi.Idgr <> @IdGr 
 where  rg.[status] != 'Reject'  
) 


GO

/****** Object:  StoredProcedure [dbo].[sp_get_gr_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [dbo].[sp_get_gr_list] -- [dbo].[sp_get_gr_list] 'XUPJ21WDN', '', 0            
(            
 @Username nvarchar(100),            
 @Search nvarchar(100),            
 @isTotal bit = 0,            
 @sort nvarchar(100) = 'Id',            
 @order nvarchar(100) = 'DESC',            
 @offset nvarchar(100) = '0',            
 @limit nvarchar(100) = '10'           
)            
AS            
BEGIN            
    SET NOCOUNT ON;            
    DECLARE @sql nvarchar(max);              
 DECLARE @WhereSql nvarchar(max) = '';            
 DECLARE @GroupId nvarchar(100);            
 DECLARE @RoleID NVARCHAR(max);           
 DECLARE @area NVARCHAR(max);            
 DECLARE @role NVARCHAR(max) = '';           
   set @RoleID = (Select RoleID from PartsInformationSystem.dbo.UserAccess where UserID = @Username)       
 SET @sort = 't0.'+@sort;            
  --SET @sort = 't0.UpdateDate';            
            
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
  SET @sql += 't0.Id            
     , t0.GrNo            
     , (select top 1 PicName     from shippingfleet s where  t0.id = s.IdGr ) as PicName           
     , (select top 1 PhoneNumber    from shippingfleet s where  t0.id = s.IdGr)as PhoneNumber          
     , (select top 1 KtpNumber     from shippingfleet s where  t0.id = s.IdGr)as KtpNumber            
     , (select top 1 SimNumber     from shippingfleet s where  t0.id = s.IdGr)as SimNumber            
     , (select top 1 StnkNumber     from shippingfleet s where  t0.id = s.IdGr)as StnkNumber           
     , (select top 1 NopolNumber    from shippingfleet s where  t0.id = s.IdGr)as NopolNumber          
     , (select top 1 EstimationTimePickup from shippingfleet s where  t0.id = s.IdGr)as  EstimationTimePickup       
  , ISNULL((select TOP 1(Id) from RequestForChange WHERE FormId = t0.Id AND FormType = ''GoodsReceive'' AND [Status] = 0),0) AS PendingRFC    
     , t0.Notes            
     , t2.Step            
     , t1.Status            
     , t0.PickupPoint            
     , CASE WHEN (t3.ViewByUser =''Waiting for pickup goods approval'')            
      THEN t3.ViewByUser +'' (''+ emp.Fullname +'')''        
   WHEN t1.[IdStep] = 30074 THEN ''Request Cancel''      
   WHEN t1.[IdStep] = 30075 THEN ''waiting for beacukai approval''      
   WHEN t1.[IdStep] = 30076 THEN ''Cancelled''      
      ELSE t3.ViewByUser            
       END AS StatusViewByUser
	   ,'+@RoleID+' As RoleID '            
 END            
 SET @sql +='FROM dbo.GoodsReceive as t0            
       INNER JOIN dbo.RequestGr as t1 on t1.IdGr = t0.Id        
    --INNER JOIN ShippingFleetRefrence sfr on sfr.IdGr = gr.Id      --   INNER JOIN CargoCipl cc on cc.IdCipl = sfr.IdCipl      
       INNER JOIN dbo.FlowStep as t2 on t2.Id = t1.IdStep            
    LEFT JOIN dbo.FlowStatus as t3 on t3.IdStep = t1.IdStep AND t3.Status = t1.Status            
    left join PartsInformationSystem.dbo.useraccess emp on emp.userid = t0.PickupPic            
       where 1=1 '+@WhereSql+'  AND t0.IsDelete=0 AND (t0.GrNo like ''%'+@Search+'%'' OR t0.PicName like ''%'+@Search+'%'')';            
            
 IF @isTotal = 0             
 BEGIN            
  SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';            
 END             
            
 --select @sql;            
 print (@sql)          
 EXECUTE(@sql);            
 END            
END 

GO

/****** Object:  StoredProcedure [dbo].[SP_get_item_by_container]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_get_item_by_container] -- [SP_get_item_by_container]
(
	@IdContainer nvarchar(100) = ''
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL nvarchar(max);
	DECLARE @WHERE nvarchar(max) = '';
	IF ISNULL(@IdContainer, '') <> '' 
	BEGIN
		SET @WHERE = ' AND t0.IdContainer='+@IdContainer+''; 
	END

	SET @SQL = 'SELECT 
					t0.Id
					, t0.IdCipl
					, t1.ReferenceNo
					, t1.IdCustomer
					, t1.[Name]
					, t1.Uom
					, t1.PartNumber
					, t1.PartNumber IdShippingFleet
					, t1.Sn
					, t1.JCode
					, t1.Ccr
					, t1.CaseNumber
					, t1.[Type]
					, t1.IdNo
					, t1.YearMade
					, t1.UnitPrice
					, t1.ExtendedValue
					, t0.Length 
					, t0.Width	
					, t0.Height 
					, t0.Gross GrossWeight	
					, t0.Net NetWeight		
					, t1.Currency		
					, t0.CreateBy		
					, t0.CreateDate		
					, t0.UpdateBy		
					, t0.UpdateDate 
					, t0.IsDelete	
					, t2.CustName
					, t2.CustNr
				FROM dbo.CargoItem t0
				LEFT JOIN dbo.CiplItem t1 on t1.Id=t0.IdCipl
				LEFT JOIN (select DISTINCT CustNr, CustName FROM dbo.MasterCustomer) t2 on t2.CustNr = t1.IdCustomer
				WHERE 1=1 '+@WHERE;

	--SELECT @SQL;
	EXECUTE(@SQL);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_next_superior]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sp_get_next_superior 'xupj21ikx'
ALTER PROCEDURE [dbo].[sp_get_next_superior] (
	@username nvarchar(100) = ''
)
AS
BEGIN
	DECLARE @counter INT = 1;
	DECLARE @next_superior nvarchar(100) = @username;
	DECLARE @result_data nvarchar(100) = '';
	
	--DROP TABLE #testing;
	--SELECT '' AD_user, '' Employee_Name INTO #testing
	--TRUNCATE TABLE #testing;
	
	WHILE @counter <= 3
	BEGIN
		DECLARE @employee_id nvarchar(100) = '';
		DECLARE @employee_name nvarchar(100) = '';
	
		SELECT @employee_id = Superior_ID FROM MDS.HC.employee WHERE AD_User = @next_superior;
		SELECT @next_superior = AD_User, @employee_name = Employee_Name FROM MDS.HC.employee WHERE Employee_ID = @employee_id;
		--SELECT @next_superior AD_User, @employee_name Employee_Name into #testing
		--SET @result_data += @employee_id + '-' +@employee_name +'+';
		SET @result_data += @employee_id+'+';
		IF ISNULL(@employee_id, '') = ''
		BEGIN
			BREAK;
		END

	    SET @counter = @counter + 1;
		--print @employee_id + ' - '+ @employee_name;
		--print @next_superior;
	END

	SELECT t0.splitdata EmployeeId, t1.AD_User AdUser, t1.Employee_Name EmployeeName 
	FROM dbo.fnSplitString(LTRIM(RTRIM(@result_data)), '+') t0
	INNER JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.Employee_ID = t0.splitdata;
	--print @result_data;
	--SELECT * FROM #testing;
	--DROP TABLE #testing;
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_reference_item]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_reference_item]
	(
	@Column NVARCHAR(100) = ''
	,@ColumnValue NVARCHAR(100) = ''
	,@Category NVARCHAR(100) = ''
	,@isTotal BIT = 0
	,@sort NVARCHAR(100) = 'Id'
	,@order NVARCHAR(100) = 'ASC'
	,@offset NVARCHAR(100) = '0'
	,@limit NVARCHAR(100) = '500'
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(max);

	SET @sort = @sort;
	SET @sql = 'SELECT ';

	IF (@isTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total '
	END
	ELSE
	BEGIN
		SET @sql += 'AvailableQuantity 
		,CaseNumber 
		,CCR Ccr 
		,Claim 
		,CoO 
		,Currency 
		,ISNULL(ExtendedValue,0) ExtendedValue 
		,ISNULL(GrossWeight,0) GrossWeight 
		,ISNULL(Height,0) Height 
		,Id 
		,ISNULL(IdCustomer,''-'') IdCustomer 
		,CAST(0 AS bigint) IdItem 
		,IDNo 
		,JCode 
		,Length 
		,ISNULL(NetWeight,0) NetWeight 
		,PartNumber 
		,ISNULL(POCustomer,''-'') POCustomer 
		,Quantity ,ISNULL(QuotationNo,''-'') QuotationNo 
		,ISNULL(ReferenceNo,''-'') ReferenceNo 
		,SIBNumber 
		,UnitModel 
		,UnitName 
		,ISNULL(UnitPrice,0) UnitPrice 
		,UnitSN 
		,UnitUom 
		,ISNULL(Volume,0) Volume 
		,ISNULL(Width,0) Width 
		,WONumber 
		,YearMade';
	END

	SET @sql += ' FROM Reference'

	IF (@Column <> '')
	BEGIN
		--SET @SQL = @SQL + ' WHERE '+@Column+' = '''+@ColumnValue+''' AND Category = '''+@Category+'''  AND AvailableQuantity > 0';
		SET @SQL = @SQL + ' WHERE ' + @Column + ' IN (SELECT F.splitdata FROM [dbo].[fnSplitString](''' + @ColumnValue + ''', '','') F) AND Createdate >= ''2020-06-08''  AND Category = ''' + @Category + '''  AND AvailableQuantity > 0';
	END
	ELSE
	BEGIN
		SET @SQL = @SQL + ' WHERE Category = ''' + @Category + ''' AND AvailableQuantity > 0 ';
	END

	--IF @isTotal = 0  
	--BEGIN 
	--  SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	--END  
	SET @sql += 'UNION ALL';

	BEGIN
		SET @sql += ' SELECT 0 AvailableQuantity 
		,CI.CaseNumber 
		,CI.Ccr 
		,CI.Claim
		,CI.CoO 
		,CI.Currency 
		,CI.ExtendedValue 
		,CI.GrossWeight 
		,CI.Height 
		,CI.Id 
		,CI.IdCustomer 
		,0 IdItem 
		,CI.IdNo IDNo 
		,CI.JCode 
		,CI.Length 
		,CI.NetWeight 
		,CI.PartNumber 
		,'''' POCustomer 
		,CI.Quantity 
		,'''' QuotationNo 
		,CI.ReferenceNo 
		,CI.SIBNumber 
		,'''' UnitModel 
		,CI.Name 
		,CI.UnitPrice 
		,CI.Sn UnitSN 
		,CI.Uom UnitUom 
		,CI.Volume 
		,CI.Width 
		,CI.WONumber 
		,CI.YearMade';
	END

	SET @sql += ' FROM CiplItem CI ';
	SET @sql += 'WHERE CI.ReferenceNo IN (SELECT F.splitdata FROM [dbo].[fnSplitString](''' + @ColumnValue + ''', '','') F) ';
	--PRINT(@sql);
	EXECUTE (@sql);
END

GO

/****** Object:  StoredProcedure [dbo].[sp_get_revise_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCedure [dbo].[sp_get_revise_cipl] -- exec sp_get_revise_cipl 1
(
	@IdCipl bigint = 0,
	@isTotal bit = 0
)
as 
BEGIN
	IF @isTotal = 0
	BEGIN
		SELECT
			t1.CiplNo
			, t2.CaseNumber
			, t2.Ccr
			, t2.PartNumber
			, t2.Currency
			, t2.ExtendedValue
			, t2.JCode
			, t2.Sn
			, t2.Quantity
			, t2.Type
			, t2.UnitPrice
			, t2.Uom
			, t2.Name
			, t2.Volume
			, t2.YearMade 
			, t0.NewLength
			, t0.NewWidth
			, t0.NewHeight
			, t0.NewNetWeight
			, t0.NewGrossWeight
			, (t0.NewLength * t0.NewWidth * t0.NewHeight) NewDimension
			, t0.OldLength
			, t0.OldWidth
			, t0.OldHeight
			, t0.OldNetWeight
			, t0.OldGrossWeight 
			, (t0.OldLength * t0.OldWidth * t0.OldHeight) OldDimension
		FROM dbo.CiplItemUpdateHistory t0
		INNER JOIN dbo.Cipl as t1 on t1.id = t0.IdCipl
		INNER JOIN dbo.CiplItem t2 on t2.id = t0.IdCiplItem
		WHERE t0.IdCipl = @IdCipl
	END
	ELSE 
	BEGIN
		SELECT count(*) total
		FROM dbo.CiplItemUpdateHistory t0
		INNER JOIN dbo.Cipl as t1 on t1.id = t0.IdCipl
		INNER JOIN dbo.CiplItem t2 on t2.id = t0.IdCiplItem
		WHERE t0.IdCipl = @IdCipl
	END
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_task_bl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_task_bl] -- [dbo].[sp_get_task_bl]'xupj21wdn'
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
		if @GroupId = 'Import Export' OR @GroupId = 'Import Export Operation' OR @GroupId = 'Import Export Operation Mgmt.'
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
	PRINT(@sql);
	EXECUTE(@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_task_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_task_cipl] -- [dbo].[sp_get_task_cipl] 'XUPJ21AAV'
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
	DECLARE @GroupId nvarchar(100);
	DECLARE @UserType nvarchar(100);
	DECLARE @UserGroupNameExternal nvarchar(100) = '';
	DECLARE @UserPosition nvarchar(100) = '';
	DECLARE @BArea nvarchar(100) = '';

	SELECT @UserType = UserType, @UserGroupNameExternal = Cust_Group_No from PartsInformationSystem.dbo.UserAccess where UserID = @Username;

	if @UserType <> 'internal' 
	BEGIN
		SET @GroupId = 'CKB';
	END
	ELSE
	BEGIN
		select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;

		IF @GroupId = 'Import Export Operation' OR @GroupId = 'Import Export' OR @GroupId = 'Import Export Operation Mgmt.'
		BEGIN
			SET @GroupId = 'Import Export';
		END
	END
		
	select @UserPosition = [Group], @BArea = Business_Area from dbo.fn_get_employee_internal_ckb() where AD_User = @Username

		SET @sql = CASE WHEN @isTotal = 1 
						THEN 'SELECT COUNT(*) as total' 
							ELSE 'select tab0.* '
						END + ' FROM fn_get_cipl_request_list('''+@Username+''', '''+ISNULL(@GroupId, 0)+''') as tab0 WHERE Status NOT IN(''Draft'', ''Reject'')' +
					CASE 
						WHEN @isTotal = 0 
						THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY' ELSE '' END;
	EXECUTE(@sql);
END

GO

/****** Object:  StoredProcedure [dbo].[sp_get_task_cl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_task_cl] -- [dbo].[sp_get_task_cl] 'CKB1'
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
	DECLARE @GroupId nvarchar(100);
	DECLARE @PicNpe nvarchar(100);
	DECLARE @UserType nvarchar(100);
	DECLARE @UserGroupNameExternal nvarchar(100) = '';

	SELECT @UserType = UserType, @UserGroupNameExternal = Cust_Group_No from PartsInformationSystem.dbo.UserAccess where UserID = @Username;

	if @UserType <> 'internal' 
	BEGIN
		SET @GroupId = 'CKB';
		SET @PicNpe = 'CKB';
	END
	ELSE
	BEGIN
		select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;
		IF @GroupId = 'Import Export Operation' OR @GroupId = 'Import Export' OR @GroupId = 'Import Export Operation Mgmt.'
		BEGIN
			SET @GroupId = 'Import Export';
		END
		SET @PicNpe = 'IMEX';
	END

    SET @sql = CASE 
			   WHEN @isTotal = 1 
					THEN 'SELECT COUNT(*) as total' 
			   ELSE 'select tab0.* '
			   END + ' FROM fn_get_cl_request_list('''+@Username+''', '''+ISNULL(@GroupId, 0)+''', '''+@PicNpe+''') as tab0 WHERE IdNextStep IN (11, 12) AND Status IN(''Submit'', ''Revise'')' +
			   CASE 
					WHEN @isTotal = 0 
					THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY' ELSE '' END;

	--select @sql;
	EXECUTE(@sql);
END

GO

/****** Object:  StoredProcedure [dbo].[sp_get_task_gr]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_task_gr] -- [dbo].[sp_get_task_cipl]'xupj21wdn', 'IMEX'
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

/****** Object:  StoredProcedure [dbo].[sp_get_task_npe_peb]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_get_task_npe_peb] -- [dbo].[sp_get_task_npe_peb]'xupj21wdn'        
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

/****** Object:  StoredProcedure [dbo].[sp_get_task_si]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_task_si] -- [dbo].[sp_get_task_si]'xupj21wdn'
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
	DECLARE @GroupId nvarchar(100);
	DECLARE @PicNpe nvarchar(100);
	DECLARE @UserType nvarchar(100);
	DECLARE @UserGroupNameExternal nvarchar(100) = '';

	SELECT @UserType = UserType, @UserGroupNameExternal = Cust_Group_No from PartsInformationSystem.dbo.UserAccess where UserID = @Username;

	if @UserType <> 'internal' 
	BEGIN
		SET @GroupId = 'CKB';
		SET @PicNpe = 'CKB';
	END
	ELSE
	BEGIN
		select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;
		IF @GroupId = 'Import Export Operation' OR @GroupId = 'Import Export' OR @GroupId = 'Import Export Operation Mgmt.'
		BEGIN
			SET @GroupId = 'Import Export';
		END
		SET @PicNpe = 'IMEX';
	END

    SET @sql = CASE 
			   WHEN @isTotal = 1 
					THEN 'SELECT COUNT(*) as total' 
			   ELSE 'select tab0.* '
			   END + ' FROM fn_get_cl_request_list('''+@Username+''', '''+ISNULL(@GroupId, 0)+''', '''+@PicNpe+''') as tab0 WHERE IdStep IN (12, 20033) AND Status IN(''Approve'')' +
			   CASE 
					WHEN @isTotal = 0 
					THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY' ELSE '' END;

	--select @sql;
	EXECUTE(@sql);
END

GO

/****** Object:  StoredProcedure [dbo].[SP_GRForExport_Detail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[SP_GRForExport_Detail]
	@GRID bigint
AS
BEGIN
SELECT CAST(ROW_NUMBER() OVER (
			ORDER BY GoodsName
		)as varchar(max)) RowNo,
		GoodsName,
		DoNo,
		DaNo
FROM(
	SELECT DISTINCT
		
		t2.Name as GoodsName,
		t0.DoNo,
		''''+t0.DaNo as DaNo
	FROM GoodsReceiveItem t0
	JOIN Cipl t1 on t1.EdoNo = t0.DoNo
	JOIN CiplItem t2 on t2.IdCipl = t1.id
	WHERE t0.IdGr = @GRID
)t0
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_cargo_item]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_insert_update_cargo_item]           
(          
 @Id nvarchar(100),          
 @ItemId nvarchar(100),          
 @IdCargo nvarchar(100),          
 @ContainerNumber nvarchar(100),          
 @ContainerType nvarchar(100),          
 @ContainerSealNumber nvarchar(100),          
 @ActionBy nvarchar(100),          
 @Length nvarchar(100) = '0',          
 @Width nvarchar(100) = '0',          
 @Height nvarchar(100) = '0',          
 @GrossWeight nvarchar(100) = '0',          
 @NetWeight nvarchar(100) = '0',          
 @isDelete bit = 0          
)          
AS          
BEGIN          
 SET NOCOUNT ON;          
          
 IF ISNULL(@Id, 0) = 0           
 BEGIN          
  INSERT INTO [dbo].[CargoItem]          
         ([ContainerNumber]          
         ,[ContainerType]          
         ,[ContainerSealNumber]          
         ,[IdCipl]          
         ,[IdCargo]          
      ,[IdCiplItem]          
         ,[InBoundDa]          
         ,[Length]          
         ,[Width]          
         ,[Height]          
         ,[Net]          
         ,[Gross]          
         ,[CreateBy]          
         ,[CreateDate]          
         ,[UpdateBy]          
         ,[UpdateDate]          
         ,[isDelete])          
   select  top 1      
   @ContainerNumber          
   , @ContainerType          
   , @ContainerSealNumber          
   , t0.IdCipl          
   , @IdCargo          
   , t0.Id          
   , null as DaNo          
   , t0.[Length]          
   , t0.Width          
   , t0.Height          
   , t0.NetWeight          
   , t0.GrossWeight          
   , @ActionBy CreateBy          
   , GETDATE()          
   , @ActionBy UpdateBy          
   , GETDATE(), 0          
   from dbo.ciplItem t0           
   join dbo.Cipl t1 on t1.id = t0.IdCipl           
   --join dbo.GoodsReceiveItem t2 on t2.DoNo = t1.EdoNo AND t2.IsDelete = 0          
   join dbo.ShippingFleetRefrence t2 on  t2.DoNo = t1.EdoNo        
   where t0.id = @ItemId;     
   set @Id = SCOPE_IDENTITY()
 END           
 ELSE           
 BEGIN          
            
  DECLARE @OldLength decimal(20, 2);          
  DECLARE @OldWidth decimal(20, 2);          
  DECLARE @OldHeight decimal(20, 2);          
  DECLARE @OldGrossWeight decimal(20, 2);          
  DECLARE @OldNetWeight decimal(20, 2);          
  DECLARE @NewLength decimal(20, 2);          
  DECLARE @NewWidth decimal(20, 2);          
  DECLARE @NewHeight decimal(20, 2);          
  DECLARE @NewGrossWeight decimal(20, 2);          
  DECLARE @NewNetWeight decimal(20, 2);          
            
  SELECT           
  @OldLength = [Length],           
  @OldWidth = Width,           
  @OldHeight = Height,           
  @OldGrossWeight = Gross,           
  @OldNetWeight = Net,          
  @NewLength = ISNULL([NewLength], 0.00),          
  @NewWidth = ISNULL([NewWidth], 0.00),          
  @NewHeight = ISNULL([NewHeight], 0.00),          
  @NewGrossWeight = ISNULL([NewGross], 0.00),          
  @NewNetWeight = ISNULL([NewNet], 0.00)          
  FROM [dbo].[CargoItem] WHERE Id = @Id          
            
  IF @NewLength = 0.00          
  BEGIN          
   IF @OldLength = @Length           
   BEGIN          
    SET @Length = null          
   END          
  END          
          
  IF @NewWidth = 0.00          
  BEGIN          
   IF @OldWidth = @Width           
   BEGIN          
    SET @Width = null          
   END          
  END          
          
  IF @NewHeight = 0.00          
  BEGIN          
   IF @OldHeight = @Height           
   BEGIN          
    SET @Height = null          
   END          
  END          
          
  IF @NewHeight = 0.00          
  BEGIN          
   IF @OldHeight = @Height           
   BEGIN          
    SET @Height = null          
   END          
  END          
          
  IF @NewGrossWeight = 0.00          
  BEGIN          
   IF @OldGrossWeight = @GrossWeight           
   BEGIN          
    SET @GrossWeight = null          
   END          
  END          
          
  IF @NewNetWeight = 0.00          
  BEGIN          
   IF @OldNetWeight = @NetWeight           
   BEGIN          
    SET @NetWeight = null          
   END          
  END          
          
  UPDATE [dbo].[CargoItem]          
  SET [NewLength] = @Length          
   ,[ContainerNumber] = @ContainerNumber          
   ,[ContainerType] = @ContainerType          
 ,[ContainerSealNumber] = @ContainerSealNumber          
      ,[NewHeight] = @Height          
      ,[NewWidth] = @Width          
      ,[NewNet] = @NetWeight          
      ,[NewGross] = @GrossWeight          
   ,[UpdateBy] = @ActionBy          
   ,[UpdateDate] = GETDATE()    
   ,isDelete = @isDelete    
  WHERE Id = @Id          
 END         
          
 SELECT CAST(@Id as bigint) as ID          
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_cargo]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_insert_update_cargo]      
(      
 @CargoID BIGINT,      
 @Consignee NVARCHAR(200),      
 @NotifyParty NVARCHAR(200),      
 @ExportType NVARCHAR(200),      
 @Category NVARCHAR(200),      
 @Incoterms NVARCHAR(200),      
 @StuffingDateStarted datetime = NULL,--='02-02-2019',      
 @StuffingDateFinished datetime = NULL,--='12-12-2019',      
 @ETA datetime = NULL,--='02-02-2019',      
 @ETD datetime = NULL,--='12-12-2019',      
 @TotalPackageBy nvarchar(max),    
 @VesselFlight NVARCHAR(30),--='vessel',      
 @ConnectingVesselFlight NVARCHAR(30),--='con vessel',      
 @VoyageVesselFlight NVARCHAR(30),--='voy vessel',      
 @VoyageConnectingVessel NVARCHAR(30),--='voy con',      
 @PortOfLoading NVARCHAR(MAX),--='start',      
 @PortOfDestination NVARCHAR(MAX),--='end',      
 @SailingSchedule datetime = NULL,--='09-09-2019',      
 @ArrivalDestination datetime = NULL,--='10-10-2019',      
 @BookingNumber NVARCHAR(20) = '',--='1122',      
 @BookingDate datetime = NULL,--='11-11-2019',      
 @Liner NVARCHAR(20) = '',--='linear'      
 @Status NVARCHAR(20) = '',      
 @ActionBy NVARCHAR(20) = '',      
 @Referrence NVARCHAR(MAX) = '',      
 @CargoType NVARCHAR(50) = '',      
 @ShippingMethod NVARCHAR(50) = ''      
)      
AS      
BEGIN      
       
 declare @ID BIGINT;      
       
 IF @CargoID <= 0      
 BEGIN         
  INSERT INTO [dbo].[Cargo]      
           ([Consignee],      
      [NotifyParty],      
   [ExportType],      
   [Category],      
   [Incoterms],      
   [StuffingDateStarted],      
   [StuffingDateFinished],      
   [ETA],      
   [ETD],      
   TotalPackageBy,    
   [VesselFlight],      
   [ConnectingVesselFlight],      
   [VoyageVesselFlight],      
   [VoyageConnectingVessel],      
   [PortOfLoading],      
   [PortOfDestination],      
   [SailingSchedule],      
   [ArrivalDestination],      
   [BookingNumber],      
   [BookingDate],      
   [Liner],      
   [Status],      
   [CreateBy]      
           ,[CreateDate]      
           ,[UpdateBy]      
           ,[UpdateDate]      
           ,[IsDelete]      
     ,[Referrence]      
     ,[ShippingMethod]      
     ,[CargoType]      
           )      
     VALUES      
           (@Consignee,      
      @NotifyParty,      
   @ExportType,      
   @Category,      
   @Incoterms,      
   @StuffingDateStarted,      
   @StuffingDateFinished,      
   @ETA,      
   @ETD,      
   @TotalPackageBy,    
   @VesselFlight,      
   @ConnectingVesselFlight,      
   @VoyageVesselFlight,      
   @VoyageConnectingVessel,      
   @PortOfLoading,      
   @PortOfDestination,      
   @SailingSchedule,      
   @ArrivalDestination,      
   @BookingNumber,      
   @BookingDate,      
   @Liner,      
   0      
           ,@ActionBy      
           ,GETDATE()      
           ,@ActionBy      
           ,GETDATE()      
           ,0      
     ,@Referrence      
     ,@ShippingMethod      
     ,@CargoType)      
      
  SET @ID = CAST(SCOPE_IDENTITY() as bigint);      
      
  IF (ISNULL(@Referrence, '') <> '')      
  BEGIN      
   INSERT INTO dbo.CargoCipl (IdCargo, IdCipl, EdoNumber, CreateBy, CreateDate, UpdateBy, UpdateDate, IsDelete)      
   SELECT @ID IdCargo, splitdata as IdCipl, t1.EdoNo, @ActionBy CreateBy, GETDATE() CreateDate, @ActionBy UpdateBy, GETDATE() UpdateDate, 0 IsDelete        
   from fnSplitString(@Referrence, ',') t0      
   JOIN dbo.Cipl t1 on t1.id = t0.splitdata AND t1.IsDelete = 0;      
  END      
      
  EXEC [dbo].[GenerateCargoNumber] @ID;      
  EXEC sp_insert_request_data @ID, 'CL', '', @Status, 'Create';      
  --EXEC [sp_update_request_cl] @ID , @ActionBy, @Status    
      
 END      
 ELSE      
 BEGIN      
  UPDATE [dbo].[Cargo]      
  SET [Consignee] = @Consignee      
   ,[NotifyParty] = @NotifyParty      
   ,[ExportType] = @ExportType      
   ,[Category] = @Category      
   ,[Incoterms] = @Incoterms      
   ,[StuffingDateStarted] = @StuffingDateStarted      
   ,[StuffingDateFinished] = @StuffingDateFinished      
   ,[ETA] = @ETA      
   ,[ETD] = @ETD      
   ,[TotalPackageBy] =@TotalPackageBy    
   ,[VesselFlight] = @VesselFlight      
   ,[ConnectingVesselFlight] = @ConnectingVesselFlight      
   ,[VoyageVesselFlight] = @VoyageVesselFlight      
   ,[VoyageConnectingVessel] = @VoyageConnectingVessel      
   ,[PortOfLoading] = @PortOfLoading      
   ,[PortOfDestination] = @PortOfDestination      
  ,[SailingSchedule] = @SailingSchedule      
   ,[ArrivalDestination] = @ArrivalDestination      
   ,[BookingNumber] = @BookingNumber      
   ,[BookingDate] = @BookingDate      
   ,[Liner] = @Liner      
   ,[UpdateDate] = GETDATE()      
   ,[UpdateBy] = @ActionBy      
   ,[Referrence] = @Referrence      
   ,[ShippingMethod] = @ShippingMethod      
   ,[CargoType] = @CargoType      
  WHERE Id = @CargoID      
      
  SET @ID = @CargoID      
      
  IF (ISNULL(@Referrence, '') <> '')      
  BEGIN      
   DELETE FROM dbo.CargoCipl WHERE IdCargo = @ID;      
      
   INSERT INTO dbo.CargoCipl (IdCargo, IdCipl, EdoNumber, CreateBy, CreateDate, UpdateBy, UpdateDate, IsDelete)      
   SELECT @ID IdCargo, splitdata as IdCipl, t1.EdoNo, @ActionBy CreateBy, GETDATE() CreateDate, @ActionBy UpdateBy, GETDATE() UpdateDate, 0 IsDelete        
   from fnSplitString(@Referrence, ',') t0      
   JOIN dbo.Cipl t1 on t1.id = t0.splitdata AND t1.IsDelete = 0;      
  END      
      
  EXEC [sp_update_request_cl] @ID, @ActionBy, @Status      
 END      
      
 SELECT CAST(@ID as BIGINT) as ID      
      
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_gr]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_insert_update_gr] --exec sp_insert_update_gr 0, 'Tri Artha', '3211022907890004', '234002000', '32001000', 'Z5226BW', '20 Jan 2020', 'testing notes dan lain lain', 'xupj21fig', '20 Jan 2019', 'xupj21fig', '29 Jan 2019', 0 
(
	@Id nvarchar(100),
	@PicName nvarchar(100),
	@KtpName nvarchar(100),
	@PhoneNumber nvarchar(100),
	@SimNumber nvarchar(100),
	@StnkNumber	nvarchar(100),
	@NopolNumber nvarchar(100),
	@EstimationTimePickup date,
	@Notes nvarchar(max),
	@Vendor nvarchar(100),
	@KirNumber nvarchar(50),
	@KirExpire date,
	@Apar bit,
	@Apd bit,
	@VehicleType nvarchar(100),
	@VehicleMerk nvarchar(100),
	@CreateBy nvarchar(100),
	@CreateDate date,
	@UpdateBy nvarchar(100) = '',
	@UpdateDate date,
	@IsDelete bit = 0,
	@SimExpiryDate date,
	@ActualTimePickup date,
	@Status nvarchar(100) = 'Draft',
	@PickupPoint nvarchar(100) = '',
	@PickupPic nvarchar(100) = ''
)
AS
BEGIN
	SET NOCOUNT ON;
	IF ISNULL(@Id, 0) = 0 
	BEGIN
		INSERT INTO [dbo].[GoodsReceive]
           ([PicName]
			, [KtpNumber]
			, [PhoneNumber]
			, [SimNumber]
			, [StnkNumber]
			, [NopolNumber]
			, [EstimationTimePickup]
			, [Notes]
			, [Vendor]
			, [KirNumber]
			, [KirExpire]
			, [Apar]
			, [Apd]
			, [VehicleType]
			, [VehicleMerk]
			, [CreateBy]
			, [CreateDate]
			, [UpdateBy]
			, [UpdateDate]
			, [SimExpiryDate]
			, [PickupPoint]
			, [PickupPic]
			, [IsDelete])
		VALUES
           (@PicName
			, @KtpName
			, @PhoneNumber
			, @SimNumber
			, @StnkNumber
			, @NopolNumber
			, @EstimationTimePickup
			, @Notes
			, @Vendor
			, @KirNumber
			, @KirExpire
			, @Apar
			, @Apd
			, @VehicleType
			, @VehicleMerk
			, @CreateBy
			, @CreateDate
			, @UpdateBy
			, @UpdateDate
			, @SimExpiryDate
			, @PickupPoint
			, @PickupPic
			,0)

		SET @Id = SCOPE_IDENTITY()
		EXEC [dbo].[GenerateGoodsReceiveNumber] @Id
		EXEC [dbo].[sp_insert_request_data] @Id, 'GR', '', @Status, 'Create'
	END
	ELSE 
	BEGIN
		UPDATE [dbo].[GoodsReceive]
		SET [PicName] = @PicName
		      ,[KtpNumber] = @KtpName
		      ,[PhoneNumber] = @PhoneNumber
		      ,[SimNumber] = @SimNumber
		      ,[StnkNumber] = @StnkNumber
		      ,[NopolNumber] = @NopolNumber
		      ,[EstimationTimePickup] = @EstimationTimePickup
		      ,[Notes] = @Notes
			  ,[Vendor] = @Vendor
			  ,[KirNumber] = @KirNumber
			  ,[KirExpire] = @KirExpire
			  ,[Apar] = @Apar
			  ,[Apd] = @Apd
			  ,[VehicleType] = @VehicleType
			  ,[VehicleMerk] = @VehicleMerk
		      ,[UpdateBy] = @UpdateBy
		      ,[UpdateDate] = @UpdateDate
			  ,[SimExpiryDate] = @SimExpiryDate
			  ,[PickupPoint] = @PickupPoint
			  ,[PickupPic] = @PickupPic
		      ,[IsDelete] = @IsDelete
		WHERE Id = @Id

		EXEC [dbo].[sp_update_request_gr] @Id, @UpdateBy, @Status, ''
	END
	SELECT CAST(@Id as bigint) as ID
END

GO

/****** Object:  StoredProcedure [dbo].[SP_NpePebInsert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_NpePebInsert]
(
	@Id BIGINT,
	@IdCl BIGINT,
	@AjuNumber NVARCHAR(200),
	@AjuDate datetime,
	@NpeNumber NVARCHAR(200),
	@NpeDate datetime,
	@Npwp NVARCHAR(50),
	@ReceiverName NVARCHAR(100),
	@PassPabeanOffice NVARCHAR(100),
	@Dhe DECIMAL(20,2),
	@PebFob DECIMAL(18,4),
	@Valuta NVARCHAR(20),
	@DescriptionPassword NVARCHAR(100),
	@DocumentComplete BIT,
	@Rate Decimal(20,2),
	@WarehouseLocation NVARCHAR(50),
	@FreightPayment Decimal(20,2),  
	@InsuranceAmount Decimal(20,2),
	@Status NVARCHAR(10),
	@DraftPeb BIT,
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@IsDelete BIT,
	@RegistrationNumber NVARCHAR(MAX),
    @NpeDateSubmitToCustomOffice datetime
)
AS
BEGIN
	DECLARE @LASTID bigint
	IF @Id = 0
	BEGIN
	INSERT INTO [dbo].[NpePeb]
           ([IdCl]
		   ,[AjuNumber]
           ,[AjuDate]
		   ,[PebNumber]
		   ,[PebDate]
		   ,[NpeNumber]
		   ,[NpeDate]
		   ,[Npwp]
		   ,[ReceiverName]
		   ,[PassPabeanOffice]
		   ,[Dhe]
		   ,[PebFob]
		   ,[Valuta]
		   ,[DescriptionPassword]
		   ,[DocumentComplete]
		   ,[Rate]
		   ,[WarehouseLocation]
		   ,[FreightPayment]
		   ,[InsuranceAmount]
		   ,[DraftPeb]
		   ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
		   ,[RegistrationNumber]
		   ,[NpeDateSubmitToCustomOffice]
           )
     VALUES
           (@IdCl
		   ,@AjuNumber
           ,@AjuDate
		   ,@AjuNumber
           ,@AjuDate
		   ,@NpeNumber
		   ,@NpeDate
		   ,@Npwp
		   ,@ReceiverName
		   ,@PassPabeanOffice
		   ,@Dhe
		   ,@PebFob
		   ,@Valuta
		   ,@DescriptionPassword
		   ,@DocumentComplete
		   ,@Rate
		   ,@WarehouseLocation
		   ,@FreightPayment
		   ,@InsuranceAmount
		   ,@DraftPeb
           ,@CreateBy
           ,@CreateDate
           ,@UpdateBy
           ,@UpdateDate
           ,@IsDelete
		   ,@RegistrationNumber
		   ,@NpeDateSubmitToCustomOffice
		   )

	SELECT @LASTID = CAST(SCOPE_IDENTITY() as bigint)
	
	--EXEC [sp_update_request_cl] @IdCl, @CreateBy, 'SUBMIT', ''
	SELECT C.Id as ID, CAST(C.IdCl AS nvarchar) as [NO], C.CreateDate as CREATEDATE FROM NpePeb C WHERE C.id = @LASTID
	END 
	ELSE
	BEGIN
	UPDATE [dbo].[NpePeb]
		SET [AjuNumber] = @AjuNumber
		   ,[AjuDate] = @AjuDate
		   ,[PebNumber] = @AjuNumber
		   ,[PebDate] = @AjuDate
		   ,[NpeNumber] = @NpeNumber
		   ,[NpeDate] = @NpeDate
		   ,[Npwp] = @Npwp
		   ,[ReceiverName] = @ReceiverName
		   ,[PassPabeanOffice] = @PassPabeanOffice
		   ,[Dhe] = @Dhe
		   ,[PebFob] = @PebFob
		   ,[Valuta] = @Valuta
		   ,[DescriptionPassword] = @DescriptionPassword
		   ,[DocumentComplete] = @DocumentComplete
		   ,[Rate] = @Rate
		   ,[WarehouseLocation] = @WarehouseLocation
		   ,[FreightPayment] = @FreightPayment
		   ,[InsuranceAmount] = @InsuranceAmount
		   ,[DraftPeb] = @DraftPeb
           ,[CreateBy] = @CreateBy
           ,[CreateDate] = @CreateDate
           ,[UpdateBy] = @CreateBy
           ,[UpdateDate] = @CreateDate
           ,[IsDelete] = @IsDelete
		   ,[RegistrationNumber] = @RegistrationNumber
		  ,[NpeDateSubmitToCustomOffice] = @NpeDateSubmitToCustomOffice
		   WHERE Id = @Id
		   SELECT C.Id as ID, CAST(C.IdCl AS nvarchar) as [NO], C.CreateDate as CREATEDATE FROM NpePeb C WHERE C.id = @Id
	END;

	IF(@Status <> 'Draft')
	BEGIN
		IF(@DraftPeb = 1 AND @DocumentComplete = 0)
			BEGIN
				SET @Status = 'Draft NPE'
			END
		ELSE IF (@DraftPeb = 1 AND @DocumentComplete = 1)
			BEGIN
				SET @Status = 'Create NPE'
			END
		EXEC [sp_update_request_cl] @IdCl, @CreateBy, @Status, ''
	END

END

GO

/****** Object:  StoredProcedure [dbo].[SP_Process_SIB]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author  : Ali Mutasal    
-- Create date : 23 April 2019    
-- Description : SP UPDATE INSERT     
-- =============================================    
ALTER PROCEDURE [dbo].[SP_Process_SIB]    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
    -- Insert statements for procedure here    
 BEGIN TRAN;    
 MERGE Reference AS T    
 USING (SELECT DISTINCT ReqNumber, DlrWO, DlrClm, SvcClm, PartNo, SerialNumber, [Description], DlrCode, UnitPrice, Currency, Qty FROM MasterSIB) AS S    
 ON (S.DlrCode = T.ReferenceNo and S.ReqNumber = T.SIBNumber and S.DlrWO = T.WONumber and S.PartNo = T.PartNumber 
 and S.SerialNumber = T.UnitSN and S.[Description] = T.UnitName and S.DlrCode = T.JCode and S.UnitPrice = T.UnitPrice 
 and S.SvcClm = T.Claim AND S.Currency = T.Currency and S.Qty = T.Quantity)    
 WHEN NOT MATCHED BY TARGET    
    THEN     
  INSERT(    
   ReferenceNo    
   ,PartNumber    
   ,UnitSN    
   ,UnitName    
   ,UnitPrice    
   ,JCode    
   ,SIBNumber    
   ,WONumber    
   ,Quantity    
   ,AvailableQuantity    
   ,Category    
   ,CreateBy    
   ,CreateDate    
   ,Claim    
   ,Currency)     
  VALUES(    
   S.DlrCode    
   ,S.PartNo    
   ,S.SerialNumber    
   ,S.[Description]    
   ,S.UnitPrice    
   ,S.DlrCode    
   ,S.ReqNumber    
   ,S.DlrWO    
   , S.Qty    
   , S.Qty    
   ,'SIB'    
   ,'system'    
   ,GETDATE()    
   ,S.SvcClm    
   ,S.Currency)      
 WHEN MATCHED     
  THEN UPDATE SET     
  T.ReferenceNo = S.DlrCode    
  ,T.PartNumber = S.PartNo    
  ,T.UnitSN = S.SerialNumber    
  ,T.UnitName = S.Description    
  ,T.UnitPrice = S.UnitPrice    
  ,T.JCode = S.DlrCode    
  ,T.SIBNumber = S.ReqNumber    
  ,T.WONumber = S.DlrWO    
  ,T.Quantity = S.Qty    
  ,T.AvailableQuantity = S.Qty    
  ,T.UpdateBy = 'system'    
  ,T.UpdateDate = GETDATE()    
  ,T.Claim = S.SvcClm    
  ,T.Currency = S.Currency    
  OUTPUT $action, Inserted.*, Deleted.*;    
    
 COMMIT TRAN;    
-- ROLLBACK TRAN;    
END    
GO

/****** Object:  StoredProcedure [dbo].[SP_RAchievement]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<hasni,Sandi>
-- Create date: <20191007>
-- Update date: <20220929>
-- =============================================
--EXEC PROCEDURE [dbo].[SP_RAchievement] '2020-02-11', '2020-01-01'
ALTER PROCEDURE [dbo].[SP_RAchievement]
(
	@StartDate nvarchar(50),
	@EndDate nvarchar(50)
)	
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
	MasterCycle.[Name] [Cycle], 
	CONCAT(ISNULL(MasterCycle.[TargetDays], 0), ' Days') [Target], 
	CONCAT(ISNULL(Actual, 0), ' Days') [Actual], 
	CAST(ISNULL([Achieved], 0) as varchar) [Achieved], 
	CAST(ISNULL([TotalData], 0) as varchar) [TotalData], 
	--(TotalData - Achieved) [Unachieved], 
	SUBSTRING(CAST(CASE WHEN TotalData > 0 THEN (
		(
			ROUND(
				CAST(Achieved as decimal) / CAST(TotalData as decimal) *100
				, 2
			)
		) 
	) ELSE 100 END as varchar), 0, 6) [Achievement]
FROM 
	(SELECT [Value], [Name], [Description] [TargetDays]
			FROM MasterParameter
			WHERE [group]='Achievement') MasterCycle
	LEFT JOIN (
	--cipl approved
	SELECT 
		MIN(t3.[Name]) [Name],
		max(t3.[TargetDays]) [TargetDays],
		CAST(AVG(
			CAST(
				CAST(DATEDIFF(hour,t1x.[SubmitDate],t1.ApprovedDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual],
		SUM(CASE WHEN (CAST(
				CAST(DATEDIFF(hour,t1x.[SubmitDate],t1.ApprovedDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			) <= t3.TargetDays) THEN 1 ELSE 0 END) [Achieved],
		COUNT(t1.IdCipl) as [TotalData]
	FROM
		Cipl t0
		JOIN (
			SELECT max(CreateDate) as [ApprovedDate], IdCipl, '1' as [Name]
				FROM [EMCS].[dbo].[CiplHistory] t0
			where Status = 'Approve' AND Step = 'Approval By Superior'
			GROUP BY IdCipl) as t1 on t1.IdCipl = t0.id
		JOIN (
			SELECT min(CreateDate) as [SubmitDate], IdCipl as [IdCiplx], '1' as [Name]
				FROM [EMCS].[dbo].[CiplHistory] t0
			where Status = 'Submit' 
			GROUP BY IdCipl) as t1x on t1x.IdCiplx = t0.id
		JOIN (SELECT [Value], [Name], [Description] [TargetDays]
			FROM MasterParameter
			WHERE [group]='Achievement' AND [Value] = 1) t3 ON 1 = 1
	WHERE [ApprovedDate] BETWEEN @StartDate AND @EndDate
	GROUP BY t1.[Name]

	UNION 

	--pickup goods
	SELECT
		MIN(t3.[Name]) [Name],
		max(t3.[TargetDays]) [TargetDays],
		CAST(AVG(
			CAST(
				CAST(DATEDIFF(hour,t2x.[SubmitDate], t2.ApprovedDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual],
		SUM(CASE WHEN (CAST(
				CAST(DATEDIFF(hour,t2x.[SubmitDate], t2.ApprovedDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			) <= t3.TargetDays) THEN 1 ELSE 0 END) [Achieved],
		COUNT(t2.EdoNo) as [TotalData]
	FROM
	ShippingFleet t0
	--JOIN ShippingFleetItem t1 on t1.IdShippingFleet = t0.Id
	JOIN (
		SELECT max(t0.CreateDate) as [SubmitDate], EdoNo, '2' as [Name]
			FROM [EMCS].[dbo].CiplHistory t0
			join Cipl t1 on t1.id = t0.IdCipl
		where Status = 'Submit'
		GROUP BY EdoNo) as t2x on t2x.EdoNo = t0.DoNo
	JOIN (
		SELECT max(t0.CreateDate) as [ApprovedDate], EdoNo, '2' as [Name]
			FROM [EMCS].[dbo].CiplHistory t0
			join Cipl t1 on t1.id = t0.IdCipl
		where Status = 'Approve'
		GROUP BY EdoNo) as t2 on t2.EdoNo = t0.DoNo
	JOIN (SELECT [Value], [Name], [Description] [TargetDays]
		FROM MasterParameter
		WHERE [group]='Achievement' AND [Value] = 2) t3 ON 1 = 1
	WHERE [ApprovedDate] BETWEEN @StartDate AND @EndDate
	GROUP BY t2.Name
	
	UNION 

	--NPE PEB
	SELECT 
		MIN(t3.[Name]) [Name],
		max(t3.[TargetDays]) [TargetDays],
		CAST(AVG(
			CAST(
			    CAST(DATEDIFF(hour,t0.NpeDateSubmitToCustomOffice, t0.NpeDate) as decimal(18,3)) 
				--CAST(DATEDIFF(hour,t0.NpeDate,t0.BlDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual],
		SUM(CASE WHEN (CAST(
				CAST(DATEDIFF(hour,t0.NpeDate,t0.NpeDateSubmitToCustomOffice) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			) <= t3.TargetDays) THEN 1 ELSE 0 END) [Achieved],
		COUNT(t0.NpeDate) as [TotalData]
	FROM
		(SELECT N.NpeDateSubmitToCustomOffice, N.NpeDate, '3' [Name] FROM NpePeb N 
		INNER JOIN BlAwb B ON B.IdCl = N.IdCl 
		INNER JOIN RequestCl RCL ON RCL.IdCl = B.IdCl 
		--INNER JOIN RequestCl RCLx ON (RCLx.IdCl = B.IdCl AND Rclx.CreateDate BETWEEN @StartDate AND @EndDate)
		WHERE
		RCL.IdStep = 10022 AND RCL.Status = 'Approve'  ) t0
		JOIN (SELECT [Value], [Name], [Description] [TargetDays]
			FROM MasterParameter
			WHERE [group]='Achievement' AND [Value] = 3) t3 ON 1 = 1
		WHERE t0.NpeDate is NOT NULL 
			AND (t0.NpeDateSubmitToCustomOffice<>'1900-01-01 00:00:00' AND t0.NpeDateSubmitToCustomOffice IS NOT NULL)
			AND t0.NpeDate BETWEEN @StartDate AND @EndDate
	GROUP BY t0.[Name]

	UNION

	--BL/AWB
	SELECT 
		MIN(t3.[Name]) [Name],
		max(t3.[TargetDays]) [TargetDays],
		CAST(AVG(
			CAST(
			    CAST(DATEDIFF(hour,t0.NpeDate,t0.MasterBlDate) as decimal(18,3)) 
				--CAST(DATEDIFF(hour,t0.NpeDate,t0.BlDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual],
		SUM(CASE WHEN (CAST(
				CAST(DATEDIFF(hour,t0.NpeDate,t0.MasterBlDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			) <= t3.TargetDays) THEN 1 ELSE 0 END) [Achieved],
		COUNT(t0.MasterBlDate) as [TotalData]
	FROM
		(SELECT N.NpeDate, B.MasterBlDate, '4' [Name] FROM NpePeb N
		INNER JOIN BlAwb B ON B.IdCl = N.IdCl 
		INNER JOIN Cargo cl ON cl.id = B.IdCl
		INNER JOIN RequestCl RCL ON RCL.IdCl = B.IdCl 
		--INNER JOIN RequestCl RCLx ON (RCLx.IdCl = B.IdCl AND Rclx.CreateDate BETWEEN @StartDate AND @EndDate)
		WHERE
		RCL.IdStep = 10022 AND RCL.Status = 'Approve' AND ShippingMethod <> 'Air' ) t0
		JOIN (SELECT [Value], [Name], [Description] [TargetDays]
			FROM MasterParameter
			WHERE [group]='Achievement' AND [Value] = 4) t3 ON 1 = 1
		--(SELECT NPEDate, BlDate, '4' [Name] FROM Cargo) t0
		WHERE t0.MasterBlDate is NOT NULL 
			AND t0.NpeDate<>'1900-01-01 00:00:00'
			AND t0.MasterBlDate BETWEEN @StartDate AND @EndDate
	GROUP BY t0.[Name]
	) [DataAchievement] ON MasterCycle.[Name] = [DataAchievement].[Name]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_RBigestCommodities]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_RBigestCommodities] (@date1        nvarchar(50),  
                                               @ExportType   nvarchar(100))   
AS   
  BEGIN  
 DECLARE @sql NVARCHAR(max);  
 DECLARE @and NVARCHAR(max);  
  
 IF(@ExportType IS NULL OR @ExportType = '')  
 BEGIN  
  SET @and = 'AND C.ExportType IS NOT NULL';  
 END  
 ELSE   
 BEGIN  
  SET @and = 'AND C.ExportType LIKE '''+@ExportType+'%'' ';  
 END  
  
 SET @sql = 'SELECT ''PP/UE'' [Category] 
	,(SELECT CASE   
		WHEN T1.Name = ''Engine''  
		THEN ''Engine'' 
		WHEN T1.Name = ''Machine''  
		THEN ''Machine''  
		WHEN T1.Name = ''Forklift''  
		THEN ''Forklift''  
		ELSE ''Parts''  
	  END  
	) [Desc]
	, ISNULL(T2.TotalSales, 0) [TotalSales]
	, ISNULL(T2.TotalNonSales, 0) [TotalNonSales]
	, ISNULL(T2.Total, 0) [Total]
FROM	(SELECT	MP.Name, MP.[Group]  
		FROM	MasterParameter MP  
		WHERE	MP.[Group] IN (''CategoryUnit'')) T1  
		LEFT JOIN ( SELECT	T3.CategoriItem, SUM(T3.TotalSales) [TotalSales], SUM(T3.TotalNonSales) [TotalNonSales], SUM(T3.Total) [Total]
					FROM (	SELECT DISTINCT A1.CategoriItem, A1.TotalSales * 100/T2.Total [TotalSales], A1.TotalNonSales * 100/T2.Total [TotalNonSales], A1.Total * 100/T2.Total [Total]
							FROM (	SELECT	C.CategoriItem, 
											CASE WHEN C.ExportType LIKE ''Sales%'' THEN Count(C.ExportType) ELSE 0 END [TotalSales],
											CASE WHEN C.ExportType LIKE ''Non Sales%'' THEN Count(C.ExportType) ELSE 0 END [TotalNonSales],
											COUNT(C.CategoriItem) [Total]
									FROM	cipl C  
											INNER JOIN CargoCipl CC ON CC.IdCipl = C.id  
											INNER JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo  
											INNER JOIN MasterParameter MP ON MP.Name = C.CategoriItem  
									WHERE	MP.[Group] = ''CategoryUnit''  
											AND RCL.IdStep IN ( 10019
																,10020  
																,10021  
																,10022  
																,10043)  
											AND RCL.STATUS = ''Approve'' 
											' + @and + '   
											AND C.IsDelete = 0  
									GROUP BY C.ExportType, C.Category, C.CategoriItem) A1  
									LEFT JOIN (	SELECT	Count(C.CategoriItem) Total, C.CategoriItem  
												FROM	cipl C  
														LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id  
														LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo  
														LEFT JOIN MasterParameter MP ON MP.Name = C.CategoriItem  
												WHERE MP.[Group] = ''CategoryUnit'' 
												' + @and + '   
												AND C.IsDelete = 0  
												GROUP BY C.CategoriItem) T2 ON T2.CategoriItem = A1.CategoriItem ) AS T3
					GROUP BY CategoriItem) AS T2 ON T2.CategoriItem = T1.Name
UNION ALL  
SELECT (  
	SELECT CASE   
		WHEN T1.Name = ''CATERPILLAR SPAREPARTS''  
			THEN ''PARTS''
		WHEN T1.Name = ''MISCELLANEOUS''  
			THEN ''MISC''  
		END  
	)  
	,(  
	  SELECT CASE   
		WHEN T1.Name = ''CATERPILLAR SPAREPARTS''
		 THEN ''Parts''  
		WHEN T1.Name = ''MISCELLANEOUS''
		 THEN ''Misc''  
		END  
	  ) Category  
	, ISNULL(T2.TotalSales, 0) [TotalSales]
	, ISNULL(T2.TotalNonSales, 0) [TotalNonSales]
	, ISNULL(T2.Total, 0) [Total] 
FROM	(SELECT	MP.Name, MP.[Group]  
		 FROM	MasterParameter MP  
		 WHERE	MP.[Name] IN (''CATERPILLAR SPAREPARTS'', ''MISCELLANEOUS'')) T1  
		LEFT JOIN ( SELECT	T3.Category, SUM(T3.TotalSales) [TotalSales], SUM(T3.TotalNonSales) [TotalNonSales], SUM(T3.Total) [Total]
					FROM	(	SELECT DISTINCT A1.Category, A1.TotalSales * 100/T2.Total [TotalSales], A1.TotalNonSales * 100/T2.Total [TotalNonSales], A1.Total * 100/T2.Total [Total]
								FROM (	SELECT  DISTINCT C.Category, 
												CASE WHEN C.ExportType LIKE ''Sales%'' THEN Count(C.ExportType) ELSE 0 END [TotalSales],
												CASE WHEN C.ExportType LIKE ''Non Sales%'' THEN Count(C.ExportType) ELSE 0 END [TotalNonSales],
												COUNT(C.Category) [Total]
										FROM	cipl C  
												LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id  
												LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo  
												LEFT JOIN MasterParameter MP ON MP.Name = C.Category  
										WHERE	MP.Name IN (''CATERPILLAR SPAREPARTS'',''MISCELLANEOUS'')  
												AND RCL.IdStep IN (  10019
																	,10020  
																	,10021  
																	,10022  
																	,10043)  
												AND RCL.STATUS = ''Approve''
												' + @and + '   
												AND C.IsDelete = 0  
										GROUP BY C.Category, C.ExportType) A1  
										LEFT JOIN (	SELECT Count(C.Category) Total, C.Category  
													FROM cipl C  
														LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id  
														LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo  
													WHERE C.Category IN (''CATERPILLAR SPAREPARTS'',''MISCELLANEOUS'') 
													' + @and + '   
														AND C.IsDelete = 0  
													GROUP BY C.Category) T2 ON T2.Category = A1.Category ) AS T3
					GROUP BY Category) AS T2 ON T2.Category = T1.Name
 ORDER BY [Desc], TotalSales, TotalNonSales DESC';  
  
 EXECUTE (@sql);  
END  
--USE [EMCS]  
--GO  
--SET ANSI_NULLS ON  
--GO  
--SET QUOTED_IDENTIFIER ON  
--GO  
  
--ALTER PROCEDURE [dbo].[SP_RBigestCommodities] (@date1        datetime,   
--                                               @date2        datetime,   
--                                               @CategoryItem nvarchar(50),   
--                                               @ExportType   nvarchar(100))   
--AS   
--  BEGIN   
--      SET NOCOUNT ON;   
  
--      DECLARE @SQL nvarchar(max);   
  
--      IF( @CategoryItem = 'Parts' )   
--        BEGIN   
--            SET @SQL =   
--            '''PRA'' OR C.CategoryItem = ''Old Core'' OR C.Categori = ''SIB''';   
--        END   
--      ELSE IF( @CategoryItem = 'Engine' )   
--        BEGIN   
--            SET @SQL = 'Engine';   
--        END   
--      ELSE IF( @CategoryItem = 'Forklift' )   
--        BEGIN   
--            SET @SQL = 'Forklift';   
--        END   
--      ELSE IF( @CategoryItem = 'Mesin' )   
--        BEGIN   
--            SET @SQL = 'Mesin';   
--        END   
--      ELSE   
--        BEGIN   
--            SET @SQL = '' + @CategoryItem + ' ';   
--        END   
  
--      SELECT MP.[Group]   
--             Category,   
--             MP.Name   
--             [DESC]   
--             ,   
--             ISNULL(Cast(NULLIF((SELECT Count(C.CategoriItem)   
--                                 FROM   cipl C   
--                                        INNER JOIN CargoItem CI   
--                                                ON C.id = CI.IdCipl   
--                                        INNER JOIN RequestCl RCL   
--                                                ON CI.IdCargo = RCL.Id   
--                                 WHERE  C.CategoriItem = @SQL   
--                                        AND C.ExportType LIKE '' + @ExportType +   
--                                                              '%'   
--                                        AND C.CreateDate BETWEEN   
--                                            CONVERT(datetime, @date1)   
--                                            AND   
--                                            CONVERT(datetime, @date2)   
--                                        AND RCL.IdStep IN ( 10020, 10021, 10022,   
--                                                            10043   
--                                                          )   
--                                        AND RCL.Status = 'Approve'   
--                                        AND C.IsDelete = 0), 0) * 100 / NULLIF(   
--                                     (SELECT Count(C.CategoriItem)   
--                                      FROM   cipl C   
--                                                                        INNER   
--                                             JOIN   
--                                             CargoItem CI   
--                                                     ON   
--                                             C.id = CI.IdCipl   
--                                             INNER JOIN   
--                                             RequestCl RCL   
--                                                     ON CI.IdCargo   
--                                                        =   
--                                                        RCL.Id   
--                                                     WHERE   
--                                             C.CategoriItem =   
--                     @CategoryItem   
--                                             AND   
--                                     C.ExportType   
--                                     LIKE '' + @ExportType   
--                                          +   
--                                          '%'   
--                                             AND   
--  C.CreateDate   
--  BETWEEN   
--  CONVERT(datetime, @date1) AND   
--  CONVERT(datetime, @date2)   
--  AND C.IsDelete = 0), 0) AS int), 0) TOTAL   
--  FROM   MasterParameter MP   
--  WHERE  MP.Name = @CategoryItem   
--  END   
GO

/****** Object:  StoredProcedure [dbo].[SP_RDetailsTracking]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_RDetailsTracking]     
 @StartMonth NVARCHAR(20),    
 @EndMonth NVARCHAR(20),    
 @ParamName NVARCHAR(50),    
 @ParamValue NVARCHAR(200),    
 @KeyNum NVARCHAR(200)    
AS    
BEGIN    
DECLARE @SQL as nvarchar(Max)    
declare @whereRef nvarchar(max) =''    
    
IF @StartMonth <>'' AND @EndMonth<>''    
 BEGIN    
     SET @whereRef=' AND CiplDate >= '''+ @StartMonth +''' AND CiplDate <= '''+ @EndMonth +''' '    
  END    
  print (@whereRef)    
    
   IF @ParamName <>''    
 BEGIN    
     SET @whereRef+=' and DescGoods = ''' + @ParamName  +''''    
  END    
   IF @ParamValue <>''    
 BEGIN    
     SET @whereRef+=' and CategoriItem = ''' + @ParamValue +''''     
  END    
 IF @KeyNum <> ''    
 BEGIN    
     SET @whereRef+=' AND CiplNo = '''+ @KeyNum +''' or RGNo = '''+ @KeyNum +''' or ClNo ='''+ @KeyNum +''' or SsNo = '''+ @KeyNum +''' or SINo = '''+ @KeyNum +''' or NOPEN = '''+ @KeyNum +''''    
  END    
    -- Insert statements for procedure here    
SET @SQL = 'SELECT * FROM [fn_GetReportDetailTracking_RDetails]() WHERE CIPLNo<>'''' '+ @whereRef + ' ORDER BY CiplDate ASC'    
   print @whereRef    
    print @SQL    
   exec(@SQL);    
END    

GO

/****** Object:  StoredProcedure [dbo].[SP_RTaxAudit]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hasni
-- Create date: 14/10/2019
-- Description:	SP Tax Audit Report
-- =============================================
--DROP PROCEDURE [dbo].[SP_RTaxAudit]
ALTER PROCEDURE [dbo].[SP_RTaxAudit]
(
	@StartDate nvarchar(100),
	@EndDate nvarchar(100)
)
AS
BEGIN
	SELECT  ROW_NUMBER() OVER(ORDER BY t2.idCipl ASC) AS [No],
		IIF(t0.ConsigneeName is NULL, t0.SoldToName, t0.ConsigneeName)  as [Name],
		IIF(t0.ConsigneeAddress is NULL, t0.SoldToAddress, t0.ConsigneeAddress) as [Address],
		ISNULL(t4.PebNumber,'-') AS pebNo,		
		FORMAT( t4.PebDate,'dd/MM/yyyy hh:mm:ss') PebDate,
		t1.Currency as CurrInvoice,
		t1.CurrValue,
		t4.Rate,
		ISNULL(t5.PPJKName, '-') AS PPJKName,
		ISNULL(t5.Address,'-') as PPJKAddress,
		t1.CurrValue * t4.Rate as DPPExport,
		ISNULL(t6.DoNo, '-') AS DoNo,
		ISNULL(t6.DaNo, '-') AS DaNo,
		FORMAT( t7.ApprovedDate,'dd/MM/yyyy hh:mm:ss') DoDate,
		--CONVERT(varchar, t7.ApprovedDate, 113) as DoDate,
		ISNULL(t4.WarehouseLocation,'-') AS WarehouseLoc,
		ISNULL(t3.PortOfLoading, '-') as LoadingPort,
		ISNULL(t4.NpeNumber,'-') as NPENo,
		FORMAT(t4.NpeDate,'dd/MM/yyyy') NpeDate,
		--CONVERT(varchar,t4.NpeDate, 113) NpeDate,
		ISNULL(t0.CiplNo,'-') as InvoiceNo,
		FORMAT(t0.CreateDate,'dd mmm yyyy hh:mm:ss') InvoiceDate,
		--CONVERT(varchar,t0.CreateDate, 113)  as InvoiceDate,
		ISNULL(t8.Publisher,'-') AS Publisher,
		ISNULL(t8.Number, '-') as BlAwbNo,
		ISNULL(FORMAT(t8.BlAwbDate,'dd mmm yyyy hh:mm:ss'), '-') AS BlAwbDate,
		--CONVERT(varchar,t8.BlAwbDate, 113)  as BlAwbDate,
		ISNULL(t3.PortOfDestination,'-') as DestinationPort,
		ISNULL(t0.Remarks,'-') AS Remarks,
		docNpe.[Filename] AS FilePeb,
		docBlAwb.[Filename] AS FileBlAwb,
		t0.ReferenceNo, -- added 2022-09-02
		(SELECT STUFF(
			(SELECT DISTINCT (', ' + QuotationNo) FROM Reference ref INNER JOIN CiplItem item ON item.ReferenceNo=ref.ReferenceNo
			WHERE item.idCipl = t0.id FOR XML PATH(''))
		, 1, 2, '')) QuotationNo, -- added 2022-09-02
		(SELECT STUFF(
			(SELECT DISTINCT (', ' + POCustomer) FROM Reference ref INNER JOIN CiplItem item ON item.ReferenceNo=ref.ReferenceNo
			WHERE item.idCipl = t0.id FOR XML PATH(''))
		, 1, 2, '')) POCustomer -- added 2022-09-02
	FROM
		Cipl t0
		JOIN (SELECT 
			DISTINCT Currency, 
					IdCipl, 
					SUM(UnitPrice) CurrValue 
			FROM CiplItem 
			GROUP BY Currency, IdCipl
			) as t1 on t1.IdCipl = t0.id
		JOIN CargoCipl t2 on t2.IdCipl = t0.id
		JOIN Cargo t3 on t3.Id = t2.IdCargo
		JOIN NpePeb t4 on t4.IdCl = t3.id
		JOIN (SELECT
				IIF(Attention is NULL, Company, Attention) PPJKName,Address,
				IdCipl
			FROM CiplForwader WHERE Forwader = 'CKB'
			) t5 on t5.IdCipl = t0.id
		JOIN ShippingFleet t6 on t6.DoNo = t0.EdoNo
		JOIN (SELECT  max(CreateDate) as ApprovedDate, IdCipl
				FROM CiplHistory
				WHERE Status = 'Approve'
				GROUP BY IdCipl
			) t7 on t7.IdCipl = t0.id 
		JOIN BlAwb t8 on t8.IdCl = t3.Id
		JOIN RequestCl t9 on t9.IdCl = t3.Id
		JOIN Documents docNpe ON docNpe.idrequest = t4.idcl AND docNpe.Category = 'NPE/PEB' AND docNpe.Tag = 'COMPLETEDOCUMENT'
		JOIN Documents docBlAwb ON docBlAwb.idrequest = t4.idcl AND docBlAwb.Category = 'BL/AWB'
	WHERE t9.IdStep = 10022
		and t9.[Status] = 'Approve'
		and t4.NpeDate between @StartDate and @EndDate
END

GO

/****** Object:  StoredProcedure [dbo].[sp_send_email_for_single]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_send_email_for_single](          
                @subject nvarchar(max),          
                @to nvarchar(max),          
                @content nvarchar(max),          
    @Email nvarchar(max) = ''          
)          
AS          
BEGIN          
                SET NOCOUNT ON          
          
                -- Send Email to User Here          
                IF (@to <> '' AND @Email = '')          
    BEGIN          
     SELECT @Email = Email           
     FROM dbo.fn_get_employee_internal_ckb()           
     WHERE AD_User = @to;          
    END          
                          
                EXEC msdb.dbo.sp_send_dbmail           
                                @recipients = 'ict.bpm02@trakindo.co.id', @copy_recipients = 'projectsupport@mkindo.com',          
                                @subject = @subject,          
                                @body = @content,          
                                @body_format = 'HTML',          
                                @profile_name = 'EMCS';          
          
                insert into dbo.Test_Email_Log ([To], Content, [Subject], CreateDate) values (@Email, @Content, @subject, GETDATE());          
          
END
GO

/****** Object:  StoredProcedure [dbo].[SP_SIInsert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_SIInsert]    
(    
 @ID BIGINT,    
 @IdCL BIGINT,    
 @Description NVARCHAR(MAX),    
 @SpecialInstruction NVARCHAR(MAX),    
 @DocumentRequired NVARCHAR(MAX),    
 @PicBlAwb NVARCHAR(10),    
 @CreateBy NVARCHAR(50),    
 @CreateDate datetime,    
 @UpdateBy NVARCHAR(50),    
 @UpdateDate datetime,    
 @IsDelete BIT,    
 @ExportType NVARCHAR(10)    
)    
AS    
BEGIN    
DECLARE @LASTID bigint    
 IF @Id <= 0    
 BEGIN    
 INSERT INTO [dbo].[ShippingInstruction]    
           ([Description]    
     ,[IdCL]    
           ,[SpecialInstruction]  
		   ,[DocumentRequired]
     ,[PicBlAwb]    
     ,[CreateBy]    
           ,[CreateDate]    
           ,[UpdateBy]    
           ,[UpdateDate]    
           ,[IsDelete]    
     ,[ExportType]    
           )    
     VALUES    
           (@Description    
     ,@IdCL    
           ,@SpecialInstruction 
		   ,@DocumentRequired
     ,@PicBlAwb    
           ,@CreateBy    
           ,@CreateDate    
           ,@UpdateBy    
           ,@UpdateDate    
           ,@IsDelete    
     ,@ExportType)    
    
 SELECT @LASTID = CAST(SCOPE_IDENTITY() as bigint)    
 EXEC dbo.GenerateShippingInstructionNumber @LASTID, @CreateBy;    
  
 SELECT @LASTID = CAST(SCOPE_IDENTITY() as bigint)    
SELECT C.id as ID, C.SlNo as [NO], C.CreateDate as CREATEDATE FROM ShippingInstruction C WHERE C.id = @LASTID     
 END    
 ELSE     
 BEGIN    
 UPDATE [ShippingInstruction] SET  
 [Description] = @Description,  
 [SpecialInstruction] = @SpecialInstruction, 
 [DocumentRequired] = @DocumentRequired,
 PicBlAwb = @PicBlAwb,  
 [UpdateBy] = @UpdateBy,  
 [UpdateDate] = @UpdateDate  
 WHERE Id = @ID  
     SELECT C.id as ID, C.SlNo as [NO], C.CreateDate as CREATEDATE FROM ShippingInstruction C WHERE C.id = @ID      
 END    
END 

GO

/****** Object:  StoredProcedure [dbo].[sp_update_request_cl]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_update_request_cl]     
(    
 @IdCl bigint,    
 @Username nvarchar(100),    
 @NewStatus nvarchar(100),    
 @Notes nvarchar(100) = ''     
)    
AS    
BEGIN    
 DECLARE @NewStepId bigint;    
 DECLARE @IdFlow bigint;    
 DECLARE @FlowName nvarchar(100);    
 DECLARE @NextStepName nvarchar(100);    
 DECLARE @Now datetime;    
 DECLARE @GroupId nvarchar(100);    
 DECLARE @UserType nvarchar(100);    
 DECLARE @NextStepIdSystem bigint;    
 DECLARE @LoadingPort nvarchar(100);    
 DECLARE @DestinationPort nvarchar(100);    
 DECLARE @CurrentStepId bigint;    
 DECLARE @CurrentStatus nvarchar(100);    
      
 SET @Now = GETDATE();    
 select @UserType = [Group] From dbo.fn_get_employee_internal_ckb() WHERE AD_User = @Username    
    
 IF @UserType <> 'internal' AND @UserType = 'CKB'    
 BEGIN    
  SET @GroupId = 'CKB';    
 END    
 ELSE     
 BEGIN    
  SELECT @GroupId = hce.Organization_Name     
  FROM employee hce     
  WHERE hce.AD_User = @Username;    
 END    
    
 --select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cl_request_list(@Username, @GroupId) t0 where t0.IdCl = @IdCl;    
 --select * from dbo.fn_get_cl_request_list_all() where IdCl = 3;    
    
 Select @CurrentStepId = IdStep, @CurrentStatus = [Status] From [dbo].[RequestCl] WHERE IdCl = @IdCl    
        
    IF @NewStatus = 'Approve'    
    BEGIN    
        SELECT @LoadingPort = PortOfLoading , @DestinationPort = PortOfDestination FROM Cargo where Id = @IdCl     
        Update Cipl SET LoadingPort = @LoadingPort ,DestinationPort = @DestinationPort Where id in (Select IdCipl From CargoCipl where IdCargo = @IdCl)    
    END    
    
    
 IF @CurrentStepId = 30069    
    BEGIN    
        IF @NewStatus = 'Approve'    
        BEGIN    
            SET @NewStepId = 30070    
            SET @NextStepName = 'Waiting NPE Document'    
            SET @FlowName = 'CL'    
        END    
        ELSE IF @NewStatus = 'Revise'    
        BEGIN    
            SET @NewStepId = 30070    
            SET @NextStepName = 'Need revision review by imex'    
            SET @FlowName = 'CL'    
            SET @NewStatus = 'Revise'    
        END      
        ELSE IF @NewStatus = 'Reject'    
        BEGIN    
            SET @NewStepId = 30070    
            SET @NextStepName = 'Reject by imex'    
            SET @FlowName = 'CL'    
            SET @NewStatus = 'Reject'    
        END      
    
        UPDATE [dbo].[RequestCl]    
        SET [IdStep] = @NewStepId    
            ,[Status] = @NewStatus    
            --,[Pic] = @Username    
            ,[UpdateBy] = @Username    
            ,[UpdateDate] = GETDATE()    
        WHERE IdCl = @IdCl    
    END    
 ELSE IF @CurrentStepId = 30071    
    BEGIN    
        IF @NewStatus = 'Approve'    
        BEGIN    
            SET @NewStepId = 10020    
            SET @NextStepName = 'Waiting for BL or AWB'    
            SET @FlowName = 'CL'    
        END    
        ELSE IF @NewStatus = 'Revise'    
        BEGIN    
            SET @NewStepId = 30072    
            SET @NextStepName = 'Need revision review by imex'    
            SET @FlowName = 'CL'    
            SET @NewStatus = 'Revise'    
        END    
        ELSE IF @NewStatus = 'Reject'    
        BEGIN    
            SET @NewStepId = 30072    
            SET @NextStepName = 'Need revision review by imex'    
            SET @FlowName = 'CL'    
            SET @NewStatus = 'Reject'    
        END    
    
        UPDATE [dbo].[RequestCl]    
        SET [IdStep] = @NewStepId    
            ,[Status] = @NewStatus    
            --,[Pic] = @Username    
            ,[UpdateBy] = @Username    
            ,[UpdateDate] = GETDATE()    
        WHERE IdCl = @IdCl    
    END    
 ELSE    
    BEGIN    
        select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cl_request_list_all() t0 where t0.IdCl = @IdCl;    
        --PRINT 'NewStepId ' + CAST(@NewStepId AS VARCHAR(10));    
        --  PRINT 'NewStatus ' + CAST(@NewStatus AS VARCHAR(10));    
        --  PRINT 'CurrentStepId ' + CAST(@CurrentStepId AS VARCHAR(10));    
        --  PRINT 'NextStepName ' + CAST(@NextStepName AS VARCHAR(10));    
            IF @CurrentStepId = 12     
                BEGIN    
                IF @NewStepId = 10017 AND @NewStatus = 'Submit'    
                BEGIN    
                declare @exportType nvarchar(10)=''    
                SET @exportType = (select top 1 exporttype from dbo.ShippingInstruction where IdCL =@IdCl)    
                IF (@exportType ='PJT')    
                BEGIN    
                SET @NewStepId =10020    
                SET @NextStepName = 'Waiting for BL or AWB'    
                SET @FlowName = 'CL'    
                SET @NewStatus = 'Approve'    
                --PRINT 'exporttype ' + CAST(@exporttype AS VARCHAR(10));    
                END    
                --PRINT 'exporttype ' + CAST(@exporttype AS VARCHAR(10));    
                END     
                END     
        UPDATE [dbo].[RequestCl]    
            SET [IdStep] = @NewStepId    
                ,[Status] = @NewStatus    
                ,[Pic] = @Username    
                ,[UpdateBy] = @Username    
                ,[UpdateDate] = GETDATE()    
        WHERE IdCl = @IdCl    
    END    
     
 -- Hasni Procedure Cancel PEB    
 IF  @NewStatus = 'Request Cancel'    
 BEGIN    
  SET @NewStepId = 30041    
    
  UPDATE [dbo].[RequestCl]    
  SET [IdStep] = @NewStepId    
      ,[Status] = @NewStatus    
      ,[Pic] = @Username    
   ,[UpdateBy] = @Username    
   ,[UpdateDate] = GETDATE()    
 WHERE IdCl = @IdCl    
 END    
    
 IF  @NewStatus = 'Draft NPE'    
 BEGIN    
  SET @NewStepId = 30069    
  SET @NewStatus = 'Submit'    
  SET @NextStepName = 'Waiting approve draft NPE'    
  SET @FlowName = 'CL'    
    
  UPDATE [dbo].[RequestCl]    
  SET [IdStep] = @NewStepId    
      ,[Status] = @NewStatus    
      ,[Pic] = @Username    
   ,[UpdateBy] = @Username    
   ,[UpdateDate] = GETDATE()    
  WHERE IdCl = @IdCl    
 END    
    
 IF  @NewStatus = 'Create NPE'    
 BEGIN    
  SET @NewStepId = 30071    
  SET @NewStatus = 'Submit'    
  SET @NextStepName = 'Waiting approval NPE'    
  SET @FlowName = 'CL'    
    
  UPDATE [dbo].[RequestCl]    
  SET [IdStep] = @NewStepId    
      ,[Status] = @NewStatus    
      ,[Pic] = @Username    
   ,[UpdateBy] = @Username    
   ,[UpdateDate] = GETDATE()    
  WHERE IdCl = @IdCl    
 END    

 --new query
 IF @NewStatus = 'Create BL AWB'
 BEGIN
 SET @NewStepId = 10022    
  SET @NewStatus = 'Approve'
  SET @NextStepName = 'Waiting for BL or AWB approval'    
  SET @FlowName = 'CL'    
    
  UPDATE [dbo].[RequestCl]    
  SET [IdStep] = @NewStepId    
      ,[Status] = @NewStatus    
      ,[Pic] = @Username    
   ,[UpdateBy] = @Username    
   ,[UpdateDate] = GETDATE()    
  WHERE IdCl = @IdCl    
 END   
    
 IF @NewStepId = 30042 AND @NewStatus = 'Approve'    
 BEGIN    
  UPDATE dbo.NpePeb SET IsDelete = 1 WHERE IdCl = @IdCl;    
 END     
    
 --======================================================    
 --- Kondisi jika cl akan melanjutkan proses ke system    
 --======================================================    
 IF @NewStepId = 11 AND @NewStatus = 'Submit'    
 BEGIN    
  select @NextStepIdSystem = x.IdNextStep from dbo.fn_get_cl_request_list_all() x where x.IdCl = @IdCl;    
    
  UPDATE [dbo].[RequestCl]    
  SET [IdStep] = @NextStepIdSystem    
      ,[Status] = @NewStatus    
      ,[Pic] = @Username    
   ,[UpdateBy] = @Username    
   ,[UpdateDate] = GETDATE()    
  WHERE IdCl = @IdCl    
    
  exec sp_set_ss_number @IdCl = @IdCl    
  exec sp_update_cipl_to_revise @IdCl    
 END    
    
 IF @NewStepId = 20033 AND @NewStatus = 'Approve'    
 BEGIN    
  select @NextStepIdSystem = x.IdNextStep from dbo.fn_get_cl_request_list_all() x where x.IdCl = @IdCl;    
    
  UPDATE [dbo].[RequestCl]    
  SET [IdStep] = @NewStepId    
      ,[Status] = @NewStatus    
      ,[Pic] = @Username    
   ,[UpdateBy] = @Username    
   ,[UpdateDate] = GETDATE()    
  WHERE IdCl = @IdCl    
    
  exec sp_update_cipl_to_revise @IdCl    
 END    
 --======================================================    
    
 exec [dbo].[sp_insert_cl_history]@id=@IdCl, @Flow=@FlowName, @Step=@NextStepName, @Status=@NewStatus, @Notes=@Notes, @CreateBy=@Username, @CreateDate=@Now;    
    
 IF((select Status from RequestCl where IdCl = @IdCl) <> 'DRAFT')    
 BEGIN      --EXEC [sp_send_email_notification] @IdCl, 'Cargo'    
  EXEC [sp_proccess_email] @IdCl, 'CL'    
 END    
END
GO