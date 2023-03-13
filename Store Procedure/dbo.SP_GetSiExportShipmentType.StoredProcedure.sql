USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetSiExportShipmentType]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_GetSiExportShipmentType]  
(  
@IdCL bigint  
)  
AS  
BEGIN  
select top 1 cf.ExportShipmentType from CargoCipl cc   
join CiplForwader cf on cc.IdCipl = cf.IdCipl  
where IdCargo = @IdCL  
end 

GO
