USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_deleteArmadaChange]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[SP_deleteArmadaChange](    
  @id nvarchar(100))          
  as          
  begin          
  delete From ShippingFleet_Change          
  where Id = @id             
  end 


GO
