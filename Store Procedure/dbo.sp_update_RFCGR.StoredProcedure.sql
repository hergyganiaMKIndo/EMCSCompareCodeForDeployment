USE [EMCS_Dev]
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
