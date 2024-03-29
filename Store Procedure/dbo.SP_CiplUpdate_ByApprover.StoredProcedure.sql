USE [EMCS_Dev]
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
