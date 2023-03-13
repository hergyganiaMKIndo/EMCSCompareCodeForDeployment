USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetCiplItemInShippingFleetItem]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[SP_GetCiplItemInShippingFleetItem]
(
@IdCipl nvarchar(100),
@IdGr nvarchar(100)
)
as 
begin 
select count(IdCiplItem) from ShippingFleetItem
where IdCipl = @IdCipl and IdGr = @IdGr
end


GO
