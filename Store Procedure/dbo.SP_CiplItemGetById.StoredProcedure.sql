USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_CiplItemGetById]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CiplItemGetById]   
(  
  @id BIGINT  
)  
AS  
BEGIN  
  SELECT distinct CI.Id  
    , CI.IdCipl  
    , CI.IdReference  
    , (SELECT CASE  
        WHEN CI.ReferenceNo = '-' THEN CI.CaseNumber   
        ELSE CI.ReferenceNo  
        END) AS ReferenceNo  
    , CI.IdCustomer  
    , CI.Name  
    ,(SELECT [Name] FROM MasterParameter WHERE [Group] = 'UOMType' AND [Value]= CI.Uom) AS UnitUom  
    , CI.PartNumber  
    , CI.Sn  
    , CI.JCode  
    , CI.Ccr  
    , CI.CaseNumber  
    , CI.Type  
    , CI.IdNo  
    , CI.YearMade  
    , CI.Quantity  
    , CI.UnitPrice  
    , CI.ExtendedValue  
    , CI.Length  
    , CI.Width  
    , CI.Height  
    , CI.Volume  
    , CI.GrossWeight  
    , CI.NetWeight  
    , CI.Currency  
 , CI.CoO  
 , CI.IdParent  
 , CI.WONumber  
 , CI.SIBNumber  
    , CI.CreateBy  
    , CI.CreateDate  
    , CI.UpdateBy  
    , CI.UpdateDate  
    , CI.IsDelete  
 , CI.Claim  
 , CI.ASNNumber  
  FROM dbo.CiplItem CI  
  WHERE CI.IdCipl = @id  
  AND CI.IsDelete = 0  
  ORDER BY IdReference, Id  
END  
  
  
  
GO
