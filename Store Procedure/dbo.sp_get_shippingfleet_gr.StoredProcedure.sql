USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_shippingfleet_gr]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_get_shippingfleet_gr]  
  (  
  @Id BIGINT
  )  
  as  
  begin  
  select * from ShippingFleet  
  where IdGr = @Id  
  End  
    
GO
