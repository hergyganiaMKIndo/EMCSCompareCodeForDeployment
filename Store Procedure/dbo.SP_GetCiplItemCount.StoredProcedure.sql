USE [EMCS_Dev]
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
