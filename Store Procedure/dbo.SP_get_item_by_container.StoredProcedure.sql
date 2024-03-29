USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_get_item_by_container]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_get_item_by_container] -- [SP_get_item_by_container]
(
	@IdContainer nvarchar(100) = ''
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL nvarchar(max);
	DECLARE @WHERE nvarchar(max) = '';
	IF ISNULL(@IdContainer, '') <> '' 
	BEGIN
		SET @WHERE = ' AND t0.IdContainer='+@IdContainer+''; 
	END

	SET @SQL = 'SELECT 
					t0.Id
					, t0.IdCipl
					, t1.ReferenceNo
					, t1.IdCustomer
					, t1.[Name]
					, t1.Uom
					, t1.PartNumber
					, t1.PartNumber IdShippingFleet
					, t1.Sn
					, t1.JCode
					, t1.Ccr
					, t1.CaseNumber
					, t1.[Type]
					, t1.IdNo
					, t1.YearMade
					, t1.UnitPrice
					, t1.ExtendedValue
					, t0.Length 
					, t0.Width	
					, t0.Height 
					, t0.Gross GrossWeight	
					, t0.Net NetWeight		
					, t1.Currency		
					, t0.CreateBy		
					, t0.CreateDate		
					, t0.UpdateBy		
					, t0.UpdateDate 
					, t0.IsDelete	
					, t2.CustName
					, t2.CustNr
				FROM dbo.CargoItem t0
				LEFT JOIN dbo.CiplItem t1 on t1.Id=t0.IdCipl
				LEFT JOIN (select DISTINCT CustNr, CustName FROM dbo.MasterCustomer) t2 on t2.CustNr = t1.IdCustomer
				WHERE 1=1 '+@WHERE;

	--SELECT @SQL;
	EXECUTE(@SQL);
END
GO
