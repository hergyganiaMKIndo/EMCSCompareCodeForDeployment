USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_insert_update_cargo_item]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_insert_update_cargo_item]           
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
