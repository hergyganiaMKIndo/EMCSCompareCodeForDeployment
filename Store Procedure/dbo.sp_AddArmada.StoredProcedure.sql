USE [EMCS_Dev]
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
