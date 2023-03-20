/****** Object:  StoredProcedure [dbo].[ShipmentAttachment]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ShipmentAttachment]
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

/****** Object:  StoredProcedure [dbo].[ShipmentReceiptPdf]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ShipmentReceiptPdf]
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

/****** Object:  StoredProcedure [dbo].[sp_AddArmada]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_AddArmada]      
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

CREATE PROCEDURE [dbo].[sp_AddArmadaForRFC]                    
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


CREATE PROCEDURE [dbo].[sp_AddArmadaHistory]          
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

CREATE procedure [dbo].[sp_AddArmadaRefrence](  
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
CREATE procedure [dbo].[sp_addShippingFleetItem]      
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

/****** Object:  StoredProcedure [dbo].[SP_ApproveChangeHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SP_ApproveChangeHistory]
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
CREATE PROCEDURE [dbo].[SP_ArmadaDocumentUpdateFile]
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

CREATE  PROCEDURE [dbo].[SP_ArmadaDocumentUpdateFileForRFC]      
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


Create	PROCEDURE [dbo].[SP_CargoDocumentAdd]
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


Create PROCEDURE [dbo].[SP_CargoDocumentDelete] (
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

/****** Object:  StoredProcedure [dbo].[SP_CargoDocumentUpdateFile]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[SP_CargoDocumentUpdateFile]
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

/****** Object:  StoredProcedure [dbo].[Sp_ChangeHistory_Insert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Sp_ChangeHistory_Insert]          
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


CREATE PROC [dbo].[SP_ChangeHistory_RequestForChange_Insert]
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
CREATE PROC [dbo].[SP_ChangeHistory_RFCItem_Insert]
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
CREATE procedure [dbo].[Sp_checkarmadadata] --'40946'
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
CREATE PROCEDURE [dbo].[SP_CiplChangeHistoryGetByFormType] -- exec [dbo].[SP_CiplChangeHistoryGetById] '33433','CIPL',0,'CreateDate','asc','0','10'              
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
CREATE PROCEDURE [dbo].[SP_CiplChangeHistoryGetById] -- exec [dbo].[SP_CiplChangeHistoryGetById] '33433','CIPL',0,'CreateDate','asc','0','10'            
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

/****** Object:  StoredProcedure [dbo].[SP_CiplGetById_For_RFC]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CiplGetById_For_RFC]  
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

/****** Object:  StoredProcedure [dbo].[sp_CiplItemChange]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_CiplItemChange]  
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

create procedure [dbo].[sp_CiplItemChangeList]
(
@Id nvarchar(50)
)
as 
begin
select * from CiplItem_Change
where IdCipl = @Id
END

GO

/****** Object:  StoredProcedure [dbo].[sp_CiplItemInArmada]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CiplItemInArmada]    
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
  
CREATE PROCEDURE [dbo].[SP_CiplItemInsert_RFC]  
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

/****** Object:  StoredProcedure [dbo].[SP_CiplUpdate_ByApprover]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[SP_CiplUpdate_ByApprover]  
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

/****** Object:  StoredProcedure [dbo].[SP_Dashboard_ExchangeRate_Today]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [dbo].[SP_Dashboard_ExchangeRate_Today] '2022-01-01', '2015-08-08'

CREATE PROCEDURE [dbo].[SP_Dashboard_ExchangeRate_Today] (
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

CREATE procedure [dbo].[Sp_DashBoard_ExchangeRate] -- exec Sp_DashBoard_ExchangeRate '2020-03-17','2020-03-23'  
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

/****** Object:  StoredProcedure [dbo].[sp_delete_cargo_item_Change]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_delete_cargo_item_Change]
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

  create procedure [dbo].[SP_deleteAllArmada](@id nvarchar(100))
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
 CREATE procedure [dbo].[SP_deleteArmada](  
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


CREATE procedure [dbo].[SP_deleteArmadaChange](    
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

CREATE procedure [dbo].[SP_deleteShippingFleet]
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

/****** Object:  StoredProcedure [dbo].[sp_get_all_reference_item]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[sp_get_all_reference_item]
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

/****** Object:  StoredProcedure [dbo].[sp_get_armada_document]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_get_armada_document]
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
      
Create PROCEDURE [dbo].[sp_get_blawb_list_idcl_history]      -- exec [sp_get_blawb_list_idcl_history] 11374   
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
  
CREATE PROCEDURE [dbo].[sp_get_blawb_list_idcl]   
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

CREATE PROCEDURE [dbo].[sp_get_blawb_list] --exec [dbo].[sp_get_blawb_list] 'eko.suhartarto','' ,0         
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

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_document_list_byid]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_cargo_document_list_byid]   
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

  
CREATE PROCEDURE [dbo].[sp_get_cargo_document_list]   
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

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_data_by_cargoId]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_cargo_item_data_by_cargoId]   
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

/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_History_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_cargo_item_History_list] -- [dbo].[sp_get_cargo_item_History_list] 41784       
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

/****** Object:  StoredProcedure [dbo].[sp_get_gr_document_list_byid]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_gr_document_list_byid]   
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
CREATE PROCEDURE [dbo].[sp_get_gr_document_list]   
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

/****** Object:  StoredProcedure [dbo].[sp_get_npepeb_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[sp_get_npepeb_list] --exec [sp_get_npepeb_list] 'xupj21wdn',''            
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

/****** Object:  StoredProcedure [dbo].[sp_get_shippingfleet_gr]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_get_shippingfleet_gr]  
  (  
  @Id BIGINT
  )  
  as  
  begin  
  select * from ShippingFleet  
  where IdGr = @Id  
  End  
    
GO

/****** Object:  StoredProcedure [dbo].[sp_get_shippingfleet_gr_reference]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_get_shippingfleet_gr_reference]    
  (    
  @Id BIGINT  
  )    
  as    
  begin    
  select * from ShippingFleetRefrence  
  where IdGr = @Id    
  End    
GO

/****** Object:  StoredProcedure [dbo].[sp_get_shippinginstruction_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[sp_get_shippinginstruction_list]   --exec [dbo].[sp_get_shippinginstruction_list] 'xupj21wdn',''        
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
CREATE PROCEDURE [dbo].[sp_get_shippingsummary_list] 
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

/****** Object:  StoredProcedure [dbo].[Sp_GetArmdaList]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Sp_GetArmdaList]
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
CREATE PROCEDURE [dbo].[SP_GetAvailableShippingCiplItem] -- exec [dbo].[SP_GetAvailableShippingCiplItem] '13383','101423','50669'   
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

/****** Object:  StoredProcedure [dbo].[SP_GetCiplId]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_GetCiplId]
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
CREATE procedure [dbo].[SP_GetCiplItem]  
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

create procedure [dbo].[SP_GetCiplItemCount]  
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


create procedure [dbo].[SP_GetCiplItemInShippingFleetItem]
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

create procedure [dbo].[sp_getcontainertype]
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
CREATE PROCEDURE [dbo].[SP_GetDhlRateItemList]
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
CREATE PROCEDURE [dbo].[SP_GetDhlShipmentItemList]
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
CREATE PROCEDURE [dbo].[SP_GetDhlShipmentPackagesList]
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
CREATE PROCEDURE [dbo].[SP_GetDhlShipmentTrackingEvent]
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

/****** Object:  StoredProcedure [dbo].[SP_GetSiExportShipmentType]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_GetSiExportShipmentType]  
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

/****** Object:  StoredProcedure [dbo].[SP_GRDocumentAdd]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[SP_GRDocumentAdd]
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

/****** Object:  StoredProcedure [dbo].[SP_GrDocumentUpdateFile]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[SP_GrDocumentUpdateFile]
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

/****** Object:  StoredProcedure [dbo].[sp_insert_bast_number]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_insert_bast_number]
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

/****** Object:  StoredProcedure [dbo].[SP_Insert_BlAwbHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

          
CREATE  PROCEDURE [dbo].[SP_Insert_BlAwbHistory]                  
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
           
CREATE PROCEDURE [dbo].[SP_Insert_BlAwbRFCChange]          
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

/****** Object:  StoredProcedure [dbo].[sp_insert_document_blAWb]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_cipl_history;      
CREATE PROCEDURE [dbo].[sp_insert_document_blAWb]      
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

/****** Object:  StoredProcedure [dbo].[sp_insert_update_cargo_item_Change]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE ProCEDURE [dbo].[sp_insert_update_cargo_item_Change]             
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

/****** Object:  StoredProcedure [dbo].[sp_insert_update_gr_armada_new]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP PROCEDURE sp_insert_update_gr
CREATE PROCEDURE [dbo].[sp_insert_update_gr_armada_new] --exec sp_insert_update_gr 0, 'Tri Artha', '3211022907890004', '234002000', '32001000', 'Z5226BW', '20 Jan 2020', 'testing notes dan lain lain', 'xupj21fig', '20 Jan 2019', 'xupj21fig', '29 Jan 2019', 0 
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

/****** Object:  StoredProcedure [dbo].[sp_insert_update_gr_new]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_insert_update_gr_new] --exec sp_insert_update_gr 0, 'Tri Artha', '3211022907890004', '234002000', '32001000', 'Z5226BW', '20 Jan 2020', 'testing notes dan lain lain', 'xupj21fig', '20 Jan 2019', 'xupj21fig', '29 Jan 2019', 0 
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

/****** Object:  StoredProcedure [dbo].[SP_MasterVendorAdd]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_MasterVendorAdd]  
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
Create procedure [dbo].[SP_MasterVendorDelete]  
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
CREATE PROCEDURE [dbo].[SP_NpePeb_Update]    
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

/****** Object:  StoredProcedure [dbo].[SP_PackagesItemUpdate]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PackagesItemUpdate]
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

/****** Object:  StoredProcedure [dbo].[sp_Process_Email_RFC]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_Process_Email_RFC]  --exec      [sp_Process_Email_RFC]  '281','Approval'
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

/****** Object:  StoredProcedure [dbo].[Sp_RequestForChange_Insert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Sp_RequestForChange_Insert]      
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

CREATE PROCEDURE [dbo].[sp_RequestForChangeHistory] --[dbo].[sp_RequestForChangeHistory] 0,'CreateDate','DESC' ,'1','10','xupj21dxd'                      
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

/****** Object:  StoredProcedure [dbo].[Sp_RFCItem_Insert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Sp_RFCItem_Insert]  
  
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

/****** Object:  StoredProcedure [dbo].[Sp_RPebReport]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Sp_RPebReport '2022-11-20','2022-11-21','','',''              
--Sp_RPebReport '','','','',''              
CREATE PROCEDURE [dbo].[Sp_RPebReport]                                 
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

/****** Object:  StoredProcedure [dbo].[sp_searchContainerNumber]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_searchContainerNumber]
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

/****** Object:  StoredProcedure [dbo].[sp_SubConCompanyAdd]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_SubConCompanyAdd]  
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
CREATE procedure [dbo].[sp_SubConCompanyDelete]
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
    
CREATE PROCEDURE [dbo].[SP_Update_BlAwb]    
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
  
CREATE PROCEDURE [dbo].[sp_update_cargo_ByApprover]    
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
CREATE PROCEDURE [dbo].[sp_update_cargo]    
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

/****** Object:  StoredProcedure [dbo].[sp_update_request_cl_for_si]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_update_request_cl_for_si] --41727, 'XUPJ21WDN', 'Submit', '', 'NonPJT' 
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

/****** Object:  StoredProcedure [dbo].[sp_update_RFCGR]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[sp_update_RFCGR]  --sp_update_RFCGR '','','',''      
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


CREATE proc [dbo].[sp_update_RFCSI]  -- sp_update_RFCSI '977','','',''    
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

/****** Object:  StoredProcedure [dbo].[SP_UpdateFileForHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[SP_UpdateFileForHistory]
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
CREATE procedure [dbo].[SP_UpdateFileForHistoryBlAwb]    
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

create procedure [dbo].[SP_UpdateGr](
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
