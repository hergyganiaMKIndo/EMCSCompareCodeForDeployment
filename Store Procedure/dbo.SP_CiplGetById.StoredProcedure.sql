USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_CiplGetById]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[SP_CiplGetById]    -- [dbo].[SP_CiplGetById]   63600
(    
  @id BIGINT    
)    
AS    
BEGIN    
  SELECT distinct C.id    
        , C.CiplNo    
        , C.ClNo    
        , C.EdoNo    
        , C.Category    
        , C.CategoriItem    
        , C.ExportType    
        , C.ExportTypeItem    
  --, (SELECT C.CategoryReference+'-'+MP.Name FROM MasterParameter MP inner join Cipl C ON C.CategoryReference = MP.Value WHERE C.id=@id) AS CategoryReference    
        , C.CategoryReference    
  , C.SoldConsignee    
        , C.SoldToName    
        , C.SoldToAddress    
        , C.SoldToCountry    
        , C.SoldToTelephone    
        , C.SoldToFax    
        , C.SoldToPic    
        , C.SoldToEmail    
        , C.ShipDelivery    
        , C.ConsigneeName    
        , C.ConsigneeAddress    
        , C.ConsigneeCountry    
        , C.ConsigneeTelephone    
        , C.ConsigneeFax    
        , C.ConsigneePic    
        , C.ConsigneeEmail    
        , C.NotifyName    
        , C.NotifyAddress    
        , C.NotifyCountry    
        , C.NotifyTelephone    
        , C.NotifyFax    
        , C.NotifyPic    
        , C.NotifyEmail    
        , C.ConsigneeSameSoldTo    
        , C.NotifyPartySameConsignee    
        , (SELECT C.Area+' - '+MP.PlantName FROM MasterPlant MP inner join Cipl C ON left(C.Area,4) = left(MP.PlantCode,4) WHERE C.id=@id) AS Area    
        , (SELECT C.Branch+' - '+MA.BAreaName FROM MasterArea MA inner join Cipl C ON left(C.Branch,4) = left(MA.BAreaCode,4) WHERE C.id=@id) AS Branch    
  , C.Currency    
  , C.Rate    
        , C.PaymentTerms    
        , C.ShippingMethod    
        , C.CountryOfOrigin    
        , C.Da    
        , C.LcNoDate    
        , C.IncoTerm    
        , C.FreightPayment    
        , C.ShippingMarks    
        , C.Remarks    
        , C.SpecialInstruction    
        , C.LoadingPort    
        , C.DestinationPort    
  , (SELECT DISTINCT Fn.BAreaCode+' - '+Fn.BAreaName FROM [dbo].fn_get_cipl_businessarea_list('') Fn    
 INNER JOIN Cipl C ON IIF(C.PickUpArea = '', NULL, left(C.PickUpArea,4)) = left(Fn.BAreaCode ,4) WHERE C.id=@id) AS PickUpArea    
  --, (SELECT DISTINCT Fn.Business_Area+' - '+Fn.BAreaName FROM [dbo].[fn_get_employee_internal_ckb]() Fn INNER JOIN Cipl C ON IIF(C.PickUpArea = '', NULL, C.PickUpArea) = Fn.Business_Area WHERE C.id=@id) AS PickUpArea    
  --, (SELECT Fn.BAreaCode+' - '+Fn.BAreaName FROM [dbo].[fn_get_plant_barea_user]() Fn INNER JOIN Cipl C ON RIGHT(C.PickUpPic,3) = RIGHT(Fn.UserID, 3) WHERE C.id=@id) AS PickUpArea    
  --, (SELECT Fn.AD_User+'-'+Fn.Employee_Name+ '-'+Fn.BAreaName FROM [dbo].[fn_get_employee_internal_ckb]() Fn INNER JOIN Cipl C ON C.PickUpPic = Fn.AD_User WHERE C.id=@id) AS PickUpPic    
  , (SELECT Fn.AD_User+'-'+Fn.Employee_Name+ '-'+Fn.BAreaName FROM [dbo].[fn_get_employee_internal_ckb]() Fn INNER JOIN Cipl C ON  (select top 1 * from dbo.fnSplitString(C.PickUpPic,'-')) = Fn.AD_User WHERE C.id=@id) AS PickUpPic    
  , C.ETD    
        , C.ETA    
        , C.CreateBy    
        , C.CreateDate    
        , C.UpdateBy    
        , C.UpdateDate    
        , C.IsDelete    
  , C.ReferenceNo    
  , ISNULL(C.Consolidate, 0) Consolidate    
  FROM dbo.Cipl C    
  WHERE C.id = @id    
END 

GO
