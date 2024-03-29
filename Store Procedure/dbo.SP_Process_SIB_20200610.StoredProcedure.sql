USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_Process_SIB_20200610]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: Ali Mutasal
-- Create date	: 23 April 2019
-- Description	: SP UPDATE INSERT 
-- =============================================
CREATE PROCEDURE [dbo].[SP_Process_SIB_20200610]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRAN;
	MERGE Reference AS T
	USING (SELECT DISTINCT ReqNumber, DlrWO, DlrClm, SvcClm, PartNo, SerialNumber, [Description], DlrCode, UnitPrice FROM MasterSIB) AS S
	ON (S.DlrCode = T.ReferenceNo and S.ReqNumber = T.SIBNumber and S.DlrWO = T.WONumber and S.PartNo = T.PartNumber and S.SerialNumber = T.UnitSN and S.[Description] = T.UnitName and S.DlrCode = T.JCode and S.UnitPrice = T.UnitPrice and S.SvcClm = T.Claim)
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
			,Claim) 
		VALUES(
			S.DlrCode
			,S.PartNo
			,S.SerialNumber
			,S.[Description]
			,S.UnitPrice
			,S.DlrCode
			,S.ReqNumber
			,S.DlrWO
			, 1
			, 1
			,'SIB'
			,'system'
			,GETDATE()
			,S.SvcClm)  
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
		,T.Quantity = 1
		,T.AvailableQuantity = 1
		,T.UpdateBy = 'system'
		,T.UpdateDate = GETDATE()
		,T.Claim = S.SvcClm
		OUTPUT $action, Inserted.*, Deleted.*;

	COMMIT TRAN;
--	ROLLBACK TRAN;
END

GO
