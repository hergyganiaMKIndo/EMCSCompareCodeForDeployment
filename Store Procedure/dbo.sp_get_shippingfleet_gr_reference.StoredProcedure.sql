USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_shippingfleet_gr_reference]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_get_shippingfleet_gr_reference]    
  (    
  @Id BIGINT  
  )    
  as    
  begin    
  select * from ShippingFleetRefrence  
  where IdGr = @Id    
  End    
GO
