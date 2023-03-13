--Compared from DB EMCS on Development, DB EMCS_QA on QA, DB EMCS_Dev on Development on 10/03/2023
/****** Object:  StoredProcedure [dbo].[GenerateCargoNumber]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	ALTER PROCEDURE [dbo].[GenerateCargoNumber]
		@ID bigint
	AS
	BEGIN
		   
		DECLARE @YEAR nvarchar(2), @MONTH nvarchar(2), @DATE nvarchar(2), @CURRENTNUMBER int, @NEXTNUMBER varchar(4)
		SET @YEAR = YEAR(GETDATE())%100
		SET @MONTH = RIGHT( '0' + CAST( MONTH( GETDATE() ) AS varchar(2) ), 2 )  
		SET @DATE = RIGHT( '0' + CAST( DAY( GETDATE() ) AS varchar(2) ), 2 ) 
	
		select @CURRENTNUMBER = ISNULL(MAX(SUBSTRING(ClNo,11,4)), 0) FROM dbo.Cargo where DATEPART(YEAR, CreateDate) = DATEPART(YEAR, GETDATE()) AND CreateBy <> 'System'
		select @NEXTNUMBER = right('0000' + convert(varchar(4), @CURRENTNUMBER + 1),4)
	
		UPDATE dbo.Cargo SET ClNo = 'CL.' + @DATE + @MONTH + @YEAR + @NEXTNUMBER WHERE id = @ID
	END
GO

/****** Object:  StoredProcedure [dbo].[GenerateCiplNumber]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	-- EXEC [dbo].[GenerateCiplNumber] '1', 'ICT'
	-- EXEC [dbo].[GenerateCiplNumber] '1', 'XUPJ21ECH'
	ALTER PROCEDURE [dbo].[GenerateCiplNumber]
	(
	
	@ID bigint, @CreateBy nvarchar(255)
	)
	AS
	BEGIN
	       DECLARE @YEAR nvarchar(2), @MONTH nvarchar(2), @CIPLNO nvarchar(20), @DATE nvarchar(2), @LASTNUMBER nvarchar(20), @NEXTNUMBER int, 
		   @LASTVAL nvarchar(20), @CATEGORY bigint, @GETCATEGORY nvarchar(2), @DEPT nvarchar(4)
		   SET @YEAR = YEAR(GETDATE())%100
		   SET @MONTH = RIGHT( '0' + CAST( MONTH( GETDATE() ) AS varchar(2) ), 2 )  
		   SET @DATE = RIGHT( '0' + CAST( DAY( GETDATE() ) AS varchar(2) ), 2 ) 
		   
		   SELECT @LASTNUMBER = ISNULL(MAX(SUBSTRING(C.CiplNo,9,4)),0) FROM dbo.Cipl C where DATEPART(YEAR, CreateDate) = DATEPART(YEAR, GETDATE()) AND C.CreateBy <> 'System'
		   SET @NEXTNUMBER = CAST(@LASTNUMBER as int) + 1;
		   SET @LASTVAL = right('0000' + convert(varchar(4),@NEXTNUMBER),4) 
		   SELECT @DEPT = ISNULL((SELECT E.Dept_Code FROM employee E WHERE E.AD_User = @CreateBy), 'NULL')
		   SELECT @CIPLNO = 'E.' + @DATE + @MONTH + @YEAR + @LASTVAL + @DEPT
		   UPDATE dbo.Cipl SET CiplNo = @CIPLNO WHERE id = @ID
	
		   SELECT top 1 C.id as ID, @CIPLNO as [NO], C.CreateDate as CREATEDATE FROM Cipl C WHERE C.id = @ID
	
	END
GO

/****** Object:  StoredProcedure [dbo].[GenerateEDONumber_20210414]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	ALTER PROCEDURE [dbo].[GenerateEDONumber_20210414] -- [GenerateEDONumber] '1', 'xupj21ech'
	(
		@ID bigint, 
		@CreateBy nvarchar(255)
	)
	AS
	BEGIN
	       DECLARE @YEAR nvarchar(2), @MONTH nvarchar(2), @EDONUMBER nvarchar(20), @DATE nvarchar(2), @LASTNUMBER nvarchar(20), 
		   @NEXTNUMBER int, @LASTVAL nvarchar(20), @DEPT nvarchar(2)
		   SET @YEAR = YEAR(GETDATE())%100
		   SET @MONTH = RIGHT( '0' + CAST( MONTH( GETDATE() ) AS varchar(2) ), 2 )  
		   SET @DATE = RIGHT( '0' + CAST( DAY( GETDATE() ) AS varchar(2) ), 2 ) 
		   
		   SELECT @LASTNUMBER = ISNULL(MAX(SUBSTRING(C.EdoNo,10,4)),0) FROM dbo.Cipl C WHERE C.CreateBy <> 'System'
		   SET @NEXTNUMBER = CAST(@LASTNUMBER as int) + 1;
		   SET @LASTVAL = right('0000' + convert(varchar(4),@NEXTNUMBER),4) 
		   SELECT @DEPT = E.Dept_Code  FROM employee E WHERE E.AD_User = @CreateBy
		   SELECT @EDONUMBER = 'DO.' + @DATE + @MONTH + @YEAR + @LASTVAL + @DEPT
		   --SELECT @CIPLNO = 'E.' + CAST(MU.RoleID AS nvarchar(10)) + @DATE + @MONTH + @YEAR + @LASTVAL + @DEPT  FROM dbo.MasterUser MU WHERE ID = @ID
		   UPDATE dbo.Cipl SET EdoNo = @EDONUMBER WHERE id = @ID
	END
GO

/****** Object:  StoredProcedure [dbo].[GenerateEDONumber]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GenerateEDONumber] -- [GenerateEDONumber] '1', 'xupj21ech'
(
	@ID bigint, 
	@CreateBy nvarchar(255)
)
AS
BEGIN
	    DECLARE @YEAR nvarchar(2), @MONTH nvarchar(2), @EDONUMBER nvarchar(20), @DATE nvarchar(2), @LASTNUMBER nvarchar(20), 
		@NEXTNUMBER int, @LASTVAL nvarchar(20), @DEPT nvarchar(2)

		SELECT @EDONUMBER = EdoNo FROM dbo.Cipl WHERE id = @ID
		IF (@EDONUMBER IS NULL)
		BEGIN

			SET @YEAR = YEAR(GETDATE())%100
			SET @MONTH = RIGHT( '0' + CAST( MONTH( GETDATE() ) AS varchar(2) ), 2 )  
			SET @DATE = RIGHT( '0' + CAST( DAY( GETDATE() ) AS varchar(2) ), 2 ) 
		   
			SELECT @LASTNUMBER = ISNULL(MAX(SUBSTRING(C.EdoNo,10,4)),0) FROM dbo.Cipl C WHERE C.CreateBy <> 'System'
			SET @NEXTNUMBER = CAST(@LASTNUMBER as int) + 1;
			SET @LASTVAL = right('0000' + convert(varchar(4),@NEXTNUMBER),4) 
			SELECT @DEPT = E.Dept_Code  FROM employee E WHERE E.AD_User = @CreateBy
			SELECT @EDONUMBER = 'DO.' + @DATE + @MONTH + @YEAR + @LASTVAL + @DEPT
			--SELECT @CIPLNO = 'E.' + CAST(MU.RoleID AS nvarchar(10)) + @DATE + @MONTH + @YEAR + @LASTVAL + @DEPT  FROM dbo.MasterUser MU WHERE ID = @ID
			UPDATE dbo.Cipl SET EdoNo = @EDONUMBER WHERE id = @ID

		END
END

GO

/****** Object:  StoredProcedure [dbo].[GenerateGoodsReceiveNumber]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[GenerateGoodsReceiveNumber]
ALTER PROCEDURE [dbo].[GenerateGoodsReceiveNumber]
(

@ID bigint 
)
AS
BEGIN
		SET ANSI_WARNINGS OFF;
	   SET NOCOUNT ON;
       DECLARE @YEAR nvarchar(4), @MONTH nvarchar(20), @GRNO nvarchar(20), @DATE nvarchar(2), @LASTNUMBER nvarchar(20), @NEXTNUMBER int, @LASTVAL nvarchar(20)
	   SET @YEAR = YEAR(GETDATE())
	   SET @MONTH = RIGHT( '0' + CAST( MONTH( GETDATE() ) AS varchar(2) ), 2 )  
	   SET @DATE = RIGHT( '0' + CAST( DAY( GETDATE() ) AS varchar(2) ), 2 ) 
	   
	   SELECT @LASTNUMBER = ISNULL(MAX(SUBSTRING(G.GrNo,12,4)),0) FROM dbo.GoodsReceive G
	   SET @NEXTNUMBER = CAST(@LASTNUMBER as int) + 1;
	   SET @LASTVAL = right('0000' + convert(varchar(4),@NEXTNUMBER),4) 
	   --SELECT @CIPLNO = 'E.' + CAST(MU.RoleID AS nvarchar(10)) + @DATE + @MONTH + @YEAR + @LASTVAL + @DEPT  FROM dbo.MasterUser MU WHERE ID = @ID
	   SELECT @GRNO = 'GR.' + @DATE + @MONTH + @YEAR + @LASTVAL
	   
	   UPDATE [dbo].[GoodsReceive] SET GrNo = @GRNO WHERE Id = @ID 
END

GO

/****** Object:  StoredProcedure [dbo].[GenerateShippingInstructionNumber]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GenerateShippingInstructionNumber]
(

@ID bigint , @CreateBy nvarchar(10) 
)
AS
BEGIN
	   
       DECLARE @YEAR nvarchar(2), @MONTH nvarchar(2), @DATE nvarchar(2), @SINO nvarchar(20), @LASTNUMBER nvarchar(20), 
	   @NEXTNUMBER int, @LASTVAL nvarchar(20), @DEPT nvarchar(2)
	   SET @YEAR = YEAR(GETDATE())%100
	   SET @MONTH = RIGHT( '0' + CAST( MONTH( GETDATE() ) AS varchar(2) ), 2 )  
	   SET @DATE = RIGHT( '0' + CAST( DAY( GETDATE() ) AS varchar(2) ), 2 ) 
	   
	   SELECT @LASTNUMBER = ISNULL(MAX(SUBSTRING(C.SlNo,10,4)),0) FROM dbo.ShippingInstruction C
	   SET @NEXTNUMBER = CAST(@LASTNUMBER as int) + 1;
	   SET @LASTVAL = right('0000' + convert(varchar(4),@NEXTNUMBER),4) 

	   SELECT @DEPT = E.Dept_Code  FROM employee E WHERE E.AD_User = @CreateBy
	   SELECT @SINO = 'SI.' + @DATE + @MONTH + @YEAR + @LASTVAL + @DEPT

	   UPDATE dbo.ShippingInstruction SET SlNo = @SINO WHERE id = @ID

END
GO

/****** Object:  StoredProcedure [dbo].[GenerateShippingSummaryNumber]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	ALTER PROCEDURE [dbo].[GenerateShippingSummaryNumber] -- [GenerateShippingSummaryNumber] 1, ''
	(
	
	@ID bigint , @DEPT nvarchar(10) 
	)
	AS
	BEGIN
		   SET NOCOUNT ON;
	       DECLARE @YEAR nvarchar(2), @MONTH nvarchar(2), @DATE nvarchar(2), @CIPLNO nvarchar(20), @LASTNUMBER nvarchar(20), @NEXTNUMBER int, @LASTVAL nvarchar(20)
		   SET @YEAR = YEAR(GETDATE())%100
		   SET @MONTH = RIGHT( '0' + CAST( MONTH( GETDATE() ) AS varchar(2) ), 2 )  
		   SET @DATE = RIGHT( '0' + CAST( DAY( GETDATE() ) AS varchar(2) ), 2 ) 
		   
		   SELECT @LASTNUMBER = SUBSTRING(MAX(SsNo), 10,4) FROM dbo.Cargo WHERE CreateBy <> 'System'
		   SET @NEXTNUMBER = ISNULL(CAST(@LASTNUMBER as int), 0) + 1;
		   SET @LASTVAL = right('0000' + convert(varchar(4),@NEXTNUMBER),4) 
		   
		   SELECT @CIPLNO = 'SS.' + @DATE + @MONTH + @YEAR + @LASTVAL;
	
		   update dbo.Cargo set SsNo = @CIPLNO where Id = @ID;
	END
GO

/****** Object:  StoredProcedure [dbo].[GetEmployeeMaster]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetEmployeeMaster]
(
@Name nvarchar(255)
)
AS
BEGIN
      select * from Employee where Employee_Name like '%'+@Name+'%'
END
GO

/****** Object:  StoredProcedure [dbo].[getListAllArea]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[getListAllArea]
AS
BEGIN
      select a.ID, a.Area, v.Employee_Name PICArea from MasterArea a 
	  left join [dbo].[vEmployeeMaster] v on a.PICArea = v.Employee_xupj collate DATABASE_DEFAULT
	  where a.IsActive = 1
END
GO

/****** Object:  StoredProcedure [dbo].[getListAllBranch]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[getListAllBranch]
AS
BEGIN
      select b.ID, a.Area, b.BranchCode, b.BranchDesc, b.IsCC100, v.Employee_Name PICBranch from MasterBranch b 
	  join MasterArea a on b.AreaID = a.ID 
	  left join [dbo].[vEmployeeMaster] v on b.PICBranch = v.Employee_xupj collate DATABASE_DEFAULT
	  where b.IsActive = 1 order by b.BranchDesc asc
END
GO

/****** Object:  StoredProcedure [dbo].[getListAllEmbargoCountry]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[getListAllEmbargoCountry]
AS
BEGIN
      select ID, CountryCode, Description from MasterEmbargoCountry 
	  where IsDeleted = 0
END
GO

/****** Object:  StoredProcedure [dbo].[getListAllKppbc]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[getListAllKppbc]
(
	@Name NVARCHAR(200)
)
AS
BEGIN
	select v.ID, a.BAreaName, v.Code, v.Name, v.Address, v.Propinsi, v.CreateBy, v.CreateDate from MasterArea a 
	  left join [dbo].[MasterKPBC] v on a.ID = v.AreaID 
	  where v.IsDeleted = 0
	  AND Name LIKE '%'+IIF(ISNULL(@Name, '') = '', Name, @Name )+'%'
END
GO

/****** Object:  StoredProcedure [dbo].[InsertEmailNotif]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--begin tran 
--rollback
--exec [dbo].[InsertEmailNotif]
--select * from TblEmailNotification where branch = 'makasar'
ALTER PROCEDURE [dbo].[InsertEmailNotif]
AS
BEGIN
	Declare @EmailPeriod int, @lastNotif int, @createemail int, @fromNotif int, @todate int
	Declare @AreaID int, @BranchID int, @BranchDesc nvarchar(50), @Supervisor nvarchar(100), @PicArea nvarchar(100), @Auditor nvarchar(100)
	declare @date2 int; set @date2 = day(GETDATE())
	select @EmailPeriod = ResultVal, @todate = ToVal from Setting where TypeConfig = 'AuditPeriodSchedule'
	and @date2 between fromval and toval

	select @fromNotif = FromVal, @lastNotif = ToVal from Setting
	where TypeConfig = 'EmailNotif' and ResultVal = @EmailPeriod
	--and (day(GETDATE() - 10) = FromVal or day(GETDATE() - 10) = ToVal)

	select @EmailPeriod, @lastNotif,@fromNotif, @todate, @date2 thisdate, 
				iif(@date2 = @fromNotif,
					 '1',
					 Iif(@date2 >= @lastnotif and @date2 <= @todate,
						 '2',
						 '0'))

	select * from Setting where TypeConfig = 'AuditPeriodSchedule' and ResultVal = @EmailPeriod and ToVal >= @date2
	IF @EmailPeriod = 2
		BEGIN
			DECLARE Email2_cursor CURSOR FOR
			Select a.AreaID, a.ID, a.BranchDesc, a.PICBranch, a.PICArea, vmu.Username from 
					( select b.AreaID, b.ID, b.BranchDesc, b.PICBranch, ma.PICArea, sa.[Status], sa.AuditPeriod, Replace(sa.dateaudit,'-','') DateAudit from 
						(select * from MasterBranch) b
						join MasterArea ma on b.AreaID = ma.ID
						left join ScoreAudit sa on b.ID = sa.branch
					) a left join vEmployeeMaster em on a.PICBranch = em.Employee_xupj
					left join [dbo].[vMasterUserEmail] vmu on vmu.branch = a.ID
					where (dateaudit = LEFT(CONVERT(varchar, getdate(),112),6) or dateaudit is null) --'201901'
						and ([status] <> 'Submit' or [status] is null)
						and (AuditPeriod = 2 or AuditPeriod is null)
		
				OPEN Email2_cursor
				FETCH NEXT FROM Email2_cursor
				INTO @AreaID, @BranchID, @BranchDesc, @Supervisor, @PicArea, @Auditor

				WHILE @@FETCH_STATUS = 0
				BEGIN	
					  INSERT INTO [dbo].[TblEmailNotification]
						   ([To] ,[CC] ,[Branch] ,[Auditor] ,[PeriodAudit] ,[Notifperiod], [IsDelete], [AlreadySending]
						   ,[CreatedOn] ,[CreatedBy])
					  VALUES(@Auditor, @Supervisor, @BranchDesc, @Auditor, @EmailPeriod, DATEADD(month, DATEDIFF(month, 0, getdate()), @todate), 0, 0, Getdate(), 1)
				FETCH NEXT FROM Email2_cursor
					INTO @AreaID, @BranchID, @BranchDesc, @Supervisor, @PicArea, @Auditor
				END
			CLOSE Email2_cursor
			DEALLOCATE Email2_cursor;
		END
	ELSE IF @EmailPeriod = 1
		BEGIN
			DECLARE Email1_cursor CURSOR FOR
			Select a.AreaID, a.ID, a.BranchDesc, a.PICBranch, a.PICArea, vmu.Username from 
					( select b.AreaID, b.ID, b.BranchDesc, b.PICBranch, ma.PICArea, sa.[Status], sa.AuditPeriod, Replace(sa.dateaudit,'-','') DateAudit from 
						(select * from MasterBranch) b
						join MasterArea ma on b.AreaID = ma.ID
						left join ScoreAudit sa on b.ID = sa.branch
					) a left join vEmployeeMaster em on a.PICBranch = em.Employee_xupj
					left join [dbo].[vMasterUserEmail] vmu on vmu.branch = a.ID
					where (dateaudit = LEFT(CONVERT(varchar, getdate(),112),6) or dateaudit is null) --'201901'
						and ([status] <> 'Submit' or [status] is null)
						and (AuditPeriod = 1 or AuditPeriod is null)
		
				OPEN Email1_cursor
				FETCH NEXT FROM Email1_cursor
				INTO @AreaID, @BranchID, @BranchDesc, @Supervisor, @PicArea, @Auditor

				WHILE @@FETCH_STATUS = 0
				BEGIN	
					  INSERT INTO [dbo].[TblEmailNotification]
						   ([To] ,[CC] ,[Branch] ,[Auditor] ,[PeriodAudit] ,[Notifperiod], [IsDelete], [AlreadySending]
						   ,[CreatedOn] ,[CreatedBy])
					  VALUES(@Auditor, @Supervisor, @BranchDesc, @Auditor, @EmailPeriod, DATEADD(month, DATEDIFF(month, 0, getdate()), @todate), 0, 0, GETDATE(), 1)
				FETCH NEXT FROM Email1_cursor
					INTO @AreaID, @BranchID, @BranchDesc, @Supervisor, @PicArea, @Auditor
				END

			CLOSE Email1_cursor
			DEALLOCATE Email1_cursor;
		END
	ELSE
		BEGIN
			select 'tidak ada email'
		END
END
GO

/****** Object:  StoredProcedure [dbo].[ShipmentAttachment]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ShipmentAttachment]
(
	@Id bigint
)
AS
BEGIN
	IF EXISTS (select DHLAttachmentID AS Id, GraphicImage from DHLAttachment Where DHLShipmentID = @Id) 
	BEGIN
	   select DHLAttachmentID AS Id, GraphicImage from DHLAttachment Where DHLShipmentID = @Id
	END
	ELSE
	BEGIN
		SELECT 1, '-'
	END
	
END
GO

/****** Object:  StoredProcedure [dbo].[ShipmentDhlReference]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ShipmentDhlReference]
(
	@Id bigint
)
AS
BEGIN
	DECLARE @reference NVARCHAR(max);
	
	SELECT @reference = Referrence from DHLShipment where IsDelete = 0 AND DHLShipmentID = @Id;

	SELECT Id, CiplNo From Cipl WHERE IsDelete = 0 AND id IN
	( select splitdata FROM fnSplitString(@reference,',') )

END
GO

/****** Object:  StoredProcedure [dbo].[ShipmentReceiptPdf]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ShipmentReceiptPdf]
(
	@Id bigint
)
AS
BEGIN
	DECLARE @reference NVARCHAR(max);
	
	SELECT @reference = Referrence from DHLShipment where IsDelete = 0 AND DHLShipmentID = @Id;

	SELECT 
		 ps.CompanyName  AS ShipperCompany
		, ps.PersonName AS ShipperPerson
		, ps.StreetLines AS ShipperAddress
		, ps.PostalCode AS ShipperPostalCode
		, ps.City AS ShipperCity
		, ps.[Description] AS ShipperCountry
		, ps.PhoneNumber AS ShipperPhone
		, ps.EmailAddress AS ShipperEmail
		, pr.CompanyName  AS ReceipentCompany
		, pr.PersonName AS ReceipentPerson
		, pr.StreetLines AS ReceipentAddress
		, pr.PostalCode AS ReceipentPostalCode
		, pr.City AS ReceipentCity
		, pr.[Description] AS ReceipentCountry
		, pr.PhoneNumber AS ReceipentPhone
		, pr.EmailAddress AS ReceipentEmail
		, ShipTimestamp AS ShipmentDate
		, IdentifyNumber AS WaybillNumber
		, ( SELECT TOP 1 mp.GlobalProductName
			FROM DHLRate r 
			JOIN DHLMasterProduct mp ON mp.ServiceType = r.ServiceType AND mp.IsDelete = 0
			WHERE r.IsDelete = 0) AS ServiceType
		, '-' AS YourOwnPackages
		, s.PackagesCount AS NumberOfPiece
		, pc.Weight AS [Weight]
		, (pc.Length * pc.Width * pc.Height) / 5000 AS Dimensional
		, IIF(pc.Weight > ((pc.Length * pc.Width * pc.Height) / 5000), ROUND(pc.Weight, 2), ROUND((pc.Length * pc.Width * pc.Height / 5000),0)) AS Chargeable
		, pc.Insured AS Insured
		, s.PaymentInfo AS TermsOfTrade
		, pc.Insured AS DeclaredValue
		, '??' AS DutiesTaxes
		, '??' AS Dutiable
		, '??' AS EstimatedDelDate
		, '??' AS PromoCode
		, '??' AS PaymentType
		, s.Account AS BillingAccount
		, '??' AS Duties
		, ISNULL(rt.ChargeAmount,0) AS ChargeAmount
		, ISNULL(rt.SpecialService,'-') AS SpecialService
		, (SELECT STUFF((SELECT ',' + CiplNo 
							FROM Cipl t1
							WHERE t1.id = t2.id
							FOR XML PATH('')
						), 1, 1, '') AS CiplNo 
			FROM Cipl t2 
			WHERE IsDelete = 0 AND id IN ( select splitdata FROM fnSplitString(@reference,',') )
			) AS Reference
		, s.ConfirmationNumber AS PickupRef
		, s.CommoditiesDesc AS DescriptionContens
	FROM DHLShipment s 
	JOIN (
			SELECT DHLShipmentID
				, CompanyName
				, PersonName
				, StreetLines
				, PostalCode
				, City
				, mc.Description 
				, PhoneNumber
				, EmailAddress
			FROM DHLPerson p
			JOIN MasterCountry mc ON mc.CountryCode = p.CountryCode AND mc.IsDeleted = 0 AND mc.CreateBy != 'XUPJ21TYO'
			WHERE PersonType = 'SHIPPER' AND IsDelete = 0
		)ps ON ps.DHLShipmentID = s.DHLShipmentID 
	JOIN (
			SELECT DHLShipmentID
				, CompanyName
				, PersonName
				, StreetLines
				, PostalCode
				, City
				, mc.Description 
				, PhoneNumber
				, EmailAddress
			FROM DHLPerson p
			JOIN MasterCountry mc ON mc.CountryCode = p.CountryCode AND mc.IsDeleted = 0 AND mc.CreateBy != 'XUPJ21TYO'
			WHERE PersonType = 'RECIPIENT' AND IsDelete = 0
		)pr ON pr.DHLShipmentID = s.DHLShipmentID
	LEFT JOIN 
		(
			SELECT DHLShipmentID
				, SUM(Weight) AS [Weight]
				, SUM(Insured) AS Insured
				, SUM(Length) AS Length
				, SUM(Height) AS Height
				, SUM(Width) AS Width
			FROM DHLPackage
			WHERE IsDelete = 0 
				AND DHLShipmentID = @Id
			GROUP BY DHLShipmentID
		)pc ON pc.DHLShipmentID = s.DHLShipmentID
	LEFT JOIN 
		(
		SELECT DHLShipmentID, 
			SUM(ISNULL(ChargeAmount,0)) AS ChargeAmount, 
			STUFF((SELECT ',' + ChargeType 
					  FROM DHLRate t1
					FOR XML PATH('')
			), 1, 1, '') AS SpecialService
		FROM DHLRate
		WHERE IsDelete = 0 
			AND DHLShipmentID = @Id
		GROUP BY DHLShipmentID
		)rt ON rt.DHLShipmentID = s.DHLShipmentID
	WHERE s.isdelete = 0 AND s.DHLShipmentID = @Id

END
GO

/****** Object:  StoredProcedure [dbo].[SP_ActivityReport_ExportByCategory]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ActivityReport_ExportByCategory]
	@startYear int,
	@endYear int
AS
BEGIN

	declare @totalCipl int
	select @totalCipl = count(distinct IdCipl) 
	from dbo.[fn_get_approved_npe_peb]() 
	where (YEAR(CreatedDate) >= @startYear or @startYear = 0) and (YEAR(CreatedDate) <= @endYear or @endYear = 0)

	select 
		Category,
		cast(
			LEFT(
				CONVERT(varchar, cast(count(distinct IdCipl) as decimal(16,2))/@totalCipl), 
				CHARINDEX('.',CONVERT(varchar, cast(count(distinct IdCipl) as decimal(16,2))/@totalCipl)) + 2
			)
		 as decimal(16,2)
	 ) as TotalPercentage
	from dbo.[fn_get_approved_npe_peb]()
	where (YEAR(CreatedDate) >= @startYear or @startYear = 0) and (YEAR(CreatedDate) <= @endYear or @endYear = 0)
	group by Category

END
GO

/****** Object:  StoredProcedure [dbo].[SP_ActivityReport_SalesVSNonSales]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ActivityReport_SalesVSNonSales]
	@startYear int,
	@endYear int
AS
BEGIN

	declare @temp_tbl table(Year int, ExportType nvarchar(100), ExtendedValue decimal(20,2))

	insert into @temp_tbl
	select 
		YEAR(CreatedDate), 
		t.ExportType, 
		sum(ExtendedValue)
	from dbo.[fn_get_approved_npe_peb]() t
	where (YEAR(CreatedDate) >= @startYear or @startYear = 0) and (YEAR(CreatedDate) <= @endYear or @endYear = 0)
	group by YEAR(CreatedDate), t.ExportType

	declare @minYear int, @maxYear int
	select @minYear = IIF(@startYear <> 0, @startYear, MIN(Year)), @maxYear = IIF(@endYear <> 0, @endYear, MAX(Year)) from @temp_tbl

	declare @yearly_tbl table(Year int, ExportType nvarchar(100))
	WHILE @minYear <= @maxYear
	BEGIN
	   insert into @yearly_tbl values(@minYear, 'Sales'), (@minYear, 'Non Sales')
	   SET @minYear = @minYear + 1;
	END;
	
	declare @tbl table (ExportType varchar(20), Year int, ExtendedValue decimal(20,2))
	insert into @tbl
	select 
		y.ExportType, 
		y.[Year], 
		ISNULL(t.ExtendedValue, 0) as ExtendedValue 
	from @yearly_tbl y
	left join @temp_tbl t on y.[Year] = t.[Year] and y.ExportType = t.ExportType
	
	SELECT * FROM  
	(
		select * from @tbl
		) AS SourceTable  
	PIVOT  
	(  
		MAX(ExtendedValue) FOR ExportType IN ([Sales], [Non Sales])  
	) AS PivotTable

END
GO

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

/****** Object:  StoredProcedure [dbo].[sp_AddArmada]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_AddArmada]      
(      
 @Id nvarchar(100),      
 @IdCipl nvarchar(100),      
 @IdGr nvarchar(100),      
 @DoNo nvarchar(100),      
 @DaNo nvarchar(100),      
 @PicName  nvarchar(100),      
    @PhoneNumber nvarchar(100),      
    @KtpNumber  nvarchar(100),      
 @SimNumber  nvarchar(100),      
    @SimExpiryDate  nvarchar(100),      
    @KirNumber   nvarchar(100),       
    @KirExpire   nvarchar(100),      
    @NopolNumber nvarchar(100),       
    @StnkNumber   nvarchar(100),      
    @EstimationTimePickup nvarchar(100),      
    @Apar   nvarchar(100),      
    @Apd   nvarchar(100) ,    
 @Bast nvarchar(100)    
      
)      
AS      
BEGIN      
 SET NOCOUNT ON;      
 IF @Id = 0      
      
 BEGIN      
        
  INSERT INTO [dbo].[ShippingFleet]      
           ([IdGr],[IdCipl],[DoNo],[DaNo],[PicName],PhoneNumber,KtpNumber,SimNumber,SimExpiryDate,KirNumber,KirExpire,NopolNumber,StnkNumber,EstimationTimePickup,Apar,Apd,Bast)      
  VALUES      
           (@IdGr, @IdCipl, @DoNo, @DaNo, @PicName, @PhoneNumber, @KtpNumber, @SimNumber, @SimExpiryDate, @KirNumber,@KirExpire,@NopolNumber,@StnkNumber,@EstimationTimePickup,@Apar,@Apd,@Bast)      
     SET @Id = SCOPE_IDENTITY()       
 END      
 ELSE       
 BEGIN      
  UPDATE [dbo].[ShippingFleet] SET       
    IdGr = @IdGr      
     , IdCipl = @IdCipl      
     , DoNo = @DoNo      
     , DaNo = @DaNo      
     ,PicName= @PicName        
     ,PhoneNumber = @PhoneNumber       
     ,KtpNumber= @KtpNumber        
     ,SimNumber= @SimNumber        
     ,SimExpiryDate = @SimExpiryDate        
     ,KirNumber = @KirNumber         
     ,KirExpire = @KirExpire         
     ,NopolNumber = @NopolNumber       
     ,StnkNumber = @StnkNumber         
     ,EstimationTimePickup = @EstimationTimePickup      
     ,Apar = @Apar         
     ,Apd = @Apd      
  ,Bast = @Bast    
  WHERE Id = @Id   
  delete From ShippingFleetRefrence  
  where IdShippingFleet = @Id   
--declare @EdoNo nvarchar(max)      
--set @EdoNo = (select DoNo From  ShippingFleet where Id = @Id)      
--delete from ShippingFleetItem      
--where IdCipl not In (select id from Cipl      
--where EdoNo IN (select * from [SDF_SplitString](@EdoNo ,','))) and IdGr = @IdGr and IdShippingFleet = @Id      
 END      
 SELECT CAST(@Id as bigint) as Id      
END 


GO

/****** Object:  StoredProcedure [dbo].[sp_AddArmadaForRFC]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_AddArmadaForRFC]                    
(                    
@Id nvarchar(100),              
 @IdShippingFleet  nvarchar(100),                    
 @IdCipl    nvarchar(100),                    
 @IdGr     nvarchar(100),                    
 @DoNo     nvarchar(100),                    
 @DaNo     nvarchar(100),                    
 @PicName    nvarchar(100),                    
 @PhoneNumber    nvarchar(100),                    
 @KtpNumber    nvarchar(100),                    
 @SimNumber    nvarchar(100),                    
 @SimExpiryDate     nvarchar(100),                    
 @KirNumber    nvarchar(100),                     
 @KirExpire    nvarchar(100),                    
 @NopolNumber   nvarchar(100),                     
 @StnkNumber     nvarchar(100),                    
 @EstimationTimePickup  nvarchar(100),                    
 @Apar     nvarchar(100),                    
 @Apd      nvarchar(100) ,         
 @Bast     nvarchar(100)   ,          
 @Status    nvarchar(100)   ,      
 @FileName     nvarchar(max)       
                    
)                    
AS                    
BEGIN                    
 SET NOCOUNT ON   
 --  if(@IdShippingFleet <> 0)      
 --begin
 if( @FileName  IS NULL or @FileName = '')      
 begin      
 set @FileName = (select [FileName] From ShippingFleet where Id = @IdShippingFleet)      
 end

 --SELECT @FileName

 --end      
  if(@IdShippingFleet <> 0)      
 begin     
 set @Id = (select Id from ShippingFleet_Change where IdShippingFleet= @IdShippingFleet)      
 set @Id = (select IIF(@Id IS NULL, -1, @Id) As Id)      
 end    
 IF @Id <= 0       
   begin      
  INSERT INTO [dbo].[ShippingFleet_Change]                    
           ([IdShippingFleet],[IdGr],[IdCipl],[DoNo],[DaNo],[PicName],PhoneNumber,KtpNumber,SimNumber,SimExpiryDate,KirNumber,KirExpire,NopolNumber,StnkNumber,EstimationTimePickup              
     ,Apar,Apd,Bast,[Status],[FileName])                    
  VALUES                    
           (@IdShippingFleet,@IdGr, @IdCipl, @DoNo, @DaNo, @PicName, @PhoneNumber, @KtpNumber, @SimNumber, @SimExpiryDate, @KirNumber,@KirExpire,@NopolNumber,@StnkNumber,        
     @EstimationTimePickup,@Apar,@Apd,@Bast,@Status,@FileName)                    
     SET @Id = SCOPE_IDENTITY()                         
  end      
  else      
  begin      
  update ShippingFleet_Change      
  set  IdShippingFleet  = @IdShippingFleet ,      
  IdCipl    = @IdCipl     ,      
  IdGr     = @IdGr     ,      
  DoNo     = @DoNo     ,      
  DaNo     = @DaNo     ,      
  PicName    = @PicName    ,      
  PhoneNumber   = @PhoneNumber   ,      
  KtpNumber    = @KtpNumber   ,       
  SimNumber    = @SimNumber   ,       
  SimExpiryDate   = @SimExpiryDate  ,       
  KirNumber    = @KirNumber   ,       
  KirExpire    = @KirExpire   ,       
  NopolNumber   = @NopolNumber   ,      
  StnkNumber   = @StnkNumber    ,      
  EstimationTimePickup = @EstimationTimePickup ,      
  Apar     = @Apar     ,      
  Apd     = @Apd     ,      
  Bast     = @Bast     ,      
  [FileName]    = @FileName    ,      
  [Status]    = @Status          
  where Id = @Id      
  end      
 SELECT CAST(@Id as bigint) as Id                    
END 

GO

/****** Object:  StoredProcedure [dbo].[sp_AddArmadaHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_AddArmadaHistory]          
(          
@Id nvarchar(100),    
 @IdShippingFleet nvarchar(100),          
 @IdCipl nvarchar(100),          
 @IdGr nvarchar(100),          
 @DoNo nvarchar(100),          
 @DaNo nvarchar(100),          
 @PicName  nvarchar(100),          
    @PhoneNumber nvarchar(100),          
    @KtpNumber  nvarchar(100),          
 @SimNumber  nvarchar(100),          
    @SimExpiryDate  nvarchar(100),          
    @KirNumber   nvarchar(100),           
    @KirExpire   nvarchar(100),          
    @NopolNumber nvarchar(100),           
    @StnkNumber   nvarchar(100),          
    @EstimationTimePickup nvarchar(100),          
    @Apar   nvarchar(100),          
    @Apd   nvarchar(100) ,        
 @Bast nvarchar(100)   ,
 @Status nvarchar(100)
          
)          
AS          
BEGIN          
 SET NOCOUNT ON;             
            
  INSERT INTO [dbo].[ShippingFleet_History]          
           ([IdShippingFleet],[IdGr],[IdCipl],[DoNo],[DaNo],[PicName],PhoneNumber,KtpNumber,SimNumber,SimExpiryDate,KirNumber,KirExpire,NopolNumber,StnkNumber,EstimationTimePickup    
     ,Apar,Apd,Bast,[Status])          
  VALUES          
           (@IdShippingFleet,@IdGr, @IdCipl, @DoNo, @DaNo, @PicName, @PhoneNumber, @KtpNumber, @SimNumber, @SimExpiryDate, @KirNumber,@KirExpire,@NopolNumber,@StnkNumber,@EstimationTimePickup,@Apar,@Apd,@Bast,@Status)          
     SET @Id = SCOPE_IDENTITY()               
 SELECT CAST(@Id as bigint) as Id          
END 

GO

/****** Object:  StoredProcedure [dbo].[sp_AddArmadaRefrence]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_AddArmadaRefrence](  
 @Id bigint = 0,  
 @IdShippingFleet bigint ,  
 @IdGr bigint,  
 @IdCipl bigint = 0,  
 @DoNo nvarchar(max)  
 )  
 AS  
 begin  
 Set @IdCipl = (Select Id from Cipl where EdoNo = @DoNo)  
 insert into ShippingFleetRefrence(IdShippingFleet,IdGr,IdCipl,DoNo,CreateDate)  
 values (@IdShippingFleet,@IdGr,@IdCipl,@DoNo,GETDATE())  
 SET @Id = SCOPE_IDENTITY()     
 SELECT CAST(@Id as bigint) as Id    
 end

GO

/****** Object:  StoredProcedure [dbo].[sp_addShippingFleetItem]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_addShippingFleetItem]      
 (      
  @Id nvarchar(15),      
  @IdShippingFleet nvarchar(15),      
  @IdGr nvarchar(15),      
  @IdCipl nvarchar(15),      
  @IdCiplItem nvarchar(15)      
      
 )      
 AS      
BEGIN      
IF @Id = 0 
Begin
set @IdCipl = (select c.IdCipl from CiplItem c
where c.Id = @IdCiplItem) 
 insert into ShippingFleetItem (IdShippingFleet,IdGr,IdCipl,IdCiplItem)      
 values(@IdShippingFleet,@IdGr,@IdCipl,@IdCiplItem)      
 Set @Id = SCOPE_IDENTITY()  
 select * from ShippingFleetItem    
 where Id = @Id 
END
else
Begin
select * from ShippingFleet
where Id = @Id
End
End

GO

/****** Object:  StoredProcedure [dbo].[sp_approve_req_revise_cipl_20210423]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- Create date: 24 Nov 2019
-- Description:	sp jika superior melakukan approval terhadap perubahan dimensi di cargo
-- =============================================
ALTER PROCEDURE [dbo].[sp_approve_req_revise_cipl_20210423] -- sp_approve_req_revise_cipl 50, 'xupj21njb'
	-- Add the parameters for the stored procedure here
	@ciplid bigint,
	@username nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE 
	@IdUpdate bigint
	, @newciplitemid bigint
	, @clId bigint
	, @NewHeight decimal
	, @NewWidth decimal
	, @NewLength decimal
	, @NewNetWeight decimal
	, @NewGrossWeight decimal
	, @TotalWaiting decimal

	-- mengupdate semua perubahan
	-- ambil semua history perubahan cipl di cargo	
	DECLARE cursor_update CURSOR
	FOR 
		SELECT Id IdUpdate, IdCiplItem, NewHeight, NewWidth, NewLength, NewNetWeight, NewGrossWeight, IdCargo
		FROM dbo.CiplItemUpdateHistory 
		WHERE IdCipl = @ciplid AND IsApprove = 0;
		 
	OPEN cursor_update;
	 
	FETCH NEXT FROM cursor_update INTO @IdUpdate, @newciplitemid, @NewHeight, @NewWidth, @NewLength, @NewNetWeight, @NewGrossWeight, @clId;
	 
	WHILE @@FETCH_STATUS = 0
	    BEGIN
			-- Update cipl item history
			UPDATE dbo.CiplItemUpdateHistory 
			SET IsApprove = 1, UpdateBy = @username, UpdateDate = GETDATE() 
			WHERE Id = @IdUpdate;

			-- Apply perubahan ke table cipl item
			UPDATE dbo.CiplItem 
			SET Height = @NewHeight, Width = @NewWidth, NetWeight = @NewNetWeight, GrossWeight = @NewGrossWeight
			WHERE Id = @newciplitemid;

	        FETCH NEXT FROM cursor_update INTO @IdUpdate, @newciplitemid, @NewHeight, @NewWidth, @NewLength, @NewNetWeight, @NewGrossWeight, @clId;
	    END;	 
	CLOSE cursor_update;	 
	DEALLOCATE cursor_update;

	-- get total waiting approval
	SELECT @totalwaiting = COUNT(*) 
	FROM dbo.CiplItemUpdateHistory 
	WHERE IdCargo = @clId AND IsApprove = 0;

	-- jika sudah tidak ada lagi approval di ciplupitem update history maka update data cl
	-- update status cl jika sudah tidak ada lagi waiting approval
	IF @totalwaiting = 0
	BEGIN
		EXEC sp_update_request_cl @clId, @username, 'Approve', ''
	END

	-- update status cipl
	--EXEC sp_update_request_cipl @IdCipl = @ciplid, @Username = @username, @NewStatus = 'Approve', @Notes = '', @NewStep = ''

END
GO

/****** Object:  StoredProcedure [dbo].[sp_approve_req_revise_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- Create date: 24 Nov 2019
-- Description:	sp jika superior melakukan approval terhadap perubahan dimensi di cargo
-- =============================================
ALTER PROCEDURE [dbo].[sp_approve_req_revise_cipl] -- sp_approve_req_revise_cipl 50, 'xupj21njb'
	-- Add the parameters for the stored procedure here
	@ciplid bigint,
	@username nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE 
	@IdUpdate bigint
	, @newciplitemid bigint
	, @clId bigint
	, @NewHeight decimal
	, @NewWidth decimal
	, @NewLength decimal
	, @NewNetWeight decimal
	, @NewGrossWeight decimal
	, @TotalWaiting decimal

	-- mengupdate semua perubahan
	-- ambil semua history perubahan cipl di cargo	
	DECLARE cursor_update CURSOR
	FOR 
		SELECT Id IdUpdate, IdCiplItem, NewHeight, NewWidth, NewLength, NewNetWeight, NewGrossWeight, IdCargo
		FROM dbo.CiplItemUpdateHistory 
		WHERE IdCipl = @ciplid AND IsApprove = 0;
		 
	OPEN cursor_update;
	 
	FETCH NEXT FROM cursor_update INTO @IdUpdate, @newciplitemid, @NewHeight, @NewWidth, @NewLength, @NewNetWeight, @NewGrossWeight, @clId;
	 
	WHILE @@FETCH_STATUS = 0
	    BEGIN
			-- Update cipl item history
			UPDATE dbo.CiplItemUpdateHistory 
			SET IsApprove = 1, UpdateBy = @username, UpdateDate = GETDATE() 
			WHERE Id = @IdUpdate;

			-- Apply perubahan ke table cipl item
			UPDATE dbo.CiplItem 
			SET Height = @NewHeight, Width = @NewWidth, NetWeight = @NewNetWeight, Length = @NewLength, GrossWeight = @NewGrossWeight
			WHERE Id = @newciplitemid;

	        FETCH NEXT FROM cursor_update INTO @IdUpdate, @newciplitemid, @NewHeight, @NewWidth, @NewLength, @NewNetWeight, @NewGrossWeight, @clId;
	    END;	 
	CLOSE cursor_update;	 
	DEALLOCATE cursor_update;

	-- get total waiting approval
	SELECT @totalwaiting = COUNT(*) 
	FROM dbo.CiplItemUpdateHistory 
	WHERE IdCargo = @clId AND IsApprove = 0;

	-- jika sudah tidak ada lagi approval di ciplupitem update history maka update data cl
	-- update status cl jika sudah tidak ada lagi waiting approval
	IF @totalwaiting = 0
	BEGIN
		EXEC sp_update_request_cl @clId, @username, 'Approve', ''
	END

	-- update status cipl
	--EXEC sp_update_request_cipl @IdCipl = @ciplid, @Username = @username, @NewStatus = 'Approve', @Notes = '', @NewStep = ''

END

GO

/****** Object:  StoredProcedure [dbo].[SP_ApproveChangeHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[SP_ApproveChangeHistory]
    @Id INT      
    ,@UpdatedBy NVARCHAR(200)     
AS        
BEGIN        
    UPDATE RequestForChange        
    SET [Status] = 1 ,  UpdateBy = @UpdatedBy       
    WHERE Id = @Id       
     
    EXEC [dbo].[sp_Process_Email_RFC] @Id,'Approved'     
END 

GO

/****** Object:  StoredProcedure [dbo].[SP_ArmadaDocumentUpdateFile]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ArmadaDocumentUpdateFile]
(
	@Id BIGINT,
	@Filename NVARCHAR(MAX) = ''
)
AS
BEGIN
 
	UPDATE dbo.ShippingFleet
	SET [FileName] = @Filename	
	WHERE Id = @Id;

END

GO

/****** Object:  StoredProcedure [dbo].[SP_ArmadaDocumentUpdateFileForRFC]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[SP_ArmadaDocumentUpdateFileForRFC]      
(      
 @Id BIGINT,      
 @Filename NVARCHAR(MAX) = '' ,  
 @buttonRFC bit  
)      
AS      
BEGIN      
    if @buttonRFC = 0  
    begin  
    UPDATE dbo.ShippingFleet_Change      
    SET [FileName] = @Filename       
    WHERE IdShippingFleet = @Id;      
    end  
 else  
 begin  
 update ShippingFleet_Change  
 set FileName = @Filename  
 where Id = @Id  
 end  
END 

GO

/****** Object:  StoredProcedure [dbo].[SP_CargoDocumentAdd]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER	PROCEDURE [dbo].[SP_CargoDocumentAdd]
(
	@Id BIGINT,
	@IdCargo BIGINT,
	@DocumentDate datetime,
	@DocumentName NVARCHAR(MAX) = '',
	@Filename NVARCHAR(MAX) = '',
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@IsDelete BIT
)
AS
BEGIN
	IF @Id <= 0
	BEGIN
	INSERT INTO [dbo].[CargoDocument]
           ([IdCargo]
		   ,[DocumentDate]
		   ,[DocumentName]
		   ,[Filename]
           ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
           )
     VALUES
           (@IdCargo
			,@DocumentDate
			,@DocumentName
			,@Filename
			,@CreateBy
			,@CreateDate
			,@UpdateBy
			,@UpdateDate
			,@IsDelete
		   )

	END
	ELSE 
	BEGIN
	UPDATE dbo.CargoDocument
	SET [DocumentDate] = @DocumentDate
		   ,[DocumentName] = @DocumentName
	WHERE Id = @Id;
	END

END

GO

/****** Object:  StoredProcedure [dbo].[SP_CargoDocumentDelete]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[SP_CargoDocumentDelete] (
	@id BIGINT
	,@UpdateBy NVARCHAR(50)
	,@UpdateDate DATETIME
	,@IsDelete BIT
	)
AS
BEGIN
	UPDATE dbo.CargoDocument
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE Id = @id;	
END

GO

/****** Object:  StoredProcedure [dbo].[SP_CargoDocumentGetById]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CargoDocumentGetById]
(
	@id BIGINT
)	
AS
BEGIN
	SELECT
		CAST(t0.IdCargo as bigint) IdCargo
		, t0.Flow
		, t0.Step
		, t0.Status
		, t3.ViewByUser
		, t0.Notes
		, t0.CreateBy
		, t0.CreateDate
	FROM CargoHistory t0
	join FlowStep t1 on t1.Step = t0.Step
	join Flow t2 on t2.Id = t1.IdFlow
	join FlowStatus t3 on t3.[Status] = t0.[Status] AND t3.IdStep = t1.Id
	join employee t4 on t4.AD_User = t0.CreateBy
	WHERE t0.IdCargo = @id;
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoDocumentUpdateFile]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_CargoDocumentUpdateFile]
(
	@Id BIGINT,
	@Filename NVARCHAR(MAX) = '',
	@UpdateBy NVARCHAR(MAX) = ''
)
AS
BEGIN
 
	UPDATE dbo.CargoDocument
	SET [Filename] = @Filename,
	[UpdateBy] = @Updateby,
	[UpdateDate] = GETDATE()
	WHERE Id = @Id;

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

/****** Object:  StoredProcedure [dbo].[SP_CargoForExport_Header_20210208]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ALTER PROCEDURE [dbo].[SP_CargoForExport_Header_20210208]
	@CargoID bigint
AS
BEGIN

	declare @CiplNos nvarchar(MAX) = STUFF(
		(SELECT ', ' + CAST(cp.CiplNo as NVARCHAR) 
			FROM Cargo c
			left join CargoItem ci on c.Id = ci.IdCargo
			left join CiplItem cpi on ci.IdCiplItem = cpi.Id
			left join Cipl cp on cpi.IdCipl = cp.id
			where c.Id = '988' and ci.isDelete = 0 and cpi.IsDelete = 0
			GROUP BY cp.CiplNo
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')

    select 
		c.ClNo, ISNULL(CONVERT(VARCHAR(11) , ch.CreateDate, 106), '-') as SubmitDate
		, @CiplNos as Reference
		, IIF(cp.Forwader IS NOT NULL AND LEN(cp.Forwader) > 0, cp.Forwader + IIF(cp.Area IS NOT NULL AND LEN(cp.Area) > 0, ' - ' + cp.Area, ''), '-') as ConsolidatorWithArea
		, e.Employee_Name as RequestorName
		, e.Email as RequestorEmail
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as ConsigneeName
		, IIF(cp.ConsigneeAddress IS NULL OR LEN(cp.ConsigneeAddress) <= 0, '-', cp.ConsigneeAddress) as ConsigneeAddress
		, IIF(cp.ConsigneePic IS NULL OR LEN(cp.ConsigneePic) <= 0, '-', cp.ConsigneePic) as ConsigneePic
		, IIF(cp.ConsigneeEmail IS NULL OR LEN(cp.ConsigneeEmail) <= 0, '-', cp.ConsigneeEmail) as ConsigneeEmail
		, IIF(cp.NotifyName IS NULL OR LEN(cp.NotifyName) <= 0, '-', cp.NotifyName) as NotifyName
		, IIF(cp.NotifyAddress IS NULL OR LEN(cp.NotifyAddress) <= 0, '-', cp.NotifyAddress) as NotifyAddress
		, IIF(cp.NotifyPic IS NULL OR LEN(cp.NotifyPic) <= 0, '-', cp.NotifyPic) as NotifyPic
		, IIF(cp.NotifyEmail IS NULL OR LEN(cp.NotifyEmail) <= 0, '-', cp.NotifyEmail) as NotifyEmail
		, CAST(ISNULL(ct.TotalCaseNumber, 0) as varchar(20)) as TotalCaseNumber
		, CAST(ISNULL(FORMAT(ct.TotalVolume, '#,0.00'), 0) as varchar(20)) as TotalVolume
		, CAST(ISNULL(ct.TotalNetWeight, 0) as varchar(20)) as TotalNetWeight
		, CAST(ISNULL(ct.TotalGrossWeight, 0) as varchar(20)) as TotalGrossWeight
		, IIF(cp.IncoTerm IS NULL OR LEN(cp.IncoTerm) <= 0, '-', cp.IncoTerm) as Incoterms
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateStarted, 106), '-') as StuffingDateStarted
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateFinished, 106), '-') as StuffingDateFinished
		, IIF(c.VesselFlight IS NULL OR LEN(c.VesselFlight) <= 0, '-', c.VesselFlight) as VesselFlight
		, IIF(c.ConnectingVesselFlight IS NULL OR LEN(c.ConnectingVesselFlight) <= 0, '-', c.ConnectingVesselFlight) as ConnectingVesselFlight
		, IIF(c.PortOfLoading IS NULL OR LEN(c.PortOfLoading) <= 0, '-', c.PortOfLoading) as LoadingPort
		, IIF(c.PortOfDestination IS NULL OR LEN(c.PortOfDestination) <= 0, '-', c.PortOfDestination) as DestinationPort
		, ISNULL(CONVERT(VARCHAR(11), c.SailingSchedule, 106), '-') as SailingSchedule
		, ISNULL(CONVERT(VARCHAR(11), c.ArrivalDestination, 106), '-') as ETA
		, IIF(c.BookingNumber IS NULL OR LEN(c.BookingNumber) <= 0, '-', c.BookingNumber) as BookingNumber
		, ISNULL(CONVERT(VARCHAR(11), c.BookingDate, 106), '-') as BookingDate
		, IIF(c.Liner IS NULL OR LEN(c.Liner) <= 0, '-', c.Liner) as Liner
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
		, ISNULL(cp.ShipDelivery, '-') as ShipDelivery
	from Cargo c
	outer apply(
		select top 1* from CargoHistory where IdCargo = c.id and Step = 'Create' and Status = 'Submit' order by Id desc
	) ch
	left join (
		select 
			CargoID
			, COUNT(CaseNumber) as TotalCaseNumber
			, FORMAT(SUM(NetWeight), '#,0.00') as TotalNetWeight
			, FORMAT(SUM(GrossWeight), '#,0.00') as TotalGrossWeight
			, SUM(Volume) as TotalVolume
			, SUM(Amount) as TotalAmount 
		from (
			select 
				master.CargoID, master.CiplID
				,cpi.CaseNumber as CaseNumber
				--, COUNT(cpi.CaseNumber) as CaseNumber
				, (SUM(ci.Width * ci.Length * ci.Height) / 1000000) as Volume
				, SUM(ci.Net) as NetWeight
				, SUM(ci.Gross) as GrossWeight
				, SUM(cpi.UnitPrice) as Amount 
			from
			(
				select 
					ci.Id as CargoItemID
					, ci.IdCargo as CargoID
					, cpi.Id AS CiplItemID
					, cp.id as CiplID
				from CargoItem ci
				inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
				inner join Cipl cp on cpi.IdCipl=cp.id
			) master
			inner join CargoItem ci on master.CargoItemID = ci.Id
			inner join CiplItem cpi on master.CiplItemID = cpi.Id
			where master.CargoID = '988' and ci.isDelete = 0 and cpi.IsDelete = 0
			group by master.CargoID, master.CiplID, cpi.CaseNumber
		) data
		group by CargoID
	) ct on c.Id = ct.CargoID
	left join (
		select ci.IdCargo, max(cpi.IdCipl) as IdCipl from CargoItem ci
		inner join CiplItem cpi on ci.IdCiplItem = cpi.Id
		group by ci.IdCargo
	) cpi on c.Id = cpi.IdCargo
	outer apply(
		select top 1* from Cipl where id= cpi.IdCipl order by Id desc
	) cp
	inner join dbo.fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join fn_get_cl_request_list_all() r on c.id = r.IdCl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	where c.Id = '988'

END



GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExport_Header_20210721]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CargoForExport_Header_20210721]
	@CargoID bigint
AS
BEGIN

	declare @CiplNos nvarchar(MAX) = STUFF(
		(SELECT ', ' + CAST(cp.CiplNo as NVARCHAR) 
			FROM Cargo c
			left join CargoItem ci on c.Id = ci.IdCargo
			left join CiplItem cpi on ci.IdCiplItem = cpi.Id
			left join Cipl cp on cpi.IdCipl = cp.id
			where c.Id = '988' and ci.isDelete = 0 and cpi.IsDelete = 0
			GROUP BY cp.CiplNo
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')

    select 
		c.ClNo, ISNULL(CONVERT(VARCHAR(11) , ch.CreateDate, 106), '-') as SubmitDate
		, @CiplNos as Reference
		, IIF(cp.Forwader IS NOT NULL AND LEN(cp.Forwader) > 0, cp.Forwader + IIF(cp.Area IS NOT NULL AND LEN(cp.Area) > 0, ' - ' + cp.Area, ''), '-') as ConsolidatorWithArea
		, e.usertype as UserType
		, e.Employee_Name as RequestorName
		, e.Email as RequestorEmail
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as ConsigneeName
		, IIF(cp.ConsigneeAddress IS NULL OR LEN(cp.ConsigneeAddress) <= 0, '-', cp.ConsigneeAddress) as ConsigneeAddress
		, IIF(cp.ConsigneePic IS NULL OR LEN(cp.ConsigneePic) <= 0, '-', cp.ConsigneePic) as ConsigneePic
		, IIF(cp.ConsigneeEmail IS NULL OR LEN(cp.ConsigneeEmail) <= 0, '-', cp.ConsigneeEmail) as ConsigneeEmail
		, IIF(cp.NotifyName IS NULL OR LEN(cp.NotifyName) <= 0, '-', cp.NotifyName) as NotifyName
		, IIF(cp.NotifyAddress IS NULL OR LEN(cp.NotifyAddress) <= 0, '-', cp.NotifyAddress) as NotifyAddress
		, IIF(cp.NotifyPic IS NULL OR LEN(cp.NotifyPic) <= 0, '-', cp.NotifyPic) as NotifyPic
		, IIF(cp.NotifyEmail IS NULL OR LEN(cp.NotifyEmail) <= 0, '-', cp.NotifyEmail) as NotifyEmail
		, CAST(ISNULL(ct.TotalCaseNumber, 0) as varchar(20)) as TotalCaseNumber
		, CAST(ISNULL(ct.TotalVolume, 0) as varchar(20)) as TotalVolume
		, CAST(ISNULL(ct.TotalNetWeight, 0) as varchar(20)) as TotalNetWeight
		, CAST(ISNULL(ct.TotalGrossWeight, 0) as varchar(20)) as TotalGrossWeight
		, IIF(cp.IncoTerm IS NULL OR LEN(cp.IncoTerm) <= 0, '-', cp.IncoTerm) as Incoterms
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateStarted, 106), '-') as StuffingDateStarted
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateFinished, 106), '-') as StuffingDateFinished
		, IIF(c.VesselFlight IS NULL OR LEN(c.VesselFlight) <= 0, '-', c.VesselFlight) as VesselFlight
		, IIF(c.ConnectingVesselFlight IS NULL OR LEN(c.ConnectingVesselFlight) <= 0, '-', c.ConnectingVesselFlight) as ConnectingVesselFlight
		, IIF(c.PortOfLoading IS NULL OR LEN(c.PortOfLoading) <= 0, '-', c.PortOfLoading) as LoadingPort
		, IIF(c.PortOfDestination IS NULL OR LEN(c.PortOfDestination) <= 0, '-', c.PortOfDestination) as DestinationPort
		, ISNULL(CONVERT(VARCHAR(11), c.SailingSchedule, 106), '-') as SailingSchedule
		, ISNULL(CONVERT(VARCHAR(11), c.ArrivalDestination, 106), '-') as ETA
		, IIF(c.BookingNumber IS NULL OR LEN(c.BookingNumber) <= 0, '-', c.BookingNumber) as BookingNumber
		, ISNULL(CONVERT(VARCHAR(11), c.BookingDate, 106), '-') as BookingDate
		, IIF(c.Liner IS NULL OR LEN(c.Liner) <= 0, '-', c.Liner) as Liner
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
		, ISNULL(cp.ShipDelivery, '-') as ShipDelivery
	from Cargo c
	outer apply(
		select top 1* from CargoHistory where IdCargo = c.id and Step = 'Create' and Status = 'Submit' order by Id desc
	) ch
	left join (
		select 
			CargoID
			, COUNT(CaseNumber) as TotalCaseNumber
			, FORMAT(SUM(NetWeight), '#,0.00') as TotalNetWeight
			, FORMAT(SUM(GrossWeight), '#,0.00') as TotalGrossWeight
			, SUM(Volume) as TotalVolume
			, SUM(Amount) as TotalAmount 
		from (
			select 
				master.CargoID, master.CiplID
				,cpi.CaseNumber as CaseNumber
				--, COUNT(cpi.CaseNumber) as CaseNumber
				, (SUM(ci.Width * ci.Length * ci.Height) / 1000000) as Volume
				, SUM(ci.Net) as NetWeight
				, SUM(ci.Gross) as GrossWeight
				, SUM(cpi.UnitPrice) as Amount 
			from
			(
				select 
					ci.Id as CargoItemID
					, ci.IdCargo as CargoID
					, cpi.Id AS CiplItemID
					, cp.id as CiplID
				from CargoItem ci
				inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
				inner join Cipl cp on cpi.IdCipl=cp.id
			) master
			inner join CargoItem ci on master.CargoItemID = ci.Id
			inner join CiplItem cpi on master.CiplItemID = cpi.Id
			where master.CargoID = @CargoID and ci.isDelete = 0 and cpi.IsDelete = 0
			group by master.CargoID, master.CiplID, cpi.CaseNumber
		) data
		group by CargoID
	) ct on c.Id = ct.CargoID
	left join (
		select ci.IdCargo, max(cpi.IdCipl) as IdCipl from CargoItem ci
		inner join CiplItem cpi on ci.IdCiplItem = cpi.Id
		group by ci.IdCargo
	) cpi on c.Id = cpi.IdCargo
	outer apply(
		select top 1* from Cipl where id= cpi.IdCipl order by Id desc
	) cp
	inner join dbo.fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join fn_get_cl_request_list_all() r on c.id = r.IdCl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	where c.Id = @CargoID

END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExport_Header_20210723]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CargoForExport_Header_20210723]
	@CargoID bigint
AS
BEGIN

	declare @CiplNos nvarchar(MAX) = STUFF(
		(SELECT ', ' + CAST(cp.CiplNo as NVARCHAR) 
			FROM Cargo c
			left join CargoItem ci on c.Id = ci.IdCargo
			left join CiplItem cpi on ci.IdCiplItem = cpi.Id
			left join Cipl cp on cpi.IdCipl = cp.id
			where c.Id = '988' and ci.isDelete = 0 and cpi.IsDelete = 0
			GROUP BY cp.CiplNo
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')

    select 
		c.ClNo, ISNULL(CONVERT(VARCHAR(11) , ch.CreateDate, 106), '-') as SubmitDate
		, @CiplNos as Reference
		, IIF(cp.Forwader IS NOT NULL AND LEN(cp.Forwader) > 0, cp.Forwader + IIF(cp.Area IS NOT NULL AND LEN(cp.Area) > 0, ' - ' + cp.Area, ''), '-') as ConsolidatorWithArea
		, e.usertype as UserType
		, e.Employee_Name as RequestorName
		, e.Email as RequestorEmail
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as ConsigneeName
		, IIF(cp.ConsigneeAddress IS NULL OR LEN(cp.ConsigneeAddress) <= 0, '-', cp.ConsigneeAddress) as ConsigneeAddress
		, IIF(cp.ConsigneePic IS NULL OR LEN(cp.ConsigneePic) <= 0, '-', cp.ConsigneePic) as ConsigneePic
		, IIF(cp.ConsigneeEmail IS NULL OR LEN(cp.ConsigneeEmail) <= 0, '-', cp.ConsigneeEmail) as ConsigneeEmail
		, IIF(cp.NotifyName IS NULL OR LEN(cp.NotifyName) <= 0, '-', cp.NotifyName) as NotifyName
		, IIF(cp.NotifyAddress IS NULL OR LEN(cp.NotifyAddress) <= 0, '-', cp.NotifyAddress) as NotifyAddress
		, IIF(cp.NotifyPic IS NULL OR LEN(cp.NotifyPic) <= 0, '-', cp.NotifyPic) as NotifyPic
		, IIF(cp.NotifyEmail IS NULL OR LEN(cp.NotifyEmail) <= 0, '-', cp.NotifyEmail) as NotifyEmail
		, CAST(ISNULL(ct.TotalCaseNumber, 0) as varchar(20)) as TotalCaseNumber
		, CAST(ISNULL(ct.TotalVolume, 0) as varchar(20)) as TotalVolume
		, CAST(ISNULL(ct.TotalNetWeight, 0) as varchar(20)) as TotalNetWeight
		, CAST(ISNULL(ct.TotalGrossWeight, 0) as varchar(20)) as TotalGrossWeight
		, IIF(cp.IncoTerm IS NULL OR LEN(cp.IncoTerm) <= 0, '-', cp.IncoTerm) as Incoterms
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateStarted, 106), '-') as StuffingDateStarted
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateFinished, 106), '-') as StuffingDateFinished
		, IIF(c.VesselFlight IS NULL OR LEN(c.VesselFlight) <= 0, '-', c.VesselFlight) as VesselFlight
		, IIF(c.ConnectingVesselFlight IS NULL OR LEN(c.ConnectingVesselFlight) <= 0, '-', c.ConnectingVesselFlight) as ConnectingVesselFlight
		, IIF(c.PortOfLoading IS NULL OR LEN(c.PortOfLoading) <= 0, '-', c.PortOfLoading) as LoadingPort
		, IIF(c.PortOfDestination IS NULL OR LEN(c.PortOfDestination) <= 0, '-', c.PortOfDestination) as DestinationPort
		, ISNULL(CONVERT(VARCHAR(11), c.SailingSchedule, 106), '-') as SailingSchedule
		, ISNULL(CONVERT(VARCHAR(11), c.ArrivalDestination, 106), '-') as ETA
		, IIF(c.BookingNumber IS NULL OR LEN(c.BookingNumber) <= 0, '-', c.BookingNumber) as BookingNumber
		, ISNULL(CONVERT(VARCHAR(11), c.BookingDate, 106), '-') as BookingDate
		, IIF(c.Liner IS NULL OR LEN(c.Liner) <= 0, '-', c.Liner) as Liner
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
		, ISNULL(cp.ShipDelivery, '-') as ShipDelivery
	from Cargo c
	outer apply(
		select top 1* from CargoHistory where IdCargo = c.id and Step = 'Create' and Status = 'Submit' order by Id desc
	) ch
	left join (
		select 
			CargoID
			, COUNT(CaseNumber) as TotalCaseNumber
			, FORMAT(SUM(NetWeight), '#,0.00') as TotalNetWeight
			, FORMAT(SUM(GrossWeight), '#,0.00') as TotalGrossWeight
			, SUM(Volume) as TotalVolume
			, SUM(Amount) as TotalAmount 
		from (
			select 
				master.CargoID, master.CiplID
				,cpi.CaseNumber as CaseNumber
				--, COUNT(cpi.CaseNumber) as CaseNumber
				, (SUM(ISNULL(ci.NewWidth, ci.Width) * ISNULL(ci.NewLength, ci.Length) * ISNULL(ci.NewHeight, ci.Height)) / 1000000) as Volume
				, SUM(ISNULL(ci.NewNet, ci.Net)) as NetWeight
				, SUM(ISNULL(ci.NewGross, ci.Gross)) as GrossWeight
				, SUM(cpi.UnitPrice) as Amount 
			from
			(
				select 
					ci.Id as CargoItemID
					, ci.IdCargo as CargoID
					, cpi.Id AS CiplItemID
					, cp.id as CiplID
				from CargoItem ci
				inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
				inner join Cipl cp on cpi.IdCipl=cp.id
			) master
			inner join CargoItem ci on master.CargoItemID = ci.Id
			inner join CiplItem cpi on master.CiplItemID = cpi.Id
			where master.CargoID = @CargoID and ci.isDelete = 0 and cpi.IsDelete = 0
			group by master.CargoID, master.CiplID, cpi.CaseNumber
		) data
		group by CargoID
	) ct on c.Id = ct.CargoID
	left join (
		select ci.IdCargo, max(cpi.IdCipl) as IdCipl from CargoItem ci
		inner join CiplItem cpi on ci.IdCiplItem = cpi.Id
		group by ci.IdCargo
	) cpi on c.Id = cpi.IdCargo
	outer apply(
		select top 1* from Cipl where id= cpi.IdCipl order by Id desc
	) cp
	inner join dbo.fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join fn_get_cl_request_list_all() r on c.id = r.IdCl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	where c.Id = @CargoID

END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExport_Header]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CargoForExport_Header]
	@CargoID bigint
AS
BEGIN

	declare @CiplNos nvarchar(MAX) = STUFF(
		(SELECT ', ' + CAST(cp.CiplNo as NVARCHAR) 
			FROM Cargo c
			left join CargoItem ci on c.Id = ci.IdCargo
			left join CiplItem cpi on ci.IdCiplItem = cpi.Id
			left join Cipl cp on cpi.IdCipl = cp.id
			where c.Id = '988' and ci.isDelete = 0 and cpi.IsDelete = 0
			GROUP BY cp.CiplNo
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')

    select 
		c.ClNo, ISNULL(CONVERT(VARCHAR(11) , ch.CreateDate, 106), '-') as SubmitDate
		, @CiplNos as Reference
		, IIF(cp.Forwader IS NOT NULL AND LEN(cp.Forwader) > 0, cp.Forwader + IIF(cp.Area IS NOT NULL AND LEN(cp.Area) > 0, ' - ' + cp.Area, ''), '-') as ConsolidatorWithArea
		, e.usertype as UserType
		, e.Employee_Name as RequestorName
		, e.Email as RequestorEmail
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as ConsigneeName
		, IIF(cp.ConsigneeAddress IS NULL OR LEN(cp.ConsigneeAddress) <= 0, '-', cp.ConsigneeAddress) as ConsigneeAddress
		, IIF(cp.ConsigneePic IS NULL OR LEN(cp.ConsigneePic) <= 0, '-', cp.ConsigneePic) as ConsigneePic
		, IIF(cp.ConsigneeEmail IS NULL OR LEN(cp.ConsigneeEmail) <= 0, '-', cp.ConsigneeEmail) as ConsigneeEmail
		, IIF(cp.NotifyName IS NULL OR LEN(cp.NotifyName) <= 0, '-', cp.NotifyName) as NotifyName
		, IIF(cp.NotifyAddress IS NULL OR LEN(cp.NotifyAddress) <= 0, '-', cp.NotifyAddress) as NotifyAddress
		, IIF(cp.NotifyPic IS NULL OR LEN(cp.NotifyPic) <= 0, '-', cp.NotifyPic) as NotifyPic
		, IIF(cp.NotifyEmail IS NULL OR LEN(cp.NotifyEmail) <= 0, '-', cp.NotifyEmail) as NotifyEmail
		, CAST(ISNULL(ct.TotalCaseNumber, 0) as varchar(20)) as TotalCaseNumber
		, CAST(ISNULL(ct.TotalVolume, 0) as varchar(20)) as TotalVolume
		, CAST(ISNULL(ct.TotalNetWeight, 0) as varchar(20)) as TotalNetWeight
		, CAST(ISNULL(ct.TotalGrossWeight, 0) as varchar(20)) as TotalGrossWeight
		, IIF(cp.IncoTerm IS NULL OR LEN(cp.IncoTerm) <= 0, '-', cp.IncoTerm) as Incoterms
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateStarted, 106), '-') as StuffingDateStarted
		, ISNULL(CONVERT(VARCHAR(11), c.StuffingDateFinished, 106), '-') as StuffingDateFinished
		, IIF(c.VesselFlight IS NULL OR LEN(c.VesselFlight) <= 0, '-', c.VesselFlight) as VesselFlight
		, IIF(c.ConnectingVesselFlight IS NULL OR LEN(c.ConnectingVesselFlight) <= 0, '-', c.ConnectingVesselFlight) as ConnectingVesselFlight
		, IIF(c.PortOfLoading IS NULL OR LEN(c.PortOfLoading) <= 0, '-', c.PortOfLoading) as LoadingPort
		, IIF(c.PortOfDestination IS NULL OR LEN(c.PortOfDestination) <= 0, '-', c.PortOfDestination) as DestinationPort
		, ISNULL(CONVERT(VARCHAR(11), c.SailingSchedule, 106), '-') as SailingSchedule
		, ISNULL(CONVERT(VARCHAR(11), c.ArrivalDestination, 106), '-') as ETA
		, IIF(c.BookingNumber IS NULL OR LEN(c.BookingNumber) <= 0, '-', c.BookingNumber) as BookingNumber
		, ISNULL(CONVERT(VARCHAR(11), c.BookingDate, 106), '-') as BookingDate
		, IIF(c.Liner IS NULL OR LEN(c.Liner) <= 0, '-', c.Liner) as Liner
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
		, ISNULL(cp.ShipDelivery, '-') as ShipDelivery
	from Cargo c
	outer apply(
		select top 1* from CargoHistory where IdCargo = c.id and Step = 'Create' and Status = 'Submit' order by Id desc
	) ch
	left join (
		select 
			CargoID
			, COUNT(CaseNumber) as TotalCaseNumber
			, FORMAT(SUM(NetWeight), '#,0.00') as TotalNetWeight
			, FORMAT(SUM(GrossWeight), '#,0.00') as TotalGrossWeight
			, SUM(Volume) as TotalVolume
			, SUM(Amount) as TotalAmount 
		from (
			select 
				master.CargoID, master.CiplID
				,case
				when master.Category = 'CATERPILLAR SPAREPARTS' AND master.CategoriItem = 'SIB'
					then CAST(count(distinct ISNULL(cpi.JCode, '-')) as varchar(5))-- ISNULL(cpi.JCode, '-')
				when master.Category = 'CATERPILLAR SPAREPARTS' AND (master.CategoriItem = 'PRA' OR master.CategoriItem = 'Old Core')
					then CAST(count(distinct ISNULL(cpi.CaseNumber, '-')) as varchar(5)) --ISNULL(cpi.CaseNumber, '-')
				--
				when master.Category = 'CATERPILLAR USED EQUIPMENT'
					then CAST(count(distinct ISNULL(cpi.Id, '-')) as varchar(5)) --convert(nvarchar(255), cpi.Id) --ISNULL(cpi.Id,null)
				--
				else CAST(count(distinct(IIF(cpi.sn != '', cpi.sn, null))) as varchar(5))-- IIF(cpi.sn != '', cpi.sn, null) --CAST(count(distinct ci.Sn) as varchar(5))
			end as CaseNumber
				--,cpi.CaseNumber as CaseNumber
				--, COUNT(cpi.CaseNumber) as CaseNumber
				, (SUM(ISNULL(ci.NewWidth, ci.Width) * ISNULL(ci.NewLength, ci.Length) * ISNULL(ci.NewHeight, ci.Height)) / 1000000) as Volume
				, SUM(ISNULL(ci.NewNet, ci.Net)) as NetWeight
				, SUM(ISNULL(ci.NewGross, ci.Gross)) as GrossWeight
				, SUM(cpi.UnitPrice) as Amount 
			from
			(
				select 
					ci.Id as CargoItemID
					, ci.IdCargo as CargoID
					, cpi.Id AS CiplItemID
					, cp.id as CiplID
					, cp.Category
					, cp.CategoriItem
				from CargoItem ci
				inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
				inner join Cipl cp on cpi.IdCipl=cp.id
			) master
			inner join CargoItem ci on master.CargoItemID = ci.Id
			inner join CiplItem cpi on master.CiplItemID = cpi.Id
			where master.CargoID = @CargoID and ci.isDelete = 0 and cpi.IsDelete = 0
			group by master.CargoID, master.CiplID, cpi.CaseNumber, master.Category, master.CategoriItem
			--,cpi.JCode, cpi.CaseNumber, cpi.sn , cpi.Id
		) data
		group by CargoID
	) ct on c.Id = ct.CargoID
	left join (
		select ci.IdCargo, max(cpi.IdCipl) as IdCipl from CargoItem ci
		inner join CiplItem cpi on ci.IdCiplItem = cpi.Id
		group by ci.IdCargo
	) cpi on c.Id = cpi.IdCargo
	outer apply(
		select top 1* from Cipl where id= cpi.IdCipl order by Id desc
	) cp
	inner join dbo.fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join fn_get_cl_request_list_all() r on c.id = r.IdCl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	where c.Id = @CargoID

END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExportSI_Detail_Item]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[SP_CargoForExportSI_Detail_Item] -- sp_get_cargo_data 1
(
	@CargoID bigint
)
AS
BEGIN
	SELECT TOP 5 t1.name AS Name
	FROM CargoItem t0
	JOIN ciplitem t1 on t0.idciplitem = t1.id
	WHERE 1=1 AND t0.idcargo = @CargoID
	GROUP BY t1.name 
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExportSI_Detail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CargoForExportSI_Detail]
	@CargoID bigint
AS
BEGIN

	select distinct ContainerNumber, ISNULL(ct.Name, '-') as ContainerType, ContainerSealNumber 
	from CargoItem ci
	left join (select Value, Name from MasterParameter where IsDeleted = 0 and [Group] = 'ContainerType') ct on ci.ContainerType = ct.Value
	where IdCargo = @CargoID and isDelete = 0

END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExportSI_Header]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CargoForExportSI_Header]
	@CargoID bigint
AS
BEGIN

    select 
		ISNULL(si.SlNo, '-') as SiNo
		, ISNULL(CONVERT(VARCHAR(11), ch.CreateDate, 106), '-') as SiSubmitDate
		, ISNULL(e.Employee_Name, '-') as SiSubmitter
		, ISNULL(c.SsNo, ISNULL(cp.CiplNo, '-')) as ReferenceNo
		, IIF(cf.Forwader IS NULL OR LEN(cf.Forwader) <= 0, '-', cf.Forwader) as Forwarder
		, IIF(cf.Attention IS NULL OR LEN(cf.Attention) <= 0, '-', cf.Attention) as ForwarderAttention
		, IIF(cf.Email IS NULL OR LEN(cf.Email) <= 0, '-', cf.Email) as ForwarderEmail
		, IIF(cf.Contact IS NULL OR LEN(cf.Contact) <= 0, '-', cf.Contact) as ForwarderContact
		, IIF(cp.ShipDelivery IS NULL OR LEN(cp.ShipDelivery) <= 0, '-', cp.ShipDelivery) as ShipDelivery
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as ConsigneeName
		, IIF(cp.ConsigneeAddress IS NULL OR LEN(cp.ConsigneeAddress) <= 0, '-', cp.ConsigneeAddress) as ConsigneeAddress
		, IIF(cp.ConsigneePic IS NULL OR LEN(cp.ConsigneePic) <= 0, '-', cp.ConsigneePic) as ConsigneePic
		, IIF(cp.ConsigneeEmail IS NULL OR LEN(cp.ConsigneeEmail) <= 0, '-', cp.ConsigneeEmail) as ConsigneeEmail
		, IIF(cp.ConsigneeTelephone IS NULL OR LEN(cp.ConsigneeTelephone) <= 0, '-', cp.ConsigneeTelephone) as ConsigneeTelephone
		, IIF(cp.NotifyName IS NULL OR LEN(cp.NotifyName) <= 0, '-', cp.NotifyName) as NotifyName
		, IIF(cp.NotifyAddress IS NULL OR LEN(cp.NotifyAddress) <= 0, '-', cp.NotifyAddress) as NotifyAddress
		, IIF(cp.NotifyPic IS NULL OR LEN(cp.NotifyPic) <= 0, '-', cp.NotifyPic) as NotifyPic
		, IIF(cp.NotifyEmail IS NULL OR LEN(cp.NotifyEmail) <= 0, '-', cp.NotifyEmail) as NotifyEmail
		, IIF(cp.NotifyTelephone IS NULL OR LEN(cp.NotifyTelephone) <= 0, '-', cp.NotifyTelephone) as NotifyTelephone
		, IIF(cp.SoldToName IS NULL OR LEN(cp.SoldToName) <= 0, '-', cp.SoldToName) as SoldToName
		, IIF(cp.SoldToAddress IS NULL OR LEN(cp.SoldToAddress) <= 0, '-', cp.SoldToAddress) as SoldToAddress
		, IIF(cp.SoldToPic IS NULL OR LEN(cp.SoldToPic) <= 0, '-', cp.SoldToPic) as SoldToPic
		, IIF(cp.SoldToEmail IS NULL OR LEN(cp.SoldToEmail) <= 0, '-', cp.SoldToEmail) as SoldToEmail
		, IIF(cp.SoldToTelephone IS NULL OR LEN(cp.SoldToTelephone) <= 0, '-', cp.SoldToTelephone) as SoldToTelephone
		, IIF(cp.IncoTerm IS NULL OR LEN(cp.IncoTerm) <= 0, '-', cp.IncoTerm) as IncoTerm
		, IIF(cp.ShippingMarks IS NULL OR LEN(cp.ShippingMarks) <= 0, '-', cp.ShippingMarks) as ShippingMarks
		, IIF(cp.Category IS NULL OR LEN(cp.Category) <= 0, '-', cp.Category) as Description
		--, CAST(FORMAT(ISNULL(CAST(ct.TotalVolume as decimal(18,2)), 0), '#,0.00') as varchar(20)) as TotalVolume
		, CAST(FORMAT(ISNULL(ct.TotalVolume, 0), '#,0.000000') as varchar(20)) as TotalVolume
		, CAST(FORMAT(ISNULL(ct.TotalNetWeight, 0), '#,0.00') as varchar(20)) as TotalNetWeight
		, CAST(FORMAT(ISNULL(ct.TotalGrossWeight, 0), '#,0.00') as varchar(20)) as TotalGrossWeight
		, IIF(c.BookingNumber IS NULL OR LEN(c.BookingNumber) <= 0, '-', c.BookingNumber) as BookingNumber
		, ISNULL(CONVERT(VARCHAR(11), c.BookingDate, 106), '-') as BookingDate
		, ISNULL(c.PortOfLoading, '-') as PortOfLoading
		, IIF(dest.Id IS NULL, '-', dest.Country + ' - ' + dest.Name) as PortOfDestination
		, ISNULL(CONVERT(VARCHAR(11), c.ArrivalDestination, 106), '-') as ETA
		, ISNULL(CONVERT(VARCHAR(11), c.SailingSchedule, 106), '-') as ETD
		, IIF(c.VoyageVesselFlight IS NULL OR LEN(c.VoyageVesselFlight) <= 0, '-', c.VoyageVesselFlight) as VesselVoyage
		, IIF(c.VoyageConnectingVessel IS NULL OR LEN(c.VoyageConnectingVessel) <= 0, '-', c.VoyageConnectingVessel) as ConnectingVesselVoyage
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as FinalDestination
		, IIF(si.DocumentRequired IS NULL OR LEN(si.DocumentRequired) <= 0, '-', si.DocumentRequired) as DocumentRequired
		, IIF(si.SpecialInstruction IS NULL OR LEN(si.SpecialInstruction) <= 0, '-', si.SpecialInstruction) as SpecialInstruction
		, IIF(c.StuffingDateStarted IS NULL OR LEN(c.StuffingDateStarted) <= 0, 'No Stuffing', 'Stuffing on : ' + CONVERT(VARCHAR(20), c.StuffingDateStarted, 107)) as StuffingDate
		, IIF(c.StuffingDateFinished IS NULL OR LEN(c.StuffingDateFinished) <= 0, 'No Stuffing', 'Stuffing off : ' + CONVERT(VARCHAR(20), c.StuffingDateFinished, 107)) as StuffingDateOff
		, IIF(c.Liner IS NULL OR LEN(c.Liner) <= 0, 'No Shipping Line', 'Shipping Line : ' + c.Liner) as Liner
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
	from Cargo c
	left join (
		select 
			ci.IdCargo
			, max(cpi.IdCipl) as IdCipl 
		from CargoItem ci
		inner join CiplItem cpi on ci.IdCiplItem = cpi.Id
		where ci.isDelete = 0 and cpi.IsDelete = 0
		group by ci.IdCargo
	) cpi on c.Id = cpi.IdCargo
	outer apply(
		select top 1* from Cipl where id= cpi.IdCipl and IsDelete = 0 order by Id desc
	) cp
	outer apply(
		select top 1* from CiplForwader where IdCipl IN(
			select distinct cp.id from CargoItem ci
			inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
			inner join Cipl cp on cpi.IdCipl=cp.id
			where ci.IdCargo = @CargoID and ci.isDelete = 0 and cpi.IsDelete = 0 and cp.IsDelete = 0
		) order by Id desc
	) cf
	left join ShippingInstruction si on c.Id = si.IdCL
	left join (
		select 
			CargoID
			, SUM(CaseNumber) as TotalCaseNumber
			, SUM(NetWeight) as TotalNetWeight
			, SUM(GrossWeight) as TotalGrossWeight
			, SUM(Volume) as TotalVolume
			, SUM(Amount) as TotalAmount 
		from (
			select 
				master.CargoID
				, master.CiplID
				, COUNT(cpi.Id) as CaseNumber
				--, COUNT(DISTINCT cpi.CaseNumber) as CaseNumber
				, SUM(ci.Net) as NetWeight, SUM(ci.Gross) as GrossWeight
				, SUM((ci.Width*ci.Length*ci.Height)/1000000) as Volume
				, SUM(cpi.UnitPrice) as Amount 
			from (
				select 
					ci.Id as CargoItemID
					, ci.IdCargo as CargoID
					, cpi.Id AS CiplItemID
					, cp.id as CiplID
					--, ISNULL(cc.Description, '-') as CargoDescription 
					, ISNULL(cp.Category, '-') as Description
				from CargoItem ci
				inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
				inner join Cipl cp on cpi.IdCipl=cp.id
				--left join CargoContainer cc on ci.IdContainer = cc.Id
			) master
			inner join CargoItem ci on master.CargoItemID = ci.Id
			inner join CiplItem cpi on master.CiplItemID = cpi.Id
			where ci.isDelete = 0 and cpi.IsDelete = 0
			group by master.CargoID, master.CiplID
		) data
		group by CargoID
	) ct on c.Id = ct.CargoID
	outer apply(
		select top 1* from CargoHistory where IdCargo = c.id and Step='Create SI' and Status = 'Submit' order by Id desc
	) ch
	left join dbo.fn_get_employee_internal_ckb() e on ch.CreateBy = e.AD_User
	left join MasterAirSeaPort load on LEFT(c.PortOfLoading, 5) = load.Code
	left join MasterAirSeaPort dest on LEFT(c.PortOfDestination, 5) = dest.Code
	left join fn_get_cl_request_list_all() r on c.id = r.IdCl
	left join fn_get_employee_internal_ckb() s on ch.UpdateBy= s.AD_User
	where c.Id = @CargoID and c.IsDelete = 0

END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExportSI]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[SP_CargoForExportSI]
	@CargoID bigint
AS
BEGIN
    declare @Container nvarchar(MAX) = 'No Container'
	declare @containers table(container nvarchar(200))

	INSERT INTO @containers
	select distinct ContainerType from CargoItem where IdCargo = @CargoID and ContainerType <> '' AND ContainerType IS NOT NULL and isDelete = 0

	IF(EXISTS(SELECT container FROM @containers))
	BEGIN
		SET @Container = STUFF(
			(
				SELECT ', ' + container FROM @containers FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') 
		,1,1,'') + ' Container'
	END

	declare @ContainerNo nvarchar(MAX) = '-'
	declare @container_nos table(container_no nvarchar(200))

	INSERT INTO @container_nos
	select distinct ContainerNumber from CargoItem where IdCargo = @CargoID and ContainerNumber <> '' AND ContainerNumber IS NOT NULL and isDelete = 0

	IF(EXISTS(SELECT container_no FROM @container_nos))
	BEGIN
		SET @ContainerNo = STUFF(
			(
				SELECT ', ' + container_no FROM @container_nos FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') 
		,1,1,'')
	END
	------------------------------------------------------------------------------
	declare @SEALNo nvarchar(MAX) = '-'
	declare @seal_nos table(seal_no nvarchar(200))

	INSERT INTO @seal_nos
	select distinct ContainerSealNumber from CargoItem where IdCargo = @CargoID and ContainerSealNumber <> '' AND ContainerSealNumber IS NOT NULL

	IF(EXISTS(SELECT seal_no FROM @seal_nos))
	BEGIN
		SET @SEALNo = STUFF(
			(
				SELECT ', ' + seal_no FROM @seal_nos FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') 
		,1,1,'')
	END

	select 
		ISNULL(si.SlNo, '-') as SiNo
		, ISNULL(CONVERT(VARCHAR(11), ch.CreateDate, 106), '-') as SiSubmitDate
		, ISNULL(e.Employee_Name, '-') as SiSubmitter
		, ISNULL(c.SsNo, ISNULL(cp.CiplNo, '-')) as ReferenceNo
		, IIF(cf.Forwader IS NULL OR LEN(cf.Forwader) <= 0, '-', cf.Forwader) as Forwarder
		, IIF(cf.Attention IS NULL OR LEN(cf.Attention) <= 0, '-', cf.Attention) as ForwarderAttention
		, IIF(cf.Email IS NULL OR LEN(cf.Email) <= 0, '-', cf.Email) as ForwarderEmail
		, IIF(cf.Contact IS NULL OR LEN(cf.Contact) <= 0, '-', cf.Contact) as ForwarderContact
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as ConsigneeName
		, IIF(cp.ConsigneeAddress IS NULL OR LEN(cp.ConsigneeAddress) <= 0, '-', cp.ConsigneeAddress) as ConsigneeAddress
		, IIF(cp.ConsigneePic IS NULL OR LEN(cp.ConsigneePic) <= 0, '-', cp.ConsigneePic) as ConsigneePic
		, IIF(cp.ConsigneeEmail IS NULL OR LEN(cp.ConsigneeEmail) <= 0, '-', cp.ConsigneeEmail) as ConsigneeEmail
		, IIF(cp.ConsigneeTelephone IS NULL OR LEN(cp.ConsigneeTelephone) <= 0, '-', cp.ConsigneeTelephone) as ConsigneeTelephone
		, IIF(cp.NotifyName IS NULL OR LEN(cp.NotifyName) <= 0, '-', cp.NotifyName) as NotifyName
		, IIF(cp.NotifyAddress IS NULL OR LEN(cp.NotifyAddress) <= 0, '-', cp.NotifyAddress) as NotifyAddress
		, IIF(cp.NotifyPic IS NULL OR LEN(cp.NotifyPic) <= 0, '-', cp.NotifyPic) as NotifyPic
		, IIF(cp.NotifyEmail IS NULL OR LEN(cp.NotifyEmail) <= 0, '-', cp.NotifyEmail) as NotifyEmail
		, IIF(cp.NotifyTelephone IS NULL OR LEN(cp.NotifyTelephone) <= 0, '-', cp.NotifyTelephone) as NotifyTelephone
		, IIF(cp.IncoTerm IS NULL OR LEN(cp.IncoTerm) <= 0, '-', cp.IncoTerm) as IncoTerm
		, IIF(cp.ShippingMarks IS NULL OR LEN(cp.ShippingMarks) <= 0, '-', cp.ShippingMarks) as ShippingMarks
		, IIF(cp.Category IS NULL OR LEN(cp.Category) <= 0, '-', cp.Category) as Description
		, CAST(FORMAT(ISNULL(CAST(ct.TotalVolume as decimal(18,2)), 0), '#,0.00') as varchar(20)) as TotalVolume
		, CAST(FORMAT(ISNULL(ct.TotalNetWeight, 0), '#,0.00') as varchar(20)) as TotalNetWeight
		, CAST(FORMAT(ISNULL(ct.TotalGrossWeight, 0), '#,0.00') as varchar(20)) as TotalGrossWeight
		, IIF(c.BookingNumber IS NULL OR LEN(c.BookingNumber) <= 0, '-', c.BookingNumber) as BookingNumber
		, ISNULL(CONVERT(VARCHAR(11), c.BookingDate, 106), '-') as BookingDate
		, IIF(c.PortOfLoading IS NULL OR LEN(c.PortOfLoading) <= 0, '-', c.PortOfLoading) as PortOfLoading
		, IIF(c.PortOfDestination IS NULL OR LEN(c.PortOfDestination) <= 0, '-', c.PortOfDestination) as PortOfDestination
		--, ISNULL(CONVERT(VARCHAR(11), c.ETA, 106), '-') as ETA
		--, ISNULL(CONVERT(VARCHAR(11), c.ETD, 106), '-') as ETD
		, ISNULL(CONVERT(VARCHAR(11), c.ArrivalDestination, 106), '-') as ETA
		, ISNULL(CONVERT(VARCHAR(11), c.SailingSchedule, 106), '-') as ETD
		, IIF(c.VoyageVesselFlight IS NULL OR LEN(c.VoyageVesselFlight) <= 0, '-', c.VoyageVesselFlight) as VesselVoyage
		, IIF(c.VoyageConnectingVessel IS NULL OR LEN(c.VoyageConnectingVessel) <= 0, '-', c.VoyageConnectingVessel) as ConnectingVesselVoyage
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as FinalDestination
		, IIF(si.DocumentRequired IS NULL OR LEN(si.DocumentRequired) <= 0, '-', si.DocumentRequired) as DocumentRequired
		, IIF(si.SpecialInstruction IS NULL OR LEN(si.SpecialInstruction) <= 0, '-', si.SpecialInstruction) as SpecialInstruction
		, IIF(c.StuffingDateStarted IS NULL OR LEN(c.StuffingDateStarted) <= 0, 'No Stuffing', 'Stuffing on : ' + CONVERT(VARCHAR(20), c.StuffingDateStarted, 107)) as StuffingDate
		, IIF(c.StuffingDateFinished IS NULL OR LEN(c.StuffingDateFinished) <= 0, 'No Stuffing', 'Stuffing off : ' + CONVERT(VARCHAR(20), c.StuffingDateFinished, 107)) as StuffingDateOff
		, @Container as Container
		, IIF(c.Liner IS NULL OR LEN(c.Liner) <= 0, 'No Shipping Line', 'Shipping Line : ' + c.Liner) as Liner
		, @ContainerNo as ContainerNo
		, @SEALNo as SEALNo
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
	from Cargo c
	left join (
		select 
			ci.IdCargo
			, max(cpi.IdCipl) as IdCipl 
		from CargoItem ci
		inner join CiplItem cpi on ci.IdCiplItem = cpi.Id
		group by ci.IdCargo
	) cpi on c.Id = cpi.IdCargo
	outer apply(
		select top 1* from Cipl where id= cpi.IdCipl order by Id desc
	) cp
	outer apply(
		select top 1* from CiplForwader where IdCipl IN(
			select distinct cp.id from CargoItem ci
			inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
			inner join Cipl cp on cpi.IdCipl=cp.id
			where ci.IdCargo = @CargoID
		) order by Id desc
	) cf
	left join ShippingInstruction si on c.Id = si.IdCL
	left join (
		select 
			CargoID
			, SUM(CaseNumber) as TotalCaseNumber
			, SUM(NetWeight) as TotalNetWeight
			, SUM(GrossWeight) as TotalGrossWeight
			, SUM(Volume) as TotalVolume
			, SUM(Amount) as TotalAmount 
		from (
			select 
				master.CargoID
				, master.CiplID
				, COUNT(DISTINCT cpi.CaseNumber) as CaseNumber
				, SUM(ci.Net) as NetWeight, SUM(ci.Gross) as GrossWeight
				, SUM(ci.Width*ci.Length*ci.Height) as Volume
				, SUM(cpi.UnitPrice) as Amount 
			from (
				select 
					ci.Id as CargoItemID
					, ci.IdCargo as CargoID
					, cpi.Id AS CiplItemID
					, cp.id as CiplID
					--, ISNULL(cc.Description, '-') as CargoDescription 
					, ISNULL(cp.Category, '-') as Description
				from CargoItem ci
				inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
				inner join Cipl cp on cpi.IdCipl=cp.id
				--left join CargoContainer cc on ci.IdContainer = cc.Id
			) master
			inner join CargoItem ci on master.CargoItemID = ci.Id
			inner join CiplItem cpi on master.CiplItemID = cpi.Id
			where ci.isDelete = 0 and cpi.IsDelete = 0
			group by master.CargoID, master.CiplID
		) data
		group by CargoID
	) ct on c.Id = ct.CargoID
	outer apply(
		select top 1* from CargoHistory where IdCargo = c.id and Step='Create SI' and Status = 'Submit' order by Id desc
	) ch
	left join dbo.fn_get_employee_internal_ckb() e on ch.CreateBy = e.AD_User
	left join fn_get_cl_request_list_all() r on c.id = r.IdCl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	where c.Id = @CargoID
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExportSSDetail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec [dbo].[SP_CargoForExportSSDetail] @CargoID = 9
ALTER PROCEDURE [dbo].[SP_CargoForExportSSDetail] 
	@CargoID bigint
AS
BEGIN
	select 
		master.CiplID
		, MAX(master.CargoDescription) CargoDescription
		, MAX(cipl.CiplNo) as CiplNo
		, CAST(COUNT(DISTINCT IIF(cpi.CaseNumber IS NULL OR LEN(cpi.CaseNumber) <= 0, '-', cpi.CaseNumber)) as varchar(5)) as TotalCaseNumber
		, CAST(CAST(SUM(ISNULL(ci.Width, 0) * ISNULL(ci.Length, 0) * ISNULL(ci.Height, 0)) as decimal(18,2)) as varchar(20)) as TotalVolume
		, CAST(FORMAT(SUM(ISNULL(ci.Net, 0)), '#,0.00') as varchar(20)) as TotalNetWeight
		, CAST(FORMAT(SUM(ISNULL(ci.Gross, 0)), '#,0.00') as varchar(20)) as TotalGrossWeight
		, CAST(FORMAT(SUM(ISNULL(cpi.Extendedvalue, 0)), '#,0.00') as varchar(20)) as TotalAmount 
	from
	(
		select 
			ci.Id as CargoItemID
			, ci.IdCargo as CargoID
			, cpi.Id AS CiplItemID
			, cp.id as CiplID
			, IIF(cp.Category IS NULL OR LEN(cp.Category) <= 0, '-', cp.Category) as CargoDescription
		from CargoItem ci
		inner join CiplItem cpi on ci.IdCiplItem=cpi.Id
		inner join Cipl cp on cpi.IdCipl=cp.id
		where ci.isDelete = 0 and cpi.IsDelete = 0
	) master
	inner join CargoItem ci on master.CargoItemID = ci.Id
	inner join CiplItem cpi on master.CiplItemID = cpi.Id
	inner join dbo.Cipl cipl on master.CiplID = cipl.id
	where master.CargoID = @CargoID and ci.isDelete = 0 and cpi.IsDelete = 0
	group by master.CiplID, cipl.CiplNo
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoForExportSSHeader]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec DROP PROCEDURE SP_CargoForExportSSHeader @CargoID = 9;
ALTER PROCEDURE [dbo].[SP_CargoForExportSSHeader]
	@CargoID bigint
AS
BEGIN
    declare @Branch nvarchar(MAX) = '-'
	declare @branches table(branch nvarchar(200))

	INSERT INTO @branches
	select distinct ISNULL(a.BAreaName, '-') from CargoItem ci
	inner join CiplItem cpi on ci.IdCiplItem = cpi.Id
	inner join Cipl cp on cpi.IdCipl = cp.id
	left join MasterArea a on cp.Branch = a.BAreaCode
	where cp.Branch is not null and cp.Branch <> '' and ci.isDelete = 0 and cpi.IsDelete = 0 and ci.IdCargo = @CargoID

	IF(EXISTS(SELECT branch FROM @branches))
	BEGIN
		SET @Branch = STUFF(
			(
				SELECT ', ' + branch FROM @branches FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') 
		,1,1,'')
	END

	select 
		ISNULL(c.SsNo, '-') as SsNo
		, ISNULL(CONVERT(VARCHAR(11), ch.CreateDate, 106), '-') as ClApprovedDate
		, ISNULL(c.ClNo, '-') as ReferenceNo
		, ISNULL(e.Employee_Name, '-') as RequestorName
		, ISNULL(e.Email, '-') as RequestorEmail
		, IIF(e.usertype IS NOT NULL, IIF(e.usertype = 'internal', 'PT. TRAKINDO UTAMA', 'PT. Cipta Krida Bahari'),'-') AS UserType
		, IIF(cp.ShipDelivery IS NULL OR LEN(cp.ShipDelivery) <= 0, '-', cp.ShipDelivery) as ShipDelivery
		, IIF(cp.ConsigneeName IS NULL OR LEN(cp.ConsigneeName) <= 0, '-', cp.ConsigneeName) as ConsigneeName
		, IIF(cp.ConsigneeAddress IS NULL OR LEN(cp.ConsigneeAddress) <= 0, '-', cp.ConsigneeAddress) as ConsigneeAddress
		, IIF(cp.ConsigneePic IS NULL OR LEN(cp.ConsigneePic) <= 0, '-', cp.ConsigneePic) as ConsigneePic
		, IIF(cp.ConsigneeEmail IS NULL OR LEN(cp.ConsigneeEmail) <= 0, '-', cp.ConsigneeEmail) as ConsigneeEmail
		, IIF(cp.NotifyName IS NULL OR LEN(cp.NotifyName) <= 0, '-', cp.NotifyName) as NotifyName
		, IIF(cp.NotifyAddress IS NULL OR LEN(cp.NotifyAddress) <= 0, '-', cp.NotifyAddress) as NotifyAddress
		, IIF(cp.NotifyPic IS NULL OR LEN(cp.NotifyPic) <= 0, '-', cp.NotifyPic) as NotifyPic
		, IIF(cp.NotifyEmail IS NULL OR LEN(cp.NotifyEmail) <= 0, '-', cp.NotifyEmail) as NotifyEmail
		, IIF(cp.SoldToName IS NULL OR LEN(cp.SoldToName) <= 0, '-', cp.SoldToName) as SoldToName
		, IIF(cp.SoldToAddress IS NULL OR LEN(cp.SoldToAddress) <= 0, '-', cp.SoldToAddress) as SoldToAddress
		, IIF(cp.SoldToPic IS NULL OR LEN(cp.SoldToPic) <= 0, '-', cp.SoldToPic) as SoldToPic
		, IIF(cp.SoldToEmail IS NULL OR LEN(cp.SoldToEmail) <= 0, '-', cp.SoldToEmail) as SoldToEmail
		, IIF(cp.Category IS NULL OR LEN(cp.Category) <= 0, '-', cp.Category) as Category
		--, CAST(FORMAT(ISNULL(ct.TotalCaseNumber, 0), '#,0.00') as varchar(20)) as TotalCaseNumber
		, CAST(ISNULL(ct.TotalCaseNumber, 0) as varchar(20)) as TotalCaseNumber
		, CAST(FORMAT(ISNULL(ct.TotalNetWeight, 0), '#,0.00') as varchar(20)) as TotalNetWeight
		, CAST(FORMAT(ISNULL(ct.TotalGrossWeight, 0), '#,0.00') as varchar(20)) as TotalGrossWeight
		, CAST(FORMAT(CAST(ISNULL(ct.TotalVolume, 0) as decimal(8,4)), '#,0.00') as varchar(20)) as TotalVolume
		, CAST(FORMAT(ISNULL(ct.TotalAmount, 0), '#,0.00') as varchar(20)) as TotalAmount
		, @Branch as Branch
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
	from Cargo c
	left join (
		select ci.IdCargo, max(cpi.IdCipl) as IdCipl from CargoItem ci
		inner join CiplItem cpi on ci.IdCiplItem = cpi.Id
		where ci.isDelete = 0 and cpi.IsDelete = 0
		group by ci.IdCargo
	) cpi on c.Id = cpi.IdCargo
	outer apply(
		select top 1* from Cipl where id= cpi.IdCipl order by Id desc
	) cp
	left join (
		select 
			CargoID
			, COUNT(CaseNumber) as TotalCaseNumber
			, SUM(NetWeight) as TotalNetWeight
			, SUM(GrossWeight) as TotalGrossWeight
			, SUM(Volume) as TotalVolume
			, SUM(Amount) as TotalAmount 
		from (
			select 
				master.CargoID, master.CiplID
				, MAX(master.CargoDescription) as CargoDescription
				,cpi.CaseNumber as CaseNumber
				--, COUNT(cpi.Id) as CaseNumber
				, (SUM(ci.Width * ci.Length * ci.Height)/1000000) as Volume
				, SUM(ci.Net) as NetWeight
				, SUM(ci.Gross) as GrossWeight
				, SUM(cpi.Extendedvalue) as Amount 
			from
			(
				select 
					ci.Id as CargoItemID
					, ci.IdCargo as CargoID
					, cpi.Id AS CiplItemID
					, cp.id as CiplID
					, ISNULL(cp.Category, '-') as CargoDescription
				from CargoItem ci
				inner join CiplItem cpi on ci.IdCiplItem=cpi.Id and cpi.IsDelete = 0
				inner join Cipl cp on cpi.IdCipl=cp.id and cp.IsDelete = 0
				where ci.Isdelete = 0
			) master
			inner join CargoItem ci on master.CargoItemID = ci.Id and ci.isDelete = 0
			inner join CiplItem cpi on master.CiplItemID = cpi.Id and cpi.IsDelete = 0
			where master.CargoID = @CargoID  
			group by master.CargoID, master.CiplID, cpi.CaseNumber
		) data
		group by CargoID
	) ct on c.Id = ct.CargoID
	outer apply(
		select top 1* from CargoHistory where IdCargo = c.id and Step='Approval By Imex' and Status = 'Approve' order by Id desc
	) ch
	left join dbo.fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join fn_get_cl_request_list_all() r on c.id = r.IdCl
	left join fn_get_employee_internal_ckb() s on ch.UpdateBy= s.AD_User
	where c.Id = @CargoID
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoGetList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[SP_CargoGetList]
ALTER PROCEDURE [dbo].[SP_CargoGetList]
AS
BEGIN
	select 
		ca.Id as CargoID, ca.ClNo, ca.Consignee ConsigneeName, ca.NotifyParty NotifyName, ca.ExportType ExportType, ca.Category, ca.IncoTerms--, ci.Container
		--, ca.CargoDescription,
	,ca.StuffingDateStarted, ca.StuffingDateFinished, ca.VesselFlight, ca.ConnectingVesselFlight, ca.VoyageVesselFlight, ca.VoyageConnectingVessel, 
	ca.PortOfLoading, ca.PortOfDestination, ca.SailingSchedule, ca.ArrivalDestination, ca.BookingNumber, ca.BookingDate, ca.Liner, ca.ETA, ca.ETD
	from Cargo ca
	Where IsDelete = 0
 --   select ca.Id as ID, ca.ClNo as CLNo, ISNULL(cp.ConsigneeName, '-') as Consignee, CONVERT(VARCHAR(9), ca.ETA, 6) AS ETA, CONVERT(VARCHAR(9), ca.ETD, 6) AS ETD,
	--ISNULL(cp.ShippingMethod, '-') as ShippingMethod, ISNULL(cp.Forwader, '-') as Forwarder, 
	--ISNULL(ca.PortOfLoading, '-') as PortOfLoading, ISNULL(ca.PortOfDestination, '-') as PortOfDestination, f.Status
	--from Cargo ca
	--cross apply (
	--	select TOP 1 * from CargoItem where IdCargo = ca.Id
	--)ci
	--left join CiplItem cpi on ci.IdCipl = cpi.id
	--left join Cipl cp on cpi.IdCipl = cp.id
	--inner join RequestCl f on ca.Id = f.IdCl
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoHistoryGetById]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[SP_CargoHistoryGetById]
(
	@id BIGINT
)	
AS
BEGIN
	SELECT
		CAST(t0.IdCargo as bigint) IdCargo
		, t0.Flow
		, t0.Step
		, t0.Status
		, t3.ViewByUser
		, t0.Notes
		, t5.Employee_Name AS CreateBy
		, t0.CreateDate
	FROM CargoHistory t0
	join FlowStep t1 on t1.Step = t0.Step
	join Flow t2 on t2.Id = t1.IdFlow
	join FlowStatus t3 on t3.[Status] = t0.[Status] AND t3.IdStep = t1.Id
	LEFT join employee t4 on t4.AD_User = t0.CreateBy
	join fn_get_employee_internal_ckb() t5 on t0.CreateBy = t5.AD_User 
	WHERE t0.IdCargo = @id
	ORDER BY t0.CreateDate desc;
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CargoProblemHistoryGetById]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CargoProblemHistoryGetById]
(
	@id NVARCHAR(10),
	@IsTotal bit = 0,
	@sort nvarchar(100) = 'Id',
	@order nvarchar(100) = 'ASC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)	
AS
BEGIN
	DECLARE @sql nvarchar(max);  
	SET @sql = 'SELECT ';
	SET @sort = 't0.'+@sort;

	IF (@IsTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total'
	END 
	ELSE
	BEGIN
		SET @sql += 't1.id
					, t0.ReqType
					, t0.Category
					, t0.[Case] as CargoCase
					, t0.Causes
					, t0.Impact
					, t0.CaseDate
					, t2.Employee_Name as PIC'
	END
	SET @sql +=' FROM ProblemHistory t0 
	join Cipl t1 on t0.IDRequest = t1.id
	join employee t2 on t2.AD_User = t0.CreateBy
	WHERE  t0.ReqType= ''Cipl'' and t1.id = '+@id;
	--select @sql;
	EXECUTE(@sql);
	--print(@sql);
	
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_ChangeHistory_Insert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[Sp_ChangeHistory_Insert]          
@FormType nvarchar(300)          
,@FormNo nvarchar(300)         
,@FormId int         
,@Reason nvarchar(MAX)          
,@CreateBy nvarchar(300)          
AS          
BEGIN          
        
DECLARE @Approver NVARCHAR(150)    
    
       
DECLARE @ResultId INT          
INSERT INTO RequestForChange (FormType,          
FormNo,        
RFCNumber,        
FormId,        
Reason,          
CreateBy,Approver,[Status]) VALUES (@FormType,@FormNo,'',@FormId,@Reason,@CreateBy,'',1)          
          
SET @ResultId = SCOPE_IDENTITY()      
        
SELECT @ResultId          
END
GO

/****** Object:  StoredProcedure [dbo].[SP_ChangeHistory_RequestForChange_Insert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[SP_ChangeHistory_RequestForChange_Insert]
 @FormType nvarchar(100)
,@FormNo INT
,@Reason NVARCHAR(MAX)
,@CreateBy NVARCHAR(150)
AS
BEGIN
DECLARE @ResultID INT
INSERT INTO RequestForChange
(FormType,
FormNo,
Reason,
CreateBy)VALUES
(@FormType,
@FormNo,
@Reason,
@CreateBy)
SET @ResultID = SCOPE_IDENTITY()
SELECT @ResultID
END

GO

/****** Object:  StoredProcedure [dbo].[SP_ChangeHistory_RFCItem_Insert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[SP_ChangeHistory_RFCItem_Insert]
@RFCID INT
,@FieldName NVARCHAR(200)
,@BeforeValue NVARCHAR(200)
,@AfterValue NVARCHAR(200)
AS
BEGIN
DECLARE @ResultID INT
INSERT INTO RFCItem
(RFCID,
AfterValue,
BeforeValue,
FieldName)VALUES
(@RFCID,
@AfterValue,
@BeforeValue,
@FieldName)
SET @ResultID = SCOPE_IDENTITY()
SELECT @ResultID
END

GO

/****** Object:  StoredProcedure [dbo].[Sp_checkarmadadata]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[Sp_checkarmadadata] --'40946'
(
@Id nvarchar(max)
)
as
begin

select Count(*) from CiplItem where IdCipl In (select distinct IdCipl from ShippingFleetItem where IdGr = @Id)
end
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplChangeHistoryGetByFormType]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplChangeHistoryGetByFormType] -- exec [dbo].[SP_CiplChangeHistoryGetById] '33433','CIPL',0,'CreateDate','asc','0','10'              
(              
 @id NVARCHAR(10),             
 @formtype NVARCHAR(100),             
 @IsTotal bit = 0,              
 @sort nvarchar(100) = 'CreateDate',              
 @order nvarchar(100) = 'DESC',              
 @offset nvarchar(100) = '0',              
 @limit nvarchar(100) = '10'              
)               
AS              
BEGIN              
 DECLARE @sql nvarchar(max);                
            
              
 SET @sql = 'SELECT ';              
 SET @sort = 'RF.'+@sort;              
              
 IF (@IsTotal <> 0)              
 BEGIN              
  SET @sql += 'count(*) total'              
 END               
 ELSE              
 BEGIN              
 SET @sql += 'R.FieldName,            
R.BeforeValue,            
R.AfterValue,        
RF.ID,        
RF.FormNo,          
RF.CreateBy,            
RF.CreateDate,            
RF.Reason'              
 END              
 SET @sql +=' FROM RequestForChange RF            
 INNER JOIN RFCItem R ON R.RFCID = RF.ID              
     WHERE  RF.FormId = '''+@id+ ''' AND RF.FormType = '''+@formtype+ '''';              
 IF @isTotal = 0               
 BEGIN              
 SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';              
 END               
               
 EXECUTE(@sql);              
               
END

GO

/****** Object:  StoredProcedure [dbo].[SP_CiplChangeHistoryGetById]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplChangeHistoryGetById] -- exec [dbo].[SP_CiplChangeHistoryGetById] '33433','CIPL',0,'CreateDate','asc','0','10'            
(            
 @id NVARCHAR(10),           
 @formtype NVARCHAR(100),           
 @IsTotal bit = 0,            
 @sort nvarchar(100) = 'CreateDate',            
 @order nvarchar(100) = 'DESC',            
 @offset nvarchar(100) = '0',            
 @limit nvarchar(100) = '10'            
)             
AS            
BEGIN            
 DECLARE @sql nvarchar(max);              
          
            
 SET @sql = 'SELECT ';            
 SET @sort = 'RF.'+@sort;            
            
 IF (@IsTotal <> 0)            
 BEGIN            
  SET @sql += 'count(*) total'            
 END             
 ELSE            
 BEGIN            
 SET @sql += 'R.FieldName,          
R.BeforeValue,          
R.AfterValue,      
RF.ID,      
RF.FormNo,        
RF.CreateBy,          
RF.CreateDate,          
RF.Reason'            
 END            
 SET @sql +=' FROM RequestForChange RF          
 INNER JOIN RFCItem R ON R.RFCID = RF.ID            
     WHERE  R.RFCID = '''+@id+ '''';            
 IF @isTotal = 0             
 BEGIN            
 SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';            
 END             
            
 --select @sql;            
 EXECUTE(@sql);            
 --print(@sql);            
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplDelete_20200612]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_CiplDelete_20200612] (
	@id BIGINT
	,@UpdateBy NVARCHAR(50)
	,@UpdateDate DATETIME
	,@Status NVARCHAR(50)
	,@IsDelete BIT
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
	END
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

/****** Object:  StoredProcedure [dbo].[SP_CiplDocumentDelete]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplDocumentDelete] (
	@id BIGINT
	,@UpdateBy NVARCHAR(50)
	,@UpdateDate DATETIME
	,@IsDelete BIT
	)
AS
BEGIN
	UPDATE dbo.CiplDocument
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE id = @id;	
END

GO

/****** Object:  StoredProcedure [dbo].[SP_CiplDocumentInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplDocumentInsert]
(
	@Id BIGINT,
	@IdCipl BIGINT,
	@DocumentDate datetime,
	@DocumentName NVARCHAR(MAX) = '',
	@Filename NVARCHAR(MAX) = '',
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@IsDelete BIT
)
AS
BEGIN
 
	IF @Id <= 0
	BEGIN
	INSERT INTO [dbo].[CiplDocument]
           ([IdCipl]
		   ,[DocumentDate]
		   ,[DocumentName]
		   ,[Filename]
           ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
           )
     VALUES
           (@IdCipl
			,@DocumentDate
			,@DocumentName
			,@Filename
			,@CreateBy
			,@CreateDate
			,@UpdateBy
			,@UpdateDate
			,@IsDelete
		   )

	END
	ELSE 
	BEGIN
	UPDATE dbo.CiplDocument
	SET [DocumentDate] = @DocumentDate
		   ,[DocumentName] = @DocumentName
	WHERE Id = @Id;
	END

END
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplDocumentUpdateFile]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplDocumentUpdateFile]
(
	@Id BIGINT,
	@Filename NVARCHAR(MAX) = '',
	@UpdateBy NVARCHAR(MAX) = ''
)
AS
BEGIN
 
	UPDATE dbo.CiplDocument
	SET [Filename] = @Filename,
	[UpdateBy] = @Updateby,
	[UpdateDate] = GETDATE()
	WHERE Id = @Id;

END
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplForExportDO]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplForExportDO]
	@CiplID bigint
AS
BEGIN
    select 
		ISNULL(c.EdoNo, '-') as EdoNo
		, ISNULL(CONVERT(VARCHAR(9), ch.UpdateDate, 6), '-') as ApprovedDate
		, ISNULL(c.CiplNo, '-') as CiplNo
		--, 'PT. Trakindo Utama' + IIF(c.Area IS NULL OR LEN(RTRIM(LTRIM(c.Area))) <= 0, '', ' - ' + c.Area) as Area
		, 'PT. Trakindo Utama' + IIF(pl.PlantName IS NOT NULL, ' ' + pl.PlantName, '') as Area
		, e.Employee_Name as RequestorName
		, e.Email as RequestorEmail
		, IIF(c.ConsigneeName IS NULL OR LEN(c.ConsigneeName) <= 0, '-', c.ConsigneeName) as ConsigneeName
		, IIF(c.ConsigneeAddress IS NULL OR LEN(c.ConsigneeAddress) <= 0, '-', c.ConsigneeAddress) as ConsigneeAddress
		, IIF(c.ConsigneePic IS NULL OR LEN(c.ConsigneePic) <= 0, '-', c.ConsigneePic) as ConsigneePic
		, IIF(c.ConsigneeEmail IS NULL OR LEN(c.ConsigneeEmail) <= 0, '-', c.ConsigneeEmail) as ConsigneeEmail
		, IIF(c.NotifyName IS NULL OR LEN(c.NotifyName) <= 0, '-', c.NotifyName) as NotifyName
		, IIF(c.NotifyAddress IS NULL OR LEN(c.NotifyAddress) <= 0, '-', c.NotifyAddress) as NotifyAddress
		, IIF(c.NotifyPic IS NULL OR LEN(c.NotifyPic) <= 0, '-', c.NotifyPic) as NotifyPic
		, IIF(c.NotifyEmail IS NULL OR LEN(c.NotifyEmail) <= 0, '-', c.NotifyEmail) as NotifyEmail
			--, ISNULL(sm.Name, '-') as ShippingMethod		
		, IIF(c.ShippingMethod IS NULL OR LEN(c.ShippingMethod) <= 0, '-', c.ShippingMethod) as ShippingMethod
			--, ISNULL(et.Name, '-') as ExportType
		, IIF(c.ExportType IS NULL OR LEN(c.ExportType) <= 0, '-', c.ExportType) as ExportType
		, IIF(c.IncoTerm IS NULL OR LEN(c.IncoTerm) <= 0, '-', c.IncoTerm) as TermOfDelivery
			--, ISNULL(fp.Name, '-') as FreightPayment
		, IIF(c.FreightPayment IS NULL OR LEN(c.FreightPayment) <= 0, '-', c.FreightPayment) as FreightPayment
		, IIF(c.LoadingPort IS NULL OR LEN(c.LoadingPort) <= 0, '-', c.LoadingPort) as LoadingPort
		, IIF(c.DestinationPort IS NULL OR LEN(c.DestinationPort) <= 0, '-', c.DestinationPort) as DestinationPort
		, ISNULL(ci.TotalQuantity, '-') as TotalQuantity
		, ISNULL(ci.TotalVolume, '0') as TotalVolume
		, ISNULL(ci.NetWeight, '0') as TotalNetWeight
		, ISNULL(ci.GrossWeight, '0') as TotalGrossWeight
		, ISNULL(ci.TotalCaseNumber, '0') as TotalCaseNumber
		, IIF(c.SpecialInstruction IS NULL OR LEN(c.SpecialInstruction) <= 0, '-', c.SpecialInstruction) as SpecialInstruction		
			--c.ExportType + ' - ' + c.Remarks as CargoDescription
		, c.Category + IIF(p.Value = 4, ' (NCV) ', ' ') + 'WITH' as CargoDescription
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
	from Cipl c
	left join (
		select 
			c.id
			, CAST(FORMAT(SUM(ISNULL(ci.Quantity, 0)), '#,0') as varchar(20)) as TotalQuantity
			, CAST(count(ci.Id) as varchar(5)) as TotalCaseNumber
			--, CAST(count(distinct ISNULL(CaseNumber, '-')) as varchar(5)) as TotalCaseNumber
			, CAST(FORMAT(SUM(CAST(ISNULL(ci.Width,0) * ISNULL(ci.Length, 0) * ISNULL(ci.Height,0) as decimal(18,2))), '#,0.00') as varchar(20)) as TotalVolume
			, CAST(FORMAT(SUM(ISNULL(ci.NetWeight, 0)) , '#,0.00') as varchar(20)) as NetWeight
			, CAST(FORMAT(SUM(CAST(ISNULL(ci.GrossWeight, 0)  as decimal(18,2))) , '#,0.00') as varchar(20))  as GrossWeight			
		from Cipl c
		left join CiplItem ci on c.id=ci.IdCipl
		group by c.id
	)ci on c.id = ci.id
	outer apply(
		select top 1 * from CiplHistory where IdCipl = c.id order by id desc
	) ch
	left join (select Value, Name from MasterParameter where [Group] like 'ShippingMethod') sm on c.ShippingMethod = sm.Value
	left join (select Value, Name from MasterParameter where [Group] like 'ExportType') et on c.ShippingMethod = et.Value
	left join (select Value, Name from MasterParameter where [Group] like 'FreightPayment') fp on c.ShippingMethod = fp.Value
	inner join fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join MasterParameter p on c.ExportType = p.Name
	left join MasterPlant pl on right(pl.PlantCode, 3) = right(c.Area, 3)
	left join fn_get_cipl_request_list_all() r on c.id = r.IdCipl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	where c.id = @CiplID
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplForExportInvoice_Detail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplForExportInvoice_Detail]
	@CiplID bigint
AS
BEGIN
    select ISNULL(CaseNumber, '-') as CaseNumber, 
	CAST(ROW_NUMBER() over (order by Id) as varchar(5)) as ItemNo, Name, cast(1 as varchar(5)) as Quantity, PartNumber = 'PartNumber', ISNULL(JCode, '-') as JCode, 
	CONCAT(Currency,' ',FORMAT(UnitPrice, '#,0.00')) as UnitPrice, CONCAT(Currency,' ',FORMAT(ExtendedValue, '#,0.00')) as ExtendedValue
	from CiplItem where IdCipl = @CiplID order by CaseNumber
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplForExportInvoice_Header]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplForExportInvoice_Header] 
	@CiplID bigint
AS
BEGIN
    select 
	ISNULL(c.CiplNo, '-') as CiplNo, ISNULL(CONVERT(VARCHAR(9), c.CreateDate, 6), '-') as CreateDate, ISNULL(c.Area, '-') as Area,e.Employee_Name as RequestorName, e.Email as RequestorEmail,
	ISNULL(c.ConsigneeName, '-') as ConsigneeName, ISNULL(c.ConsigneeAddress, '-') as ConsigneeAddress, ISNULL(c.ConsigneeTelephone, '-') as ConsigneeTelephone, ISNULL(c.ConsigneeFax, '-') as ConsigneeFax, ISNULL(c.ConsigneePic, '-') as ConsigneePic, ISNULL(c.ConsigneeEmail, '-') as ConsigneeEmail,
	ISNULL(c.NotifyName, '-') as NotifyName, ISNULL(c.NotifyAddress, '-') as NotifyAddress, ISNULL(c.NotifyTelephone, '-') as NotifyTelephone, ISNULL(c.NotifyFax, '-') as NotifyFax, ISNULL(c.NotifyPic, '-') as NotifyPic, ISNULL(c.NotifyEmail, '-') as NotifyEmail,
	ISNULL(ci.Currency, '-') as Currency, ISNULL(ci.TotalQuantity, '-') as TotalQuantity, ISNULL(ci.TotalCaseNumber, '-') as TotalCaseNumber, ISNULL(ci.TotalExtendedValue, '-') as TotalExtendedValue,
	case 
	when c.IncoTerm = 'EXW' 
		then c.IncoTerm + IIF(c.Area is not null, ' - ' + c.Area, '') 
	when c.IncoTerm = 'FCA' or c.IncoTerm = 'FAS' or c.IncoTerm = 'FOB' 
		then c.IncoTerm + IIF(c.LoadingPort is not null, ' - ' + c.LoadingPort, '')  
	when c.IncoTerm = 'CFR' or c.IncoTerm = 'CIF' or c.IncoTerm = 'CIP' or c.IncoTerm = 'CPT'or c.IncoTerm = 'DAT' 
		then c.IncoTerm + IIF(c.DestinationPort is not null, ' - ' + c.DestinationPort, '')  
	when c.IncoTerm = 'DAP' or c.IncoTerm = 'DDD' 
		then c.IncoTerm + IIF(c.ConsigneeName is not null, ' - ' + c.ConsigneeName, '') 
	else c.IncoTerm end as ShipmentTerm,
	ISNULL(c.ShippingMethod, '-') as ShippingMethod, ISNULL(c.LoadingPort, '-') as LoadingPort, ISNULL(c.DestinationPort, '-') as DestinationPort, 
	ISNULL(c.ShippingMarks, '-') as ShippingMarksDesc, ISNULL(c.Remarks, '-') as RemarksDesc
	from Cipl c
	left join (
		select c.id, MAX(ISNULL(ci.Currency, '-')) as Currency, CAST(count(ci.Id) as varchar(5)) as TotalQuantity, case
				when c.Category = 'CATERPILLAR SPAREPARTS' AND c.CategoriItem = 'SIB'
					then CAST(count(distinct ISNULL(ci.JCode, '-')) as varchar(5))
				when c.Category = 'CATERPILLAR SPAREPARTS' AND (c.CategoriItem = 'PRA' OR c.CategoriItem = 'Old Core')
					then CAST(count(distinct ISNULL(ci.CaseNumber, '-')) as varchar(5))
				else CAST(count(distinct ci.Sn) as varchar(5))
			end as TotalCaseNumber,
			CONCAT(MAX(ISNULL(ci.Currency, '-')),' ', FORMAT(sum(ISNULL(ci.ExtendedValue, 0)), '#,0.00')) as TotalExtendedValue
		from Cipl c
		left join CiplItem ci on c.id=ci.IdCipl
		group by c.id, c.Category, c.CategoriItem
	)ci on c.id = ci.id
	inner join employee e on c.CreateBy = e.AD_User
	where c.id = @CiplID
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplForExportInvoicePL_Detail_20200508]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [dbo].[SP_CiplForExportInvoicePL_Detail] 10012
ALTER PROCEDURE [dbo].[SP_CiplForExportInvoicePL_Detail_20200508] 
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
		, CAST(FORMAT(CAST(ISNULL(CI.Length, 0) * ISNULL(CI.Width, 0) * ISNULL(CI.Height, 0) as decimal(18,2)), '#,0.00') as varchar(20)) as Volume
		, CAST(ISNULL(FORMAT(CI.NetWeight, '#,0.00'), 0) as varchar(10)) as NetWeight
		, CAST(ISNULL(FORMAT(CI.GrossWeight, '#,0.00'), 0) as varchar(10)) as GrossWeight
		, CONCAT(CI.Currency, ' ', FORMAT(ISNULL(CI.UnitPrice, 0), '#,0.00')) as UnitPrice
		, CONCAT(CI.Currency, ' ', FORMAT(ISNULL(CI.ExtendedValue, 0), '#,0.00')) as ExtendedValue
		, ISNULL(CI.SIBNumber, '-') as SIBNumber
		, ISNULL(CI.WONumber, '-') as WONumber
		, ISNULL(C.VesselFlight, '-') as VesselFlight
		, ISNULL(CI.CoO, '-') as CoO
		, ISNULL(CC.EdoNumber, '-') as EDINo
	from CiplItem CI 
	left join CargoCipl CC ON CC.IdCipl = CI.IdCipl
	left join Cargo C ON C.Id = CC.IdCargo
	where CI.IdCipl = @CiplID and CI.IsDelete = 0 
	order by CI.CaseNumber ASC
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

/****** Object:  StoredProcedure [dbo].[SP_CiplForExportInvoicePL_Header_20201130]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplForExportInvoicePL_Header_20201130] 
	@CiplID bigint
AS
BEGIN
    select 
		ISNULL(c.CiplNo, '-') as CiplNo
		, ISNULL(CONVERT(VARCHAR(9), c.CreateDate, 6), '-') as CreateDate
		, ISNULL(a.BAreaName, '-') as Area
		, 'PT. Trakindo Utama' + IIF(a.ID is not null, ' - ' + a.BAreaName, '-') as FullArea
		, e.Employee_Name as RequestorName
		, e.Email as RequestorEmail
		, IIF(c.ConsigneeName IS NULL OR LEN(c.ConsigneeName) <= 0, '-', c.ConsigneeName) as ConsigneeName
		, IIF(c.ConsigneeAddress IS NULL OR LEN(c.ConsigneeAddress) <= 0, '-', c.ConsigneeAddress) as ConsigneeAddress
		, IIF(c.ConsigneeTelephone IS NULL OR LEN(c.ConsigneeTelephone) <= 0, '-', c.ConsigneeTelephone) as ConsigneeTelephone
		, IIF(c.ConsigneeFax IS NULL OR LEN(c.ConsigneeFax) <= 0, '-', c.ConsigneeFax) as ConsigneeFax
		, IIF(c.ConsigneePic IS NULL OR LEN(c.ConsigneePic) <= 0, '-', c.ConsigneePic) as ConsigneePic
		, IIF(c.ConsigneeEmail IS NULL OR LEN(c.ConsigneeEmail) <= 0, '-', c.ConsigneeEmail) as ConsigneeEmail
		, IIF(c.NotifyName IS NULL OR LEN(c.NotifyName) <= 0, '-', c.NotifyName) as NotifyName
		, IIF(c.NotifyAddress IS NULL OR LEN(c.NotifyAddress) <= 0, '-', c.NotifyAddress) as NotifyAddress
		, IIF(c.NotifyTelephone IS NULL OR LEN(c.NotifyTelephone) <= 0, '-', c.NotifyTelephone) as NotifyTelephone
		, IIF(c.NotifyFax IS NULL OR LEN(c.NotifyFax) <= 0, '-', c.NotifyFax) as NotifyFax
		, IIF(c.NotifyPic IS NULL OR LEN(c.NotifyPic) <= 0, '-', c.NotifyPic) as NotifyPic
		, IIF(c.NotifyEmail IS NULL OR LEN(c.NotifyEmail) <= 0, '-', c.NotifyEmail) as NotifyEmail
		, IIF(c.SoldToName IS NULL OR LEN(c.SoldToName) <= 0, '-', c.SoldToName) as SoldToName
		, IIF(c.SoldToAddress IS NULL OR LEN(c.SoldToAddress) <= 0, '-', c.SoldToAddress) as SoldToAddress
		, IIF(c.SoldToTelephone IS NULL OR LEN(c.SoldToTelephone) <= 0, '-', c.SoldToTelephone) as SoldToTelephone
		, IIF(c.SoldToFax IS NULL OR LEN(c.SoldToFax) <= 0, '-', c.SoldToFax) as SoldToFax
		, IIF(c.SoldToPic IS NULL OR LEN(c.SoldToPic) <= 0, '-', c.SoldToPic) as SoldToPic
		, IIF(c.SoldToEmail IS NULL OR LEN(c.SoldToEmail) <= 0, '-', c.SoldToEmail) as SoldToEmail
		, IIF(ci.Currency IS NULL OR LEN(ci.Currency) <= 0, '-', ci.Currency) as CurrencyDesc
		, IIF(c.IncoTerm IS NULL OR LEN(c.IncoTerm) <= 0, '-', c.IncoTerm) as ShipmentTerm
		, case 
			when c.IncoTerm = 'EXW' 
				then c.IncoTerm + IIF(a.ID is not null, ' - PT. Trakindo Utama ' + a.BAreaName, '') 
			when c.IncoTerm = 'FCA' or c.IncoTerm = 'FAS' or c.IncoTerm = 'FOB' 
				then c.IncoTerm + IIF(load.Id is not null, ' - ' + load.Name, '')  
			when c.IncoTerm = 'CFR' or c.IncoTerm = 'CIF' or c.IncoTerm = 'CIP' or c.IncoTerm = 'CPT'or c.IncoTerm = 'DAT' 
				then c.IncoTerm + IIF(dest.Id is not null, ' - ' + dest.Name, '')  
			when c.IncoTerm = 'DAP' or c.IncoTerm = 'DDP' 
				then c.IncoTerm + IIF(c.SoldToName is not null and LEN(c.SoldToName) > 0, ' - ' + c.SoldToName, IIF(c.ConsigneeName is not null and LEN(c.ConsigneeName) > 0, ' - ' + c.ConsigneeName, '') ) 
			else IIF(c.IncoTerm IS NULL OR LEN(c.IncoTerm) <= 0, '-', c.IncoTerm) 
		end as TotalValue
		, IIF(c.ShippingMethod IS NULL OR LEN(c.ShippingMethod) <= 0, '-', c.ShippingMethod) as ShippingMethod
		, '-' as CODesc
		, '-' as VesselCarier
		, '-' as SailingOn
		, IIF(load.Id IS NULL, '-', load.Country + ' - ' + load.Name) as LoadingPort
		, IIF(dest.Id IS NULL, '-', dest.Country + ' - ' + dest.Name) as DestinationPort
		--, IIF(c.DestinationPort IS NULL OR LEN(c.DestinationPort) <= 0, '-', c.DestinationPort) as DestinationPort
		, c.PaymentTerms
		, IIF(c.SoldToName IS NULL OR LEN(c.SoldToName) <= 0, IIF(c.ConsigneeName IS NULL OR LEN(c.ConsigneeName) <= 0, '-', c.ConsigneeName), c.SoldToName) as FinalDestination
		, ISNULL(ci.TotalQuantity, '-') as TotalQuantity
		, ISNULL(ci.TotalCaseNumber, '-') as TotalCaseNumber
		, ISNULL(ci.TotalVolume, '-') as TotalVolume
		, ISNULL(ci.TotalNetWeight, '-') as TotalNetWeight
		, ISNULL(ci.TotalGrossWeight, '-') as TotalGrossWeight
		, ISNULL(ci.TotalExtendedValue, '-') as TotalExtendedValue	
		, IIF(c.ShippingMarks IS NULL OR LEN(c.ShippingMarks) <= 0, '-', c.ShippingMarks) as ShippingMarksDesc
		, IIF(c.Remarks IS NULL OR LEN(c.Remarks) <= 0, '-', c.Remarks) as RemarksDesc
		, IIF(c.LcNoDate IS NULL OR LEN(c.LcNoDate) <= 0, '-', c.LcNoDate) as LcNoDate
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
	from Cipl c
	left join (
		select 
			c.id
			, case
				when c.Category = 'CATERPILLAR SPAREPARTS' AND c.CategoriItem = 'SIB'
					then CAST(count(distinct ISNULL(ci.JCode, '-')) as varchar(5))
				when c.Category = 'CATERPILLAR SPAREPARTS' AND (c.CategoriItem = 'PRA' OR c.CategoriItem = 'Old Core')
					then CAST(count(distinct ISNULL(ci.CaseNumber, '-')) as varchar(5))
				else CAST(count(distinct ci.Sn) as varchar(5))
			end as TotalCaseNumber
			, MAX(ISNULL(ci.Currency, '-')) as Currency
			, CAST(FORMAT(SUM(ISNULL(ci.Quantity, 0)), '#,0') as varchar(20)) as TotalQuantity
			--, CAST(count(ci.Id) as varchar(5)) as TotalCaseNumber
			--, CAST(count(distinct ISNULL(CaseNumber, '-')) as varchar(5)) as TotalCaseNumber
			, CAST(SUM(ISNULL(Volume, 0)) as varchar(20)) as TotalVolume
			, CAST(FORMAT(SUM(ISNULL(NetWeight, 0)), '#,0.00') as varchar(20)) as TotalNetWeight
			, CAST(FORMAT(SUM(ISNULL(GrossWeight, 0)), '#,0.00') as varchar(20)) as TotalGrossWeight
			, CONCAT(MAX(ISNULL(ci.Currency, '-')),' ', FORMAT(sum(ISNULL(ci.ExtendedValue, 0)), '#,0.00')) as TotalExtendedValue
		from Cipl c
		left join CiplItem ci on c.id=ci.IdCipl
		where ci.IsDelete = 0
		group by c.id, c.Category, c.CategoriItem
	)ci on c.id = ci.id
	inner join dbo.fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join MasterArea a on c.Branch = a.BAreaCode
	left join fn_get_cipl_request_list_all() r on c.id = r.IdCipl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	left join MasterAirSeaPort load on (SELECT SUBSTRING(c.LoadingPort,0,CHARINDEX('-',c.LoadingPort,0))) = load.Code
	left join MasterAirSeaPort dest on (SELECT SUBSTRING(c.DestinationPort,0,CHARINDEX('-',c.DestinationPort,0))) = dest.Code
	where c.id = @CiplID
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplForExportInvoicePL_Header]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplForExportInvoicePL_Header] 
	@CiplID bigint
AS
BEGIN
    select 
		ISNULL(c.CiplNo, '-') as CiplNo
		, ISNULL(CONVERT(VARCHAR(9), c.CreateDate, 6), '-') as CreateDate
		, ISNULL(a.BAreaName, '-') as Area
		, 'PT. Trakindo Utama' + IIF(a.ID is not null, ' - ' + a.BAreaName, '-') as FullArea
		, e.Employee_Name as RequestorName
		, e.Email as RequestorEmail
		, IIF(c.ConsigneeName IS NULL OR LEN(c.ConsigneeName) <= 0, '-', c.ConsigneeName) as ConsigneeName
		, IIF(c.ConsigneeAddress IS NULL OR LEN(c.ConsigneeAddress) <= 0, '-', c.ConsigneeAddress) as ConsigneeAddress
		, IIF(c.ConsigneeTelephone IS NULL OR LEN(c.ConsigneeTelephone) <= 0, '-', c.ConsigneeTelephone) as ConsigneeTelephone
		, IIF(c.ConsigneeFax IS NULL OR LEN(c.ConsigneeFax) <= 0, '-', c.ConsigneeFax) as ConsigneeFax
		, IIF(c.ConsigneePic IS NULL OR LEN(c.ConsigneePic) <= 0, '-', c.ConsigneePic) as ConsigneePic
		, IIF(c.ConsigneeEmail IS NULL OR LEN(c.ConsigneeEmail) <= 0, '-', c.ConsigneeEmail) as ConsigneeEmail
		, IIF(c.NotifyName IS NULL OR LEN(c.NotifyName) <= 0, '-', c.NotifyName) as NotifyName
		, IIF(c.NotifyAddress IS NULL OR LEN(c.NotifyAddress) <= 0, '-', c.NotifyAddress) as NotifyAddress
		, IIF(c.NotifyTelephone IS NULL OR LEN(c.NotifyTelephone) <= 0, '-', c.NotifyTelephone) as NotifyTelephone
		, IIF(c.NotifyFax IS NULL OR LEN(c.NotifyFax) <= 0, '-', c.NotifyFax) as NotifyFax
		, IIF(c.NotifyPic IS NULL OR LEN(c.NotifyPic) <= 0, '-', c.NotifyPic) as NotifyPic
		, IIF(c.NotifyEmail IS NULL OR LEN(c.NotifyEmail) <= 0, '-', c.NotifyEmail) as NotifyEmail
		, IIF(c.SoldToName IS NULL OR LEN(c.SoldToName) <= 0, '-', c.SoldToName) as SoldToName
		, IIF(c.SoldToAddress IS NULL OR LEN(c.SoldToAddress) <= 0, '-', c.SoldToAddress) as SoldToAddress
		, IIF(c.SoldToTelephone IS NULL OR LEN(c.SoldToTelephone) <= 0, '-', c.SoldToTelephone) as SoldToTelephone
		, IIF(c.SoldToFax IS NULL OR LEN(c.SoldToFax) <= 0, '-', c.SoldToFax) as SoldToFax
		, IIF(c.SoldToPic IS NULL OR LEN(c.SoldToPic) <= 0, '-', c.SoldToPic) as SoldToPic
		, IIF(c.SoldToEmail IS NULL OR LEN(c.SoldToEmail) <= 0, '-', c.SoldToEmail) as SoldToEmail
		, IIF(ci.Currency IS NULL OR LEN(ci.Currency) <= 0, '-', ci.Currency) as CurrencyDesc
		, IIF(c.IncoTerm IS NULL OR LEN(c.IncoTerm) <= 0, '-', c.IncoTerm) as ShipmentTerm
		, case 
			when c.IncoTerm = 'EXW' 
				then c.IncoTerm + IIF(a.ID is not null, ' - PT. Trakindo Utama ' + a.BAreaName, '') 
			when c.IncoTerm = 'FCA' or c.IncoTerm = 'FAS' or c.IncoTerm = 'FOB' 
				then c.IncoTerm + IIF(load.Id is not null, ' - ' + load.Name, '')  
			when c.IncoTerm = 'CFR' or c.IncoTerm = 'CIF' or c.IncoTerm = 'CIP' or c.IncoTerm = 'CPT'or c.IncoTerm = 'DAT' 
				then c.IncoTerm + IIF(dest.Id is not null, ' - ' + dest.Name, '')  
			when c.IncoTerm = 'DAP' or c.IncoTerm = 'DDP' 
				then c.IncoTerm + IIF(c.SoldToName is not null and LEN(c.SoldToName) > 0, ' - ' + c.SoldToName, IIF(c.ConsigneeName is not null and LEN(c.ConsigneeName) > 0, ' - ' + c.ConsigneeName, '') ) 
			else IIF(c.IncoTerm IS NULL OR LEN(c.IncoTerm) <= 0, '-', c.IncoTerm) 
		end as TotalValue
		, IIF(c.ShippingMethod IS NULL OR LEN(c.ShippingMethod) <= 0, '-', c.ShippingMethod) as ShippingMethod
		, '-' as CODesc
		, ISNULL(cg.VesselFlight, '-') as VesselCarier
		, ISNULL(CONVERT(VARCHAR(9), cg.SailingSchedule, 6), '-') as SailingOn
		, IIF(load.Id IS NULL, '-', load.Country + ' - ' + load.Name) as LoadingPort
		, IIF(dest.Id IS NULL, '-', dest.Country + ' - ' + dest.Name) as DestinationPort
		--, IIF(c.DestinationPort IS NULL OR LEN(c.DestinationPort) <= 0, '-', c.DestinationPort) as DestinationPort
		, c.PaymentTerms
		, IIF(c.SoldToName IS NULL OR LEN(c.SoldToName) <= 0, IIF(c.ConsigneeName IS NULL OR LEN(c.ConsigneeName) <= 0, '-', c.ConsigneeName), c.SoldToName) as FinalDestination
		, ISNULL(ci.TotalQuantity, '-') as TotalQuantity
		, ISNULL(ci.TotalCaseNumber, '-') as TotalCaseNumber
		, ISNULL(ci.TotalVolume, '-') as TotalVolume
		, ISNULL(ci.TotalNetWeight, '-') as TotalNetWeight
		, ISNULL(ci.TotalGrossWeight, '-') as TotalGrossWeight
		, ISNULL(ci.TotalExtendedValue, '-') as TotalExtendedValue	
		, IIF(c.ShippingMarks IS NULL OR LEN(c.ShippingMarks) <= 0, '-', c.ShippingMarks) as ShippingMarksDesc
		, IIF(c.Remarks IS NULL OR LEN(c.Remarks) <= 0, '-', c.Remarks) as RemarksDesc
		, IIF(c.LcNoDate IS NULL OR LEN(c.LcNoDate) <= 0, '-', c.LcNoDate) as LcNoDate
		, IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
		, ISNULL(c.ShipDelivery, '-') as ShipDelivery	
		, ISNULL(c.EdoNo, '-') as EdiNo
	from Cipl c
	left join (
		select 
			c.id
			, case
				when c.Category = 'CATERPILLAR SPAREPARTS' AND c.CategoriItem = 'SIB'
					then CAST(count(distinct ISNULL(ci.JCode, '-')) as varchar(5))
				when c.Category = 'CATERPILLAR SPAREPARTS' AND (c.CategoriItem = 'PRA' OR c.CategoriItem = 'Old Core')
					then CAST(count(distinct ISNULL(ci.CaseNumber, '-')) as varchar(5))
				--
				when c.Category = 'CATERPILLAR USED EQUIPMENT'
					then CAST(count(distinct ISNULL(ci.Id, '-')) as varchar(5))
				--
				else CAST(count(distinct(IIF(sn != '', sn, null))) as varchar(5)) --CAST(count(distinct ci.Sn) as varchar(5))
			end as TotalCaseNumber
			, MAX(ISNULL(ci.Currency, '-')) as Currency
			, CAST(FORMAT(SUM(ISNULL(ci.Quantity, 0)), '#,0') as varchar(20)) as TotalQuantity
			--, CAST(count(ci.Id) as varchar(5)) as TotalCaseNumber
			--, CAST(count(distinct ISNULL(CaseNumber, '-')) as varchar(5)) as TotalCaseNumber
			, CAST(SUM(ISNULL(Volume, 0)) as varchar(20)) as TotalVolume
			, CAST(FORMAT(SUM(ISNULL(NetWeight, 0)), '#,0.00') as varchar(20)) as TotalNetWeight
			, CAST(FORMAT(SUM(ISNULL(GrossWeight, 0)), '#,0.00') as varchar(20)) as TotalGrossWeight
			, CONCAT(MAX(ISNULL(ci.Currency, '-')),' ', FORMAT(sum(ISNULL(ci.ExtendedValue, 0)), '#,0.00')) as TotalExtendedValue
		from Cipl c
		left join CiplItem ci on c.id=ci.IdCipl
			AND ci.IsDelete = 0 
		--where ci.IsDelete = 0 
		group by c.id, c.Category, c.CategoriItem
	)ci on c.id = ci.id
	--AND ci.IsDelete = 0 
	inner join dbo.fn_get_employee_internal_ckb() e on c.CreateBy = e.AD_User
	left join cargocipl cgc on cgc.idcipl = c.id 
		AND cgc.IsDelete = 0
	left join cargo cg on cg.id = cgc.idcargo
		AND cg.IsDelete = 0
	left join MasterArea a on c.Branch = a.BAreaCode
	left join fn_get_cipl_request_list_all() r on c.id = r.IdCipl
	left join fn_get_employee_internal_ckb() s on r.UpdateBy= s.AD_User
	left join MasterAirSeaPort load on (SELECT SUBSTRING(c.LoadingPort,0,CHARINDEX('-',c.LoadingPort,0))) = load.Code
	left join MasterAirSeaPort dest on (SELECT SUBSTRING(c.DestinationPort,0,CHARINDEX('-',c.DestinationPort,0))) = dest.Code
	where c.id = @CiplID  
END

/****** Object:  StoredProcedure [dbo].[SP_CiplGetById_For_RFC]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplGetById_For_RFC]  
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
        , C.Area AS Area  
        , C.Branch AS Branch  
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
		,C.PickUpArea
		,C.PickUpPic
  , (SELECT DISTINCT Fn.BAreaCode+' - '+Fn.BAreaName FROM [dbo].fn_get_cipl_businessarea_list('') Fn  
 INNER JOIN Cipl C ON IIF(C.PickUpArea = '', NULL, right(C.PickUpArea,4)) = right(Fn.BAreaCode ,4) WHERE C.id=@id) AS PickUpArea  
  --, (SELECT DISTINCT Fn.Business_Area+' - '+Fn.BAreaName FROM [dbo].[fn_get_employee_internal_ckb]() Fn INNER JOIN Cipl C ON IIF(C.PickUpArea = '', NULL, C.PickUpArea) = Fn.Business_Area WHERE C.id=@id) AS PickUpArea  
  --, (SELECT Fn.BAreaCode+' - '+Fn.BAreaName FROM [dbo].[fn_get_plant_barea_user]() Fn INNER JOIN Cipl C ON RIGHT(C.PickUpPic,3) = RIGHT(Fn.UserID, 3) WHERE C.id=@id) AS PickUpArea  
  , (SELECT Fn.AD_User+'-'+Fn.Employee_Name+ '-'+Fn.BAreaName FROM [dbo].[fn_get_employee_internal_ckb]() Fn INNER JOIN Cipl C ON C.PickUpPic = Fn.AD_User WHERE C.id=@id) AS PickUpPic  
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

/****** Object:  StoredProcedure [dbo].[SP_CiplGetList_080922]    Script Date: 10/03/2023 12:07:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplGetList_080922]
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
		SET @WhereSql = ' AND (C.CiplNo LIKE ''%'+@ConsigneeName+'%'' OR C.ConsigneeName LIKE ''%'+@ConsigneeName+'%'')';
	END
	--IF @usertype ='ext-imex'
	--BEGIN
	--	SET @WhereSql = @WhereSql + ' AND ((fnReqCl.IdNextStep is NULL  AND RC.[Status]=''Approve'')  OR (fnReqCl.IdNextStep = 10021 AND RC.[Status]=''Approve'')) ';
	--END
	Print @WhereSql
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
		FROM dbo.Cipl C		
		INNER JOIN dbo.RequestCipl RC ON RC.IdCipl = C.id
		INNER JOIN dbo.CiplForwader CF ON CF.IdCipl = C.id
		INNER JOIN dbo.FlowStatus FS on FS.IdStep = RC.IdStep AND FS.[Status] = RC.Status
		INNER JOIN PartsInformationSystem.dbo.UserAccess PIS on PIS.UserID = c.CreateBy
		INNER JOIN dbo.[fn_get_cipl_request_list_all]() as fnReq on fnReq.Id = rc.Id 
		LEFT JOIN GoodsReceiveItem as GR on GR.IdCipl = C.id AND GR.isdelete = 0
		LEFT JOIN CargoCipl as CC on CC.IdCipl = C.id AND CC.Isdelete = 0
		LEFT JOIN dbo.[fn_get_gr_request_list_all]() as fnReqGr on fnReqGr.IdGr = GR.IdGr
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

/****** Object:  StoredProcedure [dbo].[SP_CiplGetList_20210428]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC [dbo].[SP_CiplGetList] '', 'XUPJ21WDN'
ALTER PROCEDURE [dbo].[SP_CiplGetList_20210428]
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
	IF (@role !='EMCS IMEX' and @CreateBy !='ict.bpm' and @usertype !='ext-imex' )
	BEGIN
		SET @WhereSql = ' AND c.CreateBy='''+@CreateBy+''' ';
	END

	IF @ConsigneeName <> ''
	BEGIN
		SET @WhereSql = ' AND C.CiplNo LIKE ''%'+@ConsigneeName+'%'' OR C.ConsigneeName LIKE ''%'+@ConsigneeName+'%''';
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
					WHEN fnreq.NextStatusViewByUser =''Pickup Goods''
					 THEN
						  CASE WHEN 
						  (fnReqGr.Status=''DRAFT'') OR (fnReq.Status=''APPROVE'' AND fnReqGr.Status is null AND RC.Status =''APPROVE'') 
								THEN ''Waiting for Pickup Goods''
							WHEN (fnReqGr.IdFlow = 14 AND (fnReqGr.Status =''Submit'' OR fnReqGr.Status =''APPROVE'' ) AND (fnReqCl.Status is Null OR fnReqCl.Status=''Submit''))
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
		FROM dbo.Cipl C		
		INNER JOIN dbo.RequestCipl RC ON RC.IdCipl = C.id
		INNER JOIN dbo.CiplForwader CF ON CF.IdCipl = C.id
		INNER JOIN dbo.FlowStatus FS on FS.IdStep = RC.IdStep AND FS.[Status] = RC.Status
		INNER JOIN PartsInformationSystem.dbo.UserAccess PIS on PIS.UserID = c.CreateBy
		INNER JOIN dbo.[fn_get_cipl_request_list_all]() as fnReq on fnReq.Id = rc.Id 
		LEFT JOIN GoodsReceiveItem as GR on GR.IdCipl = C.id AND GR.isdelete = 0
		LEFT JOIN CargoCipl as CC on CC.IdCipl = C.id AND CC.Isdelete = 0
		LEFT JOIN dbo.[fn_get_gr_request_list_all]() as fnReqGr on fnReqGr.IdGr = GR.IdGr
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

/****** Object:  StoredProcedure [dbo].[SP_CiplGetList_WithPaging]    Script Date: 10/03/2023 12:07:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplGetList_WithPaging]
(    
	@ConsigneeName NVARCHAR(200),
	@CreateBy NVARCHAR(200),
	@Offset INT = 0,
	@Limit INT = 5
)
AS
BEGIN
	DECLARE @Sql nvarchar(max);
	DECLARE @Sql2 nvarchar(max);
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
		SET @WhereSql = ' AND (C.CiplNo LIKE ''%'+@ConsigneeName+'%'' OR C.ConsigneeName LIKE ''%'+@ConsigneeName+'%'')';
	END
	--IF @usertype ='ext-imex'
	--BEGIN
	--	SET @WhereSql = @WhereSql + ' AND ((fnReqCl.IdNextStep is NULL  AND RC.[Status]=''Approve'')  OR (fnReqCl.IdNextStep = 10021 AND RC.[Status]=''Approve'')) ';
	--END
	set @Sql = ' 
	with cte as
		(
		SELECT * FROM
			(
			SELECT A.id, A.EdoNo, A.CiplNo, A.Category, A.ConsigneeName, A.ShippingMethod, A.Forwader, A.CreateDate, A.GrossWeight, A.[Status]
			,  CASE					
							WHEN fnreq.NextStatusViewByUser =''Pickup Goods''
							 THEN
								  CASE WHEN 
								  (fnReqGr.Status=''DRAFT'') OR (fnReq.Status=''APPROVE'' AND (fnReqGr.Status is null OR fnReqGr.Status = ''Waiting Approval'') AND A.Status =''APPROVE'') 
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
			FROM
			(
				SELECT DISTINCT C.id,C.EdoNo
						, C.CiplNo
						, C.Category
						, C.ConsigneeName
						, C.ShippingMethod
						, CF.Forwader
						, C.CreateDate
						, ISNULL((Select SUM(CI.GrossWeight) FROM dbo.CiplItem CI WHERE CI.idcipl = C.id),0) GrossWeight
						, RC.[Status]
						, RC.Id as RCId
				  
							FROM dbo.Cipl C		
							INNER JOIN dbo.RequestCipl RC ON RC.IdCipl = C.id
							INNER JOIN dbo.CiplForwader CF ON CF.IdCipl = C.id
							INNER JOIN dbo.FlowStatus FS on FS.IdStep = RC.IdStep AND FS.[Status] = RC.Status
							INNER JOIN PartsInformationSystem.dbo.UserAccess PIS on PIS.UserID = c.CreateBy
							INNER JOIN dbo.[fn_get_cipl_request_list_all]() as fnReq on fnReq.Id = rc.Id 
					
					
							WHERE 1=1 '+@WhereSql+'
							AND C.IsDelete = 0	
							ORDER BY C.id DESC
							OFFSET ' + CAST(@Offset as nvarchar(4)) +' ROWS FETCH NEXT ' + CAST(@Limit as nvarchar(4)) + ' ROWS ONLY
				) A
				LEFT JOIN GoodsReceiveItem as GR on GR.IdCipl = A.id AND GR.isdelete = 0
				LEFT JOIN CargoCipl as CC on CC.IdCipl = A.id AND CC.Isdelete = 0
				LEFT JOIN dbo.[fn_get_cipl_request_list_all]() as fnReq on fnReq.Id = A.RCId 
				LEFT JOIN (
							select t0.IdGr, t0.Status, t0.IdStep, t0.IdFlow from dbo.RequestGr t0 ) fnReqGr ON fnReqGr.IdGr = GR.IdGr
				LEFT JOIN (
							select t0.IdCl, t0.Status, t0.IdStep, t0.IdFlow from dbo.RequestCl t0 ) fnReqCl ON fnReqCl.IdCl = CC.IdCargo
				left join employee emp on emp.AD_User = fnReq.NextAssignTo
				--ORDER BY ID desc
				) A
		
		)
	
	SELECT A.*,cte.StatusViewByUser FROM
	(
		SELECT DISTINCT C.id,C.EdoNo
				, C.CiplNo
				, C.Category
				, C.ConsigneeName
				, C.ShippingMethod
				, CF.Forwader
				, C.CreateDate
				, ISNULL((Select SUM(CI.GrossWeight) FROM dbo.CiplItem CI WHERE CI.idcipl = C.id),0) GrossWeight
				, RC.[Status]
				--, RC.Id as RCId
				
				  
					FROM dbo.Cipl C		
					INNER JOIN dbo.RequestCipl RC ON RC.IdCipl = C.id
					INNER JOIN dbo.CiplForwader CF ON CF.IdCipl = C.id
					INNER JOIN dbo.FlowStatus FS on FS.IdStep = RC.IdStep AND FS.[Status] = RC.Status
					INNER JOIN PartsInformationSystem.dbo.UserAccess PIS on PIS.UserID = c.CreateBy
					INNER JOIN dbo.[fn_get_cipl_request_list_all]() as fnReq on fnReq.Id = rc.Id 
					
					
					WHERE 1=1 '+@WhereSql+'
					AND C.IsDelete = 0	
				
					
			) A
			LEFT JOIN cte ON a.ID = cte.id
			order by A.ID desc
		';

	
		
		--drop table #temp_cipl2
		--print (@WhereSql);
		print (@sql);
	exec(@Sql);	
	END
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

/****** Object:  StoredProcedure [dbo].[SP_CiplHistoryGetById]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplHistoryGetById] -- exec [dbo].[SP_CiplHistoryGetById] 7
(
	@id NVARCHAR(10),
	@IsTotal bit = 0,
	@sort nvarchar(100) = 'CreateDate',
	@order nvarchar(100) = 'DESC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)	
AS
BEGIN
	DECLARE @sql nvarchar(max);  
	DECLARE @type nvarchar(max);

	select @type = [type] from 
	(select CASE WHEN Category = 'CATERPILLAR SPAREPARTS' then 'SP' 
	else case when Category = 'CATERPILLAR NEW EQUIPMENT' then 'PP' 
	else case when Category = 'CATERPILLAR USED EQUIPMENT' then 'UE'
	else case when Category = 'MISCELLANEOUS' then 'MC' else ''  end end end
	end [type]
	from cipl 
	where id =@id) t0;

	SET @sql = 'SELECT DISTINCT';
	SET @sort = 't0.'+@sort;

	IF (@IsTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total'
	END 
	ELSE
	BEGIN
	SET @sql += ' t0.IdCipl
				, t0.Flow
				, t0.Step
				, t0.Status
				, t3.ViewByUser
				, t0.Notes
				, t4.Employee_Name CreateBy
				, t0.CreateDate'
	END
	SET @sql +=' FROM CiplHistory t0
					join Flow t2 on t2.Name = t0.Flow
					join FlowStep t1 on t1.Step = t0.Step AND t1.IdFlow = t2.Id
					join FlowStatus t3 on t3.[Status] = t0.[Status] AND t3.IdStep = t1.Id
					join employee t4 on t4.AD_User = t0.CreateBy
					WHERE t0.IdCipl = '+@id+ ' and t2.type = '''+@type+ '''';
	IF @isTotal = 0 
	BEGIN
	SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	END 

	--select @sql;
	EXECUTE(@sql);
	--print(@sql);
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

/****** Object:  StoredProcedure [dbo].[sp_CiplItemChange]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_CiplItemChange]  
(  
@Id nvarchar(50),  
@IdCipl nvarchar(50),  
@Status nvarchar(50),  
@CreateDate nvarchar(50)  
)  
as   
begin  
if @Status = 'Created'  
begin  
 INSERT INTO [dbo].[CiplItem]([IdCipl],[IdReference],[ReferenceNo],[IdCustomer],[Name],[Uom],[PartNumber],[Sn],[JCode],[Ccr],[CaseNumber],[Type],[IdNo],[YearMade],[Quantity]  
           ,[UnitPrice],[ExtendedValue],[Length],[Width],[Height],[Volume],[GrossWeight],[NetWeight],[Currency],[CoO],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete]  
     ,[IdParent],[SIBNumber],[WONumber],[Claim],[ASNNumber])  
   select [IdCipl],[IdReference],[ReferenceNo],[IdCustomer],[Name],[Uom],[PartNumber],[Sn],[JCode],[Ccr],[CaseNumber],[Type],[IdNo],[YearMade],[Quantity]  
           ,[UnitPrice],[ExtendedValue],[Length],[Width],[Height],[Volume],[GrossWeight],[NetWeight],[Currency],[CoO],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete]  
     ,[IdParent],[SIBNumber],[WONumber],[Claim],[ASNNumber] from CiplItem_Change where Id = @id and CreateDate = @CreateDate    
     delete From CiplItem_Change where Id = @id and CreateDate = @CreateDate  and IdCipl = @IdCipl  
  
end  
else if @Status = 'Updated'  
begin  

declare @IdReference nvarchar(max)
declare @ReferenceNo   nvarchar(max)
declare @IdCustomer    nvarchar(max)
declare @Name          nvarchar(max)
declare @Uom			  nvarchar(max)
declare @PartNumber	  nvarchar(max)
declare @Sn			  nvarchar(max)
declare @JCode		  nvarchar(max)
declare @Ccr			  nvarchar(max)
declare @CaseNumber	  nvarchar(max)
declare @Type		  nvarchar(max)
declare @IdNo		  nvarchar(max)
declare @YearMade	  nvarchar(max)
declare @Quantity	  int
declare @UnitPrice	  decimal(20,2)
declare @ExtendedValue decimal(20,2)
declare @Length		  decimal(20,2)
declare @Width		  decimal(20,2)
declare @Height		  decimal(20,2)
declare @Volume		  decimal(18,6)
declare @GrossWeight	  decimal(18,3)
declare @NetWeight	  decimal(18,3)
declare @Currency	  nvarchar(3)
declare @CoO		 	  nvarchar(max)
declare @CreateBy 	  nvarchar(max)
declare @UpdateBy 	  nvarchar(max)
declare @UpdateDate	  datetime
declare @IsDelete	  bit
declare @IdParent	  bigint
declare @SIBNumber	  nvarchar(max)
declare @WONumber	  nvarchar(max)
declare @Claim 		  nvarchar(max)
declare @ASNNumber	  nvarchar(max)
declare @IdCiplItem INT
select 
 @IdCiplItem = IdCiplItem,
 @IdReference = IdReference,
 @ReferenceNo  	= ReferenceNo, 
 @IdCustomer   	= IdCustomer , 
 @Name         	= Name       , 
 @Uom			= Uom		,
 @PartNumber	= PartNumber,
 @Sn			= Sn		,
 @JCode		 	= JCode		 ,
 @Ccr			= Ccr		,
 @CaseNumber	= CaseNumber,
 @Type		 	= Type		 ,
 @IdNo		 	= IdNo		 ,
 @YearMade	 	= YearMade	 ,
 @Quantity	 	= Quantity	 ,
 @UnitPrice	 	= UnitPrice	 ,
 @ExtendedValue	= ExtendedValue,
 @Length		= Length,
 @Width			= Width	,
 @Height		= Height,		
 @Volume		= Volume,		
 @GrossWeight	= GrossWeight,
 @NetWeight	 	= NetWeight	, 
 @Currency	 	= Currency,	 
 @CoO		 	= CoO,		 
 @CreateBy 		= CreateBy, 
 @CreateDate	= CreateDate,	
 @UpdateBy 		= UpdateBy, 
 @UpdateDate	= UpdateDate,	
 @IsDelete	 	= IsDelete,	 
 @IdParent	 	= IdParent,	 
 @SIBNumber	 	= SIBNumber,	 
 @WONumber	 	= WONumber,	 
 @Claim 		= Claim, 
 @ASNNumber	 	= ASNNumber 
 from CiplItem_Change where Id = @Id and IdCipl = @IdCipl

 Update CiplItem
set [IdCipl]	= @IdCipl,
[IdReference]	= @IdReference   ,
[ReferenceNo]	= @ReferenceNo   ,
[IdCustomer]	= @IdCustomer    ,
[Name]			= @Name         ,
[Uom]			= @Uom			  ,
[PartNumber]	= @PartNumber ,
[Sn]			= @Sn  ,
[JCode]			= @JCode  ,
[Ccr]			= @Ccr	 ,
[CaseNumber]	= @CaseNumber , 
[Type]			= @Type  ,
[IdNo]			= @IdNo  ,
[YearMade]		= @YearMade ,
[Quantity]		= @Quantity,
[UnitPrice]		= @UnitPrice ,
[ExtendedValue]	= @ExtendedValue,
[Length]		= @Length ,
[Width]			= @Width,	
[Height]		= @Height ,
[Volume]		= @Volume ,
[GrossWeight]	= @GrossWeight ,
[NetWeight]		= @NetWeight ,
[Currency]		= @Currency ,
[CoO]			= @CoO ,
[CreateBy]		= @CreateBy ,
[CreateDate]	= @CreateDate ,
[UpdateBy]		= @UpdateBy,
[UpdateDate]	= @UpdateDate ,
[IsDelete]		= @IsDelete ,
[IdParent]		= @IdParent ,
[SIBNumber]		= @SIBNumber ,
[WONumber]		= @WONumber,
[Claim]			= @Claim ,
[ASNNumber]		= @ASNNumber	  
where Id = @IdCiplItem and IdCipl = @IdCipl
  
delete From CiplItem_Change where Id = @id   and IdCipl = @IdCipl  
end  
else  
begin  
   
update CiplItem  
set [IsDelete] = 1  
where Id = (select IdCiplItem from CiplItem_Change where Id = @Id) and IdCipl = @IdCipl  
delete From CiplItem_Change where Id = @id and IdCipl = @IdCipl  
end  
end
GO

/****** Object:  StoredProcedure [dbo].[sp_CiplItemChangeList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_CiplItemChangeList]
(
@Id nvarchar(50)
)
as 
begin
select * from CiplItem_Change
where IdCipl = @Id
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

/****** Object:  StoredProcedure [dbo].[sp_CiplItemInArmada]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_CiplItemInArmada]    
 (        
 @IdCipl nvarchar(100),        
 @IdGr nvarchar(100),      
 @IdShippingFleet nvarchar(100)      
        
 )        
 As     
 BEGIN      
      
  select  t0.Id        
    , t0.IdCipl        
    , t0.IdReference        
    , (SELECT CASE        
        WHEN t0.ReferenceNo = '-' THEN t0.CaseNumber         
        ELSE t0.ReferenceNo        
        END) AS ReferenceNo        
    , t0.IdCustomer        
    , t0.Name        
    , t0.Uom         
    , t0.PartNumber        
    , t0.Sn        
    , t0.JCode        
    , t0.Ccr        
    , t0.CaseNumber        
    , t0.Type        
    , t0.IdNo        
    , t0.YearMade        
    , t0.Quantity        
    , t0.UnitPrice        
    , t0.ExtendedValue        
    , t0.Length        
    , t0.Width        
    , t0.Height        
    , t0.Volume        
    , t0.GrossWeight        
    , t0.NetWeight        
    , t0.Currency        
 , t0.CoO        
 , t0.IdParent        
 , t0.WONumber        
 , t0.SIBNumber        
    , t0.CreateBy        
    , t0.CreateDate        
    , t0.UpdateBy        
    , t0.UpdateDate        
    , t0.IsDelete        
 , t0.Claim        
 , t0.ASNNumber      
 , t3.IdShippingFleet      
   from CiplItem t0        
  join Cipl t1 on t0.IdCipl = t1.id      
  join ShippingFleetItem t3 on t3.IdCiplItem = t0.Id      
  where t0.IsDelete = 0 And t3.IdShippingFleet = @IdShippingFleet and t0.IdCipl In    
  (SELECT part FROM [SDF_SplitString](@IdCipl,','))  And t0.Id In      
  (select IdCiplItem from ShippingFleetItem t2 where t2.IdCipl In     
  (SELECT part FROM [SDF_SplitString](@IdCipl,',')) And t2.IdShippingFleet = @IdShippingFleet)     
  end 
  
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplItemInsert_RFC]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
ALTER PROCEDURE [dbo].[SP_CiplItemInsert_RFC]  
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
 @ASNNumber NVARCHAR(50) = '',  
 @Status Nvarchar(max)  
)  
AS  
BEGIN  
    DECLARE @LASTID bigint  
 DECLARE @Country NVARCHAR(100);  
 declare @OID Nvarchar(max);  
 set @OID = (select top 1 IdCiplItem from CiplItem_Change where IdCiplItem = @IdItem AND IdCipl = @IdCipl)  
 -- SELECT TOP 1 @Country = MC.CountryCode from MasterCountry MC WHERE MC.CountryCode = IIF(ISNULL(@CoO, '') = '', MC.CountryCode, @CoO ) OR MC.Description = IIF(ISNULL(@CoO, '') = '', MC.CountryCode, @CoO )  
  
 SELECT TOP 1 @Country = MC.CountryCode from MasterCountry MC WHERE MC.CountryCode = ISNULL(@CoO, '') OR MC.Description = ISNULL(@CoO, '')  
   
IF CHARINDEX(':AA',@PartNumber) > 0  
 BEGIN  
 SET @PartNumber = LEFT(@PartNumber+':AA', CHARINDEX(':AA',@PartNumber+':AA')-1)  
 END  
   
 IF (@OID Is Null OR @OID = 0)  
 BEGIN  
 INSERT INTO [dbo].[CiplItem_Change]  
           ([IdCiplItem]  
     ,[IdCipl]  
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
     ,[Status]  
           )  
     VALUES  
           (@IdItem  
     ,@IdCipl  
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
     ,@ASNNumber  
     ,@Status)  
  
 END  
 ELSE   
 BEGIN  
 UPDATE dbo.CiplItem_Change  
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
     ,[Status] = @Status  
     ,[UnitPrice] = @UnitPrice
 WHERE IdCiplItem = @IdItem;  
 END  
  
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

/****** Object:  StoredProcedure [dbo].[SP_CiplProblemHistoryGetById]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_CiplProblemHistoryGetById] --[dbo].[SP_CiplProblemHistoryGetById] 1
(
	@id NVARCHAR(10),
	@IsTotal bit = 0,
	@sort nvarchar(100) = 'Id',
	@order nvarchar(100) = 'ASC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)	
AS
BEGIN
	DECLARE @sql nvarchar(max);  
	SET @sql = 'SELECT ';
	SET @sort = 't0.'+@sort;

	IF (@IsTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total'
	END 
	ELSE
	BEGIN
		SET @sql += 't1.id
				   , t0.ReqType
				   , t0.Category
				   , t0.[Case] as CiplCase
				   , t0.Causes
				   , t0.Impact
				   , t0.CaseDate
				   , t2.Employee_Name as PIC'
	END
	SET @sql +=' FROM ProblemHistory t0 
	join Cipl t1 on t0.IDRequest = t1.id
	join employee t2 on t2.AD_User = t0.CreateBy
	WHERE  t0.ReqType= ''Cipl'' and t1.id = '+@id;
	--select @sql;
	EXECUTE(@sql);
	--print(@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[SP_CiplUpdate_ByApprover]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
ALTER PROCEDURE [dbo].[SP_CiplUpdate_ByApprover]  
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
 @ExportShipmentType NVARCHAR(Max)  
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
           --,UpdateBy = @UpdateBy  
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
  --,UpdateBy = @UpdateBy  
  ,UpdateDate = @UpdateDate  
  ,IsDelete = @IsDelete  
  ,[Type]=@Type  
  ,ExportShipmentType=@ExportShipmentType   
 WHERE IdCipl = @id;  
  

  
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

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_ExchangeRate_Today]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_ExchangeRate_Today] '2022-01-01', '2015-08-08'

ALTER PROCEDURE [dbo].[SP_Dashboard_ExchangeRate_Today] (
	@date1 NVARCHAR(100)
	,@date2 NVARCHAR(100)
	
	)
AS
BEGIN	


SELECT  [ID]
      ,[Curr]
      ,[StartDate]
      ,[EndDate]
      ,[Rate]
      ,[CreateBy]
      ,[CreateDate]
      ,[UpdateBy]
      ,[UpdateDate]
  FROM [EMCS].[dbo].[MasterKurs] MK
  WHERE MK.StartDate BETWEEN CONVERT(DATETIME, @date1) AND CONVERT(DATETIME, @date2)
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_DashBoard_ExchangeRate]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[Sp_DashBoard_ExchangeRate] -- exec Sp_DashBoard_ExchangeRate '2020-03-17','2020-03-23'  
(  
@date1 Date,  
@date2 Date  
)  
as  
begin  
select * from masterkurs   
where StartDate <= @date1 AND EndDate >= @date2
order by StartDate Desc  
end


GO

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Export_Today]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_Export_Today] '2020-01-01', '2020-12-12', '1A07'
--EXEC [dbo].[SP_Dashboard_Export_Today] '2020-01-01', '2020-12-12', 'XUPJ21PTR'
--EXEC [dbo].[SP_Dashboard_Export_Today] '2020-01-01', '2020-12-12', 'XUPJ21WDN'
--EXEC [dbo].[SP_Dashboard_Export_Today] '2020-01-01', '2020-12-12', 'ict.bpm'
ALTER PROCEDURE [dbo].[SP_Dashboard_Export_Today] (
	@date1 NVARCHAR(100)
	,@date2 NVARCHAR(100)
	,@user NVARCHAR(10)
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
		SET @and = 'AND CI.PickUpArea IS NOT NULL AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
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

	--IF (@area = '' OR @area IS NULL)
	--BEGIN
	--	IF (@user = '' OR @user IS NULL)
	--	BEGIN
	--		SET @and = 'AND CI.PickUpArea IS NOT NULL AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
	--	END
	--	ELSE
	--	BEGIN
	--		SET @and = 'AND RIGHT(CI.PickUpArea, 3) = RIGHT(''' + @user + ''',3) AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
	--	END 
	--END
	--ELSE
	--BEGIN
	--	SET @and = 'AND RIGHT(CI.PickUpArea, 3) = RIGHT(''' + @area + ''',3) AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
	--END
	SET @sql = 
		'SELECT T1.Name [Desc]
		,(
			SELECT CASE 
					WHEN T1.Name = ''Non Sales - Repair Return (Temporary)''
						THEN ''NS-RR''
					WHEN T1.Name = ''Non Sales - Return (Permanent)''
						THEN ''NS-R''
					WHEN T1.Name = ''Non Sales - Personal Effect (Permanent)''
						THEN ''NS-PE''
					WHEN T1.Name = ''Non Sales - Exhibition (Temporary)''
						THEN ''NS-E''
					ELSE ''Sales''
					END
			) Category
		,ISNULL(T2.Total, 0) Total
	FROM (
		SELECT MP.Name
		FROM MasterParameter MP
		WHERE MP.[Group] = ''ExportType''
		) T1
	LEFT JOIN (
		SELECT Count(C.ExportType) Total
			,C.ExportType
		FROM MasterParameter MP
		LEFT JOIN Cargo C ON C.ExportType = MP.Name
		LEFT JOIN RequestCl RCL ON RCL.IdCl = C.Id
		LEFT JOIN CargoCipl CC ON CC.IdCargo = C.Id
		LEFT JOIN Cipl CI ON CI.id = CC.IdCipl 
		LEFT JOIN NpePeb N on C.Id = N.IdCl
		WHERE MP.[Group] = ''ExportType'' AND CI.CreateBy <>''System''
			AND RCL.IdStep IN (
				10019
				,10020
				,10021
				,10022
				,10043
				,30042
				)
			AND RCL.Status IN (''Draft'',''Submit'',''Revise'',''Approve'')
			' 
		+ @and + '
			AND C.IsDelete = 0
			AND N.NpeNumber is not null
		GROUP BY C.ExportType
			,MP.Name
		) AS T2 ON T2.ExportType = T1.Name'

	EXECUTE (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Export_Today2]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_Export_Today2] '2020-01-01', '2020-12-12', '0A07'
--EXEC [dbo].[SP_Dashboard_Export_Today2] '2020-01-01', '2020-12-12', 'XUPJ21PTR'
--EXEC [dbo].[SP_Dashboard_Export_Today2] '2020-01-01', '2020-12-12', ''
ALTER PROCEDURE [dbo].[SP_Dashboard_Export_Today2] (
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

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Export_Value]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_Export_Value] '2020-01-01', '2020-12-12', '0A07'
--EXEC [dbo].[SP_Dashboard_Export_Value] '2020-01-01', '2020-12-12', 'XUPJ21PTR'
--EXEC [dbo].[SP_Dashboard_Export_Value] '2020-01-01', '2020-12-12', ''
ALTER PROCEDURE [dbo].[SP_Dashboard_Export_Value] (
	@date1 NVARCHAR(100)
	,@date2 NVARCHAR(100)
	,@user NVARCHAR(10)
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
		SET @and = 'AND CC.PickUpArea IS NOT NULL AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
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

	SET @sql = 'SELECT ''ExportType'' Category
		,MP.Name [Desc]
		,ISNULL((
				SELECT SUM(CI.ExtendedValue)
				FROM CiplItem CI
				INNER JOIN Cipl CC ON CC.id = CI.IdCipl
				INNER JOIN CargoItem CAI ON CI.Id = CAI.IdCiplItem
				INNER JOIN Cargo C ON CAI.IdCargo = C.Id
				INNER JOIN RequestCl RCL ON CAI.IdCargo = RCL.IdCl
				WHERE RCL.IdStep IN (
						10020
						,10021
						,10022
						,10043
						)
					AND C.ExportType = ''Non Sales - Repair Return (Temporary)''
					AND CAI.IsDelete = 0
					AND CI.IsDelete = 0
					' + @and + 
		'
				), 0) Total
	FROM RequestCl RCL
	INNER JOIN Cargo C ON RCL.IdCl = C.Id
	RIGHT JOIN MasterParameter MP ON C.ExportType = MP.Name
	WHERE MP.[Group] = ''ExportType''
		AND MP.Name = ''Non Sales - Repair Return (Temporary)''
	GROUP BY MP.Name
	
	UNION ALL
	
	SELECT ''ExportType'' Category
		,MP.Name [Desc]
		,ISNULL((
				SELECT SUM(CI.ExtendedValue)
				FROM CiplItem CI
				INNER JOIN Cipl CC ON CC.id = CI.IdCipl
				INNER JOIN CargoItem CAI ON CI.Id = CAI.IdCiplItem
				INNER JOIN Cargo C ON CAI.IdCargo = C.Id
				INNER JOIN RequestCl RCL ON CAI.IdCargo = RCL.IdCl
				WHERE RCL.IdStep IN (
						10020
						,10021
						,10022
						,10043
						)
					AND C.ExportType = ''Non Sales - Return (Permanent)''
					AND CAI.IsDelete = 0
					AND CI.IsDelete = 0
					' + @and + 
		'
				), 0) Total
	FROM RequestCl RCL
	INNER JOIN Cargo C ON RCL.IdCl = C.Id
	RIGHT JOIN NpePeb N ON C.Id = N.IdCl AND NpeNumber not in ('''',''-'') 
	RIGHT JOIN MasterParameter MP ON C.ExportType = MP.Name
	WHERE MP.[Group] = ''ExportType''
		AND MP.Name = ''Non Sales - Return (Permanent)''
		
	GROUP BY MP.Name
	
	UNION ALL
	
	SELECT ''ExportType'' Category
		,MP.Name [Desc]
		,ISNULL((
				SELECT SUM(CI.ExtendedValue)
				FROM CiplItem CI
				INNER JOIN Cipl CC ON CC.id = CI.IdCipl
				INNER JOIN CargoItem CAI ON CI.Id = CAI.IdCiplItem
				INNER JOIN Cargo C ON CAI.IdCargo = C.Id
				INNER JOIN RequestCl RCL ON CAI.IdCargo = RCL.IdCl
				WHERE RCL.IdStep IN (
						10020
						,10021
						,10022
						,10043
						)
					AND C.ExportType = ''Non Sales - Personal Effect (Permanent)''
					AND CAI.IsDelete = 0
					AND CI.IsDelete = 0
					' + @and + 
		'
				), 0) Total
	FROM RequestCl RCL
	INNER JOIN Cargo C ON RCL.IdCl = C.Id
	RIGHT JOIN MasterParameter MP ON C.ExportType = MP.Name
	WHERE MP.[Group] = ''ExportType''
		AND MP.Name = ''Non Sales - Personal Effect (Permanent)''
	GROUP BY MP.Name
	
	UNION ALL
	
	SELECT ''ExportType'' Category
		,MP.Name [Desc]
		,ISNULL((
				SELECT SUM(CI.ExtendedValue)
				FROM CiplItem CI
				INNER JOIN Cipl CC ON CC.id = CI.IdCipl
				INNER JOIN CargoItem CAI ON CI.Id = CAI.IdCiplItem
				INNER JOIN Cargo C ON CAI.IdCargo = C.Id
				INNER JOIN RequestCl RCL ON CAI.IdCargo = RCL.IdCl
				WHERE RCL.IdStep IN (
						10020
						,10021
						,10022
						,10043
						)
					AND C.ExportType = ''Non Sales - Exhibition (Temporary)''
					AND CAI.IsDelete = 0
					AND CI.IsDelete = 0
					' + @and + 
		'
				), 0) Total
	FROM RequestCl RCL
	INNER JOIN Cargo C ON RCL.IdCl = C.Id
	RIGHT JOIN MasterParameter MP ON C.ExportType = MP.Name
	WHERE MP.[Group] = ''ExportType''
		AND MP.Name = ''Non Sales - Exhibition (Temporary)''
	GROUP BY MP.Name
	
	UNION ALL
	
	SELECT ''ExportType'' Category
		,MP.Name [Desc]
		,ISNULL((
				SELECT SUM(CI.ExtendedValue)
				FROM CiplItem CI
				INNER JOIN Cipl CC ON CC.id = CI.IdCipl
				INNER JOIN CargoItem CAI ON CI.Id = CAI.IdCiplItem
				INNER JOIN Cargo C ON CAI.IdCargo = C.Id
				INNER JOIN RequestCl RCL ON CAI.IdCargo = RCL.IdCl
				WHERE RCL.IdStep IN (
						10020
						,10021
						,10022
						,10043
						)
					AND C.ExportType = ''Sales (Permanent)''
					AND CAI.IsDelete = 0
					AND CI.IsDelete = 0
					' + @and + '
				), 0) Total
	FROM RequestCl RCL
	INNER JOIN Cargo C ON RCL.IdCl = C.Id
	RIGHT JOIN MasterParameter MP ON C.ExportType = MP.Name
	WHERE MP.[Group] = ''ExportType''
		AND MP.Name = ''Sales (Permanent)''
	GROUP BY MP.Name'
		;

	EXECUTE (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Map_Branch_20210226]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_Dashboard_Map_Branch_20210226] (@user NVARCHAR(50))
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
		,MASP.Name area
		,COUNT(CC.Id) total
	FROM Highchartprovince HP
	INNER JOIN MasterArea MA ON MA.ProvinsiCode = HP.id
	INNER JOIN Cipl C ON RIGHT(C.Area, 3) = RIGHT(MA.BAreaCode, 3)
	INNER JOIN CargoCipl CC ON CC.IdCipl = C.id
	INNER JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo
	INNER JOIN Cargo CA ON CA.Id = CC.IdCargo
	INNER JOIN MasterAirSeaPort MASP ON MASP.Code = LEFT(CA.PortOfLoading, 5)
	INNER JOIN employee E ON E.AD_User = C.CreateBy
	WHERE RCL.IdStep IN (
			11
			,12
			,10017
			,20033
			,10020
			,10022
			)
		AND RCL.STATUS IN (
			''Draft''
			,''Submit''
			,''Approve''
			,''Revise''
			)
		AND YEAR(RCL.CreateDate) = YEAR(GETDATE())
		AND C.CreateBy <>''System''
	GROUP BY C.CiplNo
		,E.Employee_Name
		,MA.BAreaName
		,HP.latitude
		,HP.longitude
		,HP.name
		,C.id
		,MASP.Name
	ORDER BY C.id DESC';
	--Print  @sql
	--PRINT 'masuk'
	EXECUTE (@sql);
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

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Map_Port]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Dashboard_Map_Port] (@user NVARCHAR(50))
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

	SET @sql = 'SELECT C.CiplNo [no]
		,E.Employee_Name employee 
		,CONVERT(nvarchar, HP.latitude) lat
		,CONVERT(nvarchar, HP.longitude) lon
		,HP.[name] provinsi
		,MASP.Name area
		,COUNT(CC.Id) total
	FROM Highchartprovince HP
	INNER JOIN MasterArea MA ON MA.ProvinsiCode = HP.id
	INNER JOIN Cipl C ON RIGHT(C.Area, 3) = RIGHT(MA.BAreaCode, 3)
	INNER JOIN CargoCipl CC ON CC.IdCipl = C.id
	INNER JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo
	INNER JOIN employee E ON E.AD_User = C.CreateBy
	INNER JOIN Cargo CA ON CA.Id = CC.IdCargo
	INNER JOIN MasterAirSeaPort MASP ON MASP.Code = LEFT(CA.PortOfLoading, 5)
	WHERE RCL.IdStep IN (10019,10020,30041,30042,10021,10022)
	AND      RCL.Status IN (''Draft'',''Submit'',''Approve'',''Revise'',''Finish'')
	AND C.CreateBy <>''System''
	AND YEAR(RCL.CreateDate) = YEAR(GETDATE())
	' + @and + '
	GROUP BY 
		C.CiplNo
		,E.Employee_Name
		,MA.BAreaName
		,HP.latitude
		,HP.longitude
		,HP.name
		,C.id
		,MASP.Name
		,HP.latitude
		,HP.longitude
		ORDER BY C.id DESC';

	EXECUTE (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_NetWeight]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_NetWeight] '2020-01-01', '2020-12-12', '0A07'
--EXEC [dbo].[SP_Dashboard_NetWeight] '2020-01-01', '2020-12-12', 'XUPJ21PTR'
--EXEC [dbo].[SP_Dashboard_NetWeight] '2020-01-01', '2020-12-12', ''
ALTER PROCEDURE [dbo].[SP_Dashboard_NetWeight] (
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

	SET @sql = 'SELECT T1.Name [Category]
		,(
			SELECT CASE 
					WHEN T1.Name = ''CATERPILLAR NEW EQUIPMENT''
						THEN ''CAT NE''
					WHEN T1.Name = ''CATERPILLAR SPAREPARTS''
						THEN ''CAT PARTS''
					WHEN T1.Name = ''CATERPILLAR USED EQUIPMENT''
						THEN ''CAT UE''
					WHEN T1.Name = ''MISCELLANEOUS''
						THEN ''MISC''
					END
			) [Desc]
		, ROUND(ISNULL(T2.Total/1000, 0), 2) AS Total
	FROM (
		SELECT MP.Name
		FROM MasterParameter MP
		WHERE MP.[Group] = ''Category''
		) T1
	LEFT JOIN (
		SELECT Sum(CI.Net) Total, CA.Category
			FROM CargoItem CI
			INNER JOIN RequestCl RCL ON RCL.IdCl = CI.IdCargo
			INNER JOIN Cargo CA ON CI.IdCargo = CA.Id
			INNER JOIN Cipl C ON C.id = CI.IdCipl
			LEFT JOIN MasterParameter MP ON MP.Name = CA.Category
			WHERE MP.[Group] = ''Category''
				AND RCL.IdStep IN ( 10020, 10021, 10022, 10043 )
				AND CI.isDelete = 0 
				AND C.IsDelete = 0
				AND C.CreateBy <>''System''
				' + @and + '
					GROUP BY CA.Category
		) AS T2 ON T2.Category = T1.Name';

	EXECUTE (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Outstanding_Branch_20210226]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_Outstanding_Branch] 1, 5, '0A07'
ALTER PROCEDURE [dbo].[SP_Dashboard_Outstanding_Branch_20210226] (
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
	WHERE U.AD_User = @user;;

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

	SET @sql = 'SELECT C.CiplNo AS No
		,(
			SELECT tab0.PlantName
			FROM fn_get_cipl_businessarea_list(C.Area) AS tab0
			WHERE tab0.PlantCode = C.Area
			) Branch
		,CO.PortOfLoading
		,CO.PortOfDestination
		,CO.SailingSchedule ETD
		,CO.ArrivalDestination ETA
		,FS.ViewByUser
	FROM CIPL C
	INNER JOIN CargoCipl CC ON C.id = CC.IdCipl
	INNER JOIN Cargo CO ON CC.IdCargo = CO.Id
	INNER JOIN RequestCl RCL ON CC.IdCargo = RCL.IdCl
	INNER JOIN FlowStatus FS ON RCL.IdStep = FS.IdStep
		AND RCL.STATUS = FS.STATUS
	WHERE RCL.IdStep IN (
			12
			,10017
			,20033
			,10032
			)
		AND RCL.STATUS IN (
			''Draft''
			,''Submit''
			,''Approve''
			,''Revise''
			)
		AND YEAR(RCL.CreateDate) = YEAR(GETDATE())
		' + @and + '
	ORDER BY C.id OFFSET(('+@Page+' - 1) * '+@RowspPage+') ROWS

	FETCH NEXT '+@RowspPage+' ROWS ONLY';
	EXECUTE (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Outstanding_Branch_20210726]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [dbo].[SP_Dashboard_Outstanding_Branch] 1, 5, '0A07'
ALTER PROCEDURE [dbo].[SP_Dashboard_Outstanding_Branch_20210726] (
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
	WHERE U.AD_User = @user;;

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

	SET @sql = 'SELECT C.CiplNo AS No
		,(
			SELECT tab0.PlantName
			FROM fn_get_cipl_businessarea_list(C.Area) AS tab0
			WHERE tab0.PlantCode = C.Area
			) Branch
		,Isnull((SELECT top 1  CA.PortOfLoading FROM CargoCipl CC 
		LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo WHERE CC.IdCipl = C.id and  CA.PortOfLoading is not null ),c.LoadingPort) PortOfLoading
		,Isnull((SELECT top 1  CA.PortOfDestination FROM CargoCipl CC 
		LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo WHERE CC.IdCipl = C.id and  CA.PortOfDestination is not null),c.DestinationPort) PortOfDestination
		
		,(SELECT top 1  CA.SailingSchedule FROM CargoCipl CC 
		LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo WHERE CC.IdCipl = C.id and  CA.SailingSchedule is not null) ETD
		
		,(SELECT top 1  CA.ArrivalDestination FROM CargoCipl CC 
		LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo		
		 WHERE CC.IdCipl = C.id and  CA.ArrivalDestination is not null) ETA
		
		--,isnull((SELECT top 1 FS.ViewByUser FROM CargoCipl CC 
		--LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo
		--LEFT JOIN RequestCl rcl ON rcl.IdCl = cc.IdCargo
		--LEFT JOIN FlowStatus FS ON RCL.IdStep = FS.IdStep AND RCL.STATUS = FS.STATUS WHERE CC.IdCipl = C.id AND  FS.ViewByUser is not null),
		--(Select FS.ViewByUser From FlowStatus FS WHERE FS.IdStep = RC.idstep AND FS.STATUS = RC.STATUS)) ViewByUser

		,CASE					
			WHEN fnreq.NextStatusViewByUser =''Pickup Goods''
				THEN
					CASE WHEN 
					(fnReqGr.Status=''DRAFT'') OR (fnReq.Status=''APPROVE'' AND fnReqGr.Status is null AND RC.Status =''APPROVE'') 
						THEN ''Waiting for Pickup Goods''
					WHEN (fnReqGr.IdFlow = 14 AND (fnReqGr.Status =''Submit'' OR fnReqGr.Status =''APPROVE'' ) AND (fnReqCl.Status is Null OR fnReqCl.Status=''Submit''))
						THEN ''On process Pickup Goods''
					WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep not in (10022))
						THEN ''Preparing for export''
					WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep = 10022)
						THEN ''Finish''	
					END			
			ELSE fnReq.NextStatusViewByUser
			END AS ViewByUser

		--,CO.PortOfLoading
		--,CO.PortOfDestination
		--,CO.SailingSchedule ETD
		--,CO.ArrivalDestination ETA
		--,CO.*
		--,FS.ViewByUser
	FROM Highchartprovince HP
	INNER JOIN MasterArea MA ON MA.ProvinsiCode = HP.id
	INNER JOIN Cipl C ON RIGHT(C.Area, 3) = RIGHT(MA.BAreaCode, 3)
	--LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id
	INNER JOIN RequestCipl RC ON RC.IdCipl = C.id
	--LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo
	--LEFT JOIN Cargo CO ON CO.Id = CC.IdCargo
	--LEFT JOIN FlowStatus FS ON RCL.IdStep = FS.IdStep
	--	AND RCL.STATUS = FS.STATUS
	INNER JOIN dbo.[fn_get_cipl_request_list_all]() as fnReq on fnReq.Id = rc.Id 
	LEFT JOIN GoodsReceiveItem as GR on GR.IdCipl = C.id
	LEFT JOIN CargoCipl as CC on CC.IdCipl = C.id
	LEFT JOIN dbo.[fn_get_gr_request_list_all]() as fnReqGr on fnReqGr.IdGr = GR.IdGr
	LEFT JOIN dbo.[fn_get_cl_request_list_all]() as fnReqCl on fnReqCl.IdCl = CC.IdCargo
	WHERE 
	--RCL.IdStep IN (
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
	--	AND 
		RC.STATUS IN (			
			''Submit''
			,''Approve''
			,''Revise''
			)	
			AND RC.IdCipl NOT IN (SELECT IdCipl FROM CargoCipl CC LEFT JOIN RequestCl RCL ON CC.IdCargo = RCL.IdCl WHERE RCL.Status =''DRAFT''   )
		
		AND YEAR(RC.CreateDate) = YEAR(GETDATE())
	' + @and + '
	ORDER BY C.id OFFSET(('+@Page+' - 1) * '+@RowspPage+') ROWS

	FETCH NEXT '+@RowspPage+' ROWS ONLY';
	EXECUTE (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Outstanding_Branch]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Dashboard_Outstanding_Branch] (
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
	WHERE U.AD_User = @user;;

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

	SET @sql = 'SELECT C.CiplNo AS No
		,(
			SELECT tab0.PlantName
			FROM fn_get_cipl_businessarea_list(C.Area) AS tab0
			WHERE tab0.PlantCode = C.Area
			) Branch
		,Isnull((SELECT top 1  CA.PortOfLoading FROM CargoCipl CC 
		LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo WHERE CC.IdCipl = C.id and  CA.PortOfLoading is not null ),c.LoadingPort) PortOfLoading
		,Isnull((SELECT top 1  CA.PortOfDestination FROM CargoCipl CC 
		LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo WHERE CC.IdCipl = C.id and  CA.PortOfDestination is not null),c.DestinationPort) PortOfDestination
		
		,(SELECT top 1  CA.SailingSchedule FROM CargoCipl CC 
		LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo WHERE CC.IdCipl = C.id and  CA.SailingSchedule is not null) ETD
		
		,(SELECT top 1  CA.ArrivalDestination FROM CargoCipl CC 
		LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo		
		 WHERE CC.IdCipl = C.id and  CA.ArrivalDestination is not null) ETA
		
		--,isnull((SELECT top 1 FS.ViewByUser FROM CargoCipl CC 
		--LEFT JOIN Cargo CA ON CA.Id = CC.IdCargo
		--LEFT JOIN RequestCl rcl ON rcl.IdCl = cc.IdCargo
		--LEFT JOIN FlowStatus FS ON RCL.IdStep = FS.IdStep AND RCL.STATUS = FS.STATUS WHERE CC.IdCipl = C.id AND  FS.ViewByUser is not null),
		--(Select FS.ViewByUser From FlowStatus FS WHERE FS.IdStep = RC.idstep AND FS.STATUS = RC.STATUS)) ViewByUser

		,CASE					
			WHEN fnreq.NextStatusViewByUser =''Pickup Goods''
				THEN
					CASE WHEN 
					(fnReqGr.Status=''DRAFT'') OR (fnReq.Status=''APPROVE'' AND fnReqGr.Status is null AND RC.Status =''APPROVE'') 
						THEN ''Waiting for Pickup Goods''
					WHEN (fnReqGr.IdFlow = 14 AND (fnReqGr.Status =''Submit'' OR fnReqGr.Status =''APPROVE'' ) AND (fnReqCl.Status is Null OR fnReqCl.Status=''Submit''))
						THEN ''On process Pickup Goods''
					WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep not in (10022))
						THEN ''Preparing for export''
					WHEN (fnReqCl.IdFlow = 4 AND fnReqCl.IdStep = 10022)
						THEN ''Finish''	
					END			
			ELSE fnReq.NextStatusViewByUser
			END AS ViewByUser

		--,CO.PortOfLoading
		--,CO.PortOfDestination
		--,CO.SailingSchedule ETD
		--,CO.ArrivalDestination ETA
		--,CO.*
		--,FS.ViewByUser
	FROM Highchartprovince HP
	INNER JOIN MasterArea MA ON MA.ProvinsiCode = HP.id
	INNER JOIN Cipl C ON RIGHT(C.Area, 3) = RIGHT(MA.BAreaCode, 3)
	--LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id
	INNER JOIN RequestCipl RC ON RC.IdCipl = C.id
	--LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo
	--LEFT JOIN Cargo CO ON CO.Id = CC.IdCargo
	--LEFT JOIN FlowStatus FS ON RCL.IdStep = FS.IdStep
	--	AND RCL.STATUS = FS.STATUS
	INNER JOIN Temptable_cipl_request_list_all as fnReq on fnReq.Id = rc.Id 
	LEFT JOIN GoodsReceiveItem as GR on GR.IdCipl = C.id
	LEFT JOIN CargoCipl as CC on CC.IdCipl = C.id
	LEFT JOIN Temptable_gr_request_list_all as fnReqGr on fnReqGr.IdGr = GR.IdGr
	LEFT JOIN Temptable_cl_request_list_all as fnReqCl on fnReqCl.IdCl = CC.IdCargo
	WHERE 
	--RCL.IdStep IN (
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
	--	AND 
		RC.STATUS IN (			
			''Submit''
			,''Approve''
			,''Revise''
			)	
			AND RC.IdCipl NOT IN (SELECT IdCipl FROM CargoCipl CC LEFT JOIN RequestCl RCL ON CC.IdCargo = RCL.IdCl WHERE RCL.Status =''DRAFT''   )
		
		AND YEAR(RC.CreateDate) = YEAR(GETDATE())
	' + @and + '
	ORDER BY C.id OFFSET(('+@Page+' - 1) * '+@RowspPage+') ROWS

	FETCH NEXT '+@RowspPage+' ROWS ONLY';
	EXECUTE (@sql);
END

GO

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Outstanding_Port]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_Outstanding_Port] '1', '10', ''
ALTER PROCEDURE [dbo].[SP_Dashboard_Outstanding_Port] (
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

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_Shipment_Category]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_Shipment_Category] '2019-01-01', '2019-12-12', 'XUPJ21WDN'     
ALTER PROCEDURE [dbo].[SP_Dashboard_Shipment_Category] (
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
		SET @and = 'AND C.PickUpArea IS NOT NULL AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
	END
	ELSE
	BEGIN
		IF (
				@area = ''
				OR @area IS NULL
				)
		BEGIN
			SET @and = 'AND RIGHT(C.PickUpArea, 3) = RIGHT(''' + @user + ''',3) AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
		END
		ELSE
		BEGIN
			SET @and = 'AND RIGHT(C.PickUpArea, 3) = RIGHT(''' + @area + ''',3) AND RCL.CreateDate BETWEEN CONVERT(DATETIME, ''' + @date1 + ''') AND CONVERT(DATETIME, ''' + @date2 + ''')';
		END
	END

	SET @sql = 'SELECT ''PP/UE'' [Desc]
	,(
		SELECT CASE 
				WHEN T1.Name = ''Engine''
					THEN ''Engine''
				WHEN T1.Name = ''Machine''
					THEN ''Machine''
				WHEN T1.Name = ''Forklift''
					THEN ''Forklift''
				ELSE ''Parts''
				END
		) Category
,ISNULL(T2.Total, 0) Total
FROM (
	SELECT MP.Name, MP.[Group]
	FROM MasterParameter MP
	WHERE MP.[Group] IN (
			''CategoryUnit'')
	) T1
LEFT JOIN (
	SELECT A1.CategoriItem, A1.Total * 100/T2.Total Total FROM (SELECT Count(C.CategoriItem) Total, C.CategoriItem
                        FROM cipl C
						INNER JOIN CargoCipl CC ON CC.IdCipl = C.id
                        INNER JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo
						INNER JOIN MasterParameter MP ON MP.Name = C.CategoriItem
                        WHERE MP.[Group] = ''CategoryUnit''
							AND RCL.IdStep IN (
                                10019,10020
                                ,10021
                                ,10022
                                ,10043
                                )
                            AND RCL.STATUS = ''Approve''
							' + @and + '
                            AND C.IsDelete = 0
							GROUP BY C.Category,C.CategoriItem) A1
							LEFT JOIN (

							SELECT Count(C.CategoriItem) Total, C.CategoriItem
                        FROM cipl C
                        LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id
                        LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo
						LEFT JOIN MasterParameter MP ON MP.Name = C.CategoriItem
                        WHERE MP.[Group] = ''CategoryUnit''
							' + @and + '
                            AND C.IsDelete = 0
							GROUP BY C.CategoriItem) T2 ON T2.CategoriItem = A1.CategoriItem
	) AS T2 ON T2.CategoriItem = T1.Name
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
	,ISNULL(T2.Total, 0) Total
FROM (
	SELECT MP.Name, MP.[Group]
	FROM MasterParameter MP
	WHERE MP.[Name] IN (
			''CATERPILLAR SPAREPARTS'', ''MISCELLANEOUS'')
	) T1
LEFT JOIN (
	SELECT A1.Category, A1.Total * 100/T2.Total Total FROM (SELECT Count(C.Category) Total, C.Category
                        FROM cipl C
						LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id
                        LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo
						LEFT JOIN MasterParameter MP ON MP.Name = C.Category
                        WHERE MP.Name IN (''CATERPILLAR SPAREPARTS'',''MISCELLANEOUS'')
							AND RCL.IdStep IN (
                                10019,10020
                                ,10021
                                ,10022
                                ,10043
                                )
                            AND RCL.STATUS = ''Approve''
							' + @and + '
                            AND C.IsDelete = 0
							GROUP BY C.Category) A1
							LEFT JOIN (

							SELECT Count(C.Category) Total, C.Category
                        FROM cipl C
                        LEFT JOIN CargoCipl CC ON CC.IdCipl = C.id
                        LEFT JOIN RequestCl RCL ON RCL.IdCl = CC.IdCargo
                        WHERE C.Category IN (''CATERPILLAR SPAREPARTS'',''MISCELLANEOUS'')
						' + @and + '
                            AND C.IsDelete = 0
							GROUP BY C.Category) T2 ON T2.Category = A1.Category
	) AS T2 ON T2.Category = T1.Name';

	EXECUTE (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_delete_cargo_item_Change]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[sp_delete_cargo_item_Change]
@Id nvarchar(100)
as
begin
delete from CargoItem_Change
where IdCargo = @Id
select Cast(@Id as bigint) As Id
end

GO

/****** Object:  StoredProcedure [dbo].[SP_deleteAllArmada]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  ALTER procedure [dbo].[SP_deleteAllArmada](@id nvarchar(100))
  as
  begin
  delete From ShippingFleet
  where IdGr = @id
  delete From ShippingFleetItem
  where IdGr = @id
  end
  
GO

/****** Object:  StoredProcedure [dbo].[SP_deleteArmada]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 ALTER procedure [dbo].[SP_deleteArmada](  
  @id nvarchar(100))        
  as        
  begin        
  delete From ShippingFleet        
  where Id = @id      
  delete From ShippingFleetRefrence  
  where IdShippingFleet = @id        
  end 

GO

/****** Object:  StoredProcedure [dbo].[SP_deleteArmadaChange]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[SP_deleteArmadaChange](    
  @id nvarchar(100))          
  as          
  begin          
  delete From ShippingFleet_Change          
  where Id = @id             
  end 


GO

/****** Object:  StoredProcedure [dbo].[SP_deleteShippingFleet]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[SP_deleteShippingFleet]
(
@id nvarchar(100),
@idCiplItem nvarchar(100)
)
as 
begin
delete From ShippingFleetItem
where IdCiplItem = @idCiplItem And IdShippingFleet = @id
end
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLAttachmentInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[SP_DHLAttachmentInsert]
@DHLShipmentID nvarchar(100)
, @LabelImageFormat nvarchar(50)
, @GraphicImage varchar(MAX)
, @UserId varchar(100)

As
Set Nocount On

Insert Into DHLAttachment (DHLShipmentID, ImageFormat, GraphicImage, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
Select DHLShipmentID=@DHLShipmentID, ImageFormat=@LabelImageFormat, GraphicImage=@GraphicImage, IsDelete=0, CreateBy=@UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate=NULL
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLLogRequestInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[SP_DHLLogRequestInsert]
@ReqType varchar(50),
@DHLShipmentID bigint,
@DHLTrackingShipmentID bigint,
@Param varchar(MAX),
@UserId varchar(50)

As
Set Nocount On

Declare @DHLLogRequestID bigint 

Insert into DHLLogRequest(DHLShipmentID,DHLTrackingShipmentID,ReqType,[Param],CreateBy,CreateDate,UpdateBy,UpdateDate)
Values (@DHLShipmentID, @DHLTrackingShipmentID, @ReqType, @Param, @UserId, GETDATE(), NULL, NULL)

Select @DHLLogRequestID = Convert(bigint, SCOPE_IDENTITY())

Select @DHLLogRequestID As DHLLogRequestID
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLLogResponseInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[SP_DHLLogResponseInsert]
@DHLLogRequestID bigint,
@ReqStatus varchar(50),
@ResponseCode varchar(50),
@ResponseMsg varchar(MAX),
@UserId varchar(50)

As
Set Nocount On

Insert into DHLLogResponse(DHLLogRequestID,ReqStatus,ResponseCode,ResponseMsg,CreateBy,CreateDate,UpdateBy,UpdateDate)
Values (@DHLLogRequestID, @ReqStatus, @ResponseCode, @ResponseMsg, @UserId, GETDATE(), NULL, NULL)
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLPackageInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SP_DHLPackageInsert](@dtDHLDataType DHLDataType ReadOnly)  

As
Begin  
	Declare @DHLShipmentID bigint
	Select @DHLShipmentID = a.ID From ( Select top 1 * From @dtDHLDataType )a
	
	If exists (Select Top 1 * from DHLPackage where DHLShipmentID = @DHLShipmentID)
	Begin 
		Delete From DHLPackage Where DHLShipmentID = @DHLShipmentID
	End

    insert into DHLPackage (DHLShipmentID, PackageNumber, Insured, [Weight], [Length], Width, Height, CustReferences, CaseNumber, CiplNumber, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	select DHLShipmentID=ID, PackageNumber=ItemCode, Insured=dbo.FN_SplitStringDelimiter(ItemValue, '|', 0), [Weight]=dbo.FN_SplitStringDelimiter(ItemValue, '|', 1)
		 , [Length]=dbo.FN_SplitStringDelimiter(ItemValue, '|', 2), Width=dbo.FN_SplitStringDelimiter(ItemValue, '|', 3), Height=dbo.FN_SplitStringDelimiter(ItemValue, '|', 4)
		 , CustReferences=ItemDesc, CaseNumber=dbo.FN_SplitStringDelimiter(ItemValue, '|', 5), CiplNumber=dbo.FN_SplitStringDelimiter(ItemValue, '|', 6)
		 , IsDelete=0, CreateBy=UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate =NULL
	from @dtDHLDataType  
End  
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLRateInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SP_DHLRateInsert](@dtDHLRateType DHLRateType ReadOnly)  

As
Begin  
	Declare @DHLShipmentID bigint
	Select @DHLShipmentID = a.DHLShipmentID From ( Select top 1 * From @dtDHLRateType )a
	
	If exists (Select Top 1 * from DHLRate where DHLShipmentID = @DHLShipmentID)
	Begin 
		Delete From DHLRate Where DHLShipmentID = @DHLShipmentID
	End

    insert into DHLRate (DHLShipmentID, ServiceType, Currency, ChargeCode, ChargeType, ChargeAmount, DeliveryTime, CutoffTime, NextBusinessDay, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	select DHLShipmentID=DHLShipmentID, ServiceType=ServiceType, Currency=Currency, ChargeCode=ChargeCode, ChargeType=ChargeType, ChargeAmount=ChargeAmount, DeliveryTime=DeliveryTime, CutoffTime=CutoffTime
		 , NextBusinessDay=NextBusinessDay, IsDelete=0, CreateBy=UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate =NULL
	from @dtDHLRateType  
End  
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLShipmentInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER Proc [dbo].[SP_DHLShipmentInsert] 
@DropOffType nvarchar(100)
, @ServiceType nvarchar(100)
, @PaymentInfo nvarchar(100)
, @Account nvarchar(60)
, @Currency nvarchar(20)
, @TotalNet decimal(18,2)
, @UnitOfMeasurement nvarchar(20)
, @PackagesCount int
, @LabelType nvarchar(100)
, @LabelTemplate nvarchar(100)
, @ShipTimestamp varchar(100)
, @PickupLocation nvarchar(100)
, @PickupLocationCloseTime nvarchar(100)
, @SpecialPickupInstruction nvarchar(max)
, @CommoditiesDescription nvarchar(max)
, @CommoditiesContent nvarchar(max)
, @ShipperPersonName nvarchar(100)
, @ShipperCompanyName nvarchar(100)
, @ShipperPhoneNumber nvarchar(100)
, @ShipperEmailAddress nvarchar(100)
, @ShipperStreetLines nvarchar(100)
, @ShipperCity nvarchar(100)
, @ShipperPostalCode nvarchar(100)
, @ShipperCountryCode nvarchar(100)
, @RecipientPersonName nvarchar(100)
, @RecipientCompanyName nvarchar(100)
, @RecipientPhoneNumber nvarchar(100)
, @RecipientEmailAddress nvarchar(100)
, @RecipientStreetLines nvarchar(100)
, @RecipientCity nvarchar(100)
, @RecipientPostalCode nvarchar(100)
, @RecipientCountryCode nvarchar(100)
, @PICPersonName nvarchar(100)
, @PICPhoneNumber nvarchar(100)
, @PICEmailAddress nvarchar(100)
, @PICStreetLines nvarchar(100)
, @PackagesQty int
, @PackagesPrice decimal(18,2)
, @Referrence nvarchar(255)
, @ShipmentIdentificationNumber nvarchar(100)
, @DispatchConfirmationNumber nvarchar(100)
, @UserId varchar(100)
, @DHLShipmentID bigint

As
Set Nocount On


----# Handle Shiptimestamp null
if (@ShipTimestamp is NULL or @ShipTimestamp = '01 Jan 1900' or @ShipTimestamp = '01-01-1900')
begin
	Set @ShipTimestamp = '1900-01-01'
end


----# Insert DHLShipment
if not exists (Select top 1 * from DHLShipment where DHLShipmentID = @DHLShipmentID)
begin
	Insert Into DHLShipment (DropOffType, ServiceType, PaymentInfo, Account, Currency, TotalNet, UnitOfMeasurement, PackagesCount, LabelType, LabelTemplate, ShipTimestamp, PickupLocation, PickupLocTime
		 , SpcPickupInstruction, CommoditiesDesc, CommoditiesContent, IdentifyNumber, ConfirmationNumber, PackagesQty, PackagesPrice, Referrence, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	Select DropOffType=@DropOffType, ServiceType=@ServiceType, PaymentInfo=@PaymentInfo, Account=@Account, Currency=@Currency, TotalNet=@TotalNet, UnitOfMeasurement=@UnitOfMeasurement, PackagesCount=@PackagesCount
		 , LabelType=@LabelType, LabelTemplate=@LabelTemplate, ShipTimestamp=CONVERT(datetime, Left(@ShipTimestamp, 10), 126), PickupLocation=@PickupLocation, PickupLocTime=@PickupLocationCloseTime
		 , SpcPickupInstruction=@SpecialPickupInstruction, CommoditiesDesc=@CommoditiesDescription, CommoditiesContent=@CommoditiesContent, IdentifyNumber=@ShipmentIdentificationNumber
		 , ConfirmationNumber=@DispatchConfirmationNumber, PackagesQty=@PackagesQty, PackagesPrice=@PackagesPrice, Referrence=@Referrence, IsDelete=0, CreateBy=@UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate=NULL	

	Select @DHLShipmentID = Convert(bigint, SCOPE_IDENTITY())
end
else
begin 
	Update DHLShipment 
		Set DropOffType=@DropOffType, ServiceType=@ServiceType, PaymentInfo=@PaymentInfo, Account=@Account, Currency=@Currency, TotalNet=@TotalNet, UnitOfMeasurement=@UnitOfMeasurement
		  , PackagesCount=@PackagesCount, LabelType=@LabelType, LabelTemplate=@LabelTemplate, ShipTimestamp=CONVERT(datetime, Left(@ShipTimestamp, 10), 126)
		  , PickupLocation=@PickupLocation, PickupLocTime=@PickupLocationCloseTime, SpcPickupInstruction=@SpecialPickupInstruction, CommoditiesDesc=@CommoditiesDescription
		  , CommoditiesContent=@CommoditiesContent, IdentifyNumber=@ShipmentIdentificationNumber, ConfirmationNumber=@DispatchConfirmationNumber, PackagesQty=@PackagesQty
		  , PackagesPrice=@PackagesPrice, Referrence=@Referrence, UpdateBy=@UserId, UpdateDate=GETDATE()
	Where DHLShipmentID = @DHLShipmentID
end


----# Insert DHLPerson
If Not Exists (Select top 1 * from DHLPerson where DHLShipmentID = @DHLShipmentID and PersonType = 'SHIPPER')
Begin
	Insert into DHLPerson (DHLShipmentID, PersonType, PersonName, CompanyName, PhoneNumber, EmailAddress, StreetLines, City, PostalCode, CountryCode, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	Select DHLShipmentID=@DHLShipmentID, PersonType='SHIPPER', PersonName=@ShipperPersonName, CompanyName=@ShipperCompanyName, PhoneNumber=@ShipperPhoneNumber, EmailAddress=@ShipperEmailAddress
	, StreetLines=@ShipperStreetLines, City=@ShipperCity, PostalCode=@ShipperPostalCode, CountryCode=@ShipperCountryCode, IsDelete=0, CreateBy=@UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate=NULL
End
Else
Begin
	Update DHLPerson
		Set PersonName=@ShipperPersonName, CompanyName=@ShipperCompanyName, PhoneNumber=@ShipperPhoneNumber, EmailAddress=@ShipperEmailAddress, StreetLines=@ShipperStreetLines
		  , City=@ShipperCity, PostalCode=@ShipperPostalCode, CountryCode=@ShipperCountryCode, UpdateBy=@UserId, UpdateDate=GETDATE()
	Where DHLShipmentID = @DHLShipmentID and PersonType = 'SHIPPER'
End

If Not Exists (Select top 1 * from DHLPerson where DHLShipmentID = @DHLShipmentID and PersonType = 'RECIPIENT')
Begin
	Insert into DHLPerson (DHLShipmentID, PersonType, PersonName, CompanyName, PhoneNumber, EmailAddress, StreetLines, City, PostalCode, CountryCode, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	Select DHLShipmentID=@DHLShipmentID, PersonType='RECIPIENT', PersonName=@RecipientPersonName, CompanyName=@RecipientCompanyName, PhoneNumber=@RecipientPhoneNumber, EmailAddress=@RecipientEmailAddress
	, StreetLines=@RecipientStreetLines, City=@RecipientCity, PostalCode=@RecipientPostalCode, CountryCode=@RecipientCountryCode, IsDelete=0, CreateBy=@UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate=NULL
End
Else
Begin
	Update DHLPerson
		Set PersonName=@RecipientPersonName, CompanyName=@RecipientCompanyName, PhoneNumber=@RecipientPhoneNumber, EmailAddress=@RecipientEmailAddress, StreetLines=@RecipientStreetLines
		  , City=@RecipientCity, PostalCode=@RecipientPostalCode, CountryCode=@RecipientCountryCode, UpdateBy=@UserId, UpdateDate=GETDATE()
	Where DHLShipmentID = @DHLShipmentID and PersonType = 'RECIPIENT'
End

If Not Exists (Select top 1 * from DHLPerson where DHLShipmentID = @DHLShipmentID and PersonType = 'PIC')
Begin
	Insert into DHLPerson (DHLShipmentID, PersonType, PersonName, CompanyName, PhoneNumber, EmailAddress, StreetLines, City, PostalCode, CountryCode, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	Select DHLShipmentID=@DHLShipmentID, PersonType='PIC', PersonName=@PICPersonName, CompanyName='', PhoneNumber=@PICPhoneNumber, EmailAddress=@PICEmailAddress, StreetLines=@PICStreetLines
			, City='', PostalCode='', CountryCode='', IsDelete=0, CreateBy=@UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate=NULL
End
Else
Begin
	Update DHLPerson
		Set PersonName=@PICPersonName, PhoneNumber=@PICPhoneNumber, EmailAddress=@PICEmailAddress, StreetLines=@PICStreetLines, UpdateBy=@UserId, UpdateDate=GETDATE()
	Where DHLShipmentID = @DHLShipmentID and PersonType = 'PIC'
End

Select @DHLShipmentID 'DHLShipmentID'
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingNumberInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SP_DHLTrackingNumberInsert](@dtDHLDataType DHLDataType ReadOnly)  

As
Begin  
    insert into DHLTrackingNumber(DHLShipmentID, TrackingNumber, DescNumber, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	select DHLShipmentID=[ID], TrackingNumber=[ItemValue], DescNumber=[ItemCode], IsDelete=0, CreateBy=UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate =NULL
	from @dtDHLDataType  
End  
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingShipmentCheckStatus]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Proc [dbo].[SP_DHLTrackingShipmentCheckStatus]
@DHLShipmentID bigint
, @UserId varchar(50)

As
Set Nocount on

Declare @TrackingStat varchar(20)
Set @TrackingStat = 'PROCESS'

IF EXISTS (Select top 1 * From DHLShipment Where DHLShipmentID = @DHLShipmentID)
BEGIN
	IF EXISTS (
		Select Top 1 *
		From DHLTrackingShipment a
		Left Join DHLTrackingShipmentEvent c on a.DHLTrackingShipmentID = c.DHLTrackingShipmentID and c.EventType = 'SHIPMENT'
		Where a.DHLShipmentID = @DHLShipmentID and c.EventCode = 'OK'
	)
	BEGIN
		Exec [SP_DHLUpdStatusCipl] @DHLShipmentID, 'FINISH', @UserId

		Set @TrackingStat = 'FINISH'
	END
END
ELSE
BEGIN
	Set @TrackingStat = 'NOTFOUND'
END


SELECT @TrackingStat 'TrackingStat'
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingShipmentEventInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SP_DHLTrackingShipmentEventInsert](@dtDHLTrackingEvent DHLTrackingEvent ReadOnly)  

As
Begin  
	IF NOT EXISTS (
		Select top 1 * from @dtDHLTrackingEvent a
		left join DHLTrackingShipmentEvent b on a.DHLTrackingShipmentID=b.DHLTrackingShipmentID and a.LicensePlate=b.LicensePlate
		where b.EventCode = 'OK'
	)
	BEGIN
		IF EXISTS(
			Select top 1 * from @dtDHLTrackingEvent a
			left join DHLTrackingShipmentEvent b on a.DHLTrackingShipmentID=b.DHLTrackingShipmentID and a.EventType=b.EventType and a.LicensePlate=b.LicensePlate
		)
		BEGIN
			Delete b
			From @dtDHLTrackingEvent a
			left join DHLTrackingShipmentEvent b on a.DHLTrackingShipmentID=b.DHLTrackingShipmentID and a.EventType=b.EventType and a.LicensePlate=b.LicensePlate
		END
	
		insert into DHLTrackingShipmentEvent (DHLTrackingShipmentID, EventType, EventDate, EventTime, EventCode, EventDesc, SvcAreaCode, SvcAreaDesc, Signatory
											, ReferenceID, LicensePlate, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
		select DHLTrackingShipmentID=[DHLTrackingShipmentID], EventType=[EventType], EventDate=[EventDate], EventTime=[EventTime], EventCode=[EventCode]
			 , EventDesc=[EventDesc], SvcAreaCode=[SvcAreaCode], SvcAreaDesc=[SvcAreaDesc], Signatory=[Signatory], ReferenceID=[ReferenceID]
			 , LicensePlate=[LicensePlate], IsDelete=0, CreateBy=[UserID], CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate =NULL
		from @dtDHLTrackingEvent  
	END
End  
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingShipmentGetDataScheduler]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[SP_DHLTrackingShipmentGetDataScheduler]
@userid varchar(50)

As
Set Nocount On

declare @MsgTime varchar(25), @FirstDate datetime, @LastThreeMonth varchar(8)
Set @MsgTime = convert(varchar(19), GETDATE(), 127)
----Set @FirstDate = DATEADD(month, DATEDIFF(month, 0, getdate()), 0)
----Set @LastThreeMonth = CONVERT(varchar(8), DATEADD(MONTH, -3, @FirstDate), 112)
Set @LastThreeMonth = CONVERT(varchar(8), DATEADD(DAY, -91, GETDATE()), 112)

--select @LastThreeMonth

select top 10 LevelOfDetails = 'ALL_CHECKPOINTS', PiecesEnabled = 'B', MessageTime = @MsgTime, MessageReference = 'Tracking Automatic (' + ISNULL(b.HouseBlNumber, '') + ')'
, AWBNumber = b.HouseBlNumber
into #temp
from Cargo a
Left Join BlAwb b on a.Id = b.IdCl
where LEN(b.HouseBlNumber)=10 
and CONVERT(varchar(8), a.CreateDate, 112) > @LastThreeMonth


Select *
From(
	Select a.*, Tracking_Stat = Case When c.DHLTrackingShipmentID is NULL Then 'PROGRESS' Else 'FINISH' End
	From #temp a
	Left Join DHLTrackingShipment b on a.AWBNumber=b.AWBNumber
	Left Join DHLTrackingShipmentEvent c on b.DHLTrackingShipmentID = c.DHLTrackingShipmentID and c.EventType = 'SHIPMENT' and c.EventCode = 'OK'
)a
Where Tracking_Stat = 'PROGRESS'


Drop table #temp
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingShipmentInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[SP_DHLTrackingShipmentInsert] 
@DHLShipmentID bigint
, @AWBNumber nvarchar(100)
, @ServiceAreaCode nvarchar(100)
, @ServiceAreaDescription nvarchar(100)
, @DestinationAreaCode nvarchar(100)
, @DestinationAreaDescription nvarchar(100)
, @DestinationAreaFacilityCode nvarchar(100)
, @ShipperName nvarchar(100)
, @ConsigneeName nvarchar(100)
, @ShipmentDate nvarchar(100)
, @Pieces int
, @Weight nvarchar(100)
, @WeightUnit nvarchar(100)
, @ServiceType nvarchar(100)
, @ShipmentDescription nvarchar(100)
, @ShipperCity nvarchar(100)
, @ShipperSuburb nvarchar(100)
, @ShipperPostalCode nvarchar(100)
, @ShipperCountryCode nvarchar(100)
, @ConsigneeCity nvarchar(100)
, @ConsigneePostalCode nvarchar(100)
, @ConsigneeCountryCode nvarchar(100)
, @ReferenceID nvarchar(100)
, @ServiceInvocationID nvarchar(100)
, @UserId nvarchar(100)


As
Set Nocount On

Declare @DHLTrackingShipmentID bigint

IF EXISTS (Select Top 1 * From DHLTrackingShipment with(nolock) where DHLShipmentID <> 0 And DHLShipmentID = @DHLShipmentID)
BEGIN 
	Update DHLTrackingShipment set UpdateBy = @UserId, UpdateDate = GETDATE() Where DHLShipmentID = @DHLShipmentID

	Select @DHLTrackingShipmentID = DHLTrackingShipmentID From DHLTrackingShipment with(nolock) where DHLShipmentID = @DHLShipmentID
END
ELSE
BEGIN
	Insert Into DHLTrackingShipment (DHLShipmentID, AWBNumber, OriginSvcAreaCode, OriginSvcAreaDesc, DestSvcAreaCode, DestSvcAreaDesc, DestSvcAreaFacility
			  , ShipperName, ConsigneeName, ShipmentDate, Pieces, Weight, WeightUnit, ServiceType, ShipmentDescription, ShipperCity, ShipperSuburb
			  , ShipperPostalCode, ShipperCountryCode, ConsigneeCity, ConsigneePostalCode, ConsigneeCountryCode, ShipperReferenceID, ServiceInvocationID
			  , IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	Select DHLShipmentID=@DHLShipmentID, AWBNumber=@AWBNumber, OriginSvcAreaCode=@ServiceAreaCode, OriginSvcAreaDesc=@ServiceAreaDescription
		 , DestSvcAreaCode=@DestinationAreaCode, DestSvcAreaDesc=@DestinationAreaDescription, DestSvcAreaFacility=@DestinationAreaFacilityCode, ShipperName=@ShipperName
		 , ConsigneeName=@ConsigneeName, ShipmentDate=@ShipmentDate, Pieces=@Pieces, [Weight]=@Weight, WeightUnit=@WeightUnit, ServiceType=@ServiceType
		 , ShipmentDescription=@ShipmentDescription, ShipperCity=@ShipperCity, ShipperSuburb=@ShipperSuburb, ShipperPostalCode=@ShipperPostalCode
		 , ShipperCountryCode=@ShipperCountryCode, ConsigneeCity=@ConsigneeCity, ConsigneePostalCode=@ConsigneePostalCode, ConsigneeCountryCode=@ConsigneeCountryCode
		 , ShipperReferenceID=@ReferenceID, ServiceInvocationID=@ServiceInvocationID, IsDelete=0, CreateBy=@UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate=NULL

	Select @DHLTrackingShipmentID = Convert(bigint, SCOPE_IDENTITY())
END

Select @DHLTrackingShipmentID 'DHLTrackingShipmentID'
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingShipmentPieceInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[SP_DHLTrackingShipmentPieceInsert](@dtDHLTrackingPiece DHLTrackingPiece ReadOnly)  

As
Begin  
    insert into DHLTrackingShipmentPiece (DHLTrackingShipmentID, AWBNumber, LicensePlate, PieceNumber, Depth, Width, Height, [Weight], PackageType
										, DimWeight, WeightUnit, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	select DHLTrackingShipmentID=a.[DHLTrackingShipmentID], AWBNumber=a.[AWBNumber], LicensePlate=a.[LicensePlate], PieceNumber=a.[PieceNumber], Depth=a.[Depth]
		 , Width=a.[Width], Height=a.[Height], [Weight]=a.[Weight], PackageType=a.[PackageType], DimWeight=a.[DimWeight], WeightUnit=a.[WeightUnit]
		 , IsDelete=0, CreateBy=a.[UserID], CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate =NULL
	from @dtDHLTrackingPiece a
	left join DHLTrackingShipmentPiece b on a.DHLTrackingShipmentID=b.DHLTrackingShipmentID and a.LicensePlate=b.LicensePlate
	Where b.DHLTrackingShipmentID is NULL
End  
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingShipmentUpdateStatusCIPL]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Proc [dbo].[SP_DHLTrackingShipmentUpdateStatusCIPL]
@DHLShipmentID bigint
, @UserId varchar(50)

As
Set Nocount on

IF EXISTS (Select top 1 * From DHLShipment Where DHLShipmentID = @DHLShipmentID)
BEGIN
	IF EXISTS (
		Select Top 1 *
		From DHLTrackingShipment a
		Left Join DHLTrackingShipmentEvent c on a.DHLTrackingShipmentID = c.DHLTrackingShipmentID and c.EventType = 'SHIPMENT'
		Where a.DHLShipmentID = @DHLShipmentID and c.EventCode = 'OK'
	)
	BEGIN
		Exec [SP_DHLUpdStatusCipl] @DHLShipmentID, 'FINISH', @UserId
	END
END
GO

/****** Object:  StoredProcedure [dbo].[SP_DHLUpdStatusCipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Proc [dbo].[SP_DHLUpdStatusCipl]
@DHLShipmentID bigint
, @Type varchar(50)
, @UserId varchar(50)

As
Set Nocount On

------# TRACE
----Declare @DHLShipmentID bigint = 70057
----, @Type varchar(50)
----, @UserId varchar(50)


Declare @CiplExisting table (pkid bigint, CiplId bigint, DoNo varchar(100));
Declare @IdStepUpd bigint;

IF @Type = 'ONPROGRESS'
BEGIN
	Set @IdStepUpd = 30073;
END
ELSE IF @Type = 'FINISH'
BEGIN
	Set @IdStepUpd = 30074;
END
ELSE
BEGIN
	Set @IdStepUpd = 0;
END


----#1 Get CiplId
Insert into @CiplExisting
Select pkid = ROW_NUMBER()Over(Partition by CiplID Order by CiplID), CiplID, b.EdoNo
From
(
	Select Distinct CiplID = a.item 
	From(
		SELECT a.DHLShipmentID, x.item
		FROM(
			select DHLShipmentID, Referrence
			from DHLShipment
			where IsDelete = 0 and DHLShipmentID = @DHLShipmentID
		)a
		CROSS APPLY dbo.FN_SplitStringToRows(a.Referrence, ',') as x
	)a
)a
Left Join Cipl b on a.CiplID = b.id and b.IsDelete = 0

----select * from @CiplExisting

IF Exists (Select Top 1 * From @CiplExisting)
BEGIN
	IF @Type = 'ONPROGRESS'
	BEGIN
		Update A
			Set IdStep = @IdStepUpd
		From RequestCipl A
		Where A.IdCipl IN ( Select CiplId From @CiplExisting )
		And IsDelete = 0
	END
	ELSE IF @Type = 'FINISH'
	BEGIN
		Update A
			Set IdStep = @IdStepUpd
		From RequestCipl A
		Where A.IdCipl IN ( Select CiplId From @CiplExisting )
		And IsDelete = 0
		And IdStep = 30073
	END	
END


/*
	Declare @IDGR bigint, @TrxDate date
	Select @TrxDate = CONVERT(date, GETDATE())

	EXEC @IDGR = [dbo].[sp_insert_update_gr]
		@Id = 0,
		@PicName = @UserId,
		@KtpName = '-',
		@PhoneNumber = '',
		@SimNumber = '',
		@StnkNumber = '',
		@NopolNumber = '',
		@EstimationTimePickup = '',
		@Notes = '',
		@Vendor = '',
		@KirNumber = '',
		@KirExpire = '',
		@Apar = '',
		@Apd = '',
		@VehicleType = '',
		@VehicleMerk = '',
		@CreateBy = 'SYSTEM',
		@CreateDate = @TrxDate,
		@UpdateBy = NULL,
		@UpdateDate = NULL,
		@IsDelete = 0,
		@SimExpiryDate = NULL,
		@ActualTimePickup = NULL,
		@Status = 'Submit',
		@PickupPoint = NULL,
		@PickupPic = NULL


	Declare @Min int, @Max int
	Select @Min = MIN(PKID), @Max = MAX(pkid) From @CiplExisting
	While @Min <= @Max
	Begin
		Declare @CiplIDCurrent bigint, @DoNoCurrent varchar(100)
		Select @CiplIDCurrent = CiplId, @DoNoCurrent = DoNo From @CiplExisting Where pkid = @Min
	
		EXEC [dbo].[sp_insert_update_gr_item]
			@Id = 0,
			@IdCipl = @CiplIDCurrent,
			@IdGr = @IDGR,
			@DoNo = @DoNoCurrent,
			@DaNo = '',
			@FileName = '',
			@CreateBy = 'SYSTEM',
			@CreateDate = @TrxDate,
			@UpdateBy = NULL,
			@UpdateDate = NULL,
			@IsDelete = 0

		Set @Min = @Min + 1
	End
*/
GO

/****** Object:  StoredProcedure [dbo].[sp_get_all_reference_item]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_all_reference_item]
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
		SET @SQL = @SQL + ' WHERE ' + @Column + ' IN (SELECT F.splitdata FROM [dbo].[fnSplitString](''' + @ColumnValue + ''', '','') F) AND Createdate >= ''2020-06-08''  AND Category = ''' + @Category + ''' ';
	END
	ELSE
	BEGIN
		SET @SQL = @SQL + ' WHERE Category = ''' + @Category + '';
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

/****** Object:  StoredProcedure [dbo].[sp_get_areaUserCKB]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_get_areaUserCKB]
(
	@Name NVARCHAR(200)
)
AS
BEGIN
	SELECT CAST(t0.Id as bigint) Id, BAreaName, 
	Username, t0.CreateBy, t0.CreateDate, t0.UpdateBy, t0.UpdateDate, 
	t0.IsActive FROM [dbo].[MasterAreaUserCKB] as t0 inner join [dbo].[MasterArea] as t1 on t0.BAreaCode = t1.BAreaCode 
	where t0.IsActive = 0
	  --AND ISNULL(@Name, '') = ''
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_armada_document]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_get_armada_document]
(
	@Id NVARCHAR(10)
)	
AS
BEGIN
	select * from ShippingFleet
	where Id = @Id
	
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_blawb_list_idcl_history]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
ALTER PROCEDURE [dbo].[sp_get_blawb_list_idcl_history]      -- exec [sp_get_blawb_list_idcl_history] 11374   
(      
 @IdCargo NVARCHAR(10),      
 @IsTotal bit = 0,      
 @sort nvarchar(100) = 'Id',      
 @order nvarchar(100) = 'ASC',      
 @offset nvarchar(100) = '0',      
 @limit nvarchar(100) = '10'      
)       
AS      
BEGIN      
 DECLARE @sql nvarchar(max);        
 SET @sql = 'SELECT ';      
 SET @sort = 't0.'+@sort;      
      
 IF (@IsTotal <> 0)      
 BEGIN      
  SET @sql += 'count(*) total'      
 END       
 ELSE      
 BEGIN      
  SET @sql += ' t0.Id ,
  t0.IdBlAwb      
      ,t0.IdCl      
      ,t0.Number      
      ,t0.MasterBlDate      
      ,t0.HouseBlNumber      
      ,t0.HouseBlDate      
      ,t0.Description      
      ,t0.FileName      
      ,t0.Publisher          
      ,t0.CreateDate    
   ,t0.CreateBy 
   ,t0.Status
   ,t0.IsDelete'            
 END      
 SET @sql +=' FROM BlAwb_History t0       
  WHERE  t0.IsDelete = 0 AND t0.IdCl = '+@IdCargo;      
IF @isTotal = 0 
	BEGIN
		SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	END 
 --print(@sql)
 EXECUTE(@sql); 
 
 --select @sql;      
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_get_blawb_list_idcl]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
ALTER PROCEDURE [dbo].[sp_get_blawb_list_idcl]   
(  
 @IdCargo NVARCHAR(10),  
 @IsTotal bit = 0,  
 @sort nvarchar(100) = 'Id',  
 @order nvarchar(100) = 'ASC',  
 @offset nvarchar(100) = '0',  
 @limit nvarchar(100) = '10'  
)   
AS  
BEGIN  
 DECLARE @sql nvarchar(max);    
 SET @sql = 'SELECT ';  
 SET @sort = 't0.'+@sort;  
  
 IF (@IsTotal <> 0)  
 BEGIN  
  SET @sql += 'count(*) total'  
 END   
 ELSE  
 BEGIN  
  SET @sql += 't0.Id  
      ,t0.IdCl  
      ,t0.Number  
      ,t0.MasterBlDate  
      ,t0.HouseBlNumber  
      ,t0.HouseBlDate  
      ,t0.Description  
      ,t0.FileName  
      ,t0.Publisher  
      ,t0.BlAwbDate  
      ,t0.CreateDate
	  ,t0.CreateBy
	  ,t0.UpdateDate
	  ,t0.UpdateBy
	  ,t0.IsDelete'  
 END  
 SET @sql +=' FROM BlAwb t0   
  WHERE  t0.IsDelete = 0 AND t0.IdCl = '+@IdCargo;  
 EXECUTE(@sql);  
 --select @sql;  
END  
  
GO

/****** Object:  StoredProcedure [dbo].[sp_get_blawb_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_get_blawb_list] --exec [dbo].[sp_get_blawb_list] 'eko.suhartarto','' ,0         
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
 SET @sort = 'bl.'+@sort;          
          
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
           
  SET @sql += ' bl.IdCl  
       ,bl.Id   

      , bl.Number          
      , np.AjuNumber          
      , bl.MasterBlDate          
      , bl.HouseBlNumber          
      , bl.HouseBlDate           
      , bl.Publisher         
   ,ISNULL((select TOP 1(Id) from RequestForChange WHERE FormId = bl.IdCl AND FormType = ''BlAwb'' AND [Status] = 0),0) AS PendingRFC        
      , CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Employee_Name ELSE ua.FullName END PreparedBy          
      , CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Email ELSE ua.Email END Email                 
      , STUFF((SELECT '', ''+ISNULL(tx1.EdoNo, ''-'')          
       FROM dbo.CargoItem tx0          
       JOIN dbo.Cipl tx1 on tx1.id = tx0.IdCipl          
       WHERE tx0.IdCargo = tx0.Id          
       GROUP BY tx1.EdoNo          
       FOR XML PATH(''''),type).value(''.'',''nvarchar(max)''),1,1,'''') [RefEdo]          
      , c.ClNo          
      , c.CargoType          
      , CASE WHEN t0.[IdStep] = 30069 THEN ''Waiting approval draft PEB''           
    WHEN (t0.[IdStep] = 30070 AND t0.[Status] = ''Approve'') THEN ''Waiting NPE document''           
    WHEN ((t0.[IdStep] = 30070 OR t0.[IdStep] = 30072) AND t0.[Status] = ''Revise'') THEN ''Need revision review by imex''           
    WHEN t0.[IdStep] = 30071 THEN ''Waiting approval NPE''       
 WHEN t0.IdStep = 10020 THEN ''Approval''      
    ELSE CASE WHEN t11.Step = ''System'' THEN t8.ViewByUser ELSE t1.ViewByUser END END as StatusViewByUser 
	 ,'''+@role+''' as RoleName  '          
 END          
 SET @sql +='  FROM BlAwb bl          
 join NpePeb np on np.IdCl = bl.IdCl          
     JOIN dbo.Cargo c on c.Id = bl.IdCl          
     left join RequestCl t0 on t0.IdCl = bl.IdCl          
     left join (          
   select           
    nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep,           
    nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep,           
    ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,          
    nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName          
   from dbo.FlowNext nx          
   join dbo.FlowStatus ns on ns.Id = nx.IdStatus          
   join dbo.FlowStep np on np.Id = ns.IdStep          
   join dbo.Flow nf on nf.Id = np.IdFlow          
   join dbo.FlowStep nt on nt.Id = nx.IdStep          
  )as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status          
  inner join dbo.Flow t3 on t3.id = t0.IdFlow          
  left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](          
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id ) and t7.IdFlow = t1.IdFlow          
  left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](          
    t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id )          
  left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep          
  left join dbo.FlowNext t10 on t10.IdStatus = t9.Id          
  left join dbo.FlowStep t11 on t11.Id = t10.IdStep          
    JOIN PartsInformationSystem.dbo.[UserAccess] ua on ua.UserID = bl.CreateBy          
    LEFT JOIN employee t2 on t2.AD_User = bl.CreateBy          
    WHERE 1=1 AND bl.IsDelete = 0  AND c.CargoType != ''''' + @WhereSql+ ' AND (bl.Number like ''%'+@Search+'%'' OR bl.HouseBlNumber like ''%'+@Search+'%'')  
  And bl.id = (SELECT top 1 (id)  FROM  BlAwb  where idcl = c.id)';          
          
 IF @isTotal = 0           
 BEGIN          
  SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';          
 END           
          
 Print(@sql);          
 EXECUTE(@sql);          
 END          
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

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_document_list_byid]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_get_cargo_document_list_byid]   
(  
 @Id NVARCHAR(10),  
 @IsTotal bit = 0,  
 @sort nvarchar(100) = 'Id',  
 @order nvarchar(100) = 'ASC',  
 @offset nvarchar(100) = '0',  
 @limit nvarchar(100) = '10'  
)   
AS  
BEGIN  
 DECLARE @sql nvarchar(max);    
 SET @sql = 'SELECT ';  
 SET @sort = 't0.'+@sort;  
  
 IF (@IsTotal <> 0)  
 BEGIN  
  SET @sql += 'count(*) total'  
 END   
 ELSE  
 BEGIN  
  SET @sql += 't0.Id  
      , t0.IdCargo  
      , t0.DocumentDate  
      , t0.DocumentName  
      , t0.[Filename]  
      , '''' as CreateBy  
      , t0.CreateDate  
      , t0.UpdateBy  
      , t0.UpdateDate  
      , t0.IsDelete '  
 END  
 SET @sql +=' FROM CargoDocument t0     
 WHERE  IsDelete = 0 AND t0.Id = '+@Id;  
 EXECUTE(@sql);  
   
END  

GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_document_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
ALTER PROCEDURE [dbo].[sp_get_cargo_document_list]   
(  
 @IdCargo NVARCHAR(10),  
 @IsTotal bit = 0,  
 @sort nvarchar(100) = 'Id',  
 @order nvarchar(100) = 'ASC',  
 @offset nvarchar(100) = '0',  
 @limit nvarchar(100) = '10'  
)   
AS  
BEGIN  
 DECLARE @sql nvarchar(max);    
 SET @sql = 'SELECT ';  
 SET @sort = 't0.'+@sort;  
  
 IF (@IsTotal <> 0)  
 BEGIN  
  SET @sql += 'count(*) total'  
 END   
 ELSE  
 BEGIN  
  SET @sql += 't0.Id  
      , t0.IdCargo  
      , t0.DocumentDate  
      , t0.DocumentName  
      , t0.[Filename]  
      , t0.CreateBy  
      , t0.CreateDate  
      , t0.UpdateBy  
      , t0.UpdateDate  
      , t0.IsDelete  
      , '''' as PIC '  
 END  
 SET @sql +=' FROM CargoDocument t0   
  WHERE  IsDelete = 0 AND t0.IdCargo = '+@IdCargo;  
 EXECUTE(@sql);  
 --select @sql;  
END  

GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_data_20210721]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[sp_get_cargo_item_data]
ALTER PROCEDURE [dbo].[sp_get_cargo_item_data_20210721] -- [dbo].[sp_get_cargo_item_data] 1
(
	@Id nvarchar(100) = ''
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @sql nvarchar(max);  

	SET @sql = 'SELECT TOP 1 ';
	BEGIN
		SET @sql += 't0.Id ID    
					,t1.Id IdCargoItem
					,t2.Id IdCargo
					,t0.IdCipl      
					,t0.IdCiplItem           
					,t3.CiplNo                 
					,t2.Incoterms IncoTerm                 
					,t2.Incoterms IncoTermNumber                 
					,t1.CaseNumber                 
					,t3.EdoNo                 
					,t4.DaNo InboundDa                 
					,t0.Length                 
					,t0.Width                 
					,t0.Height                
					,t0.Net NetWeight                 
					,t1.Sn        
					,t1.PartNumber        
					,t1.Ccr        
					,t1.Quantity        
					,t1.Name ItemName        
					,t1.JCode        
					,t1.ReferenceNo              
					,t0.Gross GrossWeight                 
					,CAST(1 as bit) state        
					,t2.Category CargoDescription        
					,t0.ContainerNumber
					,t5.Description ContainerType
					,t0.ContainerSealNumber'
		END
			SET @sql +='
					FROM dbo.CargoItem t0
					JOIN dbo.CiplItem t1 on t1.Id = t0.IdCiplItem
					JOIN dbo.Cargo t2 on t2.Id = t0.IdCargo
					JOIN dbo.Cipl t3 on t3.id = t1.IdCipl
					LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo
					LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''
					WHERE 1=1 AND t0.Id='+@Id+' ';
	--select @sql;
	EXECUTE(@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_data_by_cargoId]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_get_cargo_item_data_by_cargoId]   
(    
 @Id nvarchar(100) = ''    
)    
AS    
BEGIN    
 SET NOCOUNT ON;    
 DECLARE @sql nvarchar(max);      
    
 SET @sql = 'SELECT ';    
 BEGIN    
  SET @sql += 'DISTINCT t0.Id ID        
     ,t1.Id IdCargoItem    
     ,t2.Id IdCargo    
     ,t0.IdCipl          
     ,t0.IdCiplItem               
     ,t3.CiplNo                     
     ,t2.Incoterms IncoTerm                     
     ,t2.Incoterms IncoTermNumber                     
     ,t1.CaseNumber                     
     ,t3.EdoNo                     
     ,t4.DaNo InboundDa                     
     ,ISNULL(t0.NewLength, t0.Length) Length                    
     ,ISNULL(t0.NewWidth,t0.Width) Width                     
     ,ISNULL(t0.NewHeight,t0.Height) Height                    
     ,ISNULL(t0.NewNet,t0.Net) NetWeight                     
     ,t1.Sn            
     ,t1.PartNumber            
     ,t1.Ccr            
     ,t1.Quantity            
     ,t1.Name ItemName            
     ,t1.JCode            
     ,t1.ReferenceNo                  
     ,ISNULL(t0.NewGross,t0.Gross) GrossWeight                     
     ,CAST(1 as bit) state            
     ,t2.Category CargoDescription            
     ,t0.ContainerNumber    
     ,t5.Description ContainerType    
     ,t0.ContainerSealNumber'    
  END    
   SET @sql +='    
     FROM dbo.CargoItem t0    
     JOIN dbo.CiplItem t1 on t1.Id = t0.IdCiplItem    
     JOIN dbo.Cargo t2 on t2.Id = t0.IdCargo    
     JOIN dbo.Cipl t3 on t3.id = t1.IdCipl    
     LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo    
     LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''    
     WHERE 1=1 AND t0.Id in ('+@Id+')';    
 print @sql;    
 EXECUTE(@sql);    
END 

GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_data]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cargo_item_data] -- [dbo].[sp_get_cargo_item_data] 1
(
	@Id nvarchar(100) = ''
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @sql nvarchar(max);  

	SET @sql = 'SELECT TOP 1 ';
	BEGIN
		SET @sql += 't0.Id ID    
					,t1.Id IdCargoItem
					,t2.Id IdCargo
					,t0.IdCipl      
					,t0.IdCiplItem           
					,t3.CiplNo                 
					,t2.Incoterms IncoTerm                 
					,t2.Incoterms IncoTermNumber                 
					,t1.CaseNumber                 
					,t3.EdoNo                 
					,t4.DaNo InboundDa                 
					,ISNULL(t0.NewLength, t0.Length) Length                
					,ISNULL(t0.NewWidth,t0.Width) Width                 
					,ISNULL(t0.NewHeight,t0.Height) Height                
					,ISNULL(t0.NewNet,t0.Net) NetWeight                 
					,t1.Sn        
					,t1.PartNumber        
					,t1.Ccr        
					,t1.Quantity        
					,t1.Name ItemName        
					,t1.JCode        
					,t1.ReferenceNo              
					,ISNULL(t0.NewGross,t0.Gross) GrossWeight                 
					,CAST(1 as bit) state        
					,t2.Category CargoDescription        
					,t0.ContainerNumber
					,t5.Description ContainerType
					,t0.ContainerSealNumber'
		END
			SET @sql +='
					FROM dbo.CargoItem t0
					JOIN dbo.CiplItem t1 on t1.Id = t0.IdCiplItem
					JOIN dbo.Cargo t2 on t2.Id = t0.IdCargo
					JOIN dbo.Cipl t3 on t3.id = t1.IdCipl
					LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo
					LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''
					WHERE 1=1 AND t0.Id='+@Id+' ';
	print @sql;
	EXECUTE(@sql);
END

GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_History_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cargo_item_History_list] -- [dbo].[sp_get_cargo_item_History_list] 41784       
(        
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
   SET @sql += 'ROW_NUMBER() OVER ( ORDER BY t0.Id ) RowNo        
      ,t0.Id Id      
   ,t0.IdCargo IdCargo      
   ,t0.IdCargoItem       
      ,t0.IdCipl       
   ,t0.IdCiplItem      
   ,t0.CreateBy      
   ,t0.CreateDate      
   ,t0.UpdateBy      
   ,t0.UpdateDate      
   ,t0.IsDelete      
   ,t0.Status      
   ,t2.Incoterms IncoTerm                         
      ,t2.Incoterms IncoTermNumber        
      ,t3.CiplNo                                           
      ,t1.CaseNumber                         
      ,t3.EdoNo                         
      ,t6.DaNo InboundDa                         
      ,ISNULL(t0.NewLength, t0.Length) Length                        
      ,ISNULL(t0.NewWidth,t0.Width) Width                         
      ,ISNULL(t0.NewHeight,t0.Height) Height                        
      ,ISNULL(t0.NewNet,t0.Net) Net                    
      ,ISNULL(t0.NewGross,t0.Gross) Gross        
      ,t0.NewLength                         
      ,t0.NewWidth                         
      ,t0.NewHeight                        
      ,t0.NewNet NewNetWeight                      
      ,t0.NewGross NewGrossWeight                       
      ,t1.Sn                
      ,t1.PartNumber                
      ,t1.Quantity                
      ,t1.Name ItemName                
      ,t1.JCode                
      ,t2.Category CargoDescription                
      ,t0.ContainerNumber        
      ,t5.Description ContainerType  
	  ,t0.ContainerType ContainerTypeId 
      ,t0.ContainerSealNumber'        
  END        
   SET @sql +='        
     FROM dbo.CargoItem_Change t0        
     JOIN dbo.CiplItem t1 on t1.Id = t0.IdCiplItem AND t1.isdelete = 0        
     JOIN dbo.Cargo t2 on t2.Id = t0.IdCargo AND t2.isdelete = 0        
     JOIN dbo.Cipl t3 on t3.id = t1.IdCipl AND t3.isdelete = 0        
    LEFT JOIN dbo.ShippingFleetRefrence t4 on t4.DoNo = t3.EdoNo      
 Left JOIN dbo.ShippingFleet t6 on t6.Id = t4.IdShippingFleet      
 -- LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo AND t4.isdelete = 0        
     LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''        
     WHERE t0.IdCargo='+@IdCargo+' ';        
 --IF @isTotal = 0         
 --BEGIN        
 -- SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';        
 --END         
 --select @sql;        
 EXEC(@sql);        
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_list_20210322]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cargo_item_list_20210322] -- [dbo].[sp_get_cargo_item_list] '', 1
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
			SET @sql += 'ROW_NUMBER() OVER ( ORDER BY t0.Id ) RowNo
						,t0.Id ID                 
						,t0.IdCipl                 
						,t3.CiplNo                 
						,t2.Incoterms IncoTerm                 
						,t2.Incoterms IncoTermNumber                 
						,t1.CaseNumber                 
						,t3.EdoNo                 
						,t4.DaNo InboundDa                 
						,t0.Length                 
						,t0.Width                 
						,t0.Height                
						,t0.Net NetWeight                 
						,t1.Sn        
						,t1.PartNumber        
						,t1.Ccr        
						,t1.Quantity        
						,t1.Name ItemName        
						,t1.JCode        
						,t1.ReferenceNo              
						,t0.Gross GrossWeight                 
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
					LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo AND t4.isdelete = 0
					LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''
					WHERE 1=1 AND t0.isdelete = 0 AND t0.IdCargo='+@IdCargo+' ';
	--IF @isTotal = 0 
	--BEGIN
	--	SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	--END 
	--select @sql;
	EXECUTE(@sql);
END


GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_list_20210721]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cargo_item_list_20210721] -- [dbo].[sp_get_cargo_item_list] '', 1
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
			SET @sql += 'ROW_NUMBER() OVER ( ORDER BY t0.Id ) RowNo
						,t0.Id ID                 
						,t0.IdCipl                 
						,t3.CiplNo                 
						,t2.Incoterms IncoTerm                 
						,t2.Incoterms IncoTermNumber                 
						,t1.CaseNumber                 
						,t3.EdoNo                 
						,t4.DaNo InboundDa                 
						,t0.Length                 
						,t0.Width                 
						,t0.Height                
						,t0.Net NetWeight                 
						,t1.Sn        
						,t1.PartNumber        
						,t1.Ccr        
						,t1.Quantity        
						,t1.Name ItemName        
						,t1.JCode        
						,t1.ReferenceNo              
						,t0.Gross GrossWeight                 
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
					LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo AND t4.isdelete = 0
					LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''
					WHERE 1=1 AND t0.isdelete = 0 AND t0.IdCargo='+@IdCargo+' ';
	--IF @isTotal = 0 
	--BEGIN
	--	SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	--END 
	--select @sql;
	EXEC(@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_list_approval]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cargo_item_list_approval] -- [dbo].[sp_get_cargo_item_list] '', 1
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
			SET @sql += 'ROW_NUMBER() OVER ( ORDER BY t0.Id ) RowNo
						,t0.Id ID                 
						,t0.IdCipl                 
						,t3.CiplNo                 
						,t2.Incoterms IncoTerm                 
						,t2.Incoterms IncoTermNumber                 
						,t1.CaseNumber                 
						,t3.EdoNo                 
						,t4.DaNo InboundDa                 
						,t0.Length                 
						,t0.Width                 
						,t0.Height                
						,t0.Net NetWeight              
						,t0.Gross GrossWeight                 
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
					LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo AND t4.isdelete = 0
					LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''
					WHERE 1=1 AND t0.isdelete = 0 AND t0.IdCargo='+@IdCargo+' ';
	--IF @isTotal = 0 
	--BEGIN
	--	SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	--END 
	--select @sql;
	EXEC(@sql);
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

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[sp_get_cargo_list] -- [dbo].[sp_get_cargo_list] '', 0
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

/****** Object:  StoredProcedure [dbo].[sp_get_cipl_area_available_20210324]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- drop procedure sp_get_cipl_available_by_area
-- exec [sp_get_cipl_area_available]
ALTER PROCEDURE [dbo].[sp_get_cipl_area_available_20210324] -- sp_get_cipl_available_by_area
AS
BEGIN
       SELECT 
              DISTINCT BAreaCode, BAreaName
       FROM dbo.Cipl t0 
       JOIN dbo.fn_get_cipl_request_list_all() t1 on t1.IdCipl = t0.id
       JOIN dbo.MasterArea t2 on RIGHT(t2.BAreaCode, 3) = RIGHT(t0.PickUpArea,3)
       WHERE 
       t0.id not in (select IdCipl from dbo.GoodsReceiveItem) 
       AND t1.IdNextStep IN (14, 10024, 10028, 30057);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_cipl_area_available]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cipl_area_available] -- sp_get_cipl_available_by_area
AS
BEGIN
       SELECT 
              DISTINCT BAreaCode, BAreaName
       FROM dbo.Cipl t0 
       JOIN dbo.fn_get_cipl_request_list_all() t1 on t1.IdCipl = t0.id
       JOIN dbo.MasterArea t2 on RIGHT(t2.BAreaCode, 3) = RIGHT(t0.PickUpArea,3)
       WHERE 
       t0.id not in (select IdCipl from dbo.GoodsReceiveItem WHERE Isdelete = 0) 
       AND t1.IdNextStep IN (14, 10024, 10028, 30057);
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

/****** Object:  StoredProcedure [dbo].[sp_get_cipl_businessarea_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[sp_get_task_cl]
ALTER PROCEDURE [dbo].[sp_get_cipl_businessarea_list] -- [dbo].[sp_get_task_cl] 'CKB1'
(
	@PlantCode nvarchar(50) = ''
)
AS
BEGIN
    select * from fn_get_cipl_businessarea_list('') where PlantName like '%'+ISNULL(@PlantCode, '')+'%' OR PlantCode like '%'+ISNULL(@PlantCode, '')+'%'
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_cipl_document_list_byid]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cipl_document_list_byid] --[dbo].[sp_get_document_list] 1, 'cipl'
(
	@Id NVARCHAR(10),
	@IsTotal bit = 0,
	@sort nvarchar(100) = 'Id',
	@order nvarchar(100) = 'ASC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)	
AS
BEGIN
	DECLARE @sql nvarchar(max);  
	SET @sql = 'SELECT ';
	SET @sort = 't0.'+@sort;

	IF (@IsTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total'
	END 
	ELSE
	BEGIN
		SET @sql += 't0.ID
					 , t0.IdCipl
					 , t0.DocumentDate
					 , t0.DocumentName
					 , t0.[Filename]
					 , t2.Employee_Name AS CreateBy
					 , t0.CreateDate
					 , t0.UpdateBy
					 , t0.UpdateDate
					 , t0.IsDelete '
	END
	SET @sql +=' FROM CiplDocument t0 
	JOIN employee t2 on t2.AD_User = t0.CreateBy   
	WHERE  IsDelete = 0 AND t0.Id = '+@Id;
	EXECUTE(@sql);
	--select @sql;
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_cipl_document_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cipl_document_list] --[dbo].[sp_get_document_list] 1, 'cipl'
(
	@IdCipl NVARCHAR(10),
	@IsTotal bit = 0,
	@sort nvarchar(100) = 'Id',
	@order nvarchar(100) = 'ASC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)	
AS
BEGIN
	DECLARE @sql nvarchar(max);  
	SET @sql = 'SELECT ';
	SET @sort = 't0.'+@sort;

	IF (@IsTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total'
	END 
	ELSE
	BEGIN
		SET @sql += 't0.ID
					 , t0.IdCipl
					 , t0.DocumentDate
					 , t0.DocumentName
					 , t0.[Filename]
					 , t0.CreateBy
					 , t0.CreateDate
					 , t0.UpdateBy
					 , t0.UpdateDate
					 , t2.Employee_Name as PIC '
	END
	SET @sql +=' FROM CiplDocument t0 
	JOIN employee t2 on t2.AD_User = t0.CreateBy   
	WHERE  IsDelete = 0 AND t0.IdCipl = '+@IdCipl;
	EXECUTE(@sql);
	--select @sql;
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

/****** Object:  StoredProcedure [dbo].[sp_get_cipl_pic_available]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_cipl_pic_available] -- exec [sp_get_cipl_pic_available] '1s80'
(
       @BAreaCode nvarchar(10)
)
AS
BEGIN
       SELECT DISTINCT 
              t0.PickUpPic
              , t0.PickUpArea
              , t3.BAreaName
              , t2.Employee_Name EmployeeName
       FROM dbo.Cipl t0 
       JOIN dbo.fn_get_cipl_request_list_all() t1 on t1.IdCipl = t0.id
       JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.PickUpPic
       JOIN dbo.MasterArea t3 on RIGHT(t3.BAreaCode,3) = RIGHT(t0.PickUpArea,3)
       WHERE 
       t0.id not in 
		(
			select gi.IdCipl 
			from dbo.GoodsReceiveItem gi
			join RequestGr rg ON gi.idgr = rg.idgr
			where gi.isdelete = 0 AND rg.[status] != 'Reject'
		) 
       AND t1.IdNextStep IN (14, 10024, 10028, 30057)
       AND RIGHT(t0.PickUpArea,3) = RIGHT(@BAreaCode,3);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_consignee_name_20210322]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [sp_get_consignee_name] '0002240001,0002240004,0002240006', 'PP', 'ReferenceNo'
ALTER PROCEDURE [dbo].[sp_get_consignee_name_20210322]
	(
	@ReferenceNo NVARCHAR(100) = ''
	,@Category NVARCHAR(100) = ''
	,@CategoryReference NVARCHAR(100) = ''
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(max);

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

/****** Object:  StoredProcedure [dbo].[sp_get_document_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_document_list] --[dbo].[sp_get_document_list] 1, 'cipl'
(
	@id NVARCHAR(10),
	@category nvarchar(100) = 'CIPL',
	@IsTotal bit = 0,
	@sort nvarchar(100) = 'Id',
	@order nvarchar(100) = 'ASC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)	
AS
BEGIN
	DECLARE @sql nvarchar(max);  
	SET @sql = 'SELECT ';
	SET @sort = 't0.'+@sort;

	IF (@IsTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total'
	END 
	ELSE
	BEGIN
		SET @sql += 't0.ID
					 , t0.Step
					 , t0.[Status]
					 , t0.[Name]
					 , t0.IdRequest
					 , t0.Category
					 , t0.[Date]
					 , t0.[FileName]
					 , t0.CreateBy
					 , t0.CreateDate
					 , t0.UpdateBy
					 , t0.UpdateDate
					 , t2.Employee_Name as PIC '
	END
	SET @sql +=' FROM Documents t0 
	JOIN employee t2 on t2.AD_User = t0.CreateBy   
	WHERE  t0.Category= '''+@category+''' and t0.IDRequest = '+@id;
	EXECUTE(@sql);
	--select @sql;
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

/****** Object:  StoredProcedure [dbo].[sp_get_edi_gritem_edit]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCedure [dbo].[sp_get_edi_gritem_edit] -- exec [dbo].[sp_get_edi_gritem_edit]  '1F18', 1
(
	@area nvarchar(100),
	@idGr nvarchar(100)
)
AS
select * from dbo.Cipl t0
left join dbo.RequestCipl t1 on t1.IdCipl = t0.id AND t1.IsDelete = 0 
left join dbo.fn_get_cipl_request_list_all() t2 on t2.IdCipl = t0.id
where 
t2.IdNextStep IN (14, 10024, 10028) 
AND t0.Area = @area 
AND t1.[Status] = 'Approve' 
AND EdoNo IS NOT NULL AND (t0.Id NOT IN (
	select IdCipl from dbo.GoodsReceiveItem WHERE IsDelete = 0
) OR t0.Id IN (
	select IdCipl from dbo.GoodsReceiveItem WHERE IdGr = @idGr
))
GO

/****** Object:  StoredProcedure [dbo].[sp_get_flow_next]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[sp_get_flow_next]
ALTER PROCEDURE [dbo].[sp_get_flow_next] -- [dbo].[sp_get_flow_next] 0, 5, 'Id', 'ASC', '1',  '', 0
        -- Add the parameters for the stored procedure here
         @page int = 1,
         @limit int = 5,
         @sort nvarchar(100) = 'Id',
         @order nvarchar(100) = 'DESC',
		 @IdStatus nvarchar(10),
         @term nvarchar(100) = '', 
         @isTotal bit = 0
AS
BEGIN
        SET NOCOUNT ON;
        DECLARE @sql nvarchar(max);
		DECLARE @offset int;
		SET @offset = @page;
		--if @page > 0 
		--BEGIN 
		--	SET @offset = ((@page - 1) * @limit);
		--END

        SET @sql = CASE 
					WHEN @isTotal = 1 
						THEN 'SELECT COUNT(*) as total' 
					ELSE 'SELECT t0.*, t3.Step CurrentStep, t1.Status CurrentStatus, t2.Step NextStep, t2.Id NextIdStep, t1.IdStep CurrentIdStep' 
					END + ' from dbo.FlowNext t0 
							join dbo.FlowStatus t1 on t1.Id = t0.IdStatus
							join dbo.FlowStep t2 on t2.Id = t0.IdStep
							join dbo.FlowStep t3 on t3.Id = t1.IdStep
							WHERE t0.IdStatus= '+@IdStatus+''+
                    CASE WHEN ISNULL(@term, '') <> '' THEN ' AND (t3.Step like ''%'+@term+'%'' OR t1.Status like ''%'+@term+'%'') ' ELSE '' END +
                    CASE WHEN @isTotal = 0 THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+CAST(@offset as nvarchar(100))+' ROWS FETCH NEXT '+CAST(@limit as nvarchar(100))+' ROWS ONLY' ELSE '' END;
        --select @sql;
		execute(@sql);
		
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_flow_status]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[sp_get_flow_status]
ALTER PROCEDURE [dbo].[sp_get_flow_status] -- [dbo].[sp_get_flow_status] 0, 5, 'Id', 'ASC', '1',  '', 0
         @page int = 1,
         @limit int = 5,
         @sort nvarchar(100) = 'Id',
         @order nvarchar(100) = 'DESC',
		 @IdStep nvarchar(10),
         @term nvarchar(100) = '', 
         @isTotal bit = 0
AS
BEGIN
        SET NOCOUNT ON;
        DECLARE @sql nvarchar(max);
		DECLARE @offset int;
		SET @offset = @page;
		--if @page > 0 
		--BEGIN 
		--	SET @offset = ((@page - 1) * @limit);
		--END

        SET @sql = CASE 
					WHEN @isTotal = 1 
						THEN 'SELECT COUNT(*) as total ' 
					ELSE 'SELECT t0.*, t1.IdFlow, t1.Step StepName, t1.AssignType, t1.AssignTo, t2.Name FlowName ' END 
					+ 'FROM dbo.FlowStatus t0
					   JOIN dbo.FlowStep t1 on t1.Id = t0.IdStep
					   JOIN dbo.flow t2 on t2.Id = t1.IdFlow
					   WHERE t0.IdStep= '+@IdStep+' '+
                    CASE WHEN ISNULL(@term, '') <> '' THEN ' AND (t0.Status like ''%'+@term+'%'') ' ELSE '' END +
                    CASE WHEN @isTotal = 0 THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+CAST(@offset as nvarchar(100))+' ROWS FETCH NEXT '+CAST(@limit as nvarchar(100))+' ROWS ONLY' ELSE '' END;
        --select @sql;
		execute(@sql);
		
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_flow_step]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[sp_get_flow_step]
ALTER PROCEDURE [dbo].[sp_get_flow_step] -- [dbo].[sp_get_flow_step] 0, 5, 'Id', 'ASC', '1',  '', 0
        -- Add the parameters for the stored procedure here
         @page int = 1,
         @limit int = 5,
         @sort nvarchar(100) = 'Id',
         @order nvarchar(100) = 'DESC',
		 @IdFlow nvarchar(10),
         @term nvarchar(100) = '', 
         @isTotal bit = 0
AS
BEGIN
        SET NOCOUNT ON;
        DECLARE @sql nvarchar(max);
		DECLARE @offset int;
		SET @offset = @page;
		--if @page > 0 
		--BEGIN 
		--	SET @offset = ((@page - 1) * @limit);
		--END

        SET @sql = CASE 
					WHEN @isTotal = 1 
						THEN 'SELECT COUNT(*) as total' 
					ELSE 'SELECT 
								t0.Id
								, t0.IdFlow
								, t0.Step StepName
								, t0.AssignType
								, t0.AssignTo
								, t0.Sort
								, t1.Name FlowName
								, t1.Type FlowType' 
					END + ' FROM [dbo].[FlowStep] as t0 
							INNER JOIN [dbo].[Flow] as t1 on t1.Id = t0.IdFlow
							WHERE t0.IdFlow= '+@IdFlow+' '+
                    CASE WHEN ISNULL(@term, '') <> '' THEN ' AND (t0.Name like ''%'+@term+'%'') ' ELSE '' END +
                    CASE WHEN @isTotal = 0 THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+CAST(@offset as nvarchar(100))+' ROWS FETCH NEXT '+CAST(@limit as nvarchar(100))+' ROWS ONLY' ELSE '' END;
        --select @sql;
		execute(@sql);
		
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_flow]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [dbo].[sp_get_flow]
ALTER PROCEDURE [dbo].[sp_get_flow] -- [dbo].[sp_get_flow] 0, 5, 'Id', 'ASC', '', 0
        -- Add the parameters for the stored procedure here
         @page int = 1,
         @limit int = 5,
         @sort nvarchar(100) = 'Id',
         @order nvarchar(100) = 'DESC',
         @term nvarchar(100) = '', 
         @isTotal bit = 0
AS
BEGIN
        SET NOCOUNT ON;
        DECLARE @sql nvarchar(max);
		DECLARE @offset int;
		SET @offset = @page;
		--if @page > 1 
		--BEGIN 
		--	SET @offset = ((@page - 1) * @limit);
		--END

        SET @sql = CASE 
					WHEN @isTotal = 1 
						THEN 'SELECT COUNT(*) as total' 
					ELSE 'SELECT CAST(Id as bigint) Id, Name, Type, CreateBy, CreateDate, UpdateBy, UpdateDate, IsDelete' 
					END + ' FROM [dbo].[Flow] as t0 WHERE 1=1 '+
                    CASE WHEN ISNULL(@term, '') <> '' THEN ' AND (t0.Name like ''%'+@term+'%'') ' ELSE '' END +
                    CASE WHEN @isTotal = 0 THEN ' ORDER BY '+@sort+' '+@order+' OFFSET '+CAST(@offset as nvarchar(100))+' ROWS FETCH NEXT '+CAST(@limit as nvarchar(100))+' ROWS ONLY' ELSE '' END;
        --select @sql;
		execute(@sql);
		
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_gr_data]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_get_gr_data] -- [dbo].[sp_get_gr_data] 36
(
	@Id bigint
)
AS
BEGIN
    SET NOCOUNT ON;
	--DECLARE @Id nvarchar(100);
	--SET @Id = 1;
	SELECT 
		t0.Id
		,t0.GrNo
		,t0.PicName
		,t0.PhoneNumber
		,t0.KtpNumber
		,t0.SimNumber
		,t0.StnkNumber
		,t0.NopolNumber
		,t0.EstimationTimePickup
		,t0.Vendor
		,t0.KirNumber
		,t0.KirExpire
		,t0.Apar
		,t0.Apd
		,t0.Notes
		,t0.VehicleType
		,t0.VehicleMerk
		,t0.CreateBy
		,t0.CreateDate
		,t0.UpdateBy
		,t0.UpdateDate
		,t0.IsDelete
		,t0.SimExpiryDate
		,t0.ActualTimePickup
		,t2.Step
		,t3.[Status]
		,t4.[Address] VendorAddress
		,t4.City VendorCity
		,t4.[Name] VendorName
		,t4.Telephone VendorTelephone
		,t4.[Code] VendorCode
		,t0.PickupPoint
		,t0.PickupPic
		,t7.Employee_Name PickupPicName
		,t5.BAreaName PlantName
		,t5.BAreaCode PlantCode
		,t6.Employee_Name as RequestorName
		,t6.Email as RequestorEmail
		,CAST((	
			(SELECT SUM(TotalVolume) FROM dbo.fn_get_total_cipl_all() 
					WHERE Idcipl IN (SELECT IdCipl FROM dbo.GoodsReceiveItem where IdGr = t0.Id))
		  ) as nvarchar(max)) TotalVolume
		, t8.Employee_Name RequestorName
		, t8.Email RequestorEmail
		,CAST((	
			FORMAT((SELECT SUM(TotalNetWeight) FROM dbo.fn_get_total_cipl_all() 
					WHERE Idcipl IN (SELECT IdCipl FROM dbo.GoodsReceiveItem where IdGr = t0.Id)), '#,0.00')
		 ) as nvarchar(max)) TotalNetWeight
		,CAST((	
			FORMAT((SELECT SUM(TotalGrossWeight) FROM dbo.fn_get_total_cipl_all() 
			WHERE Idcipl IN (SELECT IdCipl FROM dbo.GoodsReceiveItem where IdGr = t0.Id)), '#,0.00')
		  ) as nvarchar(max)) TotalGrossWeight
		,CAST((	
			FORMAT((SELECT SUM(TotalPackage) FROM dbo.fn_get_total_cipl_all() 
			WHERE Idcipl IN (SELECT IdCipl FROM dbo.GoodsReceiveItem where IdGr = t0.Id)), '#,0.00')
		  ) as nvarchar(max)) TotalPackages
		  , IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
	FROM dbo.GoodsReceive as t0
	INNER JOIN dbo.RequestGr as t1 on t1.IdGr = t0.Id
	INNER JOIN dbo.FlowStep as t2 on t2.Id = t1.IdStep
	LEFT JOIN dbo.FlowStatus as t3 on t3.IdStep = t1.IdStep AND t3.Status = t1.Status
	LEFT JOIN dbo.MasterVendor as t4 on t4.Code = t0.Vendor 
	LEFT JOIN dbo.MasterArea as t5 on t5.BAreaCode = t0.PickupPoint
	LEFT join dbo.fn_get_employee_internal_ckb() t6 on t0.CreateBy = t6.AD_User
	LEFT JOIN dbo.fn_get_employee_internal_ckb() t7 on t7.AD_User = t0.PickupPic 
	LEFT JOIN dbo.fn_get_employee_internal_ckb() t8 on t8.AD_User = t0.CreateBy
	left join fn_get_employee_internal_ckb() s on t0.UpdateBy= s.AD_User
    WHERE 1=1 AND t0.id = @Id
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_gr_document_list_byid]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_get_gr_document_list_byid]   
(  
 @Id NVARCHAR(10),  
 @IsTotal bit = 0,  
 @sort nvarchar(100) = 'Id',  
 @order nvarchar(100) = 'ASC',  
 @offset nvarchar(100) = '0',  
 @limit nvarchar(100) = '10'  
)   
AS  
BEGIN  
 DECLARE @sql nvarchar(max);    
 SET @sql = 'SELECT ';  
 SET @sort = 't0.'+@sort;  
  
 IF (@IsTotal <> 0)  
 BEGIN  
  SET @sql += 'count(*) total'  
 END   
 ELSE  
 BEGIN  
  SET @sql += 't0.Id  
      , t0.IdGr  
      , t0.DocumentDate  
      , t0.DocumentName  
      , t0.[Filename]  
      , '''' AS CreateBy  
      , t0.CreateDate  
      , t0.UpdateBy  
      , t0.UpdateDate  
      , t0.IsDelete '  
 END  
 SET @sql +=' FROM GoodsReceiveDocument t0    
 WHERE  IsDelete = 0 AND t0.Id = '+@Id;  
 EXECUTE(@sql);  
   
END  

GO

/****** Object:  StoredProcedure [dbo].[sp_get_gr_document_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_gr_document_list]   
(  
 @IdGr NVARCHAR(10),  
 @IsTotal bit = 0,  
 @sort nvarchar(100) = 'Id',  
 @order nvarchar(100) = 'ASC',  
 @offset nvarchar(100) = '0',  
 @limit nvarchar(100) = '10'  
)   
AS  
BEGIN  
 DECLARE @sql nvarchar(max);    
 SET @sql = 'SELECT ';  
 SET @sort = 't0.'+@sort;  
  
 IF (@IsTotal <> 0)  
 BEGIN  
  SET @sql += 'count(*) total'  
 END   
 ELSE  
 BEGIN  
  SET @sql += 't0.Id  
      , t0.IdGr  
      , t0.DocumentDate  
      , t0.DocumentName  
      , t0.[Filename]  
      , t0.CreateBy  
      , t0.CreateDate  
      , t0.UpdateBy  
      , t0.UpdateDate  
      , t0.IsDelete  
      , '''' as PIC '  
 END  
 SET @sql +=' FROM GoodsReceiveDocument t0     
 WHERE  IsDelete = 0 AND t0.IdGr = '+@IdGr;  
 EXECUTE(@sql);  
 
END  

GO

/****** Object:  StoredProcedure [dbo].[sp_get_gr_item_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_get_gr_item_list 2
ALTER procedure [dbo].[sp_get_gr_item_list]( -- exec sp_get_gr_item_list 2
	@IdGr bigint
)
as
begin
	select
		t1.CiplNo, 
		t1.EdoNo, 
		t1.DaNo,
		t1.Category,
		t0.Sn, 
		t0.Name,
		t0.PartNumber,
		t0.CaseNumber, 
		t0.Uom, 
		t0.CoO, 
		t0.Currency, 
		t0.JCode,
		t0.[Type],
		t0.YearMade,
		t0.ExtendedValue,
		t0.UnitPrice,
		t0.Quantity,
		t0.[Length],
		t0.Width,
		t0.Height,
		t0.GrossWeight,
		t0.NetWeight,
		t0.Volume
	from dbo.CiplItem t0
	inner join (
		select 
			tx0.DaNo
			, tx0.IdGr
			, tx0.DoNo
			, tx0.[FileName]
			, tx1.id IdCipl
			, tx1.Da
			, tx1.EdoNo
			, tx1.Category
			, tx1.CiplNo
			, tx1.DestinationPort
			, tx1.LoadingPort 
		From dbo.GoodsReceiveItem tx0
		left join dbo.Cipl tx1 on tx1.id = tx0.IdCipl where tx0.IdGr = @IdGr) t1 on t1.IdCipl = t0.IdCipl and t0.IsDelete = 0
end
GO

/****** Object:  StoredProcedure [dbo].[sp_get_gr_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_gr_list] -- [dbo].[sp_get_gr_list] 'XUPJ21WDN', '', 0            
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

/****** Object:  StoredProcedure [dbo].[sp_get_list_next]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_list_next] (
	@IDStep bigint,
	@IDStatus bigint
)
as 
BEGIN
	select 
		t0.Id, t0.IdStep, t0.IdStatus, t4.Name FlowName, t4.Type FlowType, t3.Step CurrentStep, t2.Status CurrentStatus, t1.Step NextStepName, 
		t2.ViewByUser, t1.AssignType, t1.AssignTo,
		t0.CreateBy, t0.CreateDate, t0.UpdateBy, t0.UpdateDate, t0.IsDelete
	from dbo.FlowNext t0
	join dbo.FlowStep t1 on t1.Id = t0.IdStep
	join dbo.FlowStatus t2 on t2.Id = t0.IdStatus
	join dbo.FlowStep t3 on t3.Id = t2.IdStep
	join dbo.Flow t4 on t4.Id = t3.IdFlow 
	where t0.IdStep = @IDStep AND t0.IdStatus = @IDStatus;
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_list_step]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_list_step] (
	@IDStep bigint,
	@IDStatus bigint
)
as 
BEGIN
	select 
		t0.Id, t0.IdStep, t0.IdStatus, t4.Name FlowName, t4.Type FlowType, t3.Step CurrentStep, t2.Status CurrentStatus, t1.Step NextStepName, 
		t2.ViewByUser, t1.AssignType, t1.AssignTo,
		t0.CreateBy, t0.CreateDate, t0.UpdateBy, t0.UpdateDate, t0.IsDelete
	from dbo.FlowNext t0
	join dbo.FlowStep t1 on t1.Id = t0.IdStep
	join dbo.FlowStatus t2 on t2.Id = t0.IdStatus
	join dbo.FlowStep t3 on t3.Id = t2.IdStep
	join dbo.Flow t4 on t4.Id = t3.IdFlow 
	where t0.IdStep = @IDStep AND t0.IdStatus = @IDStatus;
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_next_step]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_next_step] (
	@IDStep bigint,
	@IDStatus bigint
)
as 
BEGIN
	select 
		t0.Id, t0.IdStep, t0.IdStatus, t4.Name FlowName, t4.Type FlowType, t3.Step CurrentStep, t2.Status CurrentStatus, t1.Step NextStepName, 
		t2.ViewByUser, t1.AssignType, t1.AssignTo,
		t0.CreateBy, t0.CreateDate, t0.UpdateBy, t0.UpdateDate, t0.IsDelete
	from dbo.FlowNext t0
	join dbo.FlowStep t1 on t1.Id = t0.IdStep
	join dbo.FlowStatus t2 on t2.Id = t0.IdStatus
	join dbo.FlowStep t3 on t3.Id = t2.IdStep
	join dbo.Flow t4 on t4.Id = t3.IdFlow 
	where t0.IdStep = @IDStep AND t0.IdStatus = @IDStatus;
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

/****** Object:  StoredProcedure [dbo].[sp_get_npepeb_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER  PROCEDURE [dbo].[sp_get_npepeb_list] --exec [sp_get_npepeb_list] 'xupj21wdn',''            
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
 SET @sort = 'np.'+@sort;            
            
 select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;            
            
            
 SELECT @area = U.Business_Area            
  ,@role = U.[Role]            
 FROM dbo.fn_get_employee_internal_ckb() U            
 WHERE U.AD_User = @Username;            
            
 if @role !=''            
 BEGIN            
            
            
 IF (@role !='EMCS IMEX' and @Username !='ict.bpm')            
 BEGIN            
  SET @WhereSql = ' AND np.CreateBy='''+@Username+''' ';            
 END            
            
 SET @sql = 'SELECT ';            
 IF (@isTotal <> 0)            
 BEGIN            
  SET @sql += 'count(*) total '            
 END             
 ELSE            
 BEGIN            
             
  SET @sql += '   np.Id            
      , np.IdCl            
      , np.AjuNumber            
      , np.AjuDate            
      , np.PebNumber            
      , np.NpeNumber             
      , np.NpeDate            
      , np.PassPabeanOffice            
      , np.Valuta        
   ,np.RegistrationNumber        
   ,ISNULL((select TOP 1(Id) from RequestForChange WHERE FormId = np.IdCl AND FormType = ''NpePeb'' AND [Status] = 0),0) AS PendingRFC          
      , CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Employee_Name ELSE ua.FullName END PreparedBy            
      , CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Email ELSE ua.Email END Email                   
      , STUFF((SELECT '', ''+ISNULL(tx1.EdoNo, ''-'')              
           FROM dbo.CargoItem tx0              
           JOIN dbo.Cipl tx1 on tx1.id = tx0.IdCipl              
           WHERE tx0.IdCargo = tx0.Id              
           GROUP BY tx1.EdoNo              
           FOR XML PATH(''''),type).value(''.'',''nvarchar(max)''),1,1,'''') [RefEdo]               
      , c.ClNo            
      , c.CargoType            
      , CASE WHEN t0.[IdStep] = 30069 THEN ''Waiting approval draft PEB''             
    WHEN (t0.[IdStep] = 30070 AND t0.[Status] = ''Approve'') THEN ''Waiting NPE document''             
    WHEN ((t0.[IdStep] = 30070 OR t0.[IdStep] = 30072) AND t0.[Status] = ''Revise'') THEN ''Need revision review by imex''        
 when np.IsCancelled = 0 then ''Request Cancel Only PebNpe''      
 when np.IsCancelled = 1 then ''waiting for beacukai approval''      
 when np.IsCancelled = 2 then ''Cancelled''      
 WHEN t0.IdStep= 30076 THEN ''Cancelled''      
 WHEN t0.IdStep= 30075 THEN ''waiting for beacukai approval''      
 WHEN t0.IdStep= 30074 THEN ''Request Cancel''       
    WHEN t0.[IdStep] = 30071 THEN ''Waiting approval NPE''    
 WHEN (t0.[IdStep] = 10021 OR t0.IdStep = 30063) THEN ''Approve''    
 --WHEN t0.[IdStep] = 10022 THEN ''Submit''    
    ELSE CASE WHEN t4.Step = ''System'' THEN t5.ViewByUser ELSE t5.ViewByUser END END as StatusViewByUser  '            
 END            
 SET @sql +='  FROM NpePeb np            
      JOIN dbo.Cargo c on c.Id = np.IdCl            
  --   left join RequestCl t0 on t0.IdCl = np.IdCl            
  --   left join (            
  -- select             
  --  nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep,             
  --  nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep,             
  --  ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,            
  --  nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName            
  -- from dbo.FlowNext nx            
  -- join dbo.FlowStatus ns on ns.Id = nx.IdStatus            
  -- join dbo.FlowStep np on np.Id = ns.IdStep            
  -- join dbo.Flow nf on nf.Id = np.IdFlow            
  -- join dbo.FlowStep nt on nt.Id = nx.IdStep            
  --) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status            
  --inner join dbo.Flow t3 on t3.id = t0.IdFlow            
  --left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](            
  --  t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id            
  --   ) and t7.IdFlow = t1.IdFlow            
  --left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](            
  --  t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id            
  --   )            
    join dbo.RequestCl t0 on t0.IdCl = c.Id  
    JOIN dbo.FlowStep t4 on t4.Id = t0.IdStep    
    JOIN dbo.FlowStatus t5 on t5.[Status] = t0.[Status] AND t5.IdStep = t0.IdStep            
    JOIN PartsInformationSystem.dbo.[UserAccess] ua on ua.UserID = np.CreateBy            
    LEFT JOIN employee t2 on t2.AD_User = np.CreateBy            
    WHERE 1=1 AND np.IsDelete = 0 and c.IsDelete = 0 and t0.Status <> ''Draft''  AND c.CargoType != ''''' + @WhereSql+ ' AND (np.AjuNumber like ''%'+@Search+'%'' OR c.ClNo like ''%'+@Search+'%'')';            
            
 IF @isTotal = 0             
 BEGIN            
  SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';            
 END             
            
 Print(@sql);            
 EXECUTE(@sql);            
 END            
END 

GO

/****** Object:  StoredProcedure [dbo].[sp_get_picdhl_data]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_picdhl_data] -- sp_get_cargo_data 1
(
	@Id bigint,
	@PersonType nvarchar(50)
)
AS
BEGIN
	--DECLARE @Id bigint = 2;
	SELECT PersonName
	, CompanyName
	, PhoneNumber
	, EmailAddress
	, StreetLines
	, City
	, PostalCode
	, p.CountryCode	
	, mc.CountryCode + ' - ' + mc.[Description] AS CountryText
	FROM DHLPerson p
	LEFT JOIN MasterCountry mc ON p.CountryCode = mc.CountryCode AND mc.IsDeleted = 0 AND mc.CreateBy != 'XUPJ21TYO'
	WHERE 1=1 AND isdelete = 0 AND DHLShipmentID = @Id AND PersonType = @PersonType;
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_problem_history_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_problem_history_list] --[dbo].[sp_get_problem_history_list] 1
(
	@id NVARCHAR(10),
	@Type Nvarchar(100) = 'CIPL',
	@IsTotal bit = 0,
	@sort nvarchar(100) = 'ID',
	@order nvarchar(100) = 'ASC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)	
AS
BEGIN
	DECLARE @sql nvarchar(max);  
	SET @sql = 'SELECT ';
	SET @sort = 't0.'+@sort;

	IF (@IsTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total'
	END 
	ELSE
	BEGIN
		SET @sql += 't0.ID
				   , t0.ReqType
				   , t0.Category
				   , t0.[Case]
				   , t0.Causes
				   , t0.Impact
				   , t0.Comment
				   , t0.CaseDate
				   , CASE WHEN ISNULL(t2.Employee_Name, '''') <> '''' THEN t2.Employee_Name ELSE t3.FullName END as PIC'
	END
	SET @sql +=' FROM ProblemHistory t0 
	join employee t2 on t2.AD_User = t0.CreateBy
	left join [PartsInformationSystem].[dbo].[UserAccess] t3 on t3.UserID = t0.CreateBy
	WHERE  t0.ReqType= '''+@Type+''' and t0.IDRequest = '+@id;
	--select @sql;
	EXECUTE(@sql);
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

/****** Object:  StoredProcedure [dbo].[sp_get_reference_no]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_reference_no] -- EXEC [sp_get_reference_no] 'PP', '', 'ReferenceNo'
(
	@Category nvarchar(100), 
	@ReferenceNo nvarchar(100) = '',
	@CategoryReference nvarchar(100),
	@LastReference nvarchar(100) = '',
	@IdCustomer nvarchar(100) = ''
)
AS
BEGIN
-- select * from dbo.Reference
	SET NOCOUNT ON;
	DECLARE @SQL nvarchar(max);
	IF(@Category = 'REMAN') 
	BEGIN 
		SET @SQL = 'select DISTINCT TOP 25"'+@CategoryReference+'" as ReferenceNo, IdCustomer, Category, null AS LastReference, IdCustomer from dbo.Reference where 1=1 and AvailableQuantity > 0';
	END
	ELSE
	BEGIN 
		SET @SQL = 'select DISTINCT TOP 25"'+@CategoryReference+'" as ReferenceNo, IdCustomer, Category, null AS LastReference, IdCustomer from dbo.Reference where 1=1 and AvailableQuantity > 0';	
	END
	

	IF (ISNULL(@Category, '') <> '')
	BEGIN
		SET @SQL = @SQL + ' AND Category='''+@Category+'''';
	END

	IF (ISNULL(@IdCustomer, '') <> '')
	BEGIN
		SET @SQL = @SQL + ' AND IdCustomer='''+@IdCustomer+'''';
	END

	IF (ISNULL(@ReferenceNo, '') <> '')
	BEGIN
		SET @SQL = @SQL + ' AND "'+@CategoryReference+'" like ''%'+@ReferenceNo+'%''';
	END

	IF (ISNULL(@LastReference, '') <> '')
	BEGIN
		SELECT @LastReference = REPLACE(@LastReference, ',', ''',''');
		SET @SQL = @SQL + ' AND "'+@CategoryReference+'" not in ('''+@LastReference+''')';
	END

	EXECUTE(@SQL);
END


GO

/****** Object:  StoredProcedure [dbo].[sp_get_regulation_list]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_regulation_list]
AS
BEGIN
    SET NOCOUNT ON;
    
	DECLARE @MasterRegulation TABLE (
		[ID] [bigint] IDENTITY(1,1),
		ParentID [bigint], 
		[Instansi] [nvarchar](50),
		[Nomor] [nvarchar](50),
		[RegulationType] [nvarchar](50),
		[Category] [nvarchar](50),
		[Reference] [nvarchar](50),
		[Description] [nvarchar](max),
		[RegulationNo] [nvarchar](50),
		[TanggalPenetapan] [nvarchar](50),
		[TanggalDiUndangkan] [nvarchar](50),
		[TanggalBerlaku] [nvarchar](50),
		[TanggalBerakhir] [nvarchar](50),
		[Keterangan] [nvarchar](max),
		[Files] [nvarchar](max),
		[CreateBy] [nvarchar](50),
		[CreateDate] [nvarchar](50),
		[UpdateBy] [nvarchar](50),
		[UpdateDate] [nvarchar](50),
		[IsDelete] [bit]
	)

	insert into @MasterRegulation
	select 0 as ParentID, Instansi, NULL, NULL, NULL, NULL, NULL, NULL, '-', '-', '-', '-', NULL, NULL, NULL, '-', NULL, '-', 0 from
	(select distinct Instansi from MasterRegulation) data

	insert into @MasterRegulation
	select instansi.ID, data.Instansi, NULL, NULL, data.Category, NULL, NULL, NULL, '-', '-', '-', '-', NULL, NULL, NULL, '-', NULL, '-', 0 
	from (
		select distinct Instansi, Category from MasterRegulation
	) data
	inner join @MasterRegulation instansi on data.Instansi = Instansi.Instansi

	insert into @MasterRegulation
	select t.ID, 
		r.[Instansi], 
		r.[Nomor], 
		r.[RegulationType], 
		r.[Category], 
		r.[Reference], 
		r.[Description], 
		r.[RegulationNo], 
		ISNULL(convert(varchar, r.[TanggalPenetapan], 106), '-') as TanggalPenetapan, 
		ISNULL(convert(varchar, r.[TanggalDiUndangkan], 106), '-') as TanggalDiUndangkan, 
		ISNULL(convert(varchar, r.[TanggalBerlaku], 106), '-')  as TanggalBerlaku, 
		ISNULL(convert(varchar, r.[TanggalBerakhir], 106), '-') as TanggalBerakhir, 
		r.[Keterangan], 
		r.[Files], 
		r.[CreateBy], 
		ISNULL(convert(varchar, r.[CreateDate], 106), '-') as CreateDate, 
		r.[UpdateBy], 
		ISNULL(convert(varchar, r.[UpdateDate], 106), '-') AS UpdateDate, 
		r.[IsDelete] 
	from MasterRegulation r
	inner join @MasterRegulation t on r.Instansi = t.Instansi and r.Category = t.Category

	select * from @MasterRegulation

END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_report_problem_history]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec [dbo].[sp_get_report_problem_history] '2020-01-01', '2020-01-01', 'category', 'document', ''
ALTER PROCEDURE [dbo].[sp_get_report_problem_history]
(
	@startDate nvarchar(10),
	@endDate nvarchar(20),
	@type nvarchar(50) = 'reason',
	@category nvarchar(50) = 'document',
	@case nvarchar(50)
)
AS
BEGIN
	IF (@type = 'category')
	BEGIN
		SELECT 
			CAST(ROW_NUMBER() over(order by Category, Category ASC) as bigint) as [Id], 
			* 
		FROM (
			select DISTINCT		
				CAST(0 as bigint) ParentId
				, '-' [ReqType]
				, t1.Category [Category]
				, '-' [Cases]
				, '-' [Causes]
				, '-' [Impact]
				, '0' [TotalCauses]
				, '0' [TotalCases]
				, CAST(ISNULL(Total, 0) as nvarchar(100)) [TotalCategory]
				, CAST(ISNULL(ROUND(((CAST(Total as decimal(18,2)) / CAST(TotalAll as decimal(18,2))) * 100), 2), 0) as nvarchar(100)) [TotalCategoryPercentage]
			From (
				select 
					Category,
					count(*) Total, 
					(
						select count(*) From dbo.ProblemHistory
						where CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
					) TotalAll 
				From dbo.ProblemHistory
				where 
					CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
					AND Category <> 'Delegation'
				Group by Category
			) as t0
			right join dbo.MasterProblemCategory t1 on t1.Category = t0.Category
		) as result
	END
	
	IF (@type = 'case')
	BEGIN
		SELECT
			CAST(ROW_NUMBER() over(order by Category, Category ASC) as bigint) as [ID], 
			CAST(0 as bigint) ParentID
			, '-' [ReqType]
			, Category [Category]
			, [Case] [Cases]
			, '-' [Causes]
			, '-' [Impact]
			, '0' [TotalCauses]
			, CAST(ISNULL(Total, 0) as nvarchar(100)) [TotalCases]
			, '0' [TotalCategory]
			, CAST(ISNULL(ROUND(((CAST(Total as decimal(18,2)) / CAST(TotalAll as decimal(18,2))) * 100), 2), 0) as nvarchar(100)) [TotalCategoryPercentage] 
		From (
				SELECT 
					[Category],
					[Case],
					(select count(*) From dbo.ProblemHistory
						where 
							(CreateDate between CAST(@startDate as date) AND CAST(@endDate as date)) 
							AND Category = @category 
							AND [Case] = @case
					)  Total,  									
					(select count(*) From dbo.ProblemHistory
						where 
							CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
					) TotalAll 
				FROM dbo.MasterProblemCategory
				WHERE Category <> 'Delegation' AND Category = @category
				Group by [Category], [Case]
			) as result;

		--select
		--	CAST(ROW_NUMBER() over(order by Category, Category ASC) as bigint) as [ID], 
		--	CAST(0 as bigint) ParentID
		--	, '-' [ReqType]
		--	, Category [Category]
		--	, [Case] [Cases]
		--	, '-' [Causes]
		--	, '-' [Impact]
		--	, '0' [TotalCauses]
		--	, CAST(ISNULL(Total, 0) as nvarchar(100)) [TotalCases]
		--	, '0' [TotalCategory]
		--	, CAST(ISNULL(ROUND(((CAST(Total as decimal(18,2)) / CAST(TotalAll as decimal(18,2))) * 100), 2), 0) as nvarchar(100)) [TotalCategoryPercentage] 
		--From (
		--	select 
		--	    Category,
		--		[Case],
		--		count(*) Total, 
		--		(
		--			select count(*) From dbo.ProblemHistory
		--			where CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
		--		) TotalAll 
		--	From dbo.ProblemHistory 
		--	WHERE 
		--		Category = @category 
		--		AND CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
		--	Group by [Case], [Category]
		--) as result;
	END 
	
	IF (@type = 'reason')
	BEGIN
		select 
			CAST(ROW_NUMBER() over(order by Category, Category ASC) as bigint) as [ID], 
			CAST(0 as bigint) ParentID
			, '-' [ReqType]
			, Category [Category]
			, [Case] [Cases]
			, Reason [Causes]
			, Impact [Impact]
			, CAST(ISNULL(Total, 0) as nvarchar(100)) [TotalCauses]
			, '0' [TotalCases]
			, '0' [TotalCategory]
			, CAST(ISNULL(ROUND(((CAST(Total as decimal(18,2)) / CAST(TotalAll as decimal(18,2))) * 100), 2), 0) as nvarchar(100)) [TotalCategoryPercentage] 
		From (
			select 
			    Category,
				[Case], 
				[Causes] Reason,
				[Impact] Impact,
				count(*) Total, 
				(
					select count(*) From dbo.ProblemHistory
					where CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
				) TotalAll 
			From dbo.ProblemHistory 
			WHERE 
				Category = @category 
				AND [Case] = @case
				AND CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
			Group by [Case], [Category], [Causes], [Impact]
		) as result;
	END 
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_req_revise_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- Create date: 24 Nov 2019
-- Description:	sp untuk mengambil data request perubahan cipl berdasarkan cipl id
-- =============================================
ALTER PROCEDURE [dbo].[sp_get_req_revise_cipl] 
	-- Add the parameters for the stored procedure here
	@ciplid nvarchar = 100, 
	@username nvarchar = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT @ciplid, @username
	SELECT 
		t0.IdCipl
		, t0.IdCiplItem
		, t0.IdCargo
		, t2.[Name] ItemName
		, t2.CaseNumber 
		, t2.Sn
		, t2.Ccr
		, t2.ExtendedValue
		, t2.JCode
		, t2.Type
		, t2.Uom
		, t2.PartNumber
		, t2.Quantity
		, t2.YearMade
		, t0.OldHeight
		, t0.NewHeight
		, t0.OldWidth
		, t0.NewWidth
		, t0.OldLength
		, t0.NewLength
		, t0.OldNetWeight
		, t0.NewNetWeight
		, t0.OldGrossWeight
		, t0.NewGrossWeight
	FROM dbo.CiplItemUpdateHistory t0 
	left join dbo.Cipl t1 on t1.id = t0.IdCipl
	left join dbo.CiplItem t2 on t2.Id = t0.IdCiplItem and t2.IdCipl = t1.id
	where t0.IdCipl = @ciplid AND t0.IsApprove = 0;
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_revise_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_revise_cipl] -- exec sp_get_revise_cipl 1
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

/****** Object:  StoredProcedure [dbo].[SP_get_shipment_dhl_available]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_get_shipment_dhl_available]		---- SP_get_cipl_available '', '1', '1' select * from dbo.Cipl
(
	@Search nvarchar(100) = '',
	@CiplList nvarchar(max) = '',
	@AwbId nvarchar(10) = '0',
	@ConsigneePic nvarchar(max) = '',
	@ConsigneeName nvarchar(max) = '',
	@ConsigneeTelephone nvarchar(max) = '',
	@ConsigneeEmail nvarchar(max) = '',
	@ConsigneeAddress nvarchar(max) = '',
	@ConsigneeCountry nvarchar(max) = ''
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @sql nvarchar(max);
	Declare @CiplExisting table (CiplId bigint);
	Declare @tblMaster table (
		id bigint,
		CiplNo varchar(50), 
		ConsigneeName varchar(150), 
		ConsigneeAddress varchar(max), 
		ConsigneeCountry varchar(150), 
		ConsigneeTelephone varchar(150), 
		ConsigneePic varchar(150), 
		ConsigneeEmail varchar(150) 
	);

	Declare @tblMaster2 table (
		id bigint,
		CiplNo varchar(50), 
		ConsigneeName varchar(150), 
		ConsigneeAddress varchar(max), 
		ConsigneeCountry varchar(150), 
		ConsigneeTelephone varchar(150), 
		ConsigneePic varchar(150), 
		ConsigneeEmail varchar(150),
		StatusViewUser varchar(100)
	);

	--SELECT c.Id, 
	--	c.CiplNo, 
	--	c.ConsigneeName, 
	--	c.ConsigneeAddress, 
	--	c.ConsigneeCountry, 
	--	c.ConsigneeTelephone, 
	--	c.ConsigneePic, 
	--	c.ConsigneeEmail 
	--FROM cipl c
	--JOIN requestcipl rc on rc.idcipl = c.id AND rc.isdelete = 0
	--WHERE c.isdelete = 0 AND rc.idstep = 10 and rc.status = 'Approve'

	SET @sql = 'SELECT c.Id, 
		c.CiplNo, 
		c.ConsigneeName, 
		c.ConsigneeAddress, 
		c.ConsigneeCountry, 
		c.ConsigneeTelephone, 
		c.ConsigneePic, 
		c.ConsigneeEmail 
	FROM cipl c
	JOIN requestcipl rc on rc.idcipl = c.id AND rc.isdelete = 0
	WHERE c.isdelete = 0 AND rc.idstep = 10 and rc.status = ''Approve'' ';

	SET @sql =	@sql + CASE WHEN ISNULL(@Search, '') <> '' THEN 'AND c.CiplNo like ''%'+@Search+'%''' ELSE '' END +
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeName like ''%'+@ConsigneeName+'%''' ELSE '' END +
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeAddress like ''%'+@ConsigneeAddress+'%''' ELSE '' END +  
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeCountry like ''%'+@ConsigneeCountry+'%''' ELSE '' END + 
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeTelephone like ''%'+@ConsigneeTelephone+'%''' ELSE '' END + 
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneePic like ''%'+@ConsigneePic+'%''' ELSE '' END + 
				CASE WHEN ISNULL(@ConsigneeName, '') <> '' THEN 'AND c.ConsigneeEmail like ''%'+@ConsigneeEmail+'%''' ELSE '' END 

	----# Get Data Master
	--print @sql
	Insert into @tblMaster
	EXECUTE(@sql);


	----# Get Status Cipl (Only Waiting for Pickup Goods)
	Insert into @tblMaster2
	Select a.*
		 , StatusViewUser = Case when c.NextStatusViewByUser = 'Pickup Goods'
								 Then
									Case When (e.Status='DRAFT') OR (c.Status='APPROVE' AND (e.Status is null OR e.Status = 'Waiting Approval') AND b.Status = 'APPROVE') 
										 Then 'Waiting for Pickup Goods'
									Else '-' End
							Else '-' End
	From @tblMaster a
	Left Join Requestcipl b with(nolock) on a.id = b.IdCipl and b.IsDelete=0
	Left Join [fn_get_cipl_request_list_all]() c on b.id = c.Id
	Left Join GoodsReceiveItem d with(nolock) on a.id = d.IdCipl and d.IsDelete=0
	Left Join [fn_get_gr_request_list_all]() e on d.IdGr = e.IdGr

	
	Insert into @CiplExisting
	Select Distinct CiplID = a.item 
	From(
		SELECT a.DHLShipmentID, x.item
		FROM(
			select DHLShipmentID, Referrence
			from DHLShipment
			where IsDelete = 0
		)a
		CROSS APPLY dbo.FN_SplitStringToRows(a.Referrence, ',') as x
	)a


	Select a.* 
	From @tblMaster2 a
	Left Join @CiplExisting b on a.id=b.CiplId
	Where a.StatusViewUser='Waiting for Pickup Goods' And b.ciplid is NULL
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_shipmentdhl_data]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_get_shipmentdhl_data]
(
	@Id bigint
)
AS
BEGIN
	--DECLARE @Id bigint = 2;
	SELECT DHLShipmentID AS Id
	, PaymentInfo
	, Account
	, Currency
	, PackagesCount
	, ShipTimestamp
	, PickupLocation
	, PickupLocTime
	, SpcPickupInstruction
	, CommoditiesDesc
	, IdentifyNumber
	, IIF(ConfirmationNumber = '', '-',ISNULL(ConfirmationNumber, '-')) AS ConfirmationNumber
	, PackagesQty
	, PackagesPrice
	, m.AccountNumber + ' - ' + m.AccountName AS AccountText
	FROM DHLShipment s
	LEFT JOIN MasterAccountDhl m ON s.Account = m.AccountNumber
	WHERE 1=1 AND s.isdelete = 0 
	AND DHLShipmentID = @Id;
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_shippingfleet_gr_reference]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_get_shippingfleet_gr_reference]    
  (    
  @Id BIGINT  
  )    
  as    
  begin    
  select * from ShippingFleetRefrence  
  where IdGr = @Id    
  End    
GO

/****** Object:  StoredProcedure [dbo].[sp_get_shippingfleet_gr]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_get_shippingfleet_gr]  
  (  
  @Id BIGINT
  )  
  as  
  begin  
  select * from ShippingFleet  
  where IdGr = @Id  
  End  
    
GO

/****** Object:  StoredProcedure [dbo].[sp_get_shippinginstruction_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_get_shippinginstruction_list]   --exec [dbo].[sp_get_shippinginstruction_list] 'xupj21wdn',''        
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
 SET @sort = 'si.'+@sort;          
          
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
           
  SET @sql += ' si.id          
      , si.SlNo          
      , c.ClNo          
      , si.IdCL          
      , si.CreateDate          
      , si.CreateBy          
      , c.Referrence          
      , c.BookingNumber          
      , c.BookingDate          
      , c.ArrivalDestination          
      , c.SailingSchedule   
   , ISNULL((select TOP 1(Id) from RequestForChange WHERE FormId = si.IdCl AND FormType = ''ShippingInstruction'' AND [Status] = 0),0) AS PendingRFC   
      , c.Status          
      , si.Description           
      , si.DocumentRequired           
      , si.SpecialInstruction          
      , si.CreateDate          
      , si.CreateBy           
      , si.UpdateDate           
      , si.UpdateBy           
      , si.IsDelete           
      , si.PicBlAwb           
      , si.ExportType          
      , CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Employee_Name ELSE ua.FullName END PreparedBy          
      , CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Email ELSE ua.Email END Email                 
      , STUFF((SELECT '', ''+ISNULL(tx1.EdoNo, ''-'')          
       FROM dbo.CargoItem tx0          
       JOIN dbo.Cipl tx1 on tx1.id = tx0.IdCipl          
       WHERE tx0.IdCargo = tx0.Id          
       GROUP BY tx1.EdoNo          
       FOR XML PATH(''''),type).value(''.'',''nvarchar(max)''),1,1,'''') [RefEdo]                 
      , c.CargoType        
   ,CASE WHEN t0.[IdStep] = 30069 THEN ''Waiting approval draft PEB''         
    WHEN (t0.[IdStep] = 30070 AND t0.[Status] = ''Approve'') THEN ''Waiting NPE document''         
    WHEN ((t0.[IdStep] = 30070 OR t0.[IdStep] = 30072) AND t0.[Status] = ''Revise'') THEN ''Need revision review by imex''         
    WHEN t0.[IdStep] = 30071 THEN ''Waiting approval NPE''      
 WHEN t0.IdStep= 30076 THEN ''Cancelled''      
 WHEN t0.IdStep= 30075 THEN ''waiting for beacukai approval''      
 WHEN t0.IdStep= 30074 THEN ''Request Cancel''      
 WHEN t0.IdStep= 10019 THEN ''Approve''      
    ELSE CASE WHEN t4.Step = ''System'' THEN t5.ViewByUser ELSE t5.ViewByUser END END as StatusViewByUser'          
 END          
 SET @sql +=' FROM ShippingInstruction si          
     JOIN dbo.Cargo c on c.Id = si.IdCl         
  --left join RequestCl t0 on t0.IdCl = si.IdCl        
  --   left join (        
  -- select         
  --  nx.Id, nx.IdStep IdNextStep, nx.IdStatus, nx.IdStep NextStep,         
  --  nf.Name, nf.Type, nf.Id IdFlow, np.Id IdCurrentStep,         
  --  ns.Status, np.Step CurrentStep, np.AssignType, np.AssignTo, ns.ViewByUser,        
  --  nt.AssignType NextAssignType, nt.AssignTo NextAssignTo, nt.Step NextStepName        
  -- from dbo.FlowNext nx        
  -- join dbo.FlowStatus ns on ns.Id = nx.IdStatus        
  -- join dbo.FlowStep np on np.Id = ns.IdStep        
  -- join dbo.Flow nf on nf.Id = np.IdFlow        
  -- join dbo.FlowStep nt on nt.Id = nx.IdStep        
--) as t1 on t1.IdFlow = t0.IdFlow AND t1.IdCurrentStep = t0.IdStep AND t1.Status = t0.Status        
  --inner join dbo.Flow t3 on t3.id = t0.IdFlow        
  --left join dbo.FlowStep t7 on t7.Id = [dbo].[fn_get_next_step_id](        
  --  t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id        
  --   ) and t7.IdFlow = t1.IdFlow        
  --left join dbo.FlowStatus t8 on t8.[Status] = t0.[Status] AND t8.IdStep = [dbo].[fn_get_next_step_id](        
  --  t1.NextAssignType, t0.Pic, t0.IdFlow, t1.IdNextStep, [dbo].fn_get_status_id(t0.IdStep, t0.[Status]), t0.Id        
  --   )        
  --left join dbo.FlowStatus t9 on t9.[Status] = t0.[Status] AND t9.IdStep = t1.IdNextStep        
  --left join dbo.FlowNext t10 on t10.IdStatus = t9.Id        
  --left join dbo.FlowStep t11 on t11.Id = t10.IdStep    
  join dbo.RequestCl t0 on t0.IdCl = c.Id    
    JOIN dbo.FlowStep t4 on t4.Id = t0.IdStep      
    JOIN dbo.FlowStatus t5 on t5.[Status] = t0.[Status] AND t5.IdStep = t0.IdStep      
    JOIN PartsInformationSystem.dbo.[UserAccess] ua on ua.UserID = si.CreateBy          
    LEFT JOIN employee t2 on t2.AD_User = si.CreateBy          
    WHERE 1=1 AND si.IsDelete = 0  AND c.CargoType != ''''' + @WhereSql+ ' AND (si.SlNo like ''%'+@Search+'%'' OR c.ClNo like ''%'+@Search+'%'') and c.Isdelete = 0';          
          
 IF @isTotal = 0           
 BEGIN          
  SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';          
 END           
          
 print (@sql);          
 EXECUTE(@sql);          
 END          
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_get_shippingsummary_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_shippingsummary_list] 
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
	SET @sort = 'c.'+@sort;

	select @GroupId = Organization_Name from employee where Employee_Status = 'Active' AND AD_User = @Username;


	SELECT @area = U.Business_Area
		,@role = U.[Role]
	FROM dbo.fn_get_employee_internal_ckb() U
	WHERE U.AD_User = @Username;

	if @role !=''
	BEGIN


	IF (@role !='EMCS IMEX' and @Username !='ict.bpm')
	BEGIN
		SET @WhereSql = ' AND c.CreateBy='''+@Username+''' ';
	END

	SET @sql = 'SELECT ';
	IF (@isTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total '
	END 
	ELSE
	BEGIN

		SET @sql += ' c.Id
						, c.SsNo
						, c.ClNo
						, c.CreateDate
						, si.CreateBy
						--, c.CreateBy		
						, cp.CiplNo		
						,cp.ConsigneeName
						, cp.ConsigneeAddress
						,cp.SoldToName
						,cp.SoldToAddress
						, fn.TotalPackage
						, fn.TotalVolume
						, c.ShippingMethod		
						, c.CargoType		
						, c.ClNo		
						, c.SsNo		
						, c.IsDelete		
						, c.ExportType
						, ci.IdCargo
						, COUNT(ci.IdCipl) totalId
						, ci.ContainerNumber	
						, ci.ContainerType	
						, ci.ContainerSealNumber	
						, CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Employee_Name ELSE t3.FullName END PreparedBy
						, CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Email ELSE t3.Email END Email  
						, ci.IdCipl
						, cp.Category  '
	END


	SET @sql +=' from Cargo c
            left join CargoItem ci on c.Id = ci.IdCargo
			left join CiplItem cpi on ci.IdCiplItem = cpi.Id
			left join Cipl cp on cpi.IdCipl = cp.id
			left join ShippingInstruction  si on si.IdCL = c.Id 
			left join fn_get_total_cipl_all()  fn on fn.IdCipl = cpi.IdCipl
			JOIN PartsInformationSystem.dbo.[UserAccess] t3 on t3.UserID = c.CreateBy
			LEFT JOIN employee t2 on t2.AD_User = c.CreateBy
			WHERE 1=1 AND c.IsDelete = 0  ' + @WhereSql+ ' AND  (c.ClNo like ''%'+@Search+'%'' OR c.SsNo like ''%'+@Search+'%'')
			GROUP BY 
				c.Id
				, c.SsNo
				, c.ClNo
				, c.CreateDate
				, si.CreateBy
				--, c.CreateBy
				, cp.CiplNo			
				, cp.ConsigneeName
				, cp.ConsigneeAddress
				, cp.SoldToName
				, cp.SoldToAddress
				, fn.TotalPackage
				, fn.TotalVolume
				, c.ShippingMethod	
				, c.CargoType		
				, c.ClNo		
				, c.SsNo		
				, c.IsDelete		
				, c.ExportType
				--, ci.Id
				, ci.IdCargo
				, ci.ContainerNumber	
				, ci.ContainerType	
				, ci.ContainerSealNumber	
				, CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Employee_Name ELSE t3.FullName END 
				, CASE WHEN t2.Employee_Name IS NOT NULL THEN t2.Email ELSE t3.Email END 
				, ci.IdCipl
				, cp.Category
				

				HAVING COUNT(ci.IdCipl) > 1
				';

	IF @isTotal = 0 
	BEGIN
		SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	END 

	PRINT(@sql);

	EXECUTE(@sql);

	END
	
END
GO

/****** Object:  StoredProcedure [dbo].[sp_get_Superior]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_get_Superior]
(
	@EmployeeUsername NVARCHAR(200)
)
AS
BEGIN
	SELECT CAST(Id as bigint) Id, EmployeeUsername, 
	EmployeeName, SuperiorUsername, SuperiorName, CreateBy, CreateDate, UpdateBy, UpdateDate, 
	Isdeleted 
	FROM [dbo].[MasterSuperior] 
	WHERE IsDeleted = 0 AND EmployeeUsername LIKE ('%'+ @EmployeeUsername + '%')
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

/****** Object:  StoredProcedure [dbo].[sp_get_total_outsanding_export]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_get_total_outsanding_export]
AS
BEGIN
	select 
		count(*) as total
	from dbo.Cipl t0 
	left join dbo.CargoCipl t1 on t1.IdCipl = t0.id
	left join dbo.BlAwb t2 on t2.IdCl = t1.IdCargo
	left join dbo.NpePeb t3 on t2.IdCl = t1.IdCargo
	left join dbo.ShippingInstruction t4 on t2.IdCl = t1.IdCargo
	left join dbo.GoodsReceiveItem t5 on t5.IdCipl = t0.id
	where t2.Id IS NULL AND t0.CreateBy <>'SYSTEM'
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetArea_NEW]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_GetArea_NEW]
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

		MERGE dbo.MasterArea AS T
			USING 
			(
				SELECT *
				  FROM  BI_PROD.[EDW_ANALYTICS].[ECC].[dim_plant_area] WHERE PLANT NOT in ('-2','-1')
			) AS S ON T.[BAreaName] = S.PLANT_NAME
			WHEN MATCHED THEN
			UPDATE SET T.[BAreaName] = S.PLANT,
			
			[BLatitude] = 0,
			[BLongitude]  = 0,
			[AreaCode] = Isnull([Area_Code],''),
			[AreaName] = [Area_Name],
			[ALatitude] = 0,
			[ALongitude] = 0,
			[IsActive] = 1,
			CreateBy ='SYSTEM',
			CreateDate = GETDATE()
			WHEN NOT MATCHED BY TARGET THEN
			Insert ([BAreaCode]
      ,[BAreaName]
      ,[BLatitude]
      ,[BLongitude]
      ,[AreaCode]
      ,[AreaName]
      ,[ALatitude]
      ,[ALongitude]
      ,[IsActive]
	  ,CreateBy
	  ,CreateDate)
	  VALUES(
   S.PLANT 
      ,S.PLANT_NAME    
      ,0 
      ,0 
	  ,Isnull(S.[Area_Code],'')
	  ,S.[Area_Name]
      ,0 
      ,0 
      , 1 
	  ,'SYSTEM'
	  ,GETDATE());
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT > 0)
			ROLLBACK TRAN;
	END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetArea]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SP_GetArea]

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	truncate table MasterArea
Insert into MasterArea ([BAreaCode]
      ,[BAreaName]
      ,[BLatitude]
      ,[BLongitude]
      ,[AreaCode]
      ,[AreaName]
      ,[ALatitude]
      ,[ALongitude]
      ,[IsActive]
	  ,CreateBy
	  ,CreateDate)
  SELECT PLANT [BUSINESS_AREA]
      ,PLANT_NAME  [BUSINESS_AREA_NAME]    
      ,0 [BLATITUDE]
      ,0 [BLONGITUDE]
	  ,Isnull([Area_Code],'')
	  ,[Area_Name]
      ,0 [AREALATITUDE]
      ,0 [AREALONGITUDE]
      , 1 IsActive
	  ,'SYSTEM'
	  ,GETDATE()
  FROM  BI_PROD.[EDW_ANALYTICS].[ECC].[dim_plant_area] WHERE PLANT NOT in ('-2','-1')
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_GetArmdaList]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[Sp_GetArmdaList]
(@IdGr bigint,
@Id BigInt )
as
begin
if @Id = 0
begin
select * from ShippingFleet
where IdGr = @IdGr 
end
else
begin 
select * from ShippingFleet
where Id = @Id
end 
end


GO

/****** Object:  StoredProcedure [dbo].[SP_GetAvailableShippingCiplItem]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_GetAvailableShippingCiplItem] -- exec [dbo].[SP_GetAvailableShippingCiplItem] '13383','101423','50669'   
(      
@IdCipl nvarchar(100) = 0,    
@IdGr nvarchar(100),   
@IdShippingFleet nvarchar(100)   
)     
As    
Begin                                                       
--DECLARE @sql nvarchar(max);   
--DECLARE @CiplItemCount nvarchar(max);   
--Set @CiplItemCount = (select Count(IdCiplItem) from ShippingFleetItem t2 where t2.IdCipl = @IdCipl And t2.IdGr = @IdGr And t2.IdShippingFleet = @IdShippingFleet)
IF @IdShippingFleet = 0
BEGIN
  SELECT t0.id ,
         t0.idcipl ,
         t0.idreference ,
         (
                SELECT
                       CASE
                              WHEN t0.referenceno = '-' THEN t0.casenumber
                              ELSE t0.referenceno
                       END) AS referenceno ,
         t0.idcustomer ,
         t0.NAME ,
         t0.uom AS unituom ,
         t0.partnumber ,
         t0.sn ,
         t0.jcode ,
         t0.ccr ,
         t0.casenumber ,
         t0.type ,
         t0.idno ,
         t0.yearmade ,
         t0.quantity ,
         t0. unitprice ,
         t0.extendedvalue ,
         t0.length ,
         t0.width ,
         t0.height ,
         t0.volume ,
         t0.grossweight ,
         t0.netweight ,
         t0.currency ,
         t0.CoO ,
         t0.idparent ,
         t0.wonumber ,
         t0.sibnumber ,
         t0.createby ,
         t0.createdate ,
         t0.updateby ,
         t0.updatedate ,
         t0.isdelete ,
         t0.claim ,
         t0.asnnumber
  FROM   ciplitem t0
  JOIN   cipl t1
  ON     t0.idcipl = t1.id
  WHERE  t0.isdelete = 0
  AND    t0.idcipl IN
         (
                SELECT part
                FROM   [SDF_SplitString](@IdCipl,','))
  AND    t0.id NOT IN
(SELECT idciplitem FROM   shippingfleetitem t2 WHERE  t2.idcipl IN ( SELECT part FROM   [SDF_SplitString](@IdCipl,','))
                AND    t2.idgr = @IdGr)
END
ELSE 
begin
SELECT t0.id ,
       t0.idcipl ,
       t0.idreference ,
       (
              SELECT
                     CASE
                            WHEN t0.referenceno = '-' THEN t0.casenumber
                            ELSE t0.referenceno
                     END) AS referenceno ,
       t0.idcustomer ,
       t0.name ,
       t0.uom AS unituom ,
       t0.partnumber ,
       t0.sn ,
       t0.jcode ,
       t0.ccr ,
       t0.casenumber ,
       t0.type ,
       t0.idno ,
       t0.yearmade ,
       t0.quantity ,
       t0.unitprice ,
       t0.extendedvalue ,
       t0.length ,
       t0.width ,
       t0.height ,
       t0.volume ,
       t0.grossweight ,
       t0.netweight ,
       t0.currency ,
       t0.CoO ,
       t0.idparent ,
       t0.wonumber ,
       t0.sibnumber ,
       t0.createby ,
       t0.createdate ,
       t0.updateby ,
       t0.updatedate ,
       t0.isdelete ,
       t0.claim ,
       t0.asnnumber ,
       t3.idshippingfleet
FROM   ciplitem t0
JOIN   cipl t1
ON     t0.idcipl = t1.id
JOIN   shippingfleetitem t3
ON     t3.idciplitem = t0.id
WHERE  t0.isdelete = 0
AND    t3.idshippingfleet = @IdShippingFleet AND    t0.idcipl IN ( SELECT part FROM   [SDF_SplitString](@IdCipl,','))
AND    t0.id IN ( SELECT idciplitem FROM   shippingfleetitem t2 WHERE  t2.idcipl IN
(SELECT part FROM   [SDF_SplitString](@IdCipl,','))AND    t2.idgr = @IdGr AND    t2.idshippingfleet = @IdShippingFleet)
UNION
SELECT t0.id ,
       t0.idcipl ,
       t0.idreference ,
       (
              SELECT
                     CASE
                            WHEN t0.referenceno = '-' THEN t0.casenumber 
							else t0.referenceno
                     END) AS referenceno ,
       t0.idcustomer ,
       t0.NAME ,
       t0.uom AS unituom ,
       t0.partnumber ,
       t0.sn ,
       t0.jcode ,
       t0.ccr ,
       t0.casenumber ,
       t0.type ,
       t0.idno ,
       t0.yearmade ,
       t0.quantity ,
       t0.unitprice ,
       t0.extendedvalue ,
       t0.length ,
       t0.width ,
       t0.height ,
       t0.volume ,
       t0.grossweight ,
       t0.netweight ,
       t0.currency ,
       t0.CoO ,
       t0.idparent ,
       t0.wonumber ,
       t0.sibnumber ,
       t0.createby ,
       t0.createdate ,
       t0.updateby ,
       t0.updatedate ,
       t0.isdelete ,
       t0.claim ,
       t0.asnnumber ,
       -1 As IdShippingFleet
FROM   ciplitem t0

JOIN   cipl t1
ON     t0.idcipl = t1.id
WHERE  t0.isdelete = 0
AND    t0.idcipl IN
       (
              SELECT part
              FROM   [SDF_SplitString](@IdCipl,','))
AND    t0.id NOT IN
       (
              SELECT idciplitem
              FROM   shippingfleetitem t2
              WHERE  t2.idcipl IN
                     (
                            SELECT part
                            FROM   [SDF_SplitString](@IdCipl,','))
              AND    t2.idgr = @IdGr
              --AND    t2.idshippingfleet = @IdShippingFleet
			  )
END
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetCargoHeader]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DROP PROCEDURE [dbo].[SP_GetCargoHeader]
ALTER PROCEDURE [dbo].[SP_GetCargoHeader]
	@CargoID bigint
AS
BEGIN
    select 
	ca.Id as CargoID, ca.ClNo, ca.Consignee ConsigneeName, ca.NotifyParty NotifyName, ca.ExportType ExportType, ca.Category, ca.IncoTerms
	,ca.StuffingDateStarted, ca.StuffingDateFinished, ca.VesselFlight, ca.ConnectingVesselFlight, ca.VoyageVesselFlight, ca.VoyageConnectingVessel, 
	ca.PortOfLoading, ca.PortOfDestination, ca.SailingSchedule, ca.ArrivalDestination, ca.BookingNumber, ca.BookingDate, ca.Liner, ca.ETA, ca.ETD
	from Cargo ca
	where ca.Id = @CargoID
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetCiplId]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_GetCiplId]
(@DoNo nvarchar(max))
as
begin
select * from Cipl
where EdoNo In (select * from [SDF_SplitString](@DoNo,','))
end

GO

/****** Object:  StoredProcedure [dbo].[SP_GetCiplItem]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_GetCiplItem]  
(  
@IdCipl nvarchar(100)  
)  
as   
begin   
select count(Id)
 from CiplItem  
where IdCipl = @IdCipl and IsDelete = 0  
end
GO

/****** Object:  StoredProcedure [dbo].[SP_GetCiplItemCount]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[SP_GetCiplItemCount]  
(  
@IdCipl nvarchar(100),  
@IdGr nvarchar(100),
@IdShippingFleet nvarchar(100)
)  
as  
begin  
If(@IdCipl != 0)  
begin  
select count(*) from CiplItem  
where IdCipl In(SELECT splitdata FROM [fnSplitString](@IdCipl, ',')) and IsDelete = 0  
end  
Else If(@IdGr != 0)
begin  
select count(*) from ShippingFleetItem  
where IdGr =  @IdGr  
end  
Else
begin
select count(*) from ShippingFleetItem
where IdShippingFleet = @IdShippingFleet
end
end

GO

/****** Object:  StoredProcedure [dbo].[SP_GetCiplItemInShippingFleetItem]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[SP_GetCiplItemInShippingFleetItem]
(
@IdCipl nvarchar(100),
@IdGr nvarchar(100)
)
as 
begin 
select count(IdCiplItem) from ShippingFleetItem
where IdCipl = @IdCipl and IdGr = @IdGr
end


GO

/****** Object:  StoredProcedure [dbo].[sp_getcontainertype]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_getcontainertype]
(
	@ContainerType nvarchar(50),
	@Value  nvarchar(50)
	
)	
as 
begin
select * from MasterParameter
where   Value = @Value  and [Group] = @ContainerType
end

GO

/****** Object:  StoredProcedure [dbo].[SP_GetDhlRateItemList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_GetDhlRateItemList]
(    
	@AwbId BIGINT
)
AS
BEGIN
	SELECT DHLRateID AS Id 
		, ServiceType
		, ISNULL(ChargeCode, '-') AS ChargeCode
		, ChargeType
		, ChargeAmount
	FROM DHLRate
	WHERE DHLShipmentID = @AwbId AND IsDelete = 0;
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetDhlShipmentItemList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_GetDhlShipmentItemList]
(    
	@AwbId BIGINT
)
AS
BEGIN
	SELECT DHLPackageID AS Id
		, t1.CiplNo AS CiplNo
		, CaseNumber
		, 1 AS Qty
		, Length
		, Width
		, Height
		, (Length*Width*Height)/1000000 AS Volume
		, Weight
		, Insured
		, CustReferences 
	FROM DHLPackage t0 
	LEFT JOIN cipl t1 ON t0.CiplNumber = t1.id AND t1.IsDelete = 0
	WHERE DHLShipmentID = @AwbId AND t0.IsDelete = 0;
END


GO

/****** Object:  StoredProcedure [dbo].[SP_GetDhlShipmentPackagesList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_GetDhlShipmentPackagesList]
(    
	@AwbId BIGINT
)
AS
BEGIN
	SELECT 
		ROW_NUMBER() OVER (Order by t0.DhlPackageId) AS Number
		--,DHLPackageID AS Id
		, t0.CiplNumber AS CiplNumber
		, CaseNumber
		, 1 AS Qty
		--, CAST(ROUND(Length, 0) AS BIGINT) AS [Length]
		--, CAST(ROUND(Width, 0) AS BIGINT) AS Width
		--, CAST(ROUND(Height, 0) AS BIGINT) AS Height
		--, (Length*Width*Height)/1000000 AS Volume
		--, CAST(ROUND(Weight, 0) AS BIGINT) AS [Weight]
		--, CAST(ROUND(Insured, 0) AS BIGINT) AS InsuredValue
		, Length AS [Length]
		, Width AS Width
		, Height AS Height
		, (Length*Width*Height)/1000000 AS Volume
		, Weight AS [Weight]
		, Insured AS InsuredValue
		, CustReferences AS CustomerReferences
	FROM DHLPackage t0 
	--JOIN cipl t1 ON t0.CiplNumber = t1.id AND t1.IsDelete = 0
	WHERE DHLShipmentID = @AwbId AND t0.IsDelete = 0;
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetDhlShipmentTrackingEvent]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_GetDhlShipmentTrackingEvent]
(    
	@AwbId BIGINT
)
AS
BEGIN

	SELECT EventDate
		, EventTime
		, EventDesc
		, SvcAreaDesc
	FROM DHLTrackingShipment ts
	JOIN DHLTrackingShipmentEvent tse ON ts.DHLTrackingShipmentID = tse.DHLTrackingShipmentID and tse.IsDelete = 0
	WHERE ts.IsDelete = 0 AND ts.DHLShipmentID = @AwbId
	AND EventType = 'SHIPMENT'
	ORDER BY EventDate, EventTime ASC
END
GO

/****** Object:  StoredProcedure [dbo].[SP_getListAllEmployee]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SP_getListAllEmployee]
	
AS
BEGIN
		
	SELECT Employee_ID AS Id, Employee_Name + ' - ' + AD_User AS Name, AD_User AS AdUser from Employee
	WHERE AD_User IS NOT NULL
	ORDER BY Employee_Name ASC

END
GO

/****** Object:  StoredProcedure [dbo].[SP_getListUser]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SP_getListUser]
	
AS
BEGIN
	
    -- Insert statements for procedure here
	SELECT UserId, FullName from [PartsInformationSystem].[dbo].[UserAccess]
	WHERE UserType = 'ext-imex'
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GetRTaxAudit]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_GetRTaxAudit]
(
	@StartDate nvarchar(100) = '1/1/1990 00:00:00',
	@EndDate nvarchar(100) = '1/1/2025 00:00:00',
	@noaju nvarchar(100) = '-'
)
AS
BEGIN
	DECLARE @sql nvarchar(MAX);
	DECLARE @where nvarchar(MAX);
	
	SET @where = ''

	IF @noaju != '-'
		SET @where = 'and t4.AjuNumber = ''' + @noaju +''''

	--print(@where);

	SET @sql = '
	SELECT PebNo, PebDate, SUM(sumvalue) AS sumvalue, NpeDate, Nopen, FilePeb, FileBlAwb, UrlFilePeb, UrlFileBlAwb
	FROM(
	SELECT  
		ISNULL(t4.PebNumber,''-'') AS pebNo,		
		FORMAT( t4.PebDate,''dd/MM/yyyy hh:mm:ss'') PebDate,
		sum(t4.pebfob) as sumvalue,
		FORMAT(t4.NpeDate,''dd/MM/yyyy'') NpeDate,
		ISNULL(t4.RegistrationNumber,''-'') as Nopen, --add nunu
		( SELECT TOP 1 [Filename] FROM Documents WHERE idrequest = t4.idcl AND Category = ''NPE/PEB'' AND Tag = ''COMPLETEDOCUMENT'') AS FilePeb,
		( SELECT TOP 1 [Filename] FROM Documents WHERE idrequest = t4.idcl AND Category = ''BL/AWB'' AND Status = ''Approve'') AS FileBlAwb,
		''https://scis.trakindo.co.id/Upload/EMCS/NPEPEB/'' + ( SELECT TOP 1 [Filename] FROM Documents WHERE idrequest = t4.idcl AND Category = ''NPE/PEB'' AND Tag = ''COMPLETEDOCUMENT'') AS UrlFilePeb,
		''https://scis.trakindo.co.id/Upload/EMCS/BLAWB/'' + ( SELECT TOP 1 [Filename] FROM Documents WHERE idrequest = t4.idcl AND Category = ''BL/AWB'' AND Status = ''Approve'') AS UrlFileBlAwb		 
	FROM
		--Cipl t0
		--JOIN (SELECT 
		--	DISTINCT IdCipl, 
		--			SUM(ExtendedValue) CurrValue  --update nunu
		--	FROM CiplItem 
		--	GROUP BY Currency, IdCipl
		--	) as t1 on t1.IdCipl = t0.id
		--JOIN CargoCipl t2 on t2.IdCipl = t0.id and t2.IsDelete= 0
		Cargo t3 --on t3.Id = t2.IdCargo and t3.IsDelete= 0
		JOIN NpePeb t4 on t4.IdCl = t3.id and t4.IsDelete= 0
		--JOIN GoodsReceiveItem t6 on t6.DoNo = t0.EdoNo and t6.IsDelete= 0
		--JOIN (SELECT  max(CreateDate) as ApprovedDate, IdCipl
		--		FROM CiplHistory
		--		WHERE Status = ''Approve''
		--		GROUP BY IdCipl
		--	) t7 on t7.IdCipl = t0.id 
		JOIN BlAwb t8 on t8.IdCl = t3.Id and  t8.IsDelete= 0
		JOIN RequestCl t9 on t9.IdCl = t3.Id and t9.IsDelete= 0
	WHERE t9.IdStep = 10022
		and t9.[Status] = ''Approve''
		and t4.NpeDate between ''' + @StartDate + ''' and '''+ @EndDate +''' '
	set @sql = @sql + @where
	
	set @sql = @sql + ' 
	group by 
	t4.PebNumber,t4.PebDate,t4.Rate,t4.WarehouseLocation,t3.PortOfLoading
	,t4.NpeNumber,t4.NpeDate,t4.RegistrationNumber,t8.Publisher,t8.Number,t8.BlAwbDate,t3.PortOfDestination--,t0.Remarks
	,t4.idcl
	) t GROUP BY PebNo, PebDate, NpeDate, Nopen, FilePeb, FileBlAwb, UrlFilePeb, UrlFileBlAwb'

	print(@sql);
	execute(@sql);
END

GO

/****** Object:  StoredProcedure [dbo].[SP_GetSiExportShipmentType]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_GetSiExportShipmentType]  
(  
@IdCL bigint  
)  
AS  
BEGIN  
select top 1 cf.ExportShipmentType from CargoCipl cc   
join CiplForwader cf on cc.IdCipl = cf.IdCipl  
where IdCargo = @IdCL  
end 

GO

/****** Object:  StoredProcedure [dbo].[SP_GetTotal_Header]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_GetTotal_Header]
(
	@AwbId BIGINT
)
AS
BEGIN

	SELECT SUM(ci.ExtendedValue) AS TotalUnitPrice, SUM(ci.Quantity) AS TotalQuantity, ci.Currency AS Currency
	, c.IncoTerm AS IncoTerm, c.Category AS Category, c.CategoriItem AS CategoriItem
	FROM CiplItem ci
	JOIN Cipl c ON ci.IdCipl = c.id AND c.IsDelete = 0
	WHERE ci.IdCipl IN (
		SELECT CiplNumber FROM DHLPackage WHERE DHLShipmentID = @AwbId and IsDelete = 0
	) GROUP BY ci.Currency, c.IncoTerm, c.Category, c.CategoriItem

END
GO

/****** Object:  StoredProcedure [dbo].[SP_getTotalVolumeCargo]    Script Date: 10/03/2023 12:07:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_getTotalVolumeCargo] -- EXEC [sp_get_reference_no] 'PP', '', 'ReferenceNo'
(
	@idcl nvarchar(100)	
)
AS
BEGIN
-- select * from dbo.Reference
	SET NOCOUNT ON;
	DECLARE @SQL nvarchar(max);

	BEGIN 
		SET @SQL = ' select sum((length*width*height)/1000000) as volume_sistem  from CargoItem where isDelete = 0 AND IdCargo ='+ @idcl  +'';
	END
	

	EXECUTE(@SQL);
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GRDocumentAdd]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_GRDocumentAdd]
(
	@Id BIGINT,
	@IdGr BIGINT,
	@DocumentDate datetime,
	@DocumentName NVARCHAR(MAX) = '',
	@Filename NVARCHAR(MAX) = '',
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@IsDelete BIT
)
AS
BEGIN
	IF @Id <= 0
	BEGIN
	INSERT INTO [dbo].[GoodsReceiveDocument]
           ([IdGr]
		   ,[DocumentDate]
		   ,[DocumentName]
		   ,[Filename]
           ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
           )
     VALUES
           (@IdGr
			,@DocumentDate
			,@DocumentName
			,@Filename
			,@CreateBy
			,@CreateDate
			,@UpdateBy
			,@UpdateDate
			,@IsDelete
		   )

	END
	ELSE 
	BEGIN
	UPDATE dbo.GoodsReceiveDocument
	SET [DocumentDate] = @DocumentDate
		   ,[DocumentName] = @DocumentName
	WHERE Id = @Id;
	END

END

GO

USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_GrDocumentDelete]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[SP_GrDocumentDelete] (
	@id BIGINT
	,@UpdateBy NVARCHAR(50)
	,@UpdateDate DATETIME
	,@IsDelete BIT
	)
AS
BEGIN
	UPDATE dbo.GoodsReceiveDocument
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE Id = @id;	
END

GO

/****** Object:  StoredProcedure [dbo].[SP_GrDocumentDelete]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_GrDocumentDelete] (
	@id BIGINT
	,@UpdateBy NVARCHAR(50)
	,@UpdateDate DATETIME
	,@IsDelete BIT
	)
AS
BEGIN
	UPDATE dbo.GoodsReceiveDocument
		SET UpdateBy = @UpdateBy
			,UpdateDate = @UpdateDate
			,IsDelete = @IsDelete
		WHERE Id = @id;	
END

GO

/****** Object:  StoredProcedure [dbo].[SP_GrDocumentUpdateFile]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_GrDocumentUpdateFile]
(
	@Id BIGINT,
	@Filename NVARCHAR(MAX) = '',
	@UpdateBy NVARCHAR(MAX) = ''
)
AS
BEGIN
 
	UPDATE dbo.GoodsReceiveDocument
	SET [Filename] = @Filename,
	[UpdateBy] = @Updateby,
	[UpdateDate] = GETDATE()
	WHERE Id = @Id;

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

/****** Object:  StoredProcedure [dbo].[SP_GRForExport_Header]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ALTER PROCEDURE [dbo].[SP_GRForExport_Header]
	@GRID bigint
AS
BEGIN
	SET NOCOUNT ON;
	--DECLARE @Id nvarchar(100);
	--SET @Id = 1;
	SELECT 
		t0.Id
		,t0.GrNo AS RgNo
		,t0.PicName
		,t0.PhoneNumber
		,t0.KtpNumber
		,t0.SimNumber
		,t0.StnkNumber
		,t0.NopolNumber
		,ISNULL(CONVERT(VARCHAR(11), t0.EstimationTimePickup, 106), '-') as [EstimationTimePickup]
		,t0.Vendor
		,t0.KirNumber
		,ISNULL(CONVERT(VARCHAR(11), t0.KirExpire, 106), '-') as [KirExpire]
	   ,IIF(CAST(t0.Apar as varchar(20)) = '1', 'Yes', 'No') as [Apar]
	   ,IIF(CAST(t0.Apd as varchar(20)) = '1', 'Yes', 'No') as [Apd]
		,t0.Notes
		,t0.VehicleType
		,t0.VehicleMerk
		,t0.CreateBy
		,ISNULL(CONVERT(VARCHAR(11), t0.CreateDate, 106), '-') as [CreateDate]
		,t0.UpdateBy
		,ISNULL(CONVERT(VARCHAR(11), t0.UpdateDate, 106), '-') as [UpdateDate]
		,t0.IsDelete
		,ISNULL(CONVERT(VARCHAR(11), t0.SimExpiryDate, 106), '-') as [SimExpiryDate]
		,t0.ActualTimePickup
		,t2.Step
		,t3.[Status]
		,t4.[Address] VendorAddress
		,t4.City VendorCity
		,t4.[Name] VendorName
		,t4.Telephone VendorTelephone
		,t4.[Code] VendorCode
		,t0.PickupPoint
		,t0.PickupPic
		,t7.Employee_Name PickupPicName
		,t5.BAreaName PlantName
		,t5.BAreaCode PlantCode
		,t6.Employee_Name as RequestorName
		,t6.Email as RequestorEmail
		,CAST((	
			(SELECT SUM(TotalVolume) FROM dbo.fn_get_total_cipl_all() 
					WHERE Idcipl IN (SELECT IdCipl FROM dbo.GoodsReceiveItem where IdGr = t0.Id))
		  ) as nvarchar(max)) TotalVolume
		, t8.Employee_Name RequestorName
		, t8.Email RequestorEmail
		,CAST((	
			FORMAT((SELECT SUM(TotalNetWeight) FROM dbo.fn_get_total_cipl_all() 
					WHERE Idcipl IN (SELECT IdCipl FROM dbo.GoodsReceiveItem where IdGr = t0.Id)), '#,0.00')
		 ) as nvarchar(max)) TotalNetWeight
		,CAST((	
			FORMAT((SELECT SUM(TotalGrossWeight) FROM dbo.fn_get_total_cipl_all() 
			WHERE Idcipl IN (SELECT IdCipl FROM dbo.GoodsReceiveItem where IdGr = t0.Id)), '#,0.00')
		  ) as nvarchar(max)) TotalGrossWeight
		,CAST((	
			FORMAT((SELECT SUM(TotalPackage) FROM dbo.fn_get_total_cipl_all() 
			WHERE Idcipl IN (SELECT IdCipl FROM dbo.GoodsReceiveItem where IdGr = t0.Id)), '#,0.00')
		  ) as nvarchar(max)) TotalPackages
		  , IIF(s.Employee_Name IS NULL OR LEN(s.Employee_Name) <= 0, '-', s.Employee_Name) as SignedName
		, IIF(s.Position_Name IS NULL OR LEN(s.Position_Name) <= 0, '-', s.Position_Name) as SignedPosition
	FROM dbo.GoodsReceive as t0
	INNER JOIN dbo.RequestGr as t1 on t1.IdGr = t0.Id
	INNER JOIN dbo.FlowStep as t2 on t2.Id = t1.IdStep
	LEFT JOIN dbo.FlowStatus as t3 on t3.IdStep = t1.IdStep AND t3.Status = t1.Status
	LEFT JOIN dbo.MasterVendor as t4 on t4.Code = t0.Vendor 
	LEFT JOIN dbo.MasterArea as t5 on t5.BAreaCode = t0.PickupPoint
	LEFT join dbo.fn_get_employee_internal_ckb() t6 on t0.UpdateBy = t6.AD_User
	LEFT JOIN dbo.fn_get_employee_internal_ckb() t7 on t7.AD_User = t0.PickupPic 
	LEFT JOIN dbo.fn_get_employee_internal_ckb() t8 on t8.AD_User = t0.CreateBy
	left join fn_get_employee_internal_ckb() s on t0.UpdateBy= s.AD_User
    WHERE 1=1 AND t0.id = @GRID
END
GO

/****** Object:  StoredProcedure [dbo].[SP_GRHistoryGetById]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_GRHistoryGetById] -- [dbo].[SP_GRHistoryGetById] 1
(
	@id NVARCHAR(10),
	@IsTotal bit = 0,
	@sort nvarchar(100) = 'CreateDate',
	@order nvarchar(100) = 'DESC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)	
AS
BEGIN
DECLARE @sql nvarchar(max);  
	SET @sql = 'SELECT DISTINCT';
	SET @sort = 't0.'+@sort;

	IF (@IsTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total'
	END 
	ELSE
	BEGIN
	SET @sql += ' t0.IdGr
				, t0.Flow
				, t0.Step
				, t0.Status
				, t3.ViewByUser
				, t0.Notes
				, t4.Employee_Name CreateBy
				, t0.CreateDate'
	END
	SET @sql +=' FROM GoodsReceiveHistory t0
					join Flow t2 on t2.Name = t0.Flow
					join FlowStep t1 on t1.Step = t0.Step AND t1.IdFlow = t2.Id
					join FlowStatus t3 on t3.[Status] = t0.[Status] AND t3.IdStep = t1.Id
					left join employee t4 on t4.AD_User = t0.CreateBy					
					WHERE t0.isdelete = 0 AND t0.IdGr = '+@id;
	IF @isTotal = 0 
	BEGIN
	SET @sql += ' ORDER BY t0.CreateDate DESC OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	END 

	EXECUTE(@sql);
END

GO

/****** Object:  StoredProcedure [dbo].[sp_insert_bast_number]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_insert_bast_number]
AS 
INSERT INTO [EMCS_Dev].[dbo].[BastNumber] (BastNo, ReferenceNo) SELECT J_3GBELNRI, c.ReferenceNo
	FROM [EDW_PROD].[EDW_STG_SAP_ECC_DAILY].[dbo].J_3GBELK as sap
		INNER JOIN  (
			SELECT ciplitem.ReferenceNo, SUBSTRING(ciplitem.ReferenceNo, PATINDEX('%[^0]%', ciplitem.ReferenceNo+'.'), LEN(ciplitem.ReferenceNo)) as Ref
			FROM EMCS_Dev.dbo.CiplItem ciplitem
				INNER JOIN EMCS_Dev.dbo.cipl cipl ON cipl.id = ciplitem.IdCipl
			WHERE ciplitem.ReferenceNo != '' AND cipl.Category like '%CATERPILLAR USED EQUIPMENT%'
		) c ON usr02 = Ref
	WHERE NOT EXISTS (SELECT 1 FROM [EMCS_Dev].[dbo].[BastNumber] bast WHERE bast.BastNo = sap.J_3GBELNRI)
GO

/****** Object:  StoredProcedure [dbo].[SP_Insert_BlAwb]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_Insert_BlAwb]
(
	@Id BIGINT,
	@Number NVARCHAR(100),
	@MasterBlDate datetime,
	@HouseBlNumber NVARCHAR(200),
	@HouseBlDate datetime,
	@Description NVARCHAR(50),
	@FileName NVARCHAR(max),
	@Publisher NVARCHAR(50),
	@CreateBy NVARCHAR(50),
	@CreateDate datetime,
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime,
	@IsDelete BIT,
	@IdCl BIGINT,
	@Status NVARCHAR(50)
)
AS
BEGIN
	DECLARE @LASTID bigint
	IF @Id <= 0
	BEGIN
	INSERT INTO [dbo].[BlAwb]
           ([Number]
		   ,[MasterBlDate]
		   ,[HouseBlNumber]
		   ,[HouseBlDate]
           ,[Description]
		   ,[FileName]
		   ,[Publisher]
		   ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete]
		   ,[IdCl]
           )
     VALUES
           (@Number
		   ,@MasterBlDate
		   ,@HouseBlNumber
		   ,@HouseBlDate
           ,@Description
		   ,@FileName
		   ,@Publisher
           ,@CreateBy
           ,@CreateDate
           ,@UpdateBy
           ,@UpdateDate
           ,@IsDelete
		   ,@IdCl)

	SELECT @LASTID = CAST(SCOPE_IDENTITY() as bigint)
	SELECT C.Id as ID, CONVERT(nvarchar(5), C.IdCl) as [NO], C.CreateDate as CREATEDATE FROM BlAwb C WHERE C.id = @LASTID
	END
	ELSE 
	BEGIN
	UPDATE [dbo].[BlAwb]
		SET [Number] = @Number 
		   ,[MasterBlDate] = @MasterBlDate
		   ,[HouseBlNumber] = @HouseBlNumber
		   ,[HouseBlDate] = @HouseBlDate
           ,[Description] = @Description
		   ,[FileName] = @FileName
		   ,[Publisher] = @Publisher
		   ,[CreateBy] = @CreateBy
           ,[CreateDate] = @CreateDate
           ,[UpdateBy] = @UpdateBy
           ,[UpdateDate] = @UpdateDate
		   WHERE Id = @Id
		   SELECT C.Id as ID, CONVERT(nvarchar(5), C.IdCl) as [NO], C.CreateDate as CREATEDATE FROM BlAwb C WHERE C.id = @Id
	END
	
	IF(@Status <> 'Draft') 
	BEGIN
	EXEC [sp_update_request_cl] @IdCl, @CreateBy, @Status, ''
	END
END
GO
/****** Object:  StoredProcedure [dbo].[SP_Insert_BlAwbHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_Insert_BlAwbHistory]                  
(                
@Id BigInt = 0,          
 @IdBlAwb NVARCHAR(100) = '',                  
 @Number NVARCHAR(100) = '',                  
 @MasterBlDate  NVARCHAR(max) ,                  
 @HouseBlNumber NVARCHAR(200) = '',                  
 @HouseBlDate  NVARCHAR(max),                  
 @Description NVARCHAR(50) = '',                  
 @FileName NVARCHAR(max) = '',                  
 @Publisher NVARCHAR(50) = '',                  
 @CreateBy NVARCHAR(50) = '',                            
 @IsDelete BIT,                  
 @IdCl NVARCHAR(100) = '',                  
 @Status NVARCHAR(100) = ''                  
)                  
 AS                  
BEGIN            
--if @IdBlAwb = 0        
--begin        
 INSERT INTO [dbo].[BlAwb_History]                  
           ([Number]                  
     ,[MasterBlDate]                  
     ,[HouseBlNumber]                  
     ,[HouseBlDate]                  
           ,[Description]                  
     ,[FileName]                  
     ,[Publisher]                  
     ,[CreateBy]                   
     ,[CreateDate]                             
           ,[IsDelete]                  
     ,[IdCl]          
  ,[IdBlAwb]          
  ,[Status]        
           )                  
     VALUES                  
           (@Number                  
     ,@MasterBlDate                  
     ,@HouseBlNumber                  
     ,@HouseBlDate                  
           ,@Description                  
     ,@FileName                  
     ,@Publisher                  
           ,@CreateBy 
		   ,GETDATE()
           ,@IsDelete                  
     ,@IdCl          
  ,@IdBlAwb        
  ,@Status)                  
--end        
--else         
--begin        
--set @Id = (select MAX( Id) from BlAwb_History where IdBlAwb = @IdBlAwb)        
--If @Id Is Null And @Id <> '' And @Id = 0      
--begin      
--INSERT INTO [dbo].[BlAwb_History]                  
--           ([Number]                  
--     ,[MasterBlDate]                  
--     ,[HouseBlNumber]                  
--     ,[HouseBlDate]                  
--           ,[Description]                  
--     ,[FileName]                  
--     ,[Publisher]                  
--     ,[CreateBy]                             
--           ,[IsDelete]                  
--     ,[IdCl]          
--  ,[IdBlAwb]          
--  ,[Status]        
--           )                  
--     VALUES                  
--           (@Number                  
--     ,@MasterBlDate                  
--     ,@HouseBlNumber                  
--     ,@HouseBlDate                  
--           ,@Description                  
--     ,@FileName                  
--     ,@Publisher                  
--           ,@CreateBy                             
--           ,@IsDelete                  
--     ,@IdCl          
--  ,@IdBlAwb        
--  ,@Status)            
--end      
--else       
--begin      
--update BlAwb_History        
--set Number          =@Number,        
--     [MasterBlDate]   = @MasterBlDate       ,        
--     [HouseBlNumber]  = @HouseBlNumber,                
--     [HouseBlDate]    = @HouseBlDate,        
--     [Description]    = @Description,              
--     [FileName]          =@FileName,        
--     [Publisher]          =@Publisher,        
--     [CreateBy]                     =@CreateBy,        
--     [IsDelete]          =@IsDelete,        
--     [IdCl]  = @IdCl,        
--  [IdBlAwb]  = @IdBlAwb,        
--  [Status] = @Status        
--  where Id = @Id and IdBlAwb = @IdBlAwb        
--end        
--end      
      
 SELECT @Id = CAST(SCOPE_IDENTITY() as bigint)                            
END
GO

/****** Object:  StoredProcedure [dbo].[SP_Insert_BlAwbRFCChange]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
           
ALTER PROCEDURE [dbo].[SP_Insert_BlAwbRFCChange]          
(          
 @Id BIGINT,  
 @IdBlAwb BIGINT ,  
 @Number NVARCHAR(100),          
 @MasterBlDate datetime,          
 @HouseBlNumber NVARCHAR(200),          
 @HouseBlDate datetime,          
 @Description NVARCHAR(50),          
 @FileName NVARCHAR(max),          
 @Publisher NVARCHAR(50),          
 @CreateBy NVARCHAR(50),          
 @CreateDate datetime,          
 @UpdateBy NVARCHAR(50),          
 @UpdateDate datetime,          
 @IsDelete BIT,          
 @IdCl BIGINT ,  
 @Status nvarchar(max)  
)          
AS          
BEGIN       
 if( @FileName  IS NULL or @FileName = '')        
 begin        
 set @FileName = (select [FileName] From BlAwb where Id = @IdBlAwb)        
 end  
if(@IdBlAwb <> 0 and @Id = 0)        
 begin       
 set @Id = (select Id from BlAwb_Change where IdBlAwb = @IdBlAwb)        
 set @Id = (select IIF(@Id IS NULL, -1, @Id) As Id)        
 end    
 IF @Id <= 0          
 BEGIN          
 INSERT INTO [dbo].[BlAwb_Change]          
           ([Number],[MasterBlDate],[HouseBlNumber],[HouseBlDate],[Description],[FileName],[Publisher],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete],[IdCl]  
  ,[IdBlAwb],[Status])          
     VALUES          
           (@Number,@MasterBlDate,@HouseBlNumber,@HouseBlDate,@Description ,@FileName,@Publisher,@CreateBy,@CreateDate,@UpdateBy,@UpdateDate,@IsDelete,@IdCl,@IdBlAwb,@Status)          
          
 set  @Id = SCOPE_IDENTITY()           
 --SELECT C.Id as ID, CONVERT(nvarchar(5), C.IdCl) as [NO], C.CreateDate as CREATEDATE FROM BlAwb C WHERE C.id = @LASTID          
 END          
 ELSE           
 BEGIN          
 UPDATE [dbo].[BlAwb_Change]          
  SET [Number] = @Number ,[MasterBlDate] = @MasterBlDate   ,[HouseBlNumber] = @HouseBlNumber  ,[HouseBlDate] = @HouseBlDate          
           ,[Description] = @Description  ,[Publisher] = @Publisher  ,[CreateBy] = @CreateBy  ,[CreateDate] = @CreateDate          
           ,[UpdateBy] = @UpdateBy   ,[UpdateDate] = @UpdateDate ,[Status] = @Status,  
     FileName = @FileName  
     WHERE Id = @Id          
     --SELECT C.Id as ID, CONVERT(nvarchar(5), C.IdCl) as [NO], C.CreateDate as CREATEDATE FROM BlAwb C WHERE C.id = @Id          
 END          
 select CAST(@Id as bigint) as Id     
 --IF(@Status <> 'Draft')      
 --BEGIN      
 -- SET @Status = 'Create BL AWB'    
 -- EXEC [sp_update_request_cl] @IdCl, @CreateBy, @Status, ''      
 --END      
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_cargo_history]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [sp_insert_cargo_history];
ALTER PROCEDURE [dbo].[sp_insert_cargo_history]
(
	@Id bigint,
	@Flow nvarchar(100),
	@Step nvarchar(100),
	@Status nvarchar(100),
	@Notes nvarchar(max) = '',
	@CreateBy nvarchar(100),
	@CreateDate datetime
)
AS 
BEGIN
	INSERT INTO [dbo].[CargoHistory]
       ([IdCargo],[Flow],[Step],[Status],[Notes],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
     VALUES
       (@Id,@Flow,@Step,@Status,@Notes,@CreateBy,@CreateDate,@CreateBy,GETDATE(),0)
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_cipl_history]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_cipl_history;
ALTER PROCEDURE [dbo].[sp_insert_cipl_history]
(
	@Id bigint,
	@Flow nvarchar(100),
	@Step nvarchar(100),
	@Status nvarchar(100),
	@Notes nvarchar(max) = '',
	@CreateBy nvarchar(100),
	@CreateDate datetime
)
AS 
BEGIN
	INSERT INTO [dbo].[CiplHistory]
       ([IdCipl],[Flow],[Step],[Status],[Notes],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
     VALUES
       (@Id,@Flow,@Step,@Status,@Notes,@CreateBy,@CreateDate,@CreateBy,GETDATE(),0)
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_cl_history]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_cipl_history;
ALTER PROCEDURE [dbo].[sp_insert_cl_history]
(
	@Id bigint,
	@Flow nvarchar(100),
	@Step nvarchar(100),
	@Status nvarchar(100),
	@Notes nvarchar(max) = '',
	@CreateBy nvarchar(100),
	@CreateDate datetime
)
AS 
BEGIN
	INSERT INTO [dbo].CargoHistory
       (IdCargo,[Flow],[Step],[Status],[Notes],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
     VALUES
       (@Id,@Flow,@Step,@Status,@Notes,@CreateBy,@CreateDate,@CreateBy,GETDATE(),0)
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_document_blAWb]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_cipl_history;      
ALTER PROCEDURE [dbo].[sp_insert_document_blAWb]      
(      
 @IdRequest bigint,     
 @BlAwbId bigint,  
 @Category nvarchar(20),      
 @Status nvarchar(100),      
 @Step bigint,      
 @Name nvarchar(100),      
 @Tag nvarchar(20),      
 @FileName nvarchar(max),      
 @Date datetime,      
 @CreateBy nvarchar(100),      
 @CreateDate datetime,      
 @UpdateBy nvarchar(100),      
 @UpdateDate datetime,      
 @IsDelete BIT      
)      
AS       
BEGIN      
  
 Update BlAwb set [filename] = @FileName where Id = @BlAwbId   
 --DELETE FROM [dbo].[Documents] WHERE IdRequest = @IdRequest AND Status = @Status AND Tag = @Tag;      
      
 INSERT INTO [dbo].[Documents]      
       ([IdRequest],[Category],[Status],[Step],[Name],[Tag],[FileName],[Date],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])      
     VALUES      
       (@IdRequest,@Category,@Status,@Step,@Name,@Tag,@FileName,@Date,@CreateBy,@CreateDate,@UpdateBy,@UpdateDate,@IsDelete)      
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_document]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_cipl_history;
ALTER PROCEDURE [dbo].[sp_insert_document]
(
	@IdRequest bigint,
	@Category nvarchar(20),
	@Status nvarchar(100),
	@Step bigint,
	@Name nvarchar(100),
	@Tag nvarchar(20),
	@FileName nvarchar(max),
	@Date datetime,
	@CreateBy nvarchar(100),
	@CreateDate datetime,
	@UpdateBy nvarchar(100),
	@UpdateDate datetime,
	@IsDelete BIT
)
AS 
BEGIN

	DELETE FROM [dbo].[Documents] WHERE IdRequest = @IdRequest AND Status = @Status AND Tag = @Tag;

	INSERT INTO [dbo].[Documents]
       ([IdRequest],[Category],[Status],[Step],[Name],[Tag],[FileName],[Date],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
     VALUES
       (@IdRequest,@Category,@Status,@Step,@Name,@Tag,@FileName,@Date,@CreateBy,@CreateDate,@UpdateBy,@UpdateDate,@IsDelete)
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_gr_history]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_cipl_history;
ALTER PROCEDURE [dbo].[sp_insert_gr_history]
(
	@Id bigint,
	@Flow nvarchar(100),
	@Step nvarchar(100),
	@Status nvarchar(100),
	@Notes nvarchar(max) = '',
	@CreateBy nvarchar(100),
	@CreateDate datetime
)
AS 
BEGIN
	INSERT INTO [dbo].GoodsReceiveHistory
       (IdGr,[Flow],[Step],[Status],[Notes],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
     VALUES
       (@Id,@Flow,@Step,@Status,@Notes,@CreateBy,@CreateDate,@CreateBy,GETDATE(),0)
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_request_data]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DROP PROCEDURE sp_insert_request_data;
ALTER PROCEDURE [dbo].[sp_insert_request_data] -- sp_insert_request_data '2', 'CIPL', 'PP', 'Draft', 'Create'
( 
	@ID nvarchar(100), -- CIPL or CL Id
	@FlowName nvarchar(100), -- ex : 'CIPL', 'CL'
	@Category nvarchar(100), -- ex : 'PP', 'UE', 'PS'
	@Status nvarchar(100), -- ex : 'DRAFT' OR 'SUBMIT'
	@StepName nvarchar(100) = 'CREATE' -- ex : 'CREATE'	
)
AS
BEGIN
	-- Insert By Logic Query
	DECLARE @IdFlow bigint;
	DECLARE @IdStep bigint;
	DECLARE @CreateBy nvarchar(100);
	DECLARE @CreateDate datetime;

	-- Set data to Logic Query Variable
	SELECT @IdFlow = Id FROM dbo.Flow where [Name] = @FlowName AND [Type] = @Category;
	SELECT @IdStep = Id FROM dbo.FlowStep where [IdFlow] = @IdFlow AND [Step] = @StepName;
	SET @CreateDate = GETDATE();
	
	IF (@FlowName = 'CIPL')
	BEGIN
		SELECT @CreateBy = CreateBy FROM dbo.Cipl WHERE Id = @ID;
		IF (ISNULL(@CreateBy, '0') <> '0') 
		BEGIN
			INSERT INTO [dbo].[RequestCipl]
				([IdCipl],[IdFlow],[IdStep],[Status],[Pic],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
			VALUES 
				(@ID,@IdFlow,@IdStep,@Status,@CreateBy,@CreateBy, @CreateDate,@CreateBy,GETDATE(),0)

			EXEC [dbo].[sp_insert_cipl_history]@ID, @FlowName, @StepName, @Status, '', @CreateBy, @CreateDate;	
		END
	END

	IF (@FlowName = 'CL')
	BEGIN 
		SELECT @CreateBy = CreateBy FROM dbo.Cargo WHERE Id = @ID;
		IF (ISNULL(@CreateBy, '0') <> '0')  
		BEGIN
			INSERT INTO [dbo].[RequestCl]
				([IdCl],[IdFlow],[IdStep],[Status],[Pic],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
			VALUES
				(@ID, @IdFlow, @IdStep, @Status, @CreateBy, @CreateBy, @CreateDate, @CreateBy, GETDATE(), 0)

			EXEC [dbo].[sp_insert_cargo_history]@ID, @FlowName, @StepName, @Status, '', @CreateBy, @CreateDate;	
		END
	END

	IF (@FlowName = 'GR')
	BEGIN 
		SELECT @CreateBy = CreateBy FROM dbo.GoodsReceive WHERE Id = @ID;
		IF (ISNULL(@CreateBy, '0') <> '0')  
		BEGIN
			INSERT INTO [dbo].[RequestGr]
				([IdGr],[IdFlow],[IdStep],[Status],[Pic],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete])
			VALUES
				(@ID, @IdFlow, @IdStep, @Status, @CreateBy, @CreateBy, @CreateDate, @CreateBy, GETDATE(), 0)

			EXEC [dbo].[sp_insert_gr_history]@ID, @FlowName, @StepName, @Status, '', @CreateBy, @CreateDate;	
		END
	END
END
GO

/****** Object:  StoredProcedure [dbo].[SP_Insert_Temptable_cipl_request_list_all]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Insert_Temptable_cipl_request_list_all]
AS
BEGIN
	DROP TABLE Temptable_cipl_request_list_all;
	SELECT * INTO Temptable_cipl_request_list_all  FROM fn_get_cipl_request_list_all();
END

GO

/****** Object:  StoredProcedure [dbo].[SP_Insert_Temptable_cl_request_list_all]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Insert_Temptable_cl_request_list_all]
AS
BEGIN
	DROP TABLE Temptable_cl_request_list_all;
	SELECT * INTO Temptable_cl_request_list_all  FROM fn_get_cl_request_list_all();
END

--select * from temptable
GO

/****** Object:  StoredProcedure [dbo].[SP_Insert_Temptable_gr_request_list_all]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_Insert_Temptable_gr_request_list_all]
AS
BEGIN
	DROP TABLE Temptable_gr_request_list_all;
	SELECT * INTO Temptable_gr_request_list_all  FROM fn_get_gr_request_list_all();
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_cargo_item_20210721]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_update_container
ALTER PROCEDURE [dbo].[sp_insert_update_cargo_item_20210721] 
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
		 select 
			@ContainerNumber
			, @ContainerType
			, @ContainerSealNumber
			, t0.IdCipl
			, @IdCargo
			, t0.Id
			, t2.DaNo
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
		 join dbo.GoodsReceiveItem t2 on t2.DoNo = t1.EdoNo
		 where t0.id = @ItemId;
	END 
	ELSE 
	BEGIN
		UPDATE [dbo].[CargoItem]
		SET [Length] = @Length
			,[ContainerNumber] = @ContainerNumber
			,[ContainerType] = @ContainerType
			,[ContainerSealNumber] = @ContainerSealNumber
		    ,[Height] = @Height
		    ,[Width] = @Width
		    ,[Net] = @NetWeight
		    ,[Gross] = @GrossWeight
			,[UpdateBy] = @ActionBy
			,[UpdateDate] = GETDATE()
		WHERE Id = @Id
	END

	SELECT CAST(@Id as bigint) as ID
END

GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_cargo_item_Change]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER ProCEDURE [dbo].[sp_insert_update_cargo_item_Change]             
(            
@Id nvarchar(100) ,      
 @IdCargoItem nvarchar(100),            
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
 @isDelete bit = 0,      
 @Status nvarchar(100)      
)            
AS            
BEGIN            
 SET NOCOUNT ON;            
            
 IF @IdCargoItem <> 0             
 BEGIN           
 set @Id = (select Id from [CargoItem_Change] where IdCargoItem= @IdCargoItem)      
 set @Id = (select IIF(@Id IS NULL, -1, @Id) As Id)      
  end    
 IF @Id <= 0       
    
 BEGIN           
 INSERT INTO [dbo].[CargoItem_Change]            
         ([IdCargoItem]      
   ,[ContainerNumber]            
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
         ,[isDelete],      
   [Status])            
   select  top 1        
   @IdCargoItem      
   ,@ContainerNumber            
   , @ContainerType            
   , @ContainerSealNumber            
   , t0.IdCipl            
   , @IdCargo            
   , t0.Id            
   , null as DaNo            
   , @Length            
   , @Width            
   , @Height            
   , @NetWeight            
   , @GrossWeight            
   , @ActionBy CreateBy            
   , GETDATE()            
   , @ActionBy UpdateBy            
   , GETDATE(), @isDelete ,      
   @Status      
   from dbo.ciplItem t0             
   join dbo.Cipl t1 on t1.id = t0.IdCipl             
   --join dbo.GoodsReceiveItem t2 on t2.DoNo = t1.EdoNo AND t2.IsDelete = 0            
   join dbo.ShippingFleetRefrence t2 on  t2.DoNo = t1.EdoNo          
   where t0.id = @ItemId;            
 set   @Id = SCOPE_IDENTITY();       
  SELECT CAST(@Id as bigint) as Id       
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
  FROM [dbo].[CargoItem_Change] WHERE Id = @Id            
              
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
            
  UPDATE [dbo].[CargoItem_Change]            
  SET [NewLength] = @Length            
   ,[ContainerNumber] = @ContainerNumber            
   ,[ContainerType] = @ContainerType            
   ,[ContainerSealNumber] = @ContainerSealNumber            
      ,[Height] = @Height            
      ,[Width] = @Width            
      ,[Net] = @NetWeight            
      ,[Gross] = @GrossWeight     
   ,[Length] = @Length  
   ,[UpdateBy] = @ActionBy            
   ,[UpdateDate] = GETDATE()         
   ,[Status] = @Status      
   ,isDelete = @isDelete      
  WHERE Id = @Id          
  SELECT CAST(@Id as bigint) as Id       
 END           
            
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

/****** Object:  StoredProcedure [dbo].[sp_insert_update_container]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_update_container
ALTER PROCEDURE [dbo].[sp_insert_update_container] 
(
	@Id nvarchar(100),
	@CargoId nvarchar(100),
	@Number nvarchar(100),
	@Description nvarchar(200),
	@ContainerType nvarchar(200),
	@SealNumber nvarchar(200),
	@ActionBy nvarchar(100),
	@IsDelete bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	IF ISNULL(@Id, 0) = 0 
	BEGIN
	INSERT INTO [dbo].[CargoContainer]
           ([Number]
		   ,[CargoId]
           ,[Description]
		   ,[ContainerType]
		   ,[SealNumber]
           ,[CreateBy]
           ,[CreateDate]
           ,[UpdateBy]
           ,[UpdateDate]
           ,[IsDelete])
     VALUES
           (@Number
		   ,@CargoId
           ,@Description
           ,@ContainerType
		   ,@SealNumber
           ,@ActionBy
           ,GETDATE()
           ,@ActionBy
           ,GETDATE()
           ,0)
	 SET @Id = SCOPE_IDENTITY();
	END
	ELSE 
	BEGIN
		UPDATE [dbo].[CargoContainer]
		SET [Number] = @Number
			,[Description] = @Description
			,[ContainerType] = @Description
			,[SealNumber] = @SealNumber
		    ,[UpdateBy] = @ActionBy
		    ,[UpdateDate] = GETDATE()
		    ,[IsDelete] = @IsDelete
		WHERE Id = @Id
	END

	SELECT CAST(@Id as bigint) as ID
END

GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_delegation]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DROP PROCEDURE [sp_insert_update_delegation]
-- sp_insert_update_delegation 'CIPL', 33, 'xupj21ech', 'user', 'xupj21wdn'
ALTER PROCEDURE [dbo].[sp_insert_update_delegation]
(
		@Type nvarchar(50),
		@IdReq bigint,		
		@Username nvarchar(100),
		@AssignType nvarchar(50),
		@AssignTo nvarchar(100)
)
AS
BEGIN
	SET NOCOUNT ON;
	-- Insert data to table delegation
	DECLARE @Status nvarchar(50),
			@IdDelegation bigint = 0,
			@IdFlow bigint = 0,
			@Id bigint = 0,
			@IdStep bigint = 0

	SELECT @Id = Id, @IdFlow = IdFlow, @IdStep = IdStep
	FROM dbo.fn_get_cipl_request_list_all() 
	WHERE IdCipl = @IdReq;	
	
	IF @IdDelegation = 0 
	BEGIN
		-- Insert data into table delegation
		INSERT INTO [dbo].[FlowDelegation]
		           ([Type], [IdReq], [IdFlow], [IdStep], [AssignType], [AssignTo], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete])
		     VALUES
		           (@Type, @Id, @IdFlow, @IdStep, @AssignType, @AssignTo, @Username, GETDATE(), @Username, GETDATE(), 0)
		
			SET @IdDelegation = SCOPE_IDENTITY();
		
		--INSERT INTO [dbo].[RequestDelegation]
		--			([IdFlowDelegation], [IdFlow], [IdStep], [Status], [Pic], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete])
		--     VALUES
		--           (@IdDelegation, @IdFlow, @IdReq, 'Submit', @Username, @Username, GETDATE(), @Username, GETDATE(),0)
		
		--	 SELECT @IdReq = Id FROM [RequestDelegation] WHERE IdFlowDelegation = @IdDelegation
		
		-- Insert data into table cipl history
		INSERT INTO [dbo].[CiplHistory]
		           ([IdCipl], [Flow], [Step], [Status], [Notes], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete])
		     VALUES
		           (@Id, 'CIPL', @IdStep, 'Submit', 'Delegation Approval', @Username, GETDATE(), @Username, GETDATE(), 0)
	END
	ELSE 
	BEGIN
		UPDATE dbo.FlowDelegation SET AssignTo = @AssignTo WHERE Id = @IdDelegation;
		--UPDATE dbo.RequestDelegation SET UpdateDate = GETDATE() where IdFlowDelegation = @IdDelegation;
	END
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_gr_armada_new]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_update_gr
ALTER PROCEDURE [dbo].[sp_insert_update_gr_armada_new] --exec sp_insert_update_gr 0, 'Tri Artha', '3211022907890004', '234002000', '32001000', 'Z5226BW', '20 Jan 2020', 'testing notes dan lain lain', 'xupj21fig', '20 Jan 2019', 'xupj21fig', '29 Jan 2019', 0 
(
	@Id nvarchar(100),
	@DoNo nvarchar(100),
	@IdGr bigint,
	@PicName nvarchar(100),
	@PhoneNumber nvarchar(100),
	@KtpNumber nvarchar(100),
	@SimNumber nvarchar(100),
	@SimExpiryDate smalldatetime,
	@StnkNumber nvarchar(100),
	@KirNumber nvarchar(50),
	@KirExpire smalldatetime,
	@NoPolNumber nvarchar(100),
	@EstimationTimePickup date,
	@Apar bit,
	@Apd bit,
	@DoReference nvarchar(100),
	@Notes nvarchar(MAX) = '',
	@VehicleType nvarchar(100),
	@VehicleMark nvarchar(100)

)
AS
BEGIN
	SET NOCOUNT ON;
	IF ISNULL(@Id, 0) = 0 
	BEGIN
		INSERT INTO [dbo].[GoodsReceiveArmadaNew]
           (
			  [DoNo]
			, [IdGr]
			, [PicName]
			, [PhoneNumber]
			, [KtpNumber]
			, [SimNumber]
			, [SimExpiryDate]
			, [StnkNumber]
			, [KirNumber]
			, [KirExpire]
			, [NoPolNumber]
			,[EstimationTimePickup]
			,[Apar]
			,[Apd]
			,[DoReference]
			,[Notes]
			,[VehicleType]
			,[VehicleMark])

		VALUES
           (@DoNo
			, @IdGr
			, @PicName
			, @PhoneNumber
			, @KtpNumber
			, @SimNumber
			, @SimExpiryDate
			,@StnkNumber
			, @KirNumber
			,@KirExpire
			,@NoPolNumber
			,@EstimationTimePickup
			,@Apar
			,@Apd
			,@DoReference
			,@Notes
			,@VehicleType
			,@VehicleMark)

		SET @Id = SCOPE_IDENTITY()
	END
	ELSE 
	BEGIN
		UPDATE [dbo].[GoodsReceiveArmadaNew]
		SET    [Notes] = @Notes
			  ,[DoReference] = @DoReference		
		      ,[VehicleType] = @VehicleType
		      ,[VehicleMark] = @VehicleMark
		WHERE Id = @Id

	END
	SELECT CAST(@Id as bigint) as ID
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_gr_item]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE [sp_insert_update_gr_item]
ALTER PROCEDURE [dbo].[sp_insert_update_gr_item] --exec [sp_insert_update_gr_item] 0, 'Tri Artha', '3211022907890004', '234002000', '32001000', 'Z5226BW', '20 Jan 2020', 'testing notes dan lain lain', 'xupj21fig', '20 Jan 2019', 'xupj21fig', '29 Jan 2019', 0 
(
	@Id nvarchar(100),
	@IdCipl nvarchar(100),
	@IdGr nvarchar(100),
	@DoNo nvarchar(100),
	@DaNo nvarchar(100),
	@FileName	nvarchar(100),
	@CreateBy nvarchar(100),
	@CreateDate nvarchar(100),
	@UpdateBy nvarchar(100) = '',
	@UpdateDate nvarchar(100) = '',
	@IsDelete bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	IF ISNULL(@Id, 0) = 0 
	BEGIN
		INSERT INTO [dbo].[GoodsReceiveItem]
           ([IdGr],[IdCipl],[DoNo],[DaNo],[FileName],[CreateDate],[CreateBy],[UpdateDate],[UpdateBy],[IsDelete])
		VALUES
           (@IdGr, @IdCipl, @DoNo, @DaNo, @FileName, @CreateDate, @CreateBy, @UpdateDate, @UpdateBy, @IsDelete)

		SET @Id = SCOPE_IDENTITY()
	END
	ELSE 
	BEGIN
		UPDATE [dbo].[GoodsReceiveItem] SET 
			  IdGr = @IdGr
			  , IdCipl = @IdCipl
			  , DoNo = @DoNo
			  , DaNo = @DaNo
			  , FileName = @FileName
		      ,[UpdateBy] = @UpdateBy
		      ,[UpdateDate] = @UpdateDate
		      ,[IsDelete] = @IsDelete
		WHERE Id = @Id
	END
	SELECT CAST(@Id as bigint) as ID
END

GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_gr_new]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_insert_update_gr_new] --exec sp_insert_update_gr 0, 'Tri Artha', '3211022907890004', '234002000', '32001000', 'Z5226BW', '20 Jan 2020', 'testing notes dan lain lain', 'xupj21fig', '20 Jan 2019', 'xupj21fig', '29 Jan 2019', 0 
(
	@Id nvarchar(100),
	@GrNo nvarchar(20),
	@Notes nvarchar(max),
	@Vendor nvarchar(100),
	@CreateBy nvarchar(100),
	@CreateDate smalldatetime,
	@UpdateBy nvarchar(100) = '',
	@UpdateDate smalldatetime,
	@IsDelete bit = 0,
	@PickupPoint nvarchar(100) = '',
	@PickupPic nvarchar(100) = '',
	@Status nvarchar(100) = 'Draft'

)
AS
BEGIN
	SET NOCOUNT ON;
	IF ISNULL(@Id, 0) = 0 
	BEGIN
		INSERT INTO [dbo].[GoodsReceiveNew]
           (
			  [GrNo]
			, [Vendor]
			, [PickupPoint]
			, [PickupPic]
			, [Notes]
			, [CreatedBy]
			, [CreateDate]
			, [UpdatedBy]
			, [UpdateDate])
		VALUES
           (@GrNo
			, @Vendor
			, @PickupPoint
			, @PickupPic
			, @Notes
			, @CreateBy
			, @CreateDate
			,@UpdateBy
			, @UpdateDate)

		SET @Id = SCOPE_IDENTITY()
		EXEC [dbo].[GenerateGoodsReceiveNumber] @Id
		EXEC [dbo].[sp_insert_request_data] @Id, 'GR', '', @Status, 'Create'
	END
	ELSE 
	BEGIN
		UPDATE [dbo].[GoodsReceiveNew]
		SET    [Notes] = @Notes
			  ,[Vendor] = @Vendor		
		      ,[UpdatedBy] = @UpdateBy
		      ,[UpdateDate] = @UpdateDate
		
		
		WHERE Id = @Id

		EXEC [dbo].[sp_update_request_gr] @Id, @UpdateBy, @Status, ''
	END
	SELECT CAST(@Id as bigint) as ID
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

/****** Object:  StoredProcedure [dbo].[sp_insert_update_problem_history]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_cipl_history;
ALTER PROCEDURE [dbo].[sp_insert_update_problem_history]
(
	@ReqType nvarchar(100),
	@IDRequest nvarchar(100),
	@Category nvarchar(100),
	@Case nvarchar(100),
	@Causes nvarchar(100),
	@Impact nvarchar(100),
	@Comment nvarchar(max),
	@CaseDate nvarchar(100),
	@CreateBy nvarchar(100),
	@CreateDate nvarchar(100),
	@UpdateBy nvarchar(100),
	@UpdateDate nvarchar(100),
	@IdStep nvarchar(100),
	@Status nvarchar(100),
	@IsDelete nvarchar(100) = '0'
)
AS 
BEGIN
	SET NOCOUNT ON;  
	DECLARE @sql nvarchar(max);
	DECLARE @Id bigint;
	SET @sql = 'INSERT INTO [dbo].[ProblemHistory](
					[ReqType],[IDRequest],[Category],[Case],[Causes],[Impact],[Comment],[CaseDate],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete],[IdStep],[Status])
				VALUES	
					('''+@ReqType+''','''+@IDRequest+''','''+@Category+''','''+@Case+''','''+@Causes+''','''+@Impact+''','''+@Comment+''','''+@CaseDate+''','''+@CreateBy+''','''+@CreateDate+''','''+@UpdateBy+''','''+@UpdateDate+''','''+@IsDelete+''', '''+@IdStep+''', '''+@Status+''')';
	--select @sql;
	execute(@sql);
	select CAST(@@IDENTITY as bigint) ID
END
GO

/****** Object:  StoredProcedure [dbo].[sp_insert_update_superior]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_insert_update_superior] --exec sp_insert_update_gr 0, 'Tri Artha', '3211022907890004', '234002000', '32001000', 'Z5226BW', '20 Jan 2020', 'testing notes dan lain lain', 'xupj21fig', '20 Jan 2019', 'xupj21fig', '29 Jan 2019', 0 
(
	@Id bigint,
	@EmployeeUsername nvarchar(100),
	@SuperiorUsername nvarchar(100),
	@Isdelete bit = 0,
	@UpdateBy nvarchar(100),
	@UpdateDate nvarchar(100),
	@CreateBy nvarchar(100),
	@CreateDate nvarchar(100)
)
AS
BEGIN
	DECLARE @EmployeeName nvarchar(500);
	DECLARE @SuperiorName nvarchar(500);

	SELECT @EmployeeName = Employee_Name + ' - ' + AD_User from Employee
	WHERE AD_User = @EmployeeUsername;

	SELECT @SuperiorName = Employee_Name + ' - ' + AD_User from Employee
	WHERE AD_User = @SuperiorUsername;

	
	SET NOCOUNT ON;
	IF ISNULL(@Id, 0) = 0 
	BEGIN
		INSERT INTO [dbo].[MasterSuperior]
			   ([EmployeeUsername]
			   ,[EmployeeName]
			   ,[SuperiorUsername]
			   ,[SuperiorName]
			   ,[IsDeleted]
			   ,[CreateBy]
			   ,[CreateDate]
			   ,[UpdateBy]
			   ,[UpdateDate])
		 VALUES
			   (@EmployeeUsername
			   ,@EmployeeName
			   ,@SuperiorUsername
			   ,@SuperiorName
			   ,@IsDelete
			   ,@CreateBy
			   ,@CreateDate
			   ,Null
			   ,NULL)
	END
	ELSE 
	BEGIN
		UPDATE [dbo].[MasterSuperior] SET 
		[EmployeeUsername] = @EmployeeUsername,
		[EmployeeName] = @EmployeeName,
		[SuperiorUsername] = @SuperiorUsername,
		[SuperiorName] = @SuperiorName,
		[UpdateBy] = @UpdateBy,
		[UpdateDate] = @UpdateDate,
		[IsDeleted] = @IsDelete
		WHERE Id = @Id
	END
	SELECT CAST(1 as bigint) as ID
END
GO

/****** Object:  StoredProcedure [dbo].[SP_MasterVendorAdd]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_MasterVendorAdd]  
(  
@Id nvarchar(100),  
@Name nvarchar(max),  
@Code nvarchar(max),
@Address nvarchar(max), 
@City nvarchar(max), 
@Telephone nvarchar(max), 
@CreateBy nvarchar(Max),  
@UpdatedBy nvarchar(Max),
@IsManualEntry bit
)  
as  
begin  
If (@Id = 0)  
begin  
insert into [MasterVendor]([Name],[Code],[Address],City,Telephone,CreateBy,CreateDate,UpdateBy,UpdateDate,IsManualEntry)  
VALUES(@Name,@Code,@Address,@City,@Telephone,@CreateBy,GetDate(),null,null,@IsManualEntry)  
SET @Id = SCOPE_IDENTITY()
update MasterVendor
set Code = @Code+@Id
where Id= @Id
end  
else  
begin  
update [MasterVendor]  
set [Name] = @Name,  
[Address] = @Address,
City = @City,
Telephone= @Telephone, 
UpdateBy = @UpdatedBy,   
UpdateDate = GETDATE()  
where Id = @Id  
end  
select CAST(@Id as bigint) as Id
end
GO

/****** Object:  StoredProcedure [dbo].[SP_MasterVendorDelete]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_MasterVendorDelete]  
(@Id bigint)  
as   
begin  
delete from MasterVendor  
where Id = @Id   
select @Id as Id  
end 
GO

/****** Object:  StoredProcedure [dbo].[SP_NpePeb_Update]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_NpePeb_Update]    
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

/****** Object:  StoredProcedure [dbo].[SP_PackagesItemUpdate]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_PackagesItemUpdate]
(
	@Id BIGINT,
	@PackagesInsured DECIMAL(20,2) = 0,
	@CustReferences NVARCHAR(50) = '',
	@UpdateBy NVARCHAR(50),
	@UpdateDate datetime
)
AS
BEGIN

	UPDATE dbo.DHLPackage
	SET Insured = @PackagesInsured
		   ,CustReferences = @CustReferences
		   ,UpdateBy = @UpdateBy
           ,UpdateDate = UpdateDate
	WHERE DHLPackageID = @Id;

END
GO

/****** Object:  StoredProcedure [dbo].[sp_proccess_email]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sp_proccess_email 10, 'CIPL'
ALTER PROCEDURE [dbo].[sp_proccess_email](
                @RequestID bigint,
                @TypeFlow nvarchar(100)
)
AS
BEGIN
                --DECLARE @RequestID bigint = 6
                DECLARE 
                @IdFlow bigint,
                @IdStep bigint,
                @Status nvarchar(100),
                @SendType nvarchar(100),
                @SendTo nvarchar(100),
                @Name nvarchar(100),
                @Subject nvarchar(max), 
                @Template nvarchar(max),
                @Requestor nvarchar(max),
                @NextPic nvarchar(max),
                @LastPic nvarchar(max),
                @NextAssignType nvarchar(max),
				@TypeDoc nvarchar(max)

                IF @TypeFlow = 'CIPL'
                BEGIN
                                
                                DECLARE csr CURSOR 
                FOR 
                                --DECLARE @RequestID bigint = 6;
                                SELECT 
                                                t0.IdFlow, t0.IdStep, t0.Status, t1.SendType, t1.SendTo, t1.Name, t1.Subject, t1.Template,
                                                t0.CreateBy, t0.NextAssignTo, t0.Pic 
                                FROM fn_get_cipl_request_list_all() t0
                                LEFT JOIN NotifikasiEmail t1 on t1.IdFlow = t0.idFlow and t1.idStep = t0.idStep and t1.Status like '%' + t0.Status + '%'
                                WHERE t0.IdCipl = @RequestID
                                                
                                OPEN csr
                                                FETCH NEXT FROM csr
                                INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic
                                
                                                WHILE @@FETCH_STATUS = 0
                                                BEGIN

                                                SELECT @subject = dbo.[fn_proccess_email_template]('CIPL', @RequestID, @subject, @TypeDoc, @LastPic)
                                                SELECT @Template = dbo.[fn_proccess_email_template]('CIPL', @RequestID, @Template, @TypeDoc, @LastPic)
                                                
                                                -- IF(@IdStep IN (10,10026,10023,10016) AND @Status = 'Approve')
												IF(@IdStep IN (10) AND @Status = 'Approve')
                                                BEGIN
                                                                DECLARE @CKB_TEAM nvarchar(max) = 'ict.bpm@trakindo.co.id'
                                                                                , @TemplateCKB nvarchar(max) = ''
                                                                                , @EmailSubject nvarchar(max) = ''
                                                                                , @EmailMessage nvarchar(max); 

                                                                SELECT @EmailSubject = E.Subject, @EmailMessage = E.Message, @TypeDoc = E.RecipientType FROM EmailTemplate E WHERE RecipientType = 'CKB'
                                                                
                                                                SELECT @EmailSubject= dbo.[fn_proccess_email_template]('CIPL', @RequestID, @EmailSubject, @TypeDoc, @LastPic)
                                                                SELECT @EmailMessage = dbo.[fn_proccess_email_template]('CIPL', @RequestID, @EmailMessage, @TypeDoc, @LastPic)

                                                                SELECT @CKB_TEAM = CF.Email FROM CiplForwader CF WHERE IdCipl = @RequestID
                                                    exec [dbo].[sp_send_email_for_single] @EmailSubject, '', @EmailMessage, @CKB_TEAM                                                                
                                
                                                                --exec sp_send_email_for_ckb @EmailSubject, @CKB_TEAM, @EmailMessage
                                                END

                                                -- Send email
                                                IF (@SendType = 'Group')
                                                BEGIN
                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                END
                                                ELSE
                                                BEGIN
                                                                IF (@SendType = 'Requestor')
                                                                BEGIN                                                   
                                                                                exec sp_send_email_for_single @subject, @Requestor, @Template
                                                                END
                
                                                                IF (@SendType = 'Thankyou')
                                                                BEGIN
                                                                                exec sp_send_email_for_single @subject, @LastPic, @Template
                                                                END

                                                                IF (@SendType = 'LastApprover')
                                                                BEGIN
                                                                                exec sp_send_email_for_single @subject, @LastPic, @Template
                                                                END
                                                                
                                                                IF (@SendType = 'NextApprover')
                                                                BEGIN
                                                                                IF (@NextAssignType = 'Group')
                                                                                BEGIN
                                                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                                                END
                                                                                ELSE
                                                                                BEGIN
                                                                                                IF(@NextPic IS NULL)
                                                                                                BEGIN
                                                                                                                SET @NextPic = @LastPic;
                                                                                                END
                                                                                                exec sp_send_email_for_single @subject, @NextPic, @Template
                                                                                                
                                                                                END
                                                                END       
                                                END
                                                FETCH NEXT FROM csr INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic
                                END
                                CLOSE csr
                                DEALLOCATE csr
                END

                IF @TypeFlow = 'CL'
                BEGIN
                
                DECLARE csr CURSOR 
            FOR 
                                --DECLARE @RequestID bigint = 6;
                                SELECT 
                                                t0.IdFlow, t0.IdStep, t0.Status, t1.SendType, t1.SendTo, t1.Name, t1.Subject, t1.Template,
                                                t0.CreateBy, t0.NextAssignTo, t0.Pic, t0.AssignmentType
                                FROM fn_get_cl_request_list_all() t0
                                LEFT JOIN NotifikasiEmail t1 on t1.IdFlow = t0.idFlow and t1.idStep = t0.idStep and t1.Status like '%' + t0.Status + '%'
                                --WHERE t0.IdCl = 973
                                WHERE t0.IdCl = @RequestID
                                                
                                OPEN csr
                                                FETCH NEXT FROM csr
                                                INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic, @NextAssignType
                                
                                                WHILE @@FETCH_STATUS = 0
                                                BEGIN

                                                SELECT @subject = dbo.[fn_proccess_email_template]('CL', @RequestID, @subject, @TypeDoc, @LastPic)
                                                SELECT @Template = dbo.[fn_proccess_email_template]('CL', @RequestID, @Template, @TypeDoc, @LastPic)

                                                -- Send email
                                                IF (@SendType = 'Group')
                                                BEGIN
                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                END
                                                ELSE
                                                BEGIN
                                                                IF (@SendType = 'Requestor')
                                                                BEGIN                                                   
                                                                                exec sp_send_email_for_single @subject, @Requestor, @Template
                                                                END
                
                                                                IF (@SendType = 'Thankyou')
                                                                BEGIN
                                                                                exec sp_send_email_for_single @subject, @LastPic, @Template
                                                                END
                                                                
                                                                IF (@SendType = 'NextApprover')
                                                                BEGIN
                                                                                IF (@NextAssignType = 'Group')
                                                                                BEGIN
                                                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                                                END
                                                                                ELSE
                                                                                BEGIN
                                                                                   IF(@NextPic IS NULL)
                                                                                                BEGIN
                                                                                                SET @NextPic = @LastPic;
                                                                      END
                                                                                                exec sp_send_email_for_single @subject, @NextPic, @Template
                                                                                                
                                                                                END
                                                                END
                
                                                END
                                                FETCH NEXT FROM csr INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic, @NextAssignType
                                END
                                CLOSE csr
                                DEALLOCATE csr
                END

                IF @TypeFlow = 'RG'
                BEGIN
                
                DECLARE csr CURSOR 
                FOR 
                                SELECT 
                                                t0.IdFlow, t0.IdStep, t0.[Status], t1.SendType, t1.SendTo, t1.Name, t1.Subject, t1.Template,
                                                t0.CreateBy, t0.NextAssignTo, t0.Pic, t0.NextAssignType 
                                FROM fn_get_gr_request_list_all() t0
                                LEFT JOIN NotifikasiEmail t1 on t1.IdFlow = t0.idFlow and t1.idStep = t0.idStep and t1.Status like '%' + t0.Status + '%'
                                WHERE t0.IdGr = @RequestID
                                
                                OPEN csr
                                                FETCH NEXT FROM csr
                                                INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic, @NextAssignType
                                
                                                WHILE @@FETCH_STATUS = 0
                                                BEGIN

                                                SELECT @subject = dbo.[fn_proccess_email_template]('RG', @RequestID, @subject, @TypeDoc, @LastPic)
                                                SELECT @Template = dbo.[fn_proccess_email_template]('RG', @RequestID, @Template, @TypeDoc, @LastPic)

                                                ---- Send email
                                                IF (@SendType = 'Group')
                                                BEGIN
                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                END
                                                ELSE
                                                BEGIN
                                                                IF (@SendType = 'Requestor')
                                                                BEGIN                                                   
                                                                                exec sp_send_email_for_single @subject, @Requestor, @Template
                                                                END
                
                                                                IF (@SendType = 'Thankyou')
                                                                BEGIN
                                                                                exec sp_send_email_for_single @subject, @LastPic, @Template
                    END

                                                                IF (@SendType = 'LastApprover')
                                                                BEGIN
                           exec sp_send_email_for_single @subject, @LastPic, @Template
                                  END
                                                                                                
                                                                IF (@SendType = 'NextApprover')
                                                                BEGIN
                                                                                IF (@NextAssignType = 'Group')
                                                                                BEGIN
                                                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                                                END
                                                                                ELSE
                                                                                BEGIN
                                                                                                IF(@NextPic IS NULL)
                                                                                                BEGIN
                                                                                                                SET @NextPic = @LastPic;
                                                                                                END
                                                                                                exec sp_send_email_for_single @subject, @NextPic, @Template
                                                                
                                                                                END
                                                                END       
                                                END
                                                                                                                                                
                                                FETCH NEXT FROM csr INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic, @NextAssignType
                                END
                                CLOSE csr
                                DEALLOCATE csr
                END
END
GO

/****** Object:  StoredProcedure [dbo].[sp_proccess_template]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_proccess_template]
(
	@requestType nvarchar(100) = 'CIPL',
	@requestId nvarchar(100) = '',
	@template nvarchar(max) = ''
)
AS
BEGIN
	------------------------------------------------------------------
	-- 1. Melakukan Declare semua variable yang dibutuhkan
	------------------------------------------------------------------
	BEGIN
		-- ini hanya sample silahkan comment jika akan digunakan
		SET @template = 'Ini adalah email dari [requestor_name], dan ini adalah email untuk [last_pic_name]. selanjutnya akan dikirim ke [next_pic_name]';
		DECLARE @variable_table TABLE (
		    key_data VARCHAR(MAX) NULL,
		    val_data VARCHAR(MAX) NULL
		);

		DECLARE 
			@key NVARCHAR(MAX), 
			@flow NVARCHAR(MAX), 
			@val NVARCHAR(MAX),
			@requestor_name NVARCHAR(MAX),
			@requestor_id NVARCHAR(MAX),
			@requestor_username NVARCHAR(MAX),
			@last_pic_name NVARCHAR(MAX),
			@last_pic_id NVARCHAR(MAX),
			@last_pic_username NVARCHAR(MAX),
			@next_pic_name NVARCHAR(MAX),
			@next_pic_id NVARCHAR(MAX),
			@next_pic_username NVARCHAR(MAX),
			@si_number NVARCHAR(MAX) = '',
			@ss_number NVARCHAR(MAX) = '',
			@req_number NVARCHAR(MAX) = '',
			@npe_number NVARCHAR(MAX) = '',
			@peb_number NVARCHAR(MAX) = '',
			@bl_awb_number NVARCHAR(MAX) = ''
	END
	
	------------------------------------------------------------------
	-- 2. Query untuk mengisi data ke variable variable yang dibutuhkan
	------------------------------------------------------------------
	BEGIN
		-- Mengambil data dari fn request per flow
		BEGIN
			IF (@requestType = 'CIPL')
			BEGIN
				SET @flow = 'CIPL';
				SELECT 
					@requestor_id = t1.Employee_ID,
					@requestor_name = t1.Employee_Name,
					@requestor_username = t1.AD_User,
					@last_pic_id = t2.Employee_ID,
					@last_pic_name = t2.Employee_Name,
					@last_pic_username = t2.AD_User,
					@next_pic_id = t3.Employee_ID,
					@next_pic_name = t3.Employee_Name,
					@next_pic_username = t3.AD_User,
					@req_number = t4.CiplNo
				FROM 
					dbo.fn_get_cipl_request_list_all() t0 
					INNER JOIN dbo.Cipl t4 on t4.id = t0.IdCipl
					INNER JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t1.AD_User = t0.Pic
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t1.AD_User = t0.NextAssignTo
				WHERE 
					t0.Id = @requestId;
			END

			IF (@requestType IN ('CL', 'BLAWB', 'PEB_NPE'))
			BEGIN
				SET @flow = @requestType;
				SELECT 
					@requestor_id = t5.Employee_ID,
					@requestor_name = t5.Employee_Name,
					@requestor_username = t5.AD_User,
					@last_pic_id = t6.Employee_ID,
					@last_pic_name = t6.Employee_Name,
					@last_pic_username = t6.AD_User,
					@next_pic_id = t7.Employee_ID,
					@next_pic_name = t7.Employee_Name,
					@next_pic_username = t7.AD_User,
					@req_number = t1.ClNo,
					@ss_number = t1.SsNo,
					@si_number = t2.SlNo,
					@npe_number = t3.NpeNumber,
					@peb_number = t3.PebNumber,
					@bl_awb_number = t4.Number
				FROM 
					dbo.fn_get_cl_request_list_all() t0 
					INNER JOIN dbo.Cargo t1 on t1.id = t0.IdCl
					INNER JOIN dbo.ShippingInstruction t2 on t2.IdCL = t0.IdCl
					INNER JOIN dbo.NpePeb t3 on t3.IdCL = t0.IdCl
					INNER JOIN dbo.BlAwb t4 on t4.IdCL = t0.IdCl
					INNER JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.CreateBy
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t6 on t6.AD_User = t0.Pic
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t7 on t7.AD_User = t0.NextAssignTo
				WHERE 
					t0.Id = @requestId;
				SELECT * FROM dbo.fn_get_cl_request_list_all() t0 where t0.Id = @requestId;
			END

			IF (@requestType = 'RG')
			BEGIN
				SET @flow = 'Receive Goods';
				SELECT 
					@requestor_id = t1.Employee_ID,
					@requestor_name = t1.Employee_Name,
					@requestor_username = t1.AD_User,
					@last_pic_id = t2.Employee_ID,
					@last_pic_name = t2.Employee_Name,
					@last_pic_username = t2.AD_User,
					@next_pic_id = t3.Employee_ID,
					@next_pic_name = t3.Employee_Name,
					@next_pic_username = t3.AD_User,
					@req_number = t4.GrNo
				FROM 
					dbo.fn_get_gr_request_list_all() t0 
					INNER JOIN dbo.GoodsReceive t4 on t4.id = t0.IdGr
					INNER JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t1.AD_User = t0.Pic
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t1.AD_User = t0.NextAssignTo
				WHERE 
					t0.Id = @requestId;
			END

			IF (@requestType = 'DELEGATION')
			BEGIN
				SET @flow = 'Delegation';
				SELECT * FROM dbo.fn_get_gr_request_list_all() t0 where t0.Id = @requestId;
			END

			INSERT 
				INTO 
					@variable_table 
				VALUES 
					('[flow]', @flow)
					,('[requestor_name]', @requestor_name)
					,('[requestor_id]', @requestor_id)
					,('[last_pic_name]', @last_pic_name)
					,('[last_pic_id]', @last_pic_id)
					,('[next_pic_name]', @next_pic_name)
					,('[next_pic_id]', @next_pic_id)
					,('[si_number]', @si_number)
					,('[ss_number]', @ss_number)
					,('[req_number]', @req_number)
					,('[npe_number]', @npe_number)
					,('[peb_number]', @peb_number)
					,('[bl_awb_number]', @bl_awb_number)
		END
	END
	
	------------------------------------------------------------------
	-- 3. Melakukan Replace terhadap data yang di petakan di template dgn menggunakan perulangan
	------------------------------------------------------------------
	BEGIN
		DECLARE cursor_variable CURSOR
		FOR 
			SELECT 
				key_data, 
				val_data 
			FROM 
				@variable_table;
						 
		OPEN cursor_variable; 
		FETCH NEXT FROM cursor_variable INTO @key, @val; 
		WHILE @@FETCH_STATUS = 0
		    BEGIN
				-- Melakukan Replace terhadap variable di template dengan value dari hasil pencarian data diata.
				IF ISNULL(@key, '') <> ''
				BEGIN
					SET @template = REPLACE(@template, @key, @val);
				END

				FETCH NEXT FROM cursor_variable INTO 
		            @key, 
		            @val;
		    END;
		 
		CLOSE cursor_variable; 
		DEALLOCATE cursor_variable;
	END
	
	------------------------------------------------------------------
	-- 4. Menampilkan hasil dari proses replace
	------------------------------------------------------------------
	BEGIN
		SELECT @template AS result;
	END
END
GO

/****** Object:  StoredProcedure [dbo].[sp_Process_Email_RFC]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[sp_Process_Email_RFC]  --exec      [sp_Process_Email_RFC]  '281','Approval'
@RFCId int,      
@Doctype nvarchar(200)      
AS      
BEGIN      
  DECLARE @Email nvarchar(200)      
  DECLARE @Subject nvarchar(max)      
  DECLARE @Template nvarchar(max)      
  DECLARE @NextApproverEmail nvarchar(max)      
  DECLARE @ApproverUser nvarchar(max)      
  DECLARE @RequestorUser nvarchar(max)      
  DECLARE @FormType nvarchar(max)      
  DECLARE @FormId int      
  DECLARE @CreatorEmail nvarchar(max)      
  DECLARE @CCReceipent nvarchar(max)      
  DECLARE @MailTo nvarchar(max)      
  DECLARE @ProfileName nvarchar(max) = 'EMCS'      
  SELECT      
    @FormType = RFC.FormType,      
    @FormId = CONVERT(int, RFC.FormId),      
    @RequestorUser = (SELECT Email FROM dbo.fn_get_employee_internal_ckb() WHERE AD_User = RFC.CreateBy),      
    @ApproverUser = (SELECT Email FROM dbo.fn_get_employee_internal_ckb() WHERE AD_User = RFC.Approver)      
  FROM RequestForChange RFC      
  WHERE ID = @RFCId      
      
  SET @NextApproverEmail =      
                          CASE      
                            WHEN (@ApproverUser = 'xupj21dxd') THEN (SELECT      
                                Email      
                              FROM dbo.fn_get_employee_internal_ckb()      
                              WHERE AD_User = 'xupj21fig')      
                            WHEN (@ApproverUser = 'xupj21fig') THEN (SELECT      
                                Email      
                              FROM dbo.fn_get_employee_internal_ckb()      
                              WHERE AD_User = 'xupj21dxd')      
                            ELSE (SELECT      
                                Email      
                              FROM dbo.fn_get_employee_internal_ckb()      
                              WHERE AD_User = 'xupj21dxd')      
                          END;      
      
  SET @CreatorEmail =      
                     CASE      
                       WHEN @FormType = 'CIPL' THEN (SELECT      
                           Email      
                         FROM dbo.fn_get_employee_internal_ckb()      
                         WHERE AD_User = (SELECT TOP 1      
                           CreateBy      
                         FROM Cipl      
                         WHERE id = @FormId))      
                       WHEN @FormType = 'Cargo' THEN (SELECT      
                           Email      
                         FROM dbo.fn_get_employee_internal_ckb()      
                         WHERE AD_User = (SELECT TOP 1      
                           CreateBy      
                         FROM Cargo      
                         WHERE id = @FormId))      
						WHEN @FormType = 'GoodsReceive' THEN (SELECT      
                           Email      
                         FROM dbo.fn_get_employee_internal_ckb()      
                         WHERE AD_User = (SELECT TOP 1      
                           CreateBy      
                         FROM GoodsReceive      
                         WHERE id = @FormId))   
                       WHEN @FormType = 'ShippingInstruction' THEN (SELECT      
                           Email      
                         FROM dbo.fn_get_employee_internal_ckb()      
                         WHERE AD_User = (SELECT TOP 1      
                           CreateBy      
                         FROM ShippingInstruction      
                         WHERE IdCL = @FormId))      
                       WHEN @FormType = 'BlAwb' THEN (SELECT      
                           Email      
                         FROM dbo.fn_get_employee_internal_ckb()      
                         WHERE AD_User = (SELECT TOP 1      
                           CreateBy      
                         FROM BlAwb      
                         WHERE IdCl = @FormId))      
                       ELSE (SELECT      
                           Email      
                         FROM dbo.fn_get_employee_internal_ckb()      
                         WHERE AD_User = (SELECT TOP 1      
                           CreateBy      
                         FROM NpePeb      
                         WHERE IdCl = @FormId))      
                     END      
      
  SET @CCReceipent = @CreatorEmail + ';' + @NextApproverEmail  
      
  IF (@Doctype = 'Approval')      
  BEGIN      
    SELECT      
      @Subject = [Subject],      
      @Template = [Message]      
    FROM EmailTemplate      
    WHERE [Module] = 'RFC'      
    AND [Status] = 'Approval'      
    AND RecipientType = 'Requestor'      
      
    SET @Subject = dbo.[fn_proccess_email_template_RFC](@RFCId, @Subject)      
    SET @Template = dbo.[fn_proccess_email_template_RFC](@RFCId, @Template)      
    SET @MailTo = @RequestorUser     
      
BEGIN      
    EXEC msdb.dbo.sp_send_dbmail @recipients = @MailTo,      
                                 @copy_recipients = @CCReceipent,      
                                 @subject = @subject,      
                           @body = @Template,      
                                 @body_format = 'HTML',      
                                 @profile_name = @ProfileName;      
      
    INSERT INTO dbo.Test_Email_Log ([To], Content, [Subject], CreateDate)      
      VALUES (@Email, @Template, @subject, GETDATE());      
  END      
      
    SELECT      
      @Subject = [Subject],      
      @Template = [Message]      
    FROM EmailTemplate      
    WHERE [Module] = 'RFC'      
    AND [Status] = 'Approval'      
    AND RecipientType = 'Approver'      
      
    SET @Subject = dbo.[fn_proccess_email_template_RFC](@RFCId, @Subject)      
    SET @Template = dbo.[fn_proccess_email_template_RFC](@RFCId, @Template)      
    SET @MailTo = @ApproverUser      
      
  BEGIN      
    EXEC msdb.dbo.sp_send_dbmail @recipients = @MailTo,      
                                 @copy_recipients = @CCReceipent,      
                                 @subject = @subject,      
                                 @body = @Template,      
                                 @body_format = 'HTML',      
                                 @profile_name = @ProfileName;      
      
    INSERT INTO dbo.Test_Email_Log ([To], Content, [Subject], CreateDate)      
      VALUES (@Email, @Template, @subject, GETDATE());      
  END      
      
  END      
  ELSE      
  IF (@Doctype = 'Approved')      
  BEGIN      
    SELECT      
      @Subject = [Subject],      
      @Template = [Message]      
    FROM EmailTemplate      
    WHERE [Module] = 'RFC'      
    AND [Status] = 'Approved'      
    AND RecipientType = 'Requestor'      
      
    SET @Subject = dbo.[fn_proccess_email_template_RFC](@RFCId, @Subject)      
    SET @Template = dbo.[fn_proccess_email_template_RFC](@RFCId, @Template)      
    SET @MailTo = @RequestorUser      
  BEGIN      
    EXEC msdb.dbo.sp_send_dbmail @recipients = @MailTo,      
                                 @copy_recipients = @CCReceipent,      
                                 @subject = @subject,      
                                 @body = @Template,      
                                 @body_format = 'HTML',      
                                 @profile_name = @ProfileName;      
      
    INSERT INTO dbo.Test_Email_Log ([To], Content, [Subject], CreateDate)      
      VALUES (@Email, @Template, @subject, GETDATE());      
  END      
      
      
    SELECT      
      @Subject = [Subject],      
      @Template = [Message]      
    FROM EmailTemplate      
    WHERE [Module] = 'RFC'      
    AND [Status] = 'Approved'      
    AND RecipientType = 'Approver'      
      
    SET @Subject = dbo.[fn_proccess_email_template_RFC](@RFCId, @Subject)      
    SET @Template = dbo.[fn_proccess_email_template_RFC](@RFCId, @Template)      
    SET @MailTo = @ApproverUser      
      
  BEGIN      
    EXEC msdb.dbo.sp_send_dbmail @recipients = @MailTo,      
                                 @copy_recipients = @CCReceipent,      
                                 @subject = @subject,      
                                 @body = @Template,      
                                 @body_format = 'HTML',      
                                 @profile_name = @ProfileName;      
      
    INSERT INTO dbo.Test_Email_Log ([To], Content, [Subject], CreateDate)      
      VALUES (@Email, @Template, @subject, GETDATE());      
  END      
      
  END      
  ELSE      
  BEGIN      
    SELECT      
      @Subject = [Subject],      
      @Template = [Message]      
    FROM EmailTemplate      
    WHERE [Module] = 'RFC'      
    AND [Status] = 'Reject'      
    AND RecipientType = 'Requestor'      
      
    SET @Subject = dbo.[fn_proccess_email_template_RFC](@RFCId, @Subject)      
    SET @Template = dbo.[fn_proccess_email_template_RFC](@RFCId, @Template)      
    SET @MailTo = @RequestorUser      
      
  BEGIN      
    EXEC msdb.dbo.sp_send_dbmail @recipients = @MailTo,      
                                 @copy_recipients = @CCReceipent,      
                                 @subject = @subject,     
                                 @body = @Template,      
                                 @body_format = 'HTML',      
                                 @profile_name = @ProfileName;      
      
    INSERT INTO dbo.Test_Email_Log ([To], Content, [Subject], CreateDate)      
      VALUES (@Email, @Template, @subject, GETDATE());      
  END      
      
      
    SELECT      
      @Subject = [Subject],      
      @Template = [Message]      
    FROM EmailTemplate      
    WHERE [Module] = 'RFC'      
    AND [Status] = 'Reject'      
    AND RecipientType = 'Approver'      
      
    SET @Subject = dbo.[fn_proccess_email_template_RFC](@RFCId, @Subject)      
    SET @Template = dbo.[fn_proccess_email_template_RFC](@RFCId, @Template)      
    SET @MailTo = @ApproverUser      
      
  BEGIN      
    EXEC msdb.dbo.sp_send_dbmail @recipients = @MailTo,      
                                 @copy_recipients = @CCReceipent,      
                                 @subject = @subject,      
                                 @body = @Template,      
                                 @body_format = 'HTML',      
                                 @profile_name = @ProfileName;      
      
    INSERT INTO dbo.Test_Email_Log ([To], Content, [Subject], CreateDate)      
      VALUES (@Email, @Template, @subject, GETDATE());      
  END      
      
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

/****** Object:  StoredProcedure [dbo].[SP_RAchievement_Chart]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<hasni>
-- Create date: <20191007>
---- =============================================
--DROP PROCEDURE [dbo].[SP_RAchievement_Chart] 
ALTER PROCEDURE [dbo].[SP_RAchievement_Chart] 
(
	@StartDate nvarchar(10),
	@EndDate nvarchar(10),
	@Cycle nvarchar(50) 
)	
AS
BEGIN	
	DECLARE @sql nvarchar(max);  

	SET @sql = 'SELECT 
		CAST(AVG(achievement) as int) TotAchievement
	FROM
	(SELECT
			t3.Name,
			ISNULL(
				CAST(
					IIF(t1.Actual = NULL, 0, IIF(t1.Actual <= t3.TargetDays, 100, t3.TargetDays/t1.Actual*100)) as decimal(18,0))
			, 0) [Achievement]
		FROM
		(SELECT [Value], [Name], [Description] [TargetDays]
			FROM MasterParameter
			WHERE [group]=''Achievement'') t3
		LEFT JOIN 
		(
		--cipl approved
		SELECT 
			t1.[Name],
			CAST(AVG(
				CAST(
					CAST(DATEDIFF(hour,t0.CreateDate,t1.ApprovedDate) as decimal(18,3)) 
					/ CAST(''24'' as decimal(18,3)) as decimal(18,2)
				)
			) as decimal(18,1)) as [Actual]
		FROM
			Cipl t0
			JOIN (
				SELECT max(CreateDate) as [ApprovedDate], IdCipl, ''1'' as [Name]
				  FROM [EMCS].[dbo].[CiplHistory] t0
				where Status = ''Approve''
				GROUP BY IdCipl) as t1 
			on t1.IdCipl = t0.id
		GROUP BY t1.[Name]

		UNION 

		--pickup goods
		SELECT 
			t2.[Name],
			CAST(AVG(
				CAST(
					CAST(DATEDIFF(hour,t2.ApprovedDate, t0.ActualTimePickup) as decimal(18,3)) 
					/ CAST(''24'' as decimal(18,3)) as decimal(18,2)
				)
			) as decimal(18,1)) as [Actual] 
		FROM
		GoodsReceive t0
		JOIN GoodsReceiveItem t1 on t1.IdGr = t0.Id
		JOIN (
			SELECT max(t0.CreateDate) as [ApprovedDate], EdoNo, ''2'' as [Name]
			  FROM [EMCS].[dbo].CiplHistory t0
			  join Cipl t1 on t1.id = t0.IdCipl
			where Status = ''Approve''
			GROUP BY EdoNo) as t2
		on t2.EdoNo = t1.DoNo
		GROUP BY t2.Name
	
		UNION 

		--NPE PEB
		SELECT 
			t0.[Name],
			CAST(AVG(
				CAST(
					CAST(DATEDIFF(hour,t0.PebDate,t0.NpeDate) as decimal(18,3)) 
					/ CAST(''24'' as decimal(18,3)) as decimal(18,2)
				)
			) as decimal(18,1)) as [Actual]
		FROM
			(SELECT PebDate, NpeDate, ''3'' [Name] FROM Cargo) t0
		GROUP BY t0.[Name]

		UNION 

		--BL/AWB
		SELECT 
			t0.[Name],
			CAST(AVG(
				CAST(
					CAST(DATEDIFF(hour,t0.NpeDate,t0.BlDate) as decimal(18,3)) 
					/ CAST(''24'' as decimal(18,3)) as decimal(18,2)
				)
			) as decimal(18,1)) as [Actual]
		FROM
			(SELECT NPEDate, BlDate, ''4'' [Name] FROM Cargo) t0
		GROUP BY t0.[Name]

		) as t1 on t3.Value = t1.[Name]
		
	) achieved';

	IF (@Cycle <> '')
	BEGIN
		SET @sql += ' WHERE [Name] = ''' + @Cycle + '''';
	END

	--select @sql;
	EXECUTE(@sql);
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

/****** Object:  StoredProcedure [dbo].[SP_RDheBI]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hasni
-- Create date: 14/10/2019
-- Description:	SP Devisa Hasil Export (DHE) For Bank Indonesia
-- =============================================
--DROP PROCEDURE [dbo].[SP_RDheBI]
ALTER PROCEDURE [dbo].[SP_RDheBI]
(
	@StartDate nvarchar(50),
	@EndDate nvarchar(50),
	@Category nvarchar(50),
	@ExportType nvarchar(50)
)
AS
BEGIN

DECLARE @SQL as nvarchar(Max)
declare @whereRef nvarchar(max) =''
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	IF @StartDate <>'' 
	BEGIN
    	SET @whereRef=' and NpeDate >= ''' + @StartDate +''' and NpeDate <= ''' + @EndDate +''''
	 END
	 print (@whereRef)
   IF @Category <>''
	BEGIN
    	SET @whereRef+=' and Category = ' + @Category
	 END
	 IF @ExportType <>''
	BEGIN
    	SET @whereRef+=' and ExportType = ' + @ExportType
	 END

SET @SQL ='SELECT *	FROM [dbo].[fn_get_RDheBI]() WHERE NPWP <>''''' + @whereRef
 print @sql
		 exec(@SQL);
		
END
GO

/****** Object:  StoredProcedure [dbo].[sp_reject_req_revise_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- Create date: 24 Nov 2019
-- Description:	sp jika requestor cipl tidak setuju dengan perubahan dimension di cargo
-- =============================================
ALTER PROCEDURE [dbo].[sp_reject_req_revise_cipl] 
	-- Add the parameters for the stored procedure here
	@ciplid bigint, 
	@username nvarchar = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @totalwaiting int, @clid bigint;

	-- Set Nomor Id Cargo
	select @clid = IdCargo from dbo.CiplItemUpdateHistory where IdCipl = @ciplid;

    -- Insert statements for procedure here
	-- SELECT @ciplid, @ciplitemid
	
	-- Hapus semua data cipl di table update item history
	DELETE FROM dbo.CiplItemUpdateHistory WHERE IdCipl = @ciplid;

	-- Hapus cipl dari cargo dengan menggunakan deletion flag
	--UPDATE dbo.CargoCipl SET IsDelete = 1 WHERE IdCipl = @ciplid;
	--UPDATE dbo.CargoItem SET isDelete = 1 WHERE IdCipl = @ciplid;

	DELETE FROM dbo.CargoCipl WHERE IdCipl = @ciplid;
	DELETE FROM dbo.CargoItem WHERE IdCipl = @ciplid;

	-- Update status req cargo ke next step dengan mengecek ke data update history cipl
	SELECT @totalwaiting = COUNT(*) FROM dbo.CiplItemUpdateHistory WHERE IdCargo = @clid;
	IF @totalwaiting = 0
	BEGIN
		UPDATE dbo.RequestCl 
		SET IdStep = 12,[Status] = 'Approve', Pic = @username, UpdateBy = @username, UpdateDate = GETDATE()
		WHERE IdCl = @clid
	END

	-- kembalikan status cipl menjadi pickup kembali
	--EXEC sp_update_request_cipl @IdCipl = @ciplid, @Username = @username, @NewStatus = 'Reject', @Notes = '', @NewStep = ''
END
GO

/****** Object:  StoredProcedure [dbo].[SP_RejectChangeHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[SP_RejectChangeHistory]             
 @Id INT        
 ,@Reason NVARCHAR(MAX)        
 ,@UpdatedBy NVARCHAR(MAX)        
AS            
BEGIN  

DECLARE @FormId INT
 UPDATE RequestForChange            
 SET [Status] = 2 , ReasonIfRejected = @Reason ,  UpdateBy =  @UpdatedBy         
 WHERE             
   Id = @Id     

   

   DELETE FROM CiplItem_Change where IdCipl = (SELECT FormId FROM RequestForChange where Id = @Id)

   EXEC [dbo].[sp_Process_Email_RFC] @Id,'Reject'     
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_remove_CiplItem]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_remove_CiplItem]
	-- Add the parameters for the stored procedure here
	@idCIPL BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE CiplItem SET ISDELETE = 1 WHERE IDCIPL = @idCIPL
END

GO

/****** Object:  StoredProcedure [dbo].[SP_Report_Total_Export_Monthly]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[Sp_Report_Total_Export_Monthly] '2019'
ALTER PROCEDURE [dbo].[SP_Report_Total_Export_Monthly] (@year NVARCHAR(7)) 
AS 
  BEGIN 
      SELECT CAST(1 AS BIGINT) Id, ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 1 THEN 1 
                   ELSE 0 
                 END),0) AS 'January', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 2 THEN 1 
                   ELSE 0 
                 END),0) AS 'February', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 3 THEN 1 
                   ELSE 0 
                 END),0) AS 'March', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 4 THEN 1 
                   ELSE 0 
                 END),0) AS 'April', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 5 THEN 1 
                   ELSE 0 
                 END),0) AS 'May', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 6 THEN 1 
                   ELSE 0 
                 END),0) AS 'June', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 7 THEN 1 
                   ELSE 0 
                 END),0) AS 'July', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 8 THEN 1 
                   ELSE 0 
                 END),0) AS 'August', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 9 THEN 1 
                   ELSE 0 
                 END),0) AS 'September', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 10 THEN 1 
                   ELSE 0 
                 END),0) AS 'October', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 11 THEN 1 
                   ELSE 0 
                 END),0) AS 'November', 
             ISNULL(Sum(CASE Datepart(month, CreateDate) 
                   WHEN 12 THEN 1 
                   ELSE 0 
                 END),0) AS 'December', 
             ISNULL(Sum(CASE Datepart(year, CreateDate) 
                   WHEN @year THEN 1 
                   ELSE 0 
                 END),0) AS 'TOTAL' 
      FROM   dbo.RequestCl 
      WHERE  Year(CreateDate) = @year 
	  AND Status = 'Approve'
	  AND IdStep IN (10020, 10022)
  END 

GO

/****** Object:  StoredProcedure [dbo].[Sp_Report_Total_Export_Port]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sp_Report_Total_Export_Port] --'2022', ''
(@year NVARCHAR(4),
@filter NVARCHAR(MAX))
AS   
  BEGIN   
      SELECT	T1.PortOfLoading, T1.PortOfDestination, ISNULL(SUM(T1.Total),0) Total, ISNULL(SUM(T1.TotalSales),0) TotalSales, ISNULL(SUM(T1.TotalNonSales),0) TotalNonSales
	  FROM		( SELECT C.PortOfLoading,
						 C.PortOfDestination,   
						 ISNULL(COUNT(RCL.Id), 0) Total,
						 ISNULL(SUM(CASE WHEN C.ExportType LIKE 'Sales%' AND DATEPART(year, rcl.CreateDate) IN (@year) THEN 1 ELSE 0 END),0) [TotalSales],
						 ISNULL(SUM(CASE WHEN C.ExportType LIKE 'Non Sales%' AND DATEPART(year, rcl.CreateDate) IN (@year) THEN 1 ELSE 0 END),0) [TotalNonSales]  
				  FROM   dbo.RequestCl RCL
						 INNER JOIN dbo.Cargo C ON C.Id = RCL.IdCl
						 INNER JOIN NpePeb N ON C.Id = N.IdCl
				  WHERE  Year(RCL.CreateDate) = @year   
						 AND RCL.[Status] = 'Approve'   
						 AND RCL.IdStep IN ( 10020, 10022 )   
						 AND N.NpeNumber <> ''  
						 AND C.ExportType LIKE '' + @filter + '%'
				  GROUP  BY C.Id, C.PortOfLoading, C.PortOfDestination, C.ExportType, rcl.CreateDate) AS T1
	  GROUP BY	T1.PortOfLoading, T1.PortOfDestination
  END
GO

/****** Object:  StoredProcedure [dbo].[Sp_RequestForChange_Insert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[Sp_RequestForChange_Insert]      
@FormType nvarchar(300)      
,@FormNo nvarchar(300)     
,@FormId int     
,@Reason nvarchar(MAX)      
,@CreateBy nvarchar(300)      
AS      
BEGIN      
    
DECLARE @Approver NVARCHAR(150)

SET @Approver = CASE
    WHEN (@CreateBy ='XUPJ21WDN') THEN 'xupj21dxd' 
    WHEN (@CreateBy ='xupj21dxd') THEN 'xupj21fig'
END;
    
DECLARE @RFCNumber NVARCHAR(50)       
SELECT TOP 1 @RFCNumber = RFCNumber FROM RequestForChange ORDER BY ID DESC        
DECLARE @PrefixCode NVARCHAR(15)      
DECLARE @Year as NVARCHAR(20)        
SET @PrefixCode = 'RFC'      
SET @Year = YEAR(getdate())      
iF @RFCNumber IS NuLL      
BEGIN        
DECLARE @invnumber NVARCHAR(50)      
SET @invnumber = @PrefixCode + @Year + '000000'       
SET  @RFCNumber =  @invnumber       
END      
ELSE      
BEGIN       
    DECLARE @ID INT             
  DECLARE @Temp NVARCHAR(20)          
  DECLARE @Temp1 NVARCHAR(20)          
  DECLARE @Temp2 NVARCHAR(20)       
  DECLARE @Temp3 NVARCHAR(20)         
  DECLARE @TmpInvoiceNo TABLE (Id INT IDENTITY(1,1), Col4 VARCHAR(50))         
  INSERT INTO @TmpInvoiceNo(Col4) SELECT Data As QuotationNo FROM [fnSplitStringRFC](@RFCNumber,'')          
          
  DECLARE @No as NVARCHAR(20)          
  DECLARE @TableName NVARCHAR(200)          
  SELECT @Year = Col4 FROM @TmpInvoiceNo WHERE Id = 1          
  SELECT @No = Col4 FROM @TmpInvoiceNo WHERE Id = 2            
        
        
  SET @Temp =  SUBSTRING(@RFCNumber, 1, 3)      
  SET @Temp1 = SUBSTRING(@RFCNumber, 4, 4)      
  SET @Temp2 = SUBSTRING(@RFCNumber, 8, 9)      
  SET @Temp3 = SUBSTRING(@RFCNumber, 8, 9)      
  SET @Temp2 = right('00000' + cast(@Temp3 as varchar(6))+ 1, 6)      
  SET @Temp3 = right('00000' + cast(@Temp2 as varchar(6)), 6)      
  IF YEAR(getdate()) = @Temp1          
   BEGIN          
    SET @RFCNumber = @Temp +''+ @Temp1 +''+ @Temp3      
   END          
  ELSE          
   BEGIN       
   SET @RFCNumber = @Temp + CAST(YEAR(getdate()) AS NVARCHAR(4))+''+CAST('000001' AS NVARCHAR(6))          
          
   END        
 END    
    
    
-------------------------------------------------------------------------------    
DECLARE @ResultId INT      
INSERT INTO RequestForChange (FormType,      
FormNo,    
RFCNumber,    
FormId,    
Reason,      
CreateBy,Approver) VALUES (@FormType,@FormNo,@RFCNumber,@FormId,@Reason,@CreateBy,@Approver)      
      
SET @ResultId = SCOPE_IDENTITY()  
  EXEC [dbo].[sp_Process_Email_RFC] @ResultId,'Approval'   
SELECT @ResultId      
END
GO

/****** Object:  StoredProcedure [dbo].[sp_RequestForChangeHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_RequestForChangeHistory] --[dbo].[sp_RequestForChangeHistory] 0,'CreateDate','DESC' ,'1','10','xupj21dxd'                      
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

/****** Object:  StoredProcedure [dbo].[sp_revise_req_revise_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ali Mutasal
-- Create date: 24 Nov 2019
-- Description:	sp jika requestor cipl tidak setuju dengan perubahan dimension di cargo
-- =============================================
ALTER PROCEDURE [dbo].[sp_revise_req_revise_cipl] 
	-- Add the parameters for the stored procedure here
	@ciplid bigint, 
	@username nvarchar = 100
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @clid bigint;

	select TOP 1 @clid = IdCargo from dbo.CiplItemUpdateHistory where IdCipl = @ciplid;

	exec sp_update_request_cl @clid, @username, 'Revise', ''
    -- Insert statements for procedure here
	--SELECT @p1, @p2
END
GO

/****** Object:  StoredProcedure [dbo].[SP_RExportProblem]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_RExportProblem] 
(
	@IsTotal bit = 0,
	@sort nvarchar(100) = 'Id',
	@order nvarchar(100) = 'ASC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)	
AS
BEGIN
	DECLARE @sql nvarchar(max);  
	SET @sql = 'SELECT ';
	SET @sort = 't0.'+@sort;

	IF (@IsTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total'
	END 
	ELSE
	BEGIN
		SET @sql += 't0.id
				   , t0.ReqType
				   , t0.Category
				   , t0.[Case] as Cases
				   , t0.Causes
				   , t0.Impact
				   , t0.CaseDate
				   , t2.Employee_Name as PIC'
	END
	SET @sql +=' FROM ProblemHistory t0 
	join employee t2 on t2.AD_User = t0.CreateBy';
	EXECUTE(@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_RFCItem_Insert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[Sp_RFCItem_Insert]  
  
@RFCID INT  
,@TableName NVARCHAR(250) = NULL  
,@LableName NVARCHAR(250) = NULL  
,@FieldName NVARCHAR(350) = NULL  
,@BeforeValue NVARCHAR(MAX) = NULL  
,@AfterValue NVARCHAR(MAX) = NULL  
AS  
BEGIN  
  
DECLARE @ResultId INT  
  
Insert Into RFCItem   
(RFCID,  
TableName,  
LableName,  
FieldName,  
BeforeValue,  
AfterValue)   
VALUES   
(@RFCID,  
@TableName,  
@LableName,  
@FieldName,  
@BeforeValue,  
@AfterValue)  
  
SET @ResultId = SCOPE_IDENTITY()  
  
SELECT @ResultId  
END
GO

/****** Object:  StoredProcedure [dbo].[SP_ROutstandingCipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ROutstandingCipl]
(
	@startdate varchar(50),
	@enddate varchar(50)
)	
AS
BEGIN
	SELECT 
		'' Cycle
		, t1.Employee_Name PICName
		, t1.Dept_Name Department
		, t2.BAreaName Branch
		, t0.CiplNo
		, ISNULL(CONVERT(VARCHAR(9), t0.CreateDate, 6), '-') SubmitDate
		,(SELECT top 1 Status  FROM [EMCS].[dbo].[CiplHistory] t3
				where t3.IdCipl = t0.id) status
    FROM Cipl t0 
	inner join employee t1 on t0.CreateBy = t1.AD_User
	inner join MasterArea t2 on t2.BAreaCode = t0.Branch
	WHERE t0.id NOT IN (
				SELECT IdCipl  FROM [EMCS].[dbo].[CiplHistory] t0
				where Status = 'Approve'
			GROUP BY IdCipl)
		
		and t0.CreateDate between @startdate and @enddate
END
GO

/****** Object:  StoredProcedure [dbo].[Sp_RPebReport]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Sp_RPebReport '2022-11-20','2022-11-21','','',''              
--Sp_RPebReport '','','','',''              
ALTER PROCEDURE [dbo].[Sp_RPebReport]                                 
 (                              
 @StartMonth DATEtime                              
 ,@EndMonth DATEtime                              
 ,@ParamName NVARCHAR(50)                              
 ,@ParamValue NVARCHAR(200)                              
 ,@KeyNum NVARCHAR(200)                              
 )                              
AS                              
BEGIN                              
 IF (                              
   @StartMonth <> ''                              
   AND @EndMonth <> ''                              
   )                              
 BEGIN                              
SELECT  t0.IdCl                              
   ,CONCAT (                              
    LEFT(DATENAME(MONTH, IIF(t3.UpdateDate IS NOT NULL, t3.UpdateDate, t3.CreateDate)), 3)                              
    ,'-'                              
    ,DATEPART(YEAR, IIF(t3.UpdateDate IS NOT NULL, t3.UpdateDate, t3.CreateDate))                              
    ) AS PebMonth                        
 --,CAST(ROW_NUMBER() OVER (                            
 --    PARTITION BY CONCAT (                            
 --     LEFT(DATENAME(MONTH,IIF(t0.UpdateDate IS NOT NULL, t0.UpdateDate, t0.CreateDate)), 3)                            
 --     ,'-'                            
 --     ,DATEPART(YEAR,IIF(t0.UpdateDate IS NOT NULL, t0.UpdateDate, t0.CreateDate))                            
 --     ) ORDER BY IIF(t0.UpdateDate IS NOT NULL, t0.UpdateDate, t0.CreateDate)                         
 --    ) AS bigint) RowNumber               
 ,ROW_NUMBER() OVER ( ORDER BY t0.Id ) RowNumber               
   ,t0.Id               
   ,t3.id              
   ,t0.AjuNumber                              
   ,t0.RegistrationNumber AS Nopen                              
   ,IIF(t0.NpeDateSubmitToCustomOffice IS NOT NULL, t0.NpeDateSubmitToCustomOffice, t0.CreateDate)  AS  NopenDate                               
   ,t5.Company AS PPJK                              
   ,(select Top 1 ContainerNumber From CargoItem where IdCargo = t0.IdCl and isDelete = 0) AS Container                           
   ,IIF(t1.TotalPackageBy = 'CaseNo', (                              
     SELECT Cast(Count(DISTINCT ci.CaseNumber) AS NVARCHAR)                              
     FROM CargoItem c                              
     JOIN ciplITEM ci ON ci.id = c.Idciplitem                              
     WHERE c.Idcargo = t1.Id                              
      AND c.isdelete = 0                              
     ), (                              
     SELECT Cast(Count(DISTINCT c.Id) AS NVARCHAR)                              
     FROM CargoItem c                              
     JOIN ciplITEM ci ON ci.id = c.Idciplitem                              
     WHERE c.Idcargo = t1.Id                              
      AND c.isdelete = 0                              
     )) AS Packages                              
   ,(                              
    SELECT Cast(SUM(C.Gross) AS NVARCHAR)                              
    FROM CargoItem c                              
    WHERE c.Idcargo = t0.IdCl                              
     AND c.isdelete = 0                              
    ) AS Gross                              
   ,t1.ShippingMethod            
   ,'KGS' as GrossWeightUom     
   ,'KGS' as GoodsUom    
   ,t1.CargoType                              
   ,IIF(t3.ExportType = 'Non Sales - Return (Temporary)', 'Non Sales', IIF(t3.ExportType = 'Non Sales - Personal Effect (Permanent)', 'Non Sales', iif(t3.ExportType = 'Sales (Permanent)', 'Sales', iif(t3.ExportType = 'Non Sales - Repair Return (Temporary)', 'Non Sales', iif(t3.ExportType = 'Non Sales - Return (Permanent)', 'Non Sales', '-'))))) AS TYPEOFEXPORTNote                              
   ,IIF(t3.ExportType = 'Non Sales - Return (Temporary)', 'Temporary', IIF(t3.ExportType = 'Non Sales - Personal Effect (Permanent)', 'Permanent', iif(t3.ExportType = 'Sales (Permanent)', 'Permanent', iif(t3.ExportType = 'Non Sales - Repair Return (Temporary)', 'Temporary', iif(t3.ExportType = 'Non Sales - Return (Permanent)', 'Permanent', '-'))))) AS TYPEOFEXPORTType      
   ,IIF(t3.ExportType = 'Non Sales - Return (Temporary)', 'Non Sales', IIF(t3.ExportType = 'Non Sales - Personal Effect (Permanent)', 'Non Sales', iif(t3.ExportType = 'Sales (Permanent)', 'Sales', iif(t3.ExportType = 'Non Sales - Repair Return (Temporary)', 'Non Sales', iif(t3.ExportType = 'Non Sales - Return (Permanent)', 'Non Sales', '-'))))) AS Note                              
   ,IIF(t3.ExportType = 'Non Sales - Return (Temporary)', 'Temporary', IIF(t3.ExportType = 'Non Sales - Personal Effect (Permanent)', 'Permanent', iif(t3.ExportType = 'Sales (Permanent)', 'Permanent', iif(t3.ExportType = 'Non Sales - Repair Return (Temporary)', 'Temporary', iif(t3.ExportType = 'Non Sales - Return (Permanent)', 'Permanent', '-'))))) AS Type      
   ,t3.Category AS CategoryName                 
      ,(              
select cast(sum(ExtendedValue)as nvarchar) from CiplItem              
   WHERE IdCipl = t3.Id                              
     AND isDelete = 0              
  ) as Ammount              
             
   ,(                              
    SELECT CAST(Count(Id) AS NVARCHAR)                              
    FROM CiplItem                              
    WHERE IdCipl = t3.Id                            
     AND isDelete = 0                              
    ) AS CiplQty                              
   ,(select Top 1 Uom From CiplItem where IdCipl = t3.Id and isDelete = 0) AS CiplUOM                              
   ,Cast((select Top 1 NetWeight From CiplItem where IdCipl = t3.Id and isDelete = 0) AS NVARCHAR) AS [CiplWeight]                            
   ,Cast(t0.Rate AS NVARCHAR) AS PebNpeRate                              
   ,(                              
    SELECT Cast(Sum(cc.ExtendedValue) AS NVARCHAR)                              
    FROM CiplItem cc                              
    WHERE t3.ExportType LIKE 'Non Sales%'                              
     AND cc.IdCipl = t3.id                              
    ) AS NonSales                              
   ,(                        
    SELECT Cast(Sum(cc.ExtendedValue) AS NVARCHAR)                              
    FROM CiplItem cc                              
    WHERE t3.ExportType LIKE 'Sales%'                              
     AND cc.IdCipl = t3.id                              
    ) AS Sales                              
   --,(                              
   -- SELECT Cast(SUM(t7.extendedvalue) * t0.RATE AS NVARCHAR)                              
   -- ) AS TOTALEXPORTVALUEINIDR                              
,(SELECT cast(SUM(ci.extendedvalue) - NN.PebFob as nvarchar) FROM NpePeb NN                            
JOIN CargoCipl CC ON  CC.IdCargo = NN.IdCl                            
JOIN CiplItem ci on ci.IdCipl = cc.IdCipl                            
where nn.IdCl = t0.IdCl  And nn.IsCancelled Is null                          
group by nn.PebFob) as Balanced                            
   ,t1.PortOfLoading                              
   ,t1.PortOfDestination                              
   ,CONVERT(VARCHAR(11), t1.SailingSchedule, 106) AS ETD                              
   ,CONVERT(VARCHAR(11), t1.ArrivalDestination, 106) AS ETA                 
   ,(SELECT STUFF((SELECT ',' + CASE WHEN Number IS NOT NULL AND Number != '' AND Number != '-' THEN Number ELSE HouseBlNumber END FROM BlAwb WHERE idcl = t0.Idcl FOR XML PATH('')), 1, 1, '')) as  MasterBlAwbNumber              
   ,(SELECT STUFF((SELECT ',' + Convert(VARCHAR(11), CreateDate,106) FROM BlAwb WHERE idcl = t0.Idcl FOR XML PATH('')), 1, 1, '')) as  BlDate              
   --,t4.Number AS MasterBlAwbNumber                              
   --,Convert(VARCHAR(11), t4.CreateDate, 106) AS BlDate                              
   ,t1.Incoterms                              
   ,t0.Valuta      
   ,t1.Incoterms As PEBIncoterms     
   ,t0.Valuta As PEBValuta    
   ,CAST(FORMAT(sum(ISNULL(t0.PebFob, 0)), '#,0.00') AS NVARCHAR) AS Rate                              
   ,CAST(FORMAT(sum(ISNULL(t0.FreightPayment, 0)), '#,0.00') AS NVARCHAR) AS FreightPayment                       
   ,CAST(FORMAT(sum(ISNULL(t0.InsuranceAmount, 0)), '#,0.00') AS NVARCHAR) AS InsuranceAmount                  
   ,Cast(Format(Sum(ISNULL(t0.PebFob, 0) + ISNULL(t0.FreightPayment, 0) + ISNULL(t0.InsuranceAmount, 0)), '#,0.00')As Nvarchar) as TotalAmount               
   ,t0.IdCl              
   ,t3.id              
   ,Cast(Format( (select sum(ExtendedValue) from CiplItem WHERE IdCipl = t3.Id AND isDelete = 0)  + ISNULL(t0.FreightPayment, 0) + ISNULL(t0.InsuranceAmount, 0), '#,0.00')As Nvarchar) as TOTALEXPORTVALUE                 
   --,Cast(Format((              
   -- SELECT               
   --  SUM(ExtendedValue)               
   -- FROM CiplItem c1              
   -- INNER JOIN Cipl c2 on c1.IdCipl = c2.id              
   -- INNER JOIN CargoCipl cc1 ON cc1.IdCipl = c2.id              
   -- WHERE cc1.IdCargo = t0.IdCl              
   --  AND c1.isDelete = 0              
   -- GROUP BY               
   --  cc1.IdCargo) + (ISNULL(t0.FreightPayment, 0)*3) + (ISNULL(t0.InsuranceAmount, 0)*3)              
   -- , '#,0.00') AS NVARCHAR) AS TOTALVALUEPERSHIPMENT            
      ,Cast(Format((              
    SELECT               
     SUM(ExtendedValue)               
    FROM CiplItem c1              
    INNER JOIN Cipl c2 on c1.IdCipl = c2.id              
    INNER JOIN CargoCipl cc1 ON cc1.IdCipl = c2.id              
    WHERE cc1.IdCargo = t0.IdCl              
     AND c1.isDelete = 0              
    GROUP BY               
     cc1.IdCargo)              
    , '#,0.00') AS NVARCHAR) AS TOTALVALUEPERSHIPMENT              
 ,   Cast(Format((SELECT               
     SUM(ExtendedValue)               
    FROM CiplItem c1              
    INNER JOIN Cipl c2 on c1.IdCipl = c2.id              
    INNER JOIN CargoCipl cc1 ON cc1.IdCipl = c2.id              
    WHERE cc1.IdCargo = t0.IdCl              
     AND c1.isDelete = 0              
    GROUP BY               
     cc1.IdCargo) * t0.Rate            
  , '#,0.00') AS NVARCHAR) AS TOTALEXPORTVALUEINIDR        
        ,(              
select cast(sum(ExtendedValue)as nvarchar) from CiplItem              
   WHERE IdCipl = t3.Id                              
     AND isDelete = 0              
  ) as TotalExportValueInUsd       
   ,t3.CiplNo                              
   ,t3.Branch                           
   ,Convert(VARCHAR(11), t3.UpdateDate, 106) AS CiplDate                              
   ,t3.Remarks                              
   ,t3.ConsigneeName                              
   ,t3.ConsigneeCountry                              
   ,t3.ConsigneeName                              
   ,t3.ConsigneeCountry                              
   ,Cast(t0.PebFob AS NVARCHAR) AS PebFob                              
   ,(SELECT  Cast(count(Distinct ci.CaseNumber)as nvarchar) FROM NpePeb NN                            
JOIN CargoCipl CC ON  CC.IdCargo = NN.IdCl                            
JOIN CiplItem ci on ci.IdCipl = cc.IdCipl                            
where nn.IdCl = t0.IdCl ) as Colli                            
  FROM NpePeb t0                              
  LEFT JOIN Cargo t1 ON t1.Id = t0.IdCl    
  Left join dbo.RequestCl t6 on t6.IdCl = t1.Id   
  LEFT JOIN CargoCipl t2 ON t2.IdCargo = t1.Id                              
  LEFT JOIN Cipl t3 ON t3.id = t2.IdCipl                              
  --LEFT JOIN BlAwb t4 ON t4.IdCl = t2.IdCargo                              
  LEFT JOIN CiplForwader t5 ON t5.IdCipl = t3.id                              
  --LEFT JOIN CargoItem t6 ON t6.IdCargo = t2.IdCargo                               
  --LEFT JOIN CiplItem t7 ON t7.Id = t6.IdCiplItem                              
  WHERE t0.IsDelete = 0                              
   AND t1.IsDelete = 0                              
   AND t2.IsDelete = 0    
   AND t3.IsDelete = 0                              
   --AND t4.IsDelete = 0                              
   AND t5.IsDelete = 0                                              
   AND t0.NpeDateSubmitToCustomOffice BETWEEN @StartMonth                              
    AND @EndMonth     
 And t6.[Status] = 'Approve'   
  GROUP BY t0.Id                              
   ,t0.IdCl                              
,t0.AjuNumber                        
   ,t3.UpdateDate                  
   ,t3.CreateDate                  
   ,t3.ExportType                              
   ,t3.Category                              
   ,t3.Id                              
   ,t1.Id                              
   ,t0.CreateDate                                                
   ,t1.TotalPackageBy               
   ,t0.UpdateDate                                             
   ,t0.NpeDateSubmitToCustomOffice                              
   ,t5.Company                                             
   --,t0.UpdateBy                                      
   ,t0.RegistrationNumber                              
   --,t0.Nopen                                                  
   --,t0.NopenDate                                              
   ,t1.ShippingMethod                              
   ,t1.CargoType                              
   ,t1.ExportType                              
   ,t1.ExportType                              
   ,t1.PortOfLoading                              
   ,t1.PortOfDestination                              
   ,t1.SailingSchedule                              
   ,t1.ArrivalDestination                              
   --,t4.Number                              
   --,t4.CreateDate                              
   ,t1.Incoterms                              
   ,t0.Valuta                              
   ,t0.Rate                              
   ,t0.FreightPayment                              
   ,t0.InsuranceAmount                              
   ,t3.CiplNo                              
   ,t3.Branch                              
   ,t3.UpdateDate                              
   ,t3.Remarks                              
                      
   ,t3.ConsigneeName                              
   ,t3.ConsigneeCountry                              
   ,t3.ConsigneeName                              
   ,t3.ConsigneeCountry                 
   ,t0.PebFob                   
       order by t0.Id,t0.NpeDateSubmitToCustomOffice,t0.CreateDate                
 END                              
 ELSE                              
 BEGIN                              
  SELECT  t0.IdCl                              
   ,CONCAT (                              
    LEFT(DATENAME(MONTH, IIF(t3.UpdateDate IS NOT NULL, t3.UpdateDate, t3.CreateDate)), 3)                              
    ,'-'                              
    ,DATEPART(YEAR, IIF(t3.UpdateDate IS NOT NULL, t3.UpdateDate, t3.CreateDate))                              
    ) AS PebMonth                         
  --,CAST(ROW_NUMBER() OVER (                            
 --    PARTITION BY CONCAT (                            
 --     LEFT(DATENAME(MONTH,IIF(t0.UpdateDate IS NOT NULL, t0.UpdateDate, t0.CreateDate)), 3)                            
 --     ,'-'                            
 --     ,DATEPART(YEAR,IIF(t0.UpdateDate IS NOT NULL, t0.UpdateDate, t0.CreateDate))                            
 --     ) ORDER BY IIF(t0.UpdateDate IS NOT NULL, t0.UpdateDate, t0.CreateDate)                         
 --    ) AS bigint) RowNumber               
 ,ROW_NUMBER() OVER ( ORDER BY t0.Id ) RowNumber                    
   ,t0.Id                  
   ,t3.id              
   ,t0.AjuNumber                              
   ,t0.RegistrationNumber AS Nopen                              
 ,IIF(t0.NpeDateSubmitToCustomOffice IS NOT NULL, t0.NpeDateSubmitToCustomOffice, t0.CreateDate) AS NopenDate                           
   ,t5.Company AS PPJK                              
   ,(select Top 1 ContainerNumber From CargoItem where IdCargo = t0.IdCl and isDelete = 0) AS Container                             
   ,IIF(t1.TotalPackageBy = 'CaseNo', (                              
     SELECT Cast(Count(DISTINCT ci.CaseNumber) AS NVARCHAR)                              
     FROM CargoItem c                              
     JOIN ciplITEM ci ON ci.id = c.Idciplitem                              
     WHERE c.Idcargo = t1.Id                              
      AND c.isdelete = 0                              
     ), (                              
     SELECT Cast(Count(DISTINCT c.Id) AS NVARCHAR)                              
     FROM CargoItem c                              
     JOIN ciplITEM ci ON ci.id = c.Idciplitem                              
     WHERE c.Idcargo = t1.Id                              
      AND c.isdelete = 0                              
     )) AS Packages                              
   ,(                              
    SELECT Cast(SUM(C.Gross) AS NVARCHAR)                    
    FROM CargoItem c                              
    WHERE c.Idcargo = t0.IdCl                              
     AND c.isdelete = 0                              
    ) AS Gross                              
   ,t1.ShippingMethod                              
   ,t1.CargoType                              
   ,IIF(t3.ExportType = 'Non Sales - Return (Temporary)', 'Non Sales', IIF(t3.ExportType = 'Non Sales - Personal Effect (Permanent)', 'Non Sales', iif(t3.ExportType = 'Sales (Permanent)', 'Sales', iif(t3.ExportType = 'Non Sales - Repair Return (Temporary)', 'Non Sales', iif(t3.ExportType = 'Non Sales - Return (Permanent)', 'Non Sales', '-'))))) AS TYPEOFEXPORTNote                              
   ,IIF(t3.ExportType = 'Non Sales - Return (Temporary)', 'Temporary', IIF(t3.ExportType = 'Non Sales - Personal Effect (Permanent)', 'Permanent', iif(t3.ExportType = 'Sales (Permanent)', 'Permanent', iif(t3.ExportType = 'Non Sales - Repair Return (Temporary)', 'Temporary', iif(t3.ExportType = 'Non Sales - Return (Permanent)', 'Permanent', '-'))))) AS TYPEOFEXPORTType      
   ,IIF(t3.ExportType = 'Non Sales - Return (Temporary)', 'Non Sales', IIF(t3.ExportType = 'Non Sales - Personal Effect (Permanent)', 'Non Sales', iif(t3.ExportType = 'Sales (Permanent)', 'Sales', iif(t3.ExportType = 'Non Sales - Repair Return (Temporary)', 'Non Sales', iif(t3.ExportType = 'Non Sales - Return (Permanent)', 'Non Sales', '-'))))) AS Note                              
   ,IIF(t3.ExportType = 'Non Sales - Return (Temporary)', 'Temporary', IIF(t3.ExportType = 'Non Sales - Personal Effect (Permanent)', 'Permanent', iif(t3.ExportType = 'Sales (Permanent)', 'Permanent', iif(t3.ExportType = 'Non Sales - Repair Return (Temporary)', 'Temporary', iif(t3.ExportType = 'Non Sales - Return (Permanent)', 'Permanent', '-'))))) AS Type                           
   ,t3.Category AS CategoryName                  
      ,(              
select cast(sum(ExtendedValue)as nvarchar) from CiplItem              
   WHERE IdCipl = t3.Id                              
     AND isDelete = 0              
  ) as Ammount              
   ,(                              
    SELECT CAST(Count(Id) AS NVARCHAR)                              
    FROM CiplItem                              
    WHERE IdCipl = t3.Id                              
     AND isDelete = 0                              
    ) AS CiplQty                              
   ,(select Top 1 Uom From CiplItem where IdCipl = t3.Id and isDelete = 0) AS CiplUOM                     
   ,Cast((select Top 1 NetWeight From CiplItem where IdCipl = t3.Id and isDelete = 0) AS NVARCHAR) AS [CiplWeight]                              
   ,Cast(t0.Rate AS NVARCHAR) AS PebNpeRate                              
   ,(                              
    SELECT Cast(Sum(cc.ExtendedValue) AS NVARCHAR)                              
    FROM CiplItem cc                              
    WHERE t3.ExportType LIKE 'Non Sales%'                              
     AND cc.IdCipl = t3.id                              
    ) AS NonSales                              
 ,(                              
    SELECT Cast(Sum(cc.ExtendedValue) AS NVARCHAR)                    
    FROM CiplItem cc                              
    WHERE t3.ExportType LIKE 'Sales%'                              
     AND cc.IdCipl = t3.id                              
    ) AS Sales                                               
   ,(SELECT cast(SUM(ci.extendedvalue) - NN.PebFob as nvarchar) FROM NpePeb NN                            
JOIN CargoCipl CC ON  CC.IdCargo = NN.IdCl                            
JOIN CiplItem ci on ci.IdCipl = cc.IdCipl                    
where nn.IdCl = t0.IdCl   And nn.IsCancelled Is null                          
group by nn.PebFob) as Balanced                            
   ,t1.PortOfLoading                              
   ,t1.PortOfDestination                              
   ,CONVERT(VARCHAR(11), t1.SailingSchedule, 106) AS ETD                              
   ,CONVERT(VARCHAR(11), t1.ArrivalDestination, 106) AS ETA                 
   ,(SELECT STUFF((SELECT ',' + CASE WHEN Number IS NOT NULL OR Number != '' THEN Number ELSE HouseBlNumber END FROM BlAwb WHERE idcl = t0.Idcl FOR XML PATH('')), 1, 1, '')) as  MasterBlAwbNumber              
   ,(SELECT STUFF((SELECT ',' + Convert(VARCHAR(11), CreateDate,106) FROM BlAwb WHERE idcl = t0.Idcl FOR XML PATH('')), 1, 1, '')) as  BlDate                           
   ,t1.Incoterms                              
   ,t0.Valuta      
   ,t1.Incoterms As PEBIncoterms                             
   ,t0.Valuta As PEBValuta                           
   ,'KGS' as GrossWeightUom    
   ,'KGS' as GoodsUom    
   ,CAST(FORMAT(sum(ISNULL(t0.PebFob, 0)), '#,0.00') AS NVARCHAR) AS Rate                              
   ,CAST(FORMAT(sum(ISNULL(t0.FreightPayment, 0)), '#,0.00') AS NVARCHAR) AS FreightPayment                              
   ,CAST(FORMAT(sum(ISNULL(t0.InsuranceAmount, 0)), '#,0.00') AS NVARCHAR) AS InsuranceAmount                    
   ,Cast(Format(Sum(ISNULL(t0.PebFob, 0) + ISNULL(t0.FreightPayment, 0) + ISNULL(t0.InsuranceAmount, 0)), '#,0.00')As Nvarchar) as TotalAmount               
   ,t0.IdCl              
   ,t3.id              
   ,Cast(Format( (select sum(ExtendedValue) from CiplItem WHERE IdCipl = t3.Id AND isDelete = 0)  + ISNULL(t0.FreightPayment, 0) + ISNULL(t0.InsuranceAmount, 0), '#,0.00')As Nvarchar) as TOTALEXPORTVALUE                 
  ,Cast(Format((              
    SELECT               
     SUM(ExtendedValue)               
    FROM CiplItem c1              
    INNER JOIN Cipl c2 on c1.IdCipl = c2.id              
    INNER JOIN CargoCipl cc1 ON cc1.IdCipl = c2.id              
    WHERE cc1.IdCargo = t0.IdCl              
     AND c1.isDelete = 0              
    GROUP BY               
     cc1.IdCargo)              
    , '#,0.00') AS NVARCHAR) AS TOTALVALUEPERSHIPMENT            
  ,   Cast(Format((SELECT               
     SUM(ExtendedValue)               
    FROM CiplItem c1              
    INNER JOIN Cipl c2 on c1.IdCipl = c2.id              
    INNER JOIN CargoCipl cc1 ON cc1.IdCipl = c2.id              
    WHERE cc1.IdCargo = t0.IdCl              
     AND c1.isDelete = 0              
    GROUP BY               
     cc1.IdCargo) * t0.Rate            
  , '#,0.00') AS NVARCHAR) AS TOTALEXPORTVALUEINIDR          
          ,(              
select cast(sum(ExtendedValue)as nvarchar) from CiplItem              
   WHERE IdCipl = t3.Id                              
     AND isDelete = 0              
  ) as TotalExportValueInUsd       
   ,t3.CiplNo                              
   ,t3.Branch                              
   ,Convert(VARCHAR(11), t3.UpdateDate, 106) AS CiplDate                              
   ,t3.Remarks                              
   ,t3.ConsigneeName                              
   ,t3.ConsigneeCountry                              
   ,t3.ConsigneeName                              
   ,t3.ConsigneeCountry                              
   ,Cast(t0.PebFob AS NVARCHAR) AS PebFob                              
   ,(SELECT  Cast(count(Distinct ci.CaseNumber)as nvarchar) FROM NpePeb NN                            
JOIN CargoCipl CC ON  CC.IdCargo = NN.IdCl                            
JOIN CiplItem ci on ci.IdCipl = cc.IdCipl                            
where nn.IdCl = t0.IdCl ) as Colli                         
  FROM NpePeb t0                              
  LEFT JOIN Cargo t1 ON t1.Id = t0.IdCl   
    Left join dbo.RequestCl t6 on t6.IdCl = t1.Id   
  LEFT JOIN CargoCipl t2 ON t2.IdCargo = t1.Id                              
  LEFT JOIN Cipl t3 ON t3.id = t2.IdCipl                                              
  LEFT JOIN CiplForwader t5 ON t5.IdCipl = t3.id                                            
  WHERE t0.IsDelete = 0                              
   AND t1.IsDelete = 0                              
   AND t2.IsDelete = 0                              
   AND t3.IsDelete = 0                                              
   AND t5.IsDelete = 0                                                     
   and t6.[Status] = 'Approve'                              
  GROUP BY t0.Id                              
   ,t0.IdCl                              
   ,t0.AjuNumber                    
   ,t3.UpdateDate                  
   ,t3.CreateDate                  
   ,t3.ExportType                              
   ,t3.Category                              
   ,t3.Id                              
   ,t1.Id                              
   ,t0.CreateDate                                              
   ,t1.TotalPackageBy                              
   ,t0.UpdateDate                              
   ,t0.NpeDateSubmitToCustomOffice                              
   ,t5.Company                                                  
   ,t0.RegistrationNumber                                                               
   ,t1.ShippingMethod                              
   ,t1.CargoType                              
   ,t1.ExportType                              
   ,t1.ExportType                              
   ,t1.PortOfLoading                              
   ,t1.PortOfDestination                              
   ,t1.SailingSchedule                              
   ,t1.ArrivalDestination                                          
   ,t1.Incoterms                              
   ,t0.Valuta                              
   ,t0.Rate                              
   ,t0.FreightPayment                              
   ,t0.InsuranceAmount                              
   ,t3.CiplNo                              
   ,t3.Branch                              
   ,t3.UpdateDate                              
   ,t3.Remarks                              
   ,t3.ConsigneeName                              
   ,t3.ConsigneeCountry                              
   ,t3.ConsigneeName                              
   ,t3.ConsigneeCountry                              
   ,t0.PebFob                          
    order by t0.Id,t0.NpeDateSubmitToCustomOffice ,t0.CreateDate                     
 END                              
END 
GO

/****** Object:  StoredProcedure [dbo].[SP_RProblemHistory]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_RProblemHistory]
(
	@startdate nvarchar(100),
	@enddate nvarchar(100)
)	
AS
BEGIN	
	DECLARE @ProblemHistory TABLE (
		[ID] [bigint],
		ParentID [bigint], 
		[ReqType] [nvarchar](50),
		[Category] [nvarchar](100),
		[Cases] [nvarchar](200),
		[Causes] [nvarchar](MAX),
		[Impact] [nvarchar](MAX),
		[TotalCauses] [nvarchar](50),
		[TotalCases] [nvarchar](50),
		[TotalCategory] [nvarchar](50),
		[TotalCategoryPercentage] [nvarchar](50)
	)

	INSERT INTO @ProblemHistory
	SELECT 
		ROW_NUMBER() over(order by Category, Category ASC) as ID, 
		0 ParentID
		, '-' [ReqType]
		, Category
		, '-' [Cases]
		, '-' [Causes]
		, '-' [Impact]
		, '-' [TotalCauses]
		, '-' [TotalCases]
		, CAST(totalCategory as nvarchar(max)) [TotalCategory]
		, CAST([TotalCategoryPercentage] as nvarchar(max)) [TotalCategoryPercentage]
	FROM (
		select 
			Category
			,totalCategory 
			,round((totalCategory/totalAll) * 100, 0) as [TotalCategoryPercentage] 
			,'-' ReqType, '-' as Cases, '-' as Causes, '-' as Impact, '-' as TotalCauses, '-' as TotalCases
		from (
			select 
				t0.Category, 
				count(*) as totalCategory,
				(
					select cast(count(*) as decimal(16,2)) totalAllProblem 
					from dbo.ProblemHistory t3 
					where Category IS NOT NULL) as totalAll
			from dbo.ProblemHistory t0
			group by t0.Category
		) as totalProblemPerCategory
	) as result

	select * from @ProblemHistory

END
GO

/****** Object:  StoredProcedure [dbo].[SP_RPTTUBranch_Average]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_RPTTUBranch_Average]
	@StartPeriod nvarchar(20),
	@EndPeriod nvarchar(20)
AS
BEGIN

	declare @year int = DATEPART(YEAR, @StartPeriod)
	declare @startdate datetime = CAST(@year as nvarchar(4)) + '-01-01'
	declare @enddate datetime = CAST(@year as nvarchar(4)) + '-12-31'

	declare @tbl table (Description nvarchar(50), MonthNumber int, Value decimal(18,2))

	--============ Average per Week ============
	declare @maxweek int, @week int = 1
	set @maxweek = DATEPART(WEEK, @enddate)

	declare @weekly_tbl table(WeekNumber int, MonthNumber int)
	WHILE @week <= @maxweek
	BEGIN
		insert into @weekly_tbl 
		select @week, DATEPART(MONTH, DATEADD(WW, @week - 1, @startdate))
		SET @week = @week + 1;
	END;

	insert into @tbl
	select 'Average Per Week', w.MonthNumber, CAST(AVG(CAST(ISNULL(src.TotalPEB, 0) as float)) as decimal(18,2)) as WeeklyAVG
	from @weekly_tbl w
	left join(
		select 
			DATEPART(WK, PebDateNumeric) as WeekNumber
			, COUNT(DISTINCT AjuNumber) as TotalPEB
		from [dbo].[fn_get_approved_npe_peb]() 
		where ((DATEPART(MONTH, PebDateNumeric) >= DATEPART(MONTH, @StartPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @StartPeriod)) OR @StartPeriod = '') 
				AND ((DATEPART(MONTH, PebDateNumeric) <= DATEPART(MONTH, @EndPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @EndPeriod)) OR @EndPeriod = '')
		group by DATEPART(WK, PebDateNumeric)
	)src on w.WeekNumber = src.WeekNumber
	GROUP BY w.MonthNumber

	----============ Average per Day ============
	declare @monthly_tbl table(MonthNumber int, TotalDays int)
	declare @month int = 1

	WHILE @month <= 12
	BEGIN
		insert into @monthly_tbl (MonthNumber, TotalDays)
		select @month
		, DATEDIFF(DAY, cast(@year as char(4)) + '-' + cast(@month as char(2)) + '-01', cast(IIF(@month+1 > 12, @year + 1, @year) as char(4)) + '-' + cast(IIF(@month+1 > 12, 1, @month+1) as char(2)) + '-01')
		SET @month += 1;
	END;

	insert into @tbl
	select 'Average Per Day', m.MonthNumber, CAST(ROUND(CAST(ISNULL(src.TotalPEB, 0) as float)/m.TotalDays, 2, 1) as decimal(18,2)) as DailyAVG
	from @monthly_tbl m
	left join (
		select 
			DATEPART(MONTH, PebDateNumeric) as MonthNumber
			, COUNT(DISTINCT AjuNumber) as TotalPEB
		from [dbo].[fn_get_approved_npe_peb]() 
		where ((DATEPART(MONTH, PebDateNumeric) >= DATEPART(MONTH, @StartPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @StartPeriod)) OR @StartPeriod = '') 
				AND ((DATEPART(MONTH, PebDateNumeric) <= DATEPART(MONTH, @EndPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @EndPeriod)) OR @EndPeriod = '')
		group by DATEPART(MONTH, PebDateNumeric)
	)src on m.MonthNumber = src.MonthNumber

	select * from(
		select Description, LEFT(DATENAME(MONTH , DATEADD(MONTH, MonthNumber, -1)), 3) as MonthName, Value from @tbl
	)src
	pivot(max(Value) for MonthName in ([Jan],[Feb],[Mar],[Apr],[May],[Jun],[Jul],[Aug],[Sep],[Oct],[Nov],[Dec])) pvt
	order by Description desc

END
GO

/****** Object:  StoredProcedure [dbo].[SP_RPTTUBranch_AverageYTD]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_RPTTUBranch_AverageYTD]
	@StartPeriod nvarchar(20),
	@EndPeriod nvarchar(20)
AS
BEGIN

	declare @YTDMonthlyAVG decimal(18,2), @YTDWeeklyAVG decimal(18,2), @YTDDailyAVG decimal(18,2)

	declare @year int = DATEPART(YEAR, @StartPeriod)
	declare @StartMonth int = DATEPART(MONTH, @StartPeriod), @EndMonth int = DATEPART(MONTH, @EndPeriod)

	declare @monthly_tbl table(MonthNumber int, TotalDays int)
	declare @month int = 1

	WHILE @month <= 12
	BEGIN
		insert into @monthly_tbl 
		select @month
		, DATEDIFF(DAY, cast(@year as char(4)) + '-' + cast(@month as char(2)) + '-01', cast(IIF(@month+1 > 12, @year + 1, @year) as char(4)) + '-' + cast(IIF(@month+1 > 12, 1, @month+1) as char(2)) + '-01')
		SET @month += 1;
	END;

	--============ Average per Month ============
	select @YTDMonthlyAVG = CAST(ROUND(AVG(CAST(ISNULL(src.TotalPEB, 0) as float)), 2, 1) as decimal(18,2))
	from @monthly_tbl m
	left join (
		select 
			DATEPART(MONTH, PebDateNumeric) as MonthNumber
			, COUNT(DISTINCT AjuNumber) as TotalPEB
		from [dbo].[fn_get_approved_npe_peb]() 
		where ((DATEPART(MONTH, PebDateNumeric) >= DATEPART(MONTH, @StartPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @StartPeriod)) OR @StartPeriod = '') 
				AND ((DATEPART(MONTH, PebDateNumeric) <= DATEPART(MONTH, @EndPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @EndPeriod)) OR @EndPeriod = '')
		group by DATEPART(MONTH, PebDateNumeric)
	)src on m.MonthNumber = src.MonthNumber


	--============ Weekly Average (YTD) ============
	declare @maxweek int, @week int = 1
	declare @startdate datetime = CAST(@year as nvarchar(4)) + '-01-01'
	declare @enddate datetime = CAST(@year as nvarchar(4)) + '-12-31'
	set @maxweek = DATEPART(WEEK, @enddate)
	declare @weekly_tbl table(WeekNumber int, MonthNumber int)

	WHILE @week <= @maxweek
	BEGIN
		insert into @weekly_tbl 
		select @week, DATEPART(MONTH, DATEADD(WW, @week - 1, @startdate))
		SET @week = @week + 1;
	END;

	select @YTDWeeklyAVG = CAST(ROUND(AVG(TotalPEB), 2, 1) as decimal(18,2)) 
	from (
		select w.MonthNumber, AVG(CAST(ISNULL(src.TotalPEB, 0) as float)) as TotalPEB
		from @weekly_tbl w
		left join(
			select 
				DATEPART(WK, PebDateNumeric) as WeekNumber
				, COUNT(DISTINCT AjuNumber) as TotalPEB
			from [dbo].[fn_get_approved_npe_peb]() 
			where ((DATEPART(MONTH, PebDateNumeric) >= DATEPART(MONTH, @StartPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @StartPeriod)) OR @StartPeriod = '') 
					AND ((DATEPART(MONTH, PebDateNumeric) <= DATEPART(MONTH, @EndPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @EndPeriod)) OR @EndPeriod = '')
			group by DATEPART(WK, PebDateNumeric)
		)src on w.WeekNumber = src.WeekNumber
		GROUP BY w.MonthNumber
	)src where MonthNumber >= @StartMonth and MonthNumber <= @EndMonth


	--============ Daily Average (YTD) ============
	select @YTDDailyAVG = CAST(ROUND(AVG(TotalPEB), 2, 1) as decimal(18,2)) 
	from (
		select m.MonthNumber, CAST(ISNULL(src.TotalPEB, 0) as float)/m.TotalDays as TotalPEB
		from @monthly_tbl m
		left join (
			select 
				DATEPART(MONTH, PebDateNumeric) as MonthNumber
				, COUNT(DISTINCT AjuNumber) as TotalPEB
			from [dbo].[fn_get_approved_npe_peb]() 
			where ((DATEPART(MONTH, PebDateNumeric) >= DATEPART(MONTH, @StartPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @StartPeriod)) OR @StartPeriod = '') 
					AND ((DATEPART(MONTH, PebDateNumeric) <= DATEPART(MONTH, @EndPeriod) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @EndPeriod)) OR @EndPeriod = '')
			group by DATEPART(MONTH, PebDateNumeric)
		)src on m.MonthNumber = src.MonthNumber
	)src where MonthNumber >= @StartMonth and MonthNumber <= @EndMonth

	select @YTDMonthlyAVG as YTDMonthlyAVG, @YTDWeeklyAVG as YTDWeeklyAVG, @YTDDailyAVG as YTDDailyAVG

END
GO

/****** Object:  StoredProcedure [dbo].[SP_RPTTUBranch]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_RPTTUBranch]
	@StartMonth nvarchar(20),
	@EndMonth nvarchar(20),
	@Type nvarchar(20)
AS
BEGIN

	declare @tbl table (Name nvarchar(200), TotalPEB int, TotalPEBJan int, TotalPEBFeb int, TotalPEBMar int, TotalPEBApr int, TotalPEBMay int, TotalPEBJun int, TotalPEBJul int, TotalPEBAug int, TotalPEBSep int, TotalPEBOct int, TotalPEBNov int, TotalPEBDec int)

	IF(@Type = 'Branch')
	BEGIN
		insert into @tbl
		select 
			Branch
		, count(DISTINCT AjuNumber) as TotalPEB
			, IIF(DATEPART(MONTH, PebDateNumeric) = 1, count(DISTINCT AjuNumber), 0) as TotalPEBJan
			, IIF(DATEPART(MONTH, PebDateNumeric) = 2, count(DISTINCT AjuNumber), 0) as TotalPEBFeb
			, IIF(DATEPART(MONTH, PebDateNumeric) = 3, count(DISTINCT AjuNumber), 0) as TotalPEBMar
			, IIF(DATEPART(MONTH, PebDateNumeric) = 4, count(DISTINCT AjuNumber), 0) as TotalPEBApr
			, IIF(DATEPART(MONTH, PebDateNumeric) = 5, count(DISTINCT AjuNumber), 0) as TotalPEBMay
			, IIF(DATEPART(MONTH, PebDateNumeric) = 6, count(DISTINCT AjuNumber), 0) as TotalPEBJun
			, IIF(DATEPART(MONTH, PebDateNumeric) = 7, count(DISTINCT AjuNumber), 0) as TotalPEBJul
			, IIF(DATEPART(MONTH, PebDateNumeric) = 8, count(DISTINCT AjuNumber), 0) as TotalPEBAug
			, IIF(DATEPART(MONTH, PebDateNumeric) = 9, count(DISTINCT AjuNumber), 0) as TotalPEBSep
			, IIF(DATEPART(MONTH, PebDateNumeric) = 10, count(DISTINCT AjuNumber), 0) as TotalPEBOct
			, IIF(DATEPART(MONTH, PebDateNumeric) = 11, count(DISTINCT AjuNumber), 0) as TotalPEBNov
			, IIF(DATEPART(MONTH, PebDateNumeric) = 12, count(DISTINCT AjuNumber), 0) as TotalPEBDec 
		from [dbo].[fn_get_approved_npe_peb]() 
		where ((DATEPART(MONTH, PebDateNumeric) >= DATEPART(MONTH, @StartMonth) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @StartMonth)) OR @StartMonth = '') 
				AND ((DATEPART(MONTH, PebDateNumeric) <= DATEPART(MONTH, @EndMonth) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @EndMonth)) OR @EndMonth = '')
		group by Branch, DATEPART(MONTH, PebDateNumeric)
	END
	ELSE IF(@Type = 'Loading')
	BEGIN
		insert into @tbl
		select 
			PortOfLoading
			, count(DISTINCT AjuNumber) as TotalPEB
			, IIF(DATEPART(MONTH, PebDateNumeric) = 1, count(DISTINCT AjuNumber), 0) as TotalPEBJan
			, IIF(DATEPART(MONTH, PebDateNumeric) = 2, count(DISTINCT AjuNumber), 0) as TotalPEBFeb
			, IIF(DATEPART(MONTH, PebDateNumeric) = 3, count(DISTINCT AjuNumber), 0) as TotalPEBMar
			, IIF(DATEPART(MONTH, PebDateNumeric) = 4, count(DISTINCT AjuNumber), 0) as TotalPEBApr
			, IIF(DATEPART(MONTH, PebDateNumeric) = 5, count(DISTINCT AjuNumber), 0) as TotalPEBMay
			, IIF(DATEPART(MONTH, PebDateNumeric) = 6, count(DISTINCT AjuNumber), 0) as TotalPEBJun
			, IIF(DATEPART(MONTH, PebDateNumeric) = 7, count(DISTINCT AjuNumber), 0) as TotalPEBJul
			, IIF(DATEPART(MONTH, PebDateNumeric) = 8, count(DISTINCT AjuNumber), 0) as TotalPEBAug
			, IIF(DATEPART(MONTH, PebDateNumeric) = 9, count(DISTINCT AjuNumber), 0) as TotalPEBSep
			, IIF(DATEPART(MONTH, PebDateNumeric) = 10, count(DISTINCT AjuNumber), 0) as TotalPEBOct
			, IIF(DATEPART(MONTH, PebDateNumeric) = 11, count(DISTINCT AjuNumber), 0) as TotalPEBNov
			, IIF(DATEPART(MONTH, PebDateNumeric) = 12, count(DISTINCT AjuNumber), 0) as TotalPEBDec	
		from [dbo].[fn_get_approved_npe_peb]() 
		where ((DATEPART(MONTH, PebDateNumeric) >= DATEPART(MONTH, @StartMonth) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @StartMonth)) OR @StartMonth = '') 
				AND ((DATEPART(MONTH, PebDateNumeric) <= DATEPART(MONTH, @EndMonth) AND DATEPART(YEAR, PebDateNumeric) = DATEPART(YEAR, @EndMonth)) OR @EndMonth = '')
		group by PortOfLoading, DATEPART(MONTH, PebDateNumeric)
	END

	select 
		CAST(ROW_NUMBER() OVER ( ORDER BY Name ) as NVARCHAR(5)) RowNumber
		, * 
	from @tbl

END
GO

/****** Object:  StoredProcedure [dbo].[SP_RSailingEstimation]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[SP_RSailingEstimation]
	-- Add the parameters for the stored procedure here
	@origin varchar(50),
	@destination varchar(50)
AS
BEGIN
DECLARE @SQL as nvarchar(Max)
declare @whereRef nvarchar(max) =''
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	IF @origin <>'' 
	BEGIN
    	SET @whereRef=' and ConsigneeCountry = '''' + @origin +'''''
	 END
	 print (@whereRef)
   IF @destination <>''
	BEGIN
    	SET @whereRef+=' and SoldToCountry = '''' + @destination +'''''
	 END
    -- Insert statements for procedure here
SET @SQL = 'SELECT * FROM [Fn_RSailingEstimation]() WHERE 1=1 '+ @whereRef
   
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

/****** Object:  StoredProcedure [dbo].[SP_RTrendExport]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hasni
-- Create date: 16/10/2019
-- Description:	Trend Export (Interval Year)
-- =============================================
ALTER PROCEDURE [dbo].[SP_RTrendExport]
	--@year int
AS
BEGIN
	-- Insert statements for procedure here
	-- total export value per thn (peb approved)
	SELECT 
		SUM(ExtendedValue) as totalExportValue, 
		COUNT(DISTINCT AjuNumber) totalPeb, 
		Year(t4.CreateDate) as [year]
	FROM NpePeb t0
	JOIN RequestCl t1 
		on t1.IdCl = t0.IdCl AND t1.IdStep = 10020
		and t1.[Status] = 'Approve'
	JOIN Cargo t2 on t2.id = t1.IdCl
	JOIN CargoCipl t3 on t3.IdCargo = t2.Id
	JOIN CiplItem t4 on t4.IdCipl = t3.IdCipl AND t4.Currency = 'USD'
	WHERE Year(t4.CreateDate)= 2019--@year
	GROUP BY Year(t4.CreateDate)

END
GO

/****** Object:  StoredProcedure [dbo].[sp_searchContainerNumber]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_searchContainerNumber]
(
	@IdCargo bigint,
	@ContainerNumber  nvarchaR(100)
	
)	
as 
begin
select * from CargoItem
where IdCargo = @IdCargo and ContainerNumber = @ContainerNumber
end

GO

/****** Object:  StoredProcedure [dbo].[sp_send_email_for_ckb]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_send_email_for_ckb](
                @subject nvarchar(max),
                @to nvarchar(max),
                @content nvarchar(max)
)
AS
BEGIN
                SET NOCOUNT ON
                
                EXEC msdb.dbo.sp_send_dbmail 
                                @recipients = @to,
                                @copy_recipients = 'ict.bpm@trakindo.co.id',
                                @subject = @subject,
                                @body = @content,
                                @body_format = 'HTML',
                                @profile_name = 'EMCS';

                insert into dbo.Test_Email_Log ([To], Content, [Subject], CreateDate) values (@to, @Content, @subject, GETDATE());

END
GO

/****** Object:  StoredProcedure [dbo].[sp_send_email_for_group]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_send_email_for_group] -- sp_send_email_for_group 'Ali Mutasal', 'content', 'IMEX'
(
	@subject nvarchar(max) = '',
	@groupname nvarchar(max) = '',
	@content nvarchar(max) = ''
)
AS
BEGIN
	DECLARE @to NVARCHAR(MAX);
	DECLARE @EmailTos nvarchar(max);
	SELECT @EmailTos = cast(stuff((
		SELECT ';' + convert(nvarchar(max), '' + cast(d.Email as nvarchar(255))+'') 
		from (
			SELECT DISTINCT Email from fn_get_employee_internal_ckb() d where d.[Group] = @groupname 					
		) d
	for xml path('')), 1, 1, '') as nvarchar(max))

	IF (@EmailTos <> '') 
	BEGIN
		exec dbo.sp_send_email_for_single @subject, '', @content, @EmailTos
	END	 
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

/****** Object:  StoredProcedure [dbo].[sp_send_email_notifications]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[sp_send_email_notifications] 
AS
BEGIN

	DECLARE @ID AS VARCHAR(100);
	DECLARE @EmailTo AS VARCHAR(MAX);
	DECLARE @EmailSubject AS VARCHAR(500);
	DECLARE @EmailBody AS VARCHAR(MAX);
	DECLARE @MailItemID AS INT;
	DECLARE @result AS INT = -1;

	UPDATE [EmailQueue]
	SET IsSent = 0, [Message] = l.description 
	FROM [EmailQueue] mail
	JOIN msdb.dbo.sysmail_faileditems as items  ON (items.mailitem_id = mail.MailItemID)
	JOIN msdb.dbo.sysmail_event_log AS l ON items.mailitem_id = l.mailitem_id  

	DECLARE mail_cursor CURSOR FOR
	SELECT [ID]
			,[EmailTo]
			,[EmailSubject]
			,[EmailBody]
	FROM [EmailQueue]
	WHERE IsSent = 0

	OPEN mail_cursor  
	FETCH NEXT FROM mail_cursor   
	INTO @ID, @EmailTo, @EmailSubject, @EmailBody

	WHILE @@FETCH_STATUS = 0  																																																																										WHILE @@FETCH_STATUS = 0  
	BEGIN  		
		BEGIN TRY
			-- Send Email
		EXEC @result =  msdb.dbo.sp_send_dbmail 
				@recipients = @EmailTo,
				@subject = @EmailSubject,
				@body = @EmailBody,
				@body_format = 'HTML',
				@profile_name = 'EMCS',
				@mailitem_id = @MailItemID;
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE() AS ErrorMessage;
			UPDATE [EmailQueue] SET [Message] = ERROR_MESSAGE(), MailItemID = NULL WHERE ID = @ID
		END CATCH

		IF @result = 0
		BEGIN
			UPDATE [EmailQueue] SET IsSent = 1, [Message] = 'Success', MailItemID = @MailItemID , SendDate = getDate() WHERE ID = @ID
		END

		FETCH NEXT FROM mail_cursor   
		INTO @ID, @EmailTo, @EmailSubject, @EmailBody
	END
	CLOSE mail_cursor;
	DEALLOCATE mail_cursor; 

END
GO

/****** Object:  StoredProcedure [dbo].[SP_sendmail_RequestShipment]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Proc [dbo].[SP_sendmail_RequestShipment] 
@DHLShipmentID bigint,
@UserId varchar(50)
	
AS
BEGIN
SET NOCOUNT ON
	
	-------#TRACE
	--Declare @DHLShipmentID bigint = 70057
	--	  , @userid varchar(50) = 'tes'

		--select * from DHLShipment order by CreateDate desc
		--select * from DhlPerson
		--select * from DHLPackage where DHLShipmentID=70057

	----#1 Inisiasi var
	Declare @body nvarchar(max), @Subject varchar(200), @StatusError varchar(100)
	Declare @AWBNumber varchar(50), @ConfirmationNumber varchar(50), @UserCreateID varchar(50), @UserCreateName varchar(50), @ShipperName varchar(50), @ShipperEmail varchar(50)
		  , @CiplId varchar(100), @CiplNo varchar(150)
	Declare @RecipientName varchar(100), @RecipientCompany varchar(100), @RecipientPhone varchar(100), @RecipientEmail varchar(100), @RecipientStreetlines varchar(max), @RecipientCity varchar(100)
	Declare @ShipmentLength decimal(18,2), @ShipmentWidth decimal(18,2), @ShipmentHeight decimal(18,2), @ShipmentWeight decimal(18,2), @ShipmentPackagesQty int, @ShipmentUnitPrice decimal(18,2)
		  , @ShipmentPickupDatetime varchar(16), @ShipmentLocation varchar(100)
	Declare @TblCiplNo table (CiplNo varchar(100))
	
	Select @AWBNumber = ISNULL(IdentifyNumber, ''), @ConfirmationNumber = ISNULL(ConfirmationNumber, ''), @UserCreateID = isnull(CreateBy, ''), @CiplId = ISNULL(Referrence, ''), @ShipmentPackagesQty = PackagesCount
		 , @ShipmentUnitPrice = PackagesPrice, @ShipmentLocation = ISNULL(PickupLocation, ''), @ShipmentPickupDatetime = CONVERT(varchar(10), ShipTimestamp, 120) + ' ' + PickupLocTime
	From DHLShipment 
	Where DHLShipmentID = @DHLShipmentID

	Select @ShipmentWidth = SUM([Width]), @ShipmentLength = SUM([Length]), @ShipmentHeight = SUM(Height), @ShipmentWeight = SUM([Weight])
	From DHLPackage
	Where DHLShipmentID = @DHLShipmentID 
		  AND IsDelete = 0

	Select @ShipperName = ISNULL(PersonName, ''), @ShipperEmail = ISNULL(EmailAddress, '')
	From DHLPerson 
	Where DHLShipmentID = @DHLShipmentID 
		  AND PersonType = 'SHIPPER' 
		  AND IsDelete = 0

	Select @RecipientName = ISNULL(PersonName, ''), @RecipientCompany = ISNULL(CompanyName, ''), @RecipientPhone = ISNULL(PhoneNumber, ''), @RecipientEmail = ISNULL(EmailAddress, '')
		 , @RecipientStreetlines = ISNULL(StreetLines, ''), @RecipientCity = ISNULL(City, '') + ', ' + ISNULL(PostalCode, '')
	From DHLPerson
	Where DHLShipmentID = @DHLShipmentID 
		  AND PersonType = 'RECIPIENT' 
		  AND IsDelete = 0	

	----# Get CiplNo
	Insert into @TblCiplNo
	Select CiplNo
	From Cipl 
	Where id in ( Select Item From dbo.FN_SplitStringToRows(@CiplId, ',') )

	Select @CiplNo = ISNULL(CiplNolist, '')
	From
	(
		select distinct  
		stuff
		(
			(
				select ', ' + u.CiplNo
				from @TblCiplNo u
				where u.CiplNo = CiplNo
				order by u.CiplNo
				for xml path('')
			),1,1,''
		) as CiplNolist
		from @TblCiplNo
		group by CiplNo
	)a

	Select @UserCreateName = ISNULL(FullName, '') 
	From [PartsInformationSystem].[dbo].[UserAccess] with(nolock) 
	Where UserID = @UserCreateID

	--select @AWBNumber '@AWBNumber', @ShipperName '@ShipperName', @UserCreateID '@UserCreateID', @UserCreateName '@UserCreateName', @ConfirmationNumber '@ConfirmationNumber', @CiplNo '@CiplNo', @RecipientName '@RecipientName'
	--	 , @RecipientCompany '@RecipientCompany', @RecipientPhone '@RecipientPhone', @RecipientEmail '@RecipientEmail', @RecipientStreetlines '@RecipientStreetlines', @RecipientCity '@RecipientCity'
	--	 , @ShipmentLength '@ShipmentLength', @ShipmentWidth '@ShipmentWidth', @ShipmentHeight '@ShipmentHeight', @ShipmentWeight '@ShipmentWeight', @ShipmentPackagesQty '@ShipmentPackagesQty', @ShipmentUnitPrice '@ShipmentUnitPrice'
	--	 , @ShipmentPickupDatetime '@ShipmentPickupDatetime', @ShipmentLocation '@ShipmentLocation'

	Set @Subject = 'DHL Express Shipment Confirmation ['+ @AWBNumber +']'

	
	 SET @body ='<p>Dear Mr/Mrs ' + @ShipperName + '<br /><br />
					A DHL Express shipment has been created by  ' + @UserCreateName + '. Please print the enclosed shipment paperwork and attach it to your shipment. <br /><br />
					
					<table style="width: 100%; border: none;">
						<tbody>
							<tr>
								<td style="width: 20%;">Pickup Confirmation Number</td>
								<td style="width: 1%;">:</td>
								<td style="width: 79%;">' + @ConfirmationNumber + '</td>
							</tr>
							<tr>
								<td>Refer to CIPL No</td>
								<td>:</td>
								<td>' +@CiplNo+ '</td>
							</tr>
						</tbody>
					</table>
					<br /><br />

					<table style="width: 90%; border: none;">
						<tbody>
							<tr>
								<td style="background-color: #cbcaf4;">&nbsp;&nbsp;<b>Recipient</b></td>
								<td></td>
								<td></td>
								<td style="background-color: #cbcaf4;">&nbsp;&nbsp;<b>Shipment Info</b></td>
								<td></td>
								<td></td>
							</tr>
							<tr>
								<td style="width: 11%;">Name</td>
								<td style="width: 1%;">:</td>
								<td style="width: 30%;">' + @RecipientName + '</td>
								<td style="width: 17%;">AWB No</td>
								<td style="width: 1%;">:</td>
								<td style="width: 40%;">' + @AWBNumber + '</td>
							</tr>
							<tr>
								<td>Company</td>
								<td>:</td>
								<td>' + @RecipientCompany + '</td>
								<td>Length</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentLength) + '</td>
							</tr>
							<tr>
								<td>Phone</td>
								<td>:</td>
								<td>' + @RecipientPhone + '</td>
								<td>Width</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentWidth) + '</td>
							</tr>
							<tr>
								<td>Email</td>
								<td>:</td>
								<td>' + @RecipientEmail + '</td>
								<td>Height</td>
								<td>:</td>
								<td>' + ISNULL(Convert(varchar, @ShipmentHeight), '') + '</td>
							</tr>
							<tr>
								<td>Street Lines</td>
								<td>:</td>
								<td>' + @RecipientStreetlines + '</td>
								<td>Weight</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentWeight) + '</td>
							</tr>
							<tr>
								<td>City</td>
								<td>:</td>
								<td>' + @RecipientCity + '</td>
								<td>Total Package / Collies</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentPackagesQty) + '</td>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td>Total Unit Price</td>
								<td>:</td>
								<td>' + Convert(varchar, @ShipmentUnitPrice) + '</td>
							</tr>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td>Date / Time Pickup</td>
								<td>:</td>
								<td>' + @ShipmentPickupDatetime + '</td>
							</tr>
							<tr>
								<td></td>
								<td></td>
								<td></td>
								<td>Pickup Location</td>
								<td>:</td>
								<td>' + @ShipmentLocation + '</td>
							</tr>
						</tbody>
					</table>
					
					<br /><br />
					Thank you. <br />
				 </p>'

	--Print (@body);
		
	if isnull(@ShipperName, '') <> ''
	begin
		BEGIN TRY
			BEGIN TRANSACTION;

			EXEC msdb.dbo.sp_send_dbmail	
				@profile_name = 'EMCS',  
				@recipients = 'ict.bpm@trakindo.co.id',	--@ShipperName, 
				@copy_recipients = '',
				@body = @body,  
				@subject = @subject,
				@blind_copy_recipients = 'hidayat@iforce.co.id',
				@body_format = 'HTML';
			
			COMMIT TRANSACTION;
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			BEGIN
				Set @StatusError = 'Failed'
			END
		END CATCH;

		--Print @StatusError + ' - ' + isnull(@to_string, '')

		----Insert into LogEmail (IdEmail, InnovationId, [From], [To], Cc, [Subject], Body, [Status], IsActive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
		----select IdEmail=NULL, InnovationId=@innovationid, [From]='"Innovation Notification" <noreply@trakindo.co.id>', [To]=@to_string, Cc=@cc_string
		----	, [Subject]=@subject, Body=@body, [Status]=@StatusError, IsActive=1, CreatedBy=@usercreate, CreatedDate=GETDATE(), UpdatedBy=null, UpdatedDate=null
	end
END
GO

/****** Object:  StoredProcedure [dbo].[sp_sendmailnotification]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: EMCS
-- Create date	: 23 Jan 2019
-- Description	: SP Untuk mengirimkan Email
-- =============================================
-- exec [dbo].[SP_SendMailNotification]
ALTER PROCEDURE [dbo].[sp_sendmailnotification]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	DECLARE @id bigint, @to nvarchar(max), @cc nvarchar(max), @auditor nvarchar(max), @periodaudit nvarchar(max), @branch nvarchar(max), @notifperiod datetime;
	DECLARE @body nvarchar(max), @subject nvarchar(max)
	SET NOCOUNT ON;
	
	DECLARE db_cursor CURSOR FOR 
    
	-- Insert statements for procedure here
	SELECT ID, [To], [CC], [Branch], [Auditor], iif([PeriodAudit] = 2, 'Final Audit', 'First Audit') PeriodAudit, [Notifperiod] FROM dbo.TblEmailNotification
	WHERE AlreadySending = 0

	--select @body = TemplateEmail from Setting where TypeConfig = 'TemplateEmail'

	-- Declare Cursor to Looping the PIP data

	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @id, @to, @cc, @branch, @auditor, @periodaudit, @notifperiod

	WHILE @@FETCH_STATUS = 0
	BEGIN 
	
		BEGIN TRY
			select 
				@body = REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
												TemplateEmail,
												'{Auditor}',@auditor),
											'{PeriodAudit}',@periodaudit),
										 '{Branch}',@branch),
									'{NotifPeriod}',day(@notifperiod)),
								'{Link}','<a href="http://pis.trakindo.co.id/"> Contamination Control Portal </a>')
			from Setting where TypeConfig = 'TemplateEmail'
			
			select @subject = REPLACE(REPLACE(templateemail,'{Branch}',@branch),'{PeriodAudit}',@periodaudit) from Setting where TypeConfig = 'SubjectEmail'
			
			EXEC msdb.dbo.sp_send_dbmail  
			    @profile_name = 'CCPMail',  
			    @recipients = @to,  
			    @body = @body,  
			    @subject = @subject,
				@body_format = 'HTML';  

			UPDATE [dbo].[tblEmailNotification] SET AlreadySending = 1, UpdatedBy = 1, UpdatedOn = GETDATE() WHERE ID = @id;
		END TRY
		BEGIN CATCH
			--select @id;
			SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;  
		END CATCH

		FETCH NEXT FROM db_cursor INTO @id, @to, @cc, @branch, @auditor, @periodaudit, @notifperiod
	END	  
	CLOSE db_cursor
	DEALLOCATE db_cursor	
END
GO

/****** Object:  StoredProcedure [dbo].[sp_set_ss_number]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[sp_set_ss_number]
	@IdCl nvarchar(100)
AS
BEGIN
	DECLARE @Status nvarchar(100);
	declare @count int

	select @Status = [Status] from dbo.RequestCl where IdCl = @IdCl;
	select @count=count(*) from CargoItem where IdCargo = @IdCl

	IF ISNULL(@Status, '') = 'Submit' AND @count > 1
	BEGIN
		exec dbo.GenerateShippingSummaryNumber @IdCl, ''
	END
END
GO

/****** Object:  StoredProcedure [dbo].[SP_ShipmentDhlDelete]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ShipmentDhlDelete]
(    
	@DHLShipmentID BIGINT
)
AS
BEGIN
	DECLARE @TrackingShipmentId INT;

	SELECT @TrackingShipmentId = DHLTrackingShipmentID FROM DHLTrackingShipment where DHLShipmentID =  @DHLShipmentID;

	update DHLShipment set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLPackage set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLPerson set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLRate set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLAttachment set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLTrackingNumber set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLTrackingShipment set IsDelete = 1 where DHLShipmentID = @DHLShipmentID
	update DHLTrackingShipmentEvent set IsDelete = 1 where DHLTrackingShipmentID = @TrackingShipmentId
	update DHLTrackingShipmentPiece set IsDelete = 1 where DHLTrackingShipmentID = @TrackingShipmentId

END
GO

/****** Object:  StoredProcedure [dbo].[SP_ShipmentDhlGetList]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---- Exec SP_ShipmentDhlGetList '', 'ict.bpm'

ALTER PROCEDURE [dbo].[SP_ShipmentDhlGetList]
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

/****** Object:  StoredProcedure [dbo].[SP_ShipmentDhlInsertDetail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_ShipmentDhlInsertDetail]
(    
	@DHLShipmentID BIGINT,
	@CreateBy NVARCHAR(200)
)
AS
BEGIN
	--DECLARE @DHLShipmentID BIGINT = 12;
	--DECLARE @CreateBy NVARCHAR(200) = 'XUPJ21WDN';
	DECLARE @Reference nvarchar(max);

	update DHLPackage set IsDelete = 1 Where DHLShipmentID = @DHLShipmentID

	SELECT @Reference = Referrence FROM DHLShipment WHERE DHLShipmentID = @DHLShipmentID
	print @Reference	

	INSERT INTO dbo.DHLPackage (DHLShipmentID, PackageNumber, Insured, Weight, Length, Width, Height, CustReferences, CaseNumber, CiplNumber, IsDelete, CreateBy, CreateDate)
	SELECT @DHLShipmentID AS DHLShipmentID, ROW_NUMBER() OVER(ORDER BY ci.CaseNumber ASC) AS PackageNumber, '0.00', SUM(ci.GrossWeight)
	, SUM(ci.Length), SUM(ci.Width), SUM(ci.Height), '-', ci.CaseNumber, ci.IdCipl AS CiplNumber, 0 AS IsDelete, @CreateBy AS CreateBy, GETDATE() AS CreateDate
	FROM fnSplitString(@Reference, ',') t0 
	JOIN CiplItem ci ON ci.IdCipl = t0.splitdata AND ci.IsDelete = 0
	GROUP BY ci.CaseNumber, ci.IdCipl

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

/****** Object:  StoredProcedure [dbo].[sp_SubConCompanyAdd]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_SubConCompanyAdd]  
(  
@Id nvarchar(100),  
@Name nvarchar(max),  
@Value nvarchar(max),  
@CreateBy nvarchar(Max),  
@UpdatedBy nvarchar(Max) 
)  
as  
begin  
If (@Id = 0)  
begin  
insert into MasterSubConCompany([Name],[Value],CreatedBy,UpdatedBy,CreateDate,UpdateDate)  
VALUES(@Name,@Value,@CreateBy,'',GetDate(),'')  
SET @Id = SCOPE_IDENTITY()  
end  
else  
begin  
update MasterSubConCompany  
set [Name] = @Name,  
[Value] = @Value,  
UpdatedBy = @UpdatedBy,   
UpdateDate = GETDATE()  
where Id = @Id  
end  
select CAST(@Id as bigint) as Id
end
GO

/****** Object:  StoredProcedure [dbo].[sp_SubConCompanyDelete]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_SubConCompanyDelete]
(@Id bigint)
as 
begin
delete from MasterSubConCompany
where Id = @Id 
select @Id as Id
end	

GO

/****** Object:  StoredProcedure [dbo].[SP_Update_BlAwb]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
ALTER PROCEDURE [dbo].[SP_Update_BlAwb]    
(    
 @Id BIGINT,    
 @Number NVARCHAR(100),    
 @MasterBlDate datetime,    
 @HouseBlNumber NVARCHAR(200),    
 @HouseBlDate datetime,    
 @Description NVARCHAR(50),    
 @FileName NVARCHAR(max),    
 @Publisher NVARCHAR(50),    
 @UpdateBy NVARCHAR(50),    
 @UpdateDate datetime,    
 @IdCl BIGINT    
)    
AS    
BEGIN    
 DECLARE @LASTID bigint    
 UPDATE [dbo].[BlAwb]    
  SET [Number] = @Number     
     ,[MasterBlDate] = @MasterBlDate    
     ,[HouseBlNumber] = @HouseBlNumber    
     ,[HouseBlDate] = @HouseBlDate    
     ,[Description] = @Description    
     ,[FileName] = @FileName    
     ,[Publisher] = @Publisher    
  ,[UpdateBy] = @UpdateBy    
  ,[UpdateDate] = @UpdateDate    
     WHERE Id = @Id    
     SELECT C.Id as ID, CONVERT(nvarchar(5), C.IdCl) as [NO], C.CreateDate as CREATEDATE FROM BlAwb C WHERE C.id = @Id      
    
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_update_cargo_ByApprover]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
ALTER PROCEDURE [dbo].[sp_update_cargo_ByApprover]    
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
 @VesselFlight NVARCHAR(30),--='vessel',    
 @ConnectingVesselFlight NVARCHAR(30),--='con vessel',    
 @VoyageVesselFlight NVARCHAR(30),--='voy vessel',    
 @VoyageConnectingVessel NVARCHAR(30),--='voy con',    
 @PortOfLoading NVARCHAR(30),--='start',    
 @PortOfDestination NVARCHAR(30),--='end',    
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
    
 SELECT CAST(@ID as BIGINT) as ID    
    
END    
GO

/****** Object:  StoredProcedure [dbo].[sp_update_cargo]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  --DROP PROCEDURE [dbo].[sp_CargoInsert]    
ALTER PROCEDURE [dbo].[sp_update_cargo]    
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
 @PortOfLoading NVARCHAR(30),--='start',    
 @PortOfDestination NVARCHAR(30),--='end',    
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
    
 SELECT CAST(@ID as BIGINT) as ID    
    
END 
GO

/****** Object:  StoredProcedure [dbo].[sp_update_cipl_to_revise]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_update_cipl_to_revise] (
	@IdCargo nvarchar(100)
)
AS 
BEGIN
	SET NOCOUNT ON;
	UPDATE tab0
	SET 
		tab0.IdStep = tab1.NextStepId,
		tab0.[Status] = tab1.NextStatus
	FROM
	dbo.RequestCipl as tab0 
	INNER JOIN (select 
		t2.Id IdReq
		,CASE 
			WHEN t1.IdFlow = 1
			THEN 10032 
			WHEN t1.IdFlow = 2
			THEN 10033
			WHEN t1.IdFlow = 3
			THEN 10035
		END as NextStepId
		, 'Submit' NextStatus
		FROM dbo.CiplItemUpdateHistory as t0
		INNER JOIN dbo.fn_get_cipl_request_list_all() as t1 on t1.IdCipl = t0.IdCipl
		INNER JOIN dbo.RequestCipl as t2 on t2.IdCipl = t0.IdCipl
		WHERE IsApprove = 0
	) as tab1 on tab1.IdReq = tab0.Id AND tab0.IdCipl IN (
		select tx.IdCipl 
		from dbo.CargoCipl tx
		inner join dbo.CiplItemUpdateHistory ty on ty.IdCipl = tx.IdCipl AND ty.IdCargo = tx.IdCargo AND ty.IsApprove = 0
		where ty.IdCargo = @IdCargo
	)
END

GO

/****** Object:  StoredProcedure [dbo].[sp_update_request_cipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_update_request_cipl] -- sp_update_request_cipl(1, 'XUPJ21SAR', 'Submit', 'Testing Notes')
(
	@IdCipl bigint,
	@Username nvarchar(100),
	@NewStatus nvarchar(100),
	@Notes nvarchar(100) = '',
	@NewStep nvarchar(100) = ''
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @NewStepId bigint;
	DECLARE @IdFlow bigint;
	DECLARE @FlowName nvarchar(100);
	DECLARE @NextStepName nvarchar(100);
	DECLARE @Now datetime;
	DECLARE @GroupId nvarchar(100);
	DECLARE @CurrentStepId bigint;
	DECLARE @IdCargo nvarchar(100);
	DECLARE @IdStepCargo bigint;
	DECLARE @StatusCargo nvarchar(100);
		
	SET @Now = GETDATE();
	--SET @IdCipl = 1;
	--SET @Username = 'XUPJ21FIG';
	--SET @GroupId = 'IMEX';
	--SET @NewStatus = 'REJECT';

	select @GroupId = hce.Organization_Name from employee hce WHERE hce.AD_User = @Username;
	--select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cipl_request_list(@Username, @GroupId) t0 where t0.IdCipl = @IdCipl;
	select @IdFlow = IdFlow, @CurrentStepId = IdStep, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_cipl_request_list_all() t0 where t0.IdCipl = @IdCipl;

	-- Jika Revise Cipl
	IF ISNULL(@NewStep, '') <> ''
	BEGIN
		SET @NewStepId = @NewStep
		select @IdFlow = IdFlow, @NextStepName = Step from dbo.FlowStep where Id = @NewStepId;
	END	

	UPDATE [dbo].[RequestCipl]
	  SET [IdFlow] = @IdFlow
	     ,[IdStep] = @NewStepId
	     ,[Status] = @NewStatus
	     ,[Pic] = @Username
		 ,[UpdateBy] = @Username
		 ,[UpdateDate] = GETDATE()
	WHERE IdCipl = @IdCipl
	
	--PENAMBAHAN KONDISI REVISE 
	--LINGGA OKANTA S || 15.04.2021
	--===================================

	--Cek CIPL Sudah ada di CL belum
	select @IdCargo = IdCargo from cargocipl where idcipl = @IdCipl
	
	--Cek status di CL apakah revisinya sudah di approve IMEX atau belum, kalau sudah status dikembalikan ke 'Waiting for shipping instruction'
	IF @CurrentStepId = 10035 AND ISNULL(@IdCargo, '') <> ''
	BEGIN
		PRINT 'OK 1'
		select @IdStepCargo = IdStep, @StatusCargo = [Status] from requestcl where idcl = @IdCargo

		IF @IdStepCargo = 12 AND @StatusCargo = 'Approve'
		BEGIN
			PRINT 'OK 2'
			UPDATE RequestCipl SET idflow = 3, IdStep = 10, [status] = 'Approve' WHere IdCipl = @IdCipl
			exec [sp_approve_req_revise_cipl] @ciplid = @IdCipl, @username = @Username
		END
	END
	
	
	PRINT 'OK 3'
	--===================================

	-- Hasni Procedure Cancel CIPL
	IF  @NewStatus = 'Request Cancel'
	BEGIN
		IF @IdFlow = 1
		BEGIN 
			SET @NewStepId = 30037
		END
		ELSE IF @IdFlow = 2
		BEGIN
			SET @NewStepId = 30033
		END
		ELSE IF @IdFlow = 3
		BEGIN
			SET @NewStepId = 30044
		END

		UPDATE [dbo].[RequestCipl]
		  SET [IdFlow] = @IdFlow
			 ,[IdStep] = @NewStepId
			 ,[Status] = 'Submit'
			 ,[Pic] = @Username
			 ,[UpdateBy] = @Username
			 ,[UpdateDate] = GETDATE()
		WHERE IdCipl = @IdCipl
	END
	
	IF @NextStepName = 'Approval By Superior' AND @NewStatus = 'Approve'
	BEGIN
		EXEC [dbo].[GenerateEDONumber] @IdCipl, @Username
	END

	-- cancel CIPL
	IF @NewStepId IN (30039, 30035, 30046) AND @NewStatus = 'Approve'
	BEGIN
		exec [dbo].[sp_cipldelete] @IdCipl, @Username, GETDATE, 'ALL', 1
	END 

	-- Action CIPL Revise 
	IF (@CurrentStepId = 10032) OR (@CurrentStepId = 10033) OR (@CurrentStepId =10035) 
	BEGIN
		IF @NewStatus = 'Approve'
		BEGIN
			exec [sp_approve_req_revise_cipl] @ciplid = @IdCipl, @username = @Username
		END

		IF @NewStatus = 'Reject'
		BEGIN
			exec [sp_reject_req_revise_cipl] @ciplid = @IdCipl, @username = @Username
		END

		IF @NewStatus = 'Revise'
		BEGIN
			exec [sp_revise_req_revise_cipl] @ciplid = @IdCipl, @username = @Username
		END
	END

	IF @CurrentStepId IN (14, 10024, 10028) AND @NewStatus = 'Approve'
	BEGIN
		IF @IdFlow = 1
		BEGIN 
			SET @NewStepId = 1
		END
		ELSE IF @IdFlow = 2
		BEGIN
			SET @NewStepId = 6
		END
		ELSE IF @IdFlow = 3
		BEGIN
			SET @NewStepId = 9
		END

		UPDATE [dbo].[RequestCipl]
		  SET [IdFlow] = @IdFlow
			 ,[IdStep] = @NewStepId
			 ,[Status] = 'Draft'
			 ,[Pic] = @Username
			 ,[UpdateBy] = @Username
			 ,[UpdateDate] = GETDATE()
		WHERE IdCipl = @IdCipl
	END 

	exec [dbo].[sp_insert_cipl_history]@id=@IdCipl, @Flow=@FlowName, @Step=@NextStepName, @Status=@NewStatus, @Notes=@Notes, @CreateBy=@Username, @CreateDate=@Now;

	IF((select Status from RequestCipl where IdCipl = @IdCipl) <> 'DRAFT')
	BEGIN
		--EXEC [sp_send_email_notification] @IdCipl, 'CIPL'
		EXEC [sp_proccess_email] @IdCipl, 'CIPL'
	END
END

GO

/****** Object:  StoredProcedure [dbo].[sp_update_request_cl_for_si]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_update_request_cl_for_si] --41727, 'XUPJ21WDN', 'Submit', '', 'NonPJT' 
(      
 @IdCl bigint,      
 @Username nvarchar(100),      
 @NewStatus nvarchar(100),      
 @Notes nvarchar(100) = '',   
 @exportType nvarchar(10)=''      
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
                --declare @exportType nvarchar(10)=''      
                --SET @exportType = (select top 1 exporttype from dbo.ShippingInstruction where IdCL =@IdCl)      
                IF (@exportType ='PJT')      
                BEGIN      
					--SET @NewStepId = 10020   
					--SET @NextStepName = 'Waiting for BL or AWB'      
					--SET @FlowName = 'CL'      
					--SET @NewStatus = 'Approve'    
					SET @NewStepId = 10021 
					--SET @NewStepId = 10017 
					SET @NextStepName = 'Waiting for BL or AWB'      
					SET @FlowName = 'CL'      
					SET @NewStatus = 'Create'
                --PRINT 'exporttype ' + CAST(@exporttype AS VARCHAR(10));      
                END   
				--ELSE IF (@exportType = 'NonPJT')
				--BEGIN
				--	SET @NewStepId = 10020   
				--	SET @NextStepName = 'Waiting for BL or AWB'      
				--	SET @FlowName = 'CL'      
				--	SET @NewStatus = 'Approve'
				--END   
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

/****** Object:  StoredProcedure [dbo].[sp_update_request_gr]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_update_request_gr] -- sp_update_request_gr(1, 'XUPJ21SAR', 'Submit', 'Testing Notes')
(
	@IdGr bigint,
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
		
	SET @Now = GETDATE();
	select @GroupId = hce.Organization_Name from employee hce WHERE hce.AD_User = @Username;
	--select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_gr_request_list(@Username, @GroupId) t0 where t0.IdGr = @IdGr;
	select @IdFlow = IdFlow, @FlowName = upper(FlowName), @NewStepId = IdNextStep, @NextStepName = NextStepName from fn_get_gr_request_list_all() t0 where t0.IdGr = @IdGr;

	UPDATE [dbo].[RequestGr]
	  SET [IdFlow] = @IdFlow
	     ,[IdStep] = @NewStepId
	     ,[Status] = @NewStatus
	     ,[Pic] = @Username
		 ,[UpdateBy] = @Username
		 ,[UpdateDate] = GETDATE()
	WHERE IdGr = @IdGr
	
	exec [dbo].[sp_insert_gr_history]@id=@IdGr, @Flow=@FlowName, @Step=@NextStepName, @Status=@NewStatus, @Notes=@Notes, @CreateBy=@Username, @CreateDate=@Now;

	IF((select Status from RequestGr where IdGr = @IdGr) <> 'DRAFT')
	BEGIN
		--EXEC [sp_send_email_notification] @IdGr, 'GoodReceive'
		EXEC [sp_proccess_email] @IdGr, 'RG'
	END
END
GO

/****** Object:  StoredProcedure [dbo].[sp_update_RFCGR]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER proc [dbo].[sp_update_RFCGR]  --sp_update_RFCGR '','','',''      
(        
@Id nvarchar(100),        
@Vendor nvarchar(100) = null,         
@VehicleType nvarchar(100) = null,     
@VehicleMerk nvarchar(100) = null,      
@PickupPoint nvarchar(100) = null,    
@PickupPic nvarchar(100) = null,    
@Notes nvarchar(100) = null        
)        
as        
begin        
if  @Vendor <> ''    
begin      
update GoodsReceive        
set Vendor = @Vendor      
where Id = @Id        
end      
if  @VehicleType <> ''    
begin      
update GoodsReceive        
set VehicleType = @VehicleType      
where Id = @Id        
end    
if  @VehicleMerk <> ''      
begin      
update GoodsReceive        
set VehicleMerk = @VehicleMerk      
where Id = @Id        
end    
if  @PickupPoint <> ''      
begin      
update GoodsReceive        
set PickupPoint = @PickupPoint      
where Id = @Id        
end    
if  @PickupPic <> ''    
begin      
update GoodsReceive        
set PickupPic = @PickupPic      
where Id = @Id        
end    
if  @Notes <> ''    
begin      
update GoodsReceive        
set Notes = @Notes      
where Id = @Id        
end    
end
GO

/****** Object:  StoredProcedure [dbo].[sp_update_RFCSI]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[sp_update_RFCSI]  -- sp_update_RFCSI '977','','',''    
(      
@IdCl nvarchar(100),      
@SpecialInstruction nvarchar(100) = null,      
@DocumentRequired   nvarchar(100) = null     
)      
as      
begin      
if  @SpecialInstruction <> ''    
begin    
update ShippingInstruction      
set SpecialInstruction = @SpecialInstruction    
where IdCL = @IdCl      
end    
if  @DocumentRequired <> ''     
begin    
update ShippingInstruction      
set DocumentRequired = @DocumentRequired     
where IdCL = @IdCl      
end       
end

GO

/****** Object:  StoredProcedure [dbo].[sp_update_staging_employee]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_update_staging_employee]
as
BEGIN
       -- 1. Cek apakah table exists jika ya maka akan di drop dahulu
       --IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
       --                 WHERE TABLE_SCHEMA = 'dbo' 
       --                 AND  TABLE_NAME = 'Employee'))
       --BEGIN
       --       DROP TABLE Employee;
       --END
 Truncate Table Employee     
       -- 2. Buat table dan insert data ke table employee sebagai staging table HC.Employee
Insert Into Employee ([Employee_ID]
             ,[Employee_Name]
             ,[Email]
             ,[Dept_Code]
             ,[Dept_Name]
             ,[Division_Code]
             ,[Division_Name]
             ,[SubArea_Code]
             ,[SubArea_Name]
             ,[Cost_Center]
             ,[Job_Cluster]
             ,[Gender]
             ,[Employee_Status]
             ,[Superior_ID]
             ,[Superior_Name]
             ,[Company_ID]
             ,[Organization_ID]
             ,[Organization_Name]
             ,[Position_ID]
             ,[Position_Name]
             ,[Job_ID]
             ,[Job_Name]
             ,[Business_Area]
             ,[AD_User]
             ,[ETL_Date]
             ,[Personal_Area]
             ,[Personal_Area_Name]
             ,[Last_Updated_Date]
             ,[Created_By]
             ,[Phone_No]
             ,[Employee_Subgroup]
             ,[Employee_Subgroup_Desc]
             ,[HC_Admin_ID]
             ,[HC_Area_ID]
             ,[Action_Id]
             ,[Action_Name]
             ,[Hire_date]
             ,[Transaction_Date]
             ,[Hiring_process_date]
             ,[Org_assignment_Date]
             ,[MSS_Status]
             ,[Promotion_Date]
             ,[Termination_Date]
             ,[Time_In_Current_Position]
             ,[Email_HC_Area]
             ,[Email_HC_Admin]
             ,[HC_Admin_Name]
             ,[Email_Superior]
             ,[level]
             ,[SAP_User_ID])

       SELECT [Employee_ID]
             ,[Employee_Name]
             ,[Email]
             ,[Dept_Code]
             ,[Dept_Name]
             ,[Division_Code]
             ,[Division_Name]
             ,[SubArea_Code]
             ,[SubArea_Name]
             ,[Cost_Center]
             ,[Job_Cluster]
             ,[Gender]
             ,[Employee_Status]
             ,[Superior_ID]
             ,[Superior_Name]
             ,[Company_ID]
             ,[Organization_ID]
             ,[Organization_Name]
             ,[Position_ID]
             ,[Position_Name]
             ,[Job_ID]
             ,[Job_Name]
             ,[Business_Area]
             ,[AD_User]
             ,[ETL_Date]
             ,[Personal_Area]
             ,[Personal_Area_Name]
             ,[Last_Updated_Date]
             ,[Created_By]
             ,[Phone_No]
             ,[Employee_Subgroup]
             ,[Employee_Subgroup_Desc]
             ,[HC_Admin_ID]
             ,[HC_Area_ID]
             ,[Action_Id]
             ,[Action_Name]
             ,[Hire_date]
             ,[Transaction_Date]
             ,[Hiring_process_date]
             ,[Org_assignment_Date]
             ,[MSS_Status]
             ,[Promotion_Date]
             ,[Termination_Date]
             ,[Time_In_Current_Position]
             ,[Email_HC_Area]
             ,[Email_HC_Admin]
             ,[HC_Admin_Name]
             ,[Email_Superior]
             ,[level]
             ,[SAP_User_ID]
         --INTO Employee
         FROM   [BI_PROD].[EDW_MDS].[HC].[employee]
END
GO

/****** Object:  StoredProcedure [dbo].[sp_update_staging_employee2]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_update_staging_employee2]
as
BEGIN
       -- 1. Cek apakah table exists jika ya maka akan di drop dahulu
       --IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
       --                 WHERE TABLE_SCHEMA = 'dbo' 
       --                 AND  TABLE_NAME = 'Employee'))
       --BEGIN
       --       DROP TABLE Employee;
       --END
 Truncate Table Employee     
       -- 2. Buat table dan insert data ke table employee sebagai staging table HC.Employee
Insert Into Employee ([Employee_ID]
             ,[Employee_Name]
             ,[Email]
             ,[Dept_Code]
             ,[Dept_Name]
             ,[Division_Code]
             ,[Division_Name]
             ,[SubArea_Code]
             ,[SubArea_Name]
             ,[Cost_Center]
             ,[Job_Cluster]
             ,[Gender]
             ,[Employee_Status]
             ,[Superior_ID]
             ,[Superior_Name]
             ,[Company_ID]
             ,[Organization_ID]
             ,[Organization_Name]
             ,[Position_ID]
             ,[Position_Name]
             ,[Job_ID]
             ,[Job_Name]
             ,[Business_Area]
             ,[AD_User]
             ,[ETL_Date]
             ,[Personal_Area]
             ,[Personal_Area_Name]
             ,[Last_Updated_Date]
             ,[Created_By]
             ,[Phone_No]
             ,[Employee_Subgroup]
             ,[Employee_Subgroup_Desc]
             ,[HC_Admin_ID]
             ,[HC_Area_ID]
             ,[Action_Id]
             ,[Action_Name]
             ,[Hire_date]
             ,[Transaction_Date]
             ,[Hiring_process_date]
             ,[Org_assignment_Date]
             ,[MSS_Status]
             ,[Promotion_Date]
             ,[Termination_Date]
             ,[Time_In_Current_Position]
             ,[Email_HC_Area]
             ,[Email_HC_Admin]
             ,[HC_Admin_Name]
             ,[Email_Superior]
             ,[level]
             ,[SAP_User_ID])

       SELECT [Employee_ID]
             ,[Employee_Name]
             ,[Email]
             ,[Dept_Code]
             ,[Dept_Name]
             ,[Division_Code]
             ,[Division_Name]
             ,[SubArea_Code]
             ,[SubArea_Name]
             ,[Cost_Center]
             ,[Job_Cluster]
             ,[Gender]
             ,[Employee_Status]
             ,[Superior_ID]
             ,[Superior_Name]
             ,[Company_ID]
             ,[Organization_ID]
             ,[Organization_Name]
             ,[Position_ID]
             ,[Position_Name]
             ,[Job_ID]
             ,[Job_Name]
             ,[Business_Area]
             ,[AD_User]
             ,[ETL_Date]
             ,[Personal_Area]
             ,[Personal_Area_Name]
             ,[Last_Updated_Date]
             ,[Created_By]
             ,[Phone_No]
             ,[Employee_Subgroup]
             ,[Employee_Subgroup_Desc]
             ,[HC_Admin_ID]
             ,[HC_Area_ID]
             ,[Action_Id]
             ,[Action_Name]
             ,[Hire_date]
             ,[Transaction_Date]
             ,[Hiring_process_date]
             ,[Org_assignment_Date]
             ,[MSS_Status]
             ,[Promotion_Date]
             ,[Termination_Date]
             ,[Time_In_Current_Position]
             ,[Email_HC_Area]
             ,[Email_HC_Admin]
             ,[HC_Admin_Name]
             ,[Email_Superior]
             ,[level]
             ,[SAP_User_ID]
         --INTO Employee
         FROM   [BI_PROD].[EDW_MDS].[HC].[employee]
END
GO

/****** Object:  StoredProcedure [dbo].[SP_UpdateFileForHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[SP_UpdateFileForHistory]
(
@IdShippingFleet bigint,
@FileName nvarchar(max) = ''
)
as
begin
declare @Id  bigint 
insert  into ShippingFleetDocumentHistory(IdShippingFleet,FileName,CreateDate)
values (@IdShippingFleet,@FileName,GETDATE())
set @Id = SCOPE_IDENTITY()
select @Id As Id
end

GO

/****** Object:  StoredProcedure [dbo].[SP_UpdateFileForHistoryBlAwb]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_UpdateFileForHistoryBlAwb]    
(    
@IdBlAwb bigint,    
@FileName nvarchar(max) = ''    
)    
as    
begin    
declare @Id  bigint     
insert  into [BlAwbDocumentHistory](IdBlAwb,FileName,CreateDate)    
values (@IdBlAwb,@FileName,GETDATE())    
set @Id = SCOPE_IDENTITY()    
select @Id As Id    
end

GO

/****** Object:  StoredProcedure [dbo].[SP_UpdateGr]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[SP_UpdateGr](
  @Id nvarchar(100),
   @PickupPoint nvarchar(100),
   @PickupPic nvarchar(100)
  )
  as 
  begin 
  Update GoodsReceive
  set PickupPoint = @PickupPoint,
  PickupPic = @PickupPic
  where Id = @Id
  select * from GoodsReceive
  where Id = @Id
  End
  

GO
