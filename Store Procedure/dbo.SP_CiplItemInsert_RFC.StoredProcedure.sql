USE [EMCS_Dev]
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
