USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_edi_available]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[sp_get_edi_available] -- [dbo].[sp_get_edi_available] '1241', 'xupj21hbk'      
(      
       @area nvarchar(100),      
       @pic nvarchar(100) = '',
	   @IdGr bigint = 0
)      
AS  

select        
       t0.[id] Id   
      ,t0.[CiplNo]      
      ,t0.[ClNo]      
      ,t0.[EdoNo]      
      ,t0.[Category]      
      ,t0.[CategoriItem]      
      ,t0.[ExportType]      
      ,t0.[ExportTypeItem]      
      ,t0.[SoldToName]      
      ,t0.[SoldToAddress]      
      ,t0.[SoldToCountry]      
      ,t0.[SoldToTelephone]      
      ,t0.[SoldToFax]      
      ,t0.[SoldToPic]      
      ,t0.[SoldToEmail]      
      ,t0.[ConsigneeName]      
      ,t0.[ConsigneeAddress]      
      ,t0.[ConsigneeCountry]      
      ,t0.[ConsigneeTelephone]      
      ,t0.[ConsigneeFax]      
      ,t0.[ConsigneePic]      
      ,t0.[ConsigneeEmail]      
      ,t0.[NotifyName]      
      ,t0.[NotifyAddress]      
      ,t0.[NotifyCountry]      
      ,t0.[NotifyTelephone]      
      ,t0.[NotifyFax]      
      ,t0.[NotifyPic]      
      ,t0.[NotifyEmail]      
      ,t0.[ConsigneeSameSoldTo]      
      ,t0.[NotifyPartySameConsignee]      
      ,t0.[Area]      
      ,t0.[Branch]      
      ,t0.[PaymentTerms]      
      ,t0.[ShippingMethod]      
      ,t0.[CountryOfOrigin]      
      ,t0.[Da]      
      ,t0.[LcNoDate]      
      ,t0.[IncoTerm]      
      ,t0.[FreightPayment]      
      ,t0.[Forwader]      
      ,t0.[ShippingMarks]      
      ,t0.[Remarks]      
      ,t0.[SpecialInstruction]      
      ,t0.[LoadingPort]      
      ,t0.[DestinationPort]      
      ,t0.[ETD]      
      ,t0.[ETA]      
      ,t0.[CreateBy]      
      ,t0.[CreateDate]      
      ,t0.[UpdateBy]      
      ,t0.[UpdateDate]      
      ,t0.[IsDelete]      
      ,t0.[SoldConsignee]      
      ,t0.[ShipDelivery]      
      ,t0.[Rate]      
      ,t0.[Currency]      
      ,t0.[PickUpPic]      
      ,t0.[PickUpArea]      
      ,t0.[CategoryReference]      
      ,t0.[ReferenceNo]      
      ,t0.[Consolidate]      
from dbo.Cipl t0      
left join dbo.RequestCipl t1 on t1.IdCipl = t0.id AND t1.IsDelete = 0       
left join dbo.fn_get_cipl_request_list_all() t2 on t2.IdCipl = t0.id   

where       
t2.IdNextStep IN (14, 10024, 10028, 30057)       
AND RIGHT(t0.PickUpArea,3) = RIGHT(@area,3)      
--AND t0.PickUpPic = @pic      
--AND t2.BAreaUser = @area      
AND t1.[Status] = 'Approve'       
AND EdoNo IS NOT NULL    
AND t0.Id not  IN (      
    select gi.IdCipl       
 from dbo.ShippingFleetRefrence gi      
 join RequestGr rg ON gi.idgr = rg.idgr 
  and gi.Idgr <> @IdGr 
 where  rg.[status] != 'Reject'  
) 


GO
