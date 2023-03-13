USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_deleteShippingFleet]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[SP_deleteShippingFleet]
(
@id nvarchar(100),
@idCiplItem nvarchar(100)
)
as 
begin
delete From ShippingFleetItem
where IdCiplItem = @idCiplItem And IdShippingFleet = @id
end
GO
