USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_update_RFCSI]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[sp_update_RFCSI]  -- sp_update_RFCSI '977','','',''    
(      
@IdCl nvarchar(100),      
@SpecialInstruction nvarchar(100) = null,      
@DocumentRequired   nvarchar(100) = null     
)      
as      
begin      
if  @SpecialInstruction <> ''    
begin    
update ShippingInstruction      
set SpecialInstruction = @SpecialInstruction    
where IdCL = @IdCl      
end    
if  @DocumentRequired <> ''     
begin    
update ShippingInstruction      
set DocumentRequired = @DocumentRequired     
where IdCL = @IdCl      
end       
end

GO
