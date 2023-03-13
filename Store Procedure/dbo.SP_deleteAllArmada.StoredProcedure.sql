USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_deleteAllArmada]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  create procedure [dbo].[SP_deleteAllArmada](@id nvarchar(100))
  as
  begin
  delete From ShippingFleet
  where IdGr = @id
  delete From ShippingFleetItem
  where IdGr = @id
  end
  
GO
