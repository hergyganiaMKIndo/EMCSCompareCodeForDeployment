USE [EMCS_Dev]
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
