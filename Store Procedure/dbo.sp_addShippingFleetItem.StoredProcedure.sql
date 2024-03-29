USE [EMCS_Dev]
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
