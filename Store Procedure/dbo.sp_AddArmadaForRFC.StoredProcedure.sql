USE [EMCS_Dev]
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
