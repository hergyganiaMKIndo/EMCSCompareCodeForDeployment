USE [EMCS_Dev]
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
