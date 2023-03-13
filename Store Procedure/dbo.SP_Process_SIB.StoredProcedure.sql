USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_Process_SIB]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author  : Ali Mutasal    
-- Create date : 23 April 2019    
-- Description : SP UPDATE INSERT     
-- =============================================    
CREATE PROCEDURE [dbo].[SP_Process_SIB]    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
    -- Insert statements for procedure here    
 BEGIN TRAN;    
 MERGE Reference AS T    
 USING (SELECT DISTINCT ReqNumber, DlrWO, DlrClm, SvcClm, PartNo, SerialNumber, [Description], DlrCode, UnitPrice, Currency, Qty FROM MasterSIB) AS S    
 ON (S.DlrCode = T.ReferenceNo and S.ReqNumber = T.SIBNumber and S.DlrWO = T.WONumber and S.PartNo = T.PartNumber 
 and S.SerialNumber = T.UnitSN and S.[Description] = T.UnitName and S.DlrCode = T.JCode and S.UnitPrice = T.UnitPrice 
 and S.SvcClm = T.Claim AND S.Currency = T.Currency and S.Qty = T.Quantity)    
 WHEN NOT MATCHED BY TARGET    
    THEN     
  INSERT(    
   ReferenceNo    
   ,PartNumber    
   ,UnitSN    
   ,UnitName    
   ,UnitPrice    
   ,JCode    
   ,SIBNumber    
   ,WONumber    
   ,Quantity    
   ,AvailableQuantity    
   ,Category    
   ,CreateBy    
   ,CreateDate    
   ,Claim    
   ,Currency)     
  VALUES(    
   S.DlrCode    
   ,S.PartNo    
   ,S.SerialNumber    
   ,S.[Description]    
   ,S.UnitPrice    
   ,S.DlrCode    
   ,S.ReqNumber    
   ,S.DlrWO    
   , S.Qty    
   , S.Qty    
   ,'SIB'    
   ,'system'    
   ,GETDATE()    
   ,S.SvcClm    
   ,S.Currency)      
 WHEN MATCHED     
  THEN UPDATE SET     
  T.ReferenceNo = S.DlrCode    
  ,T.PartNumber = S.PartNo    
  ,T.UnitSN = S.SerialNumber    
  ,T.UnitName = S.Description    
  ,T.UnitPrice = S.UnitPrice    
  ,T.JCode = S.DlrCode    
  ,T.SIBNumber = S.ReqNumber    
  ,T.WONumber = S.DlrWO    
  ,T.Quantity = S.Qty    
  ,T.AvailableQuantity = S.Qty    
  ,T.UpdateBy = 'system'    
  ,T.UpdateDate = GETDATE()    
  ,T.Claim = S.SvcClm    
  ,T.Currency = S.Currency    
  OUTPUT $action, Inserted.*, Deleted.*;    
    
 COMMIT TRAN;    
-- ROLLBACK TRAN;    
END    
GO
