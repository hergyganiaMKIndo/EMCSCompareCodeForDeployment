USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_reference_item_20210203]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [sp_get_reference_item] 'ReferenceNo', '0002240001,0002240004,0002240006', 'PP', 0
CREATE PROCEDURE [dbo].[sp_get_reference_item_20210203]
	(
	@Column NVARCHAR(100) = ''
	,@ColumnValue NVARCHAR(100) = ''
	,@Category NVARCHAR(100) = ''
	,@isTotal BIT = 0
	,@sort NVARCHAR(100) = 'Id'
	,@order NVARCHAR(100) = 'ASC'
	,@offset NVARCHAR(100) = '0'
	,@limit NVARCHAR(100) = '500'
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(max);

	SET @sort = @sort;
	SET @sql = 'SELECT ';

	IF (@isTotal <> 0)
	BEGIN
		SET @sql += 'count(*) total '
	END
	ELSE
	BEGIN
		SET @sql += 'AvailableQuantity 
		,CaseNumber 
		,CCR Ccr 
		,Claim 
		,CoO 
		,Currency 
		,ISNULL(ExtendedValue,0) ExtendedValue 
		,ISNULL(GrossWeight,0) GrossWeight 
		,ISNULL(Height,0) Height 
		,Id 
		,ISNULL(IdCustomer,''-'') IdCustomer 
		,CAST(0 AS bigint) IdItem 
		,IDNo 
		,JCode 
		,Length 
		,ISNULL(NetWeight,0) NetWeight 
		,PartNumber 
		,ISNULL(POCustomer,''-'') POCustomer 
		,Quantity ,ISNULL(QuotationNo,''-'') QuotationNo 
		,ISNULL(ReferenceNo,''-'') ReferenceNo 
		,SIBNumber 
		,UnitModel 
		,UnitName 
		,ISNULL(UnitPrice,0) UnitPrice 
		,UnitSN 
		,UnitUom 
		,ISNULL(Volume,0) Volume 
		,ISNULL(Width,0) Width 
		,WONumber 
		,YearMade';
	END

	SET @sql += ' FROM Reference'

	IF (@Column <> '')
	BEGIN
		--SET @SQL = @SQL + ' WHERE '+@Column+' = '''+@ColumnValue+''' AND Category = '''+@Category+'''  AND AvailableQuantity > 0';
		SET @SQL = @SQL + ' WHERE ' + @Column + ' IN (SELECT F.splitdata FROM [dbo].[fnSplitString](''' + @ColumnValue + ''', '','') F)  AND Category = ''' + @Category + '''  AND AvailableQuantity > 0';
	END
	ELSE
	BEGIN
		SET @SQL = @SQL + ' WHERE Category = ''' + @Category + ''' AND AvailableQuantity > 0 ';
	END

	--IF @isTotal = 0  
	--BEGIN 
	--  SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	--END  
	SET @sql += 'UNION ALL';

	BEGIN
		SET @sql += ' SELECT 0 AvailableQuantity 
		,CI.CaseNumber 
		,CI.Ccr 
		,CI.Claim
		,CI.CoO 
		,CI.Currency 
		,CI.ExtendedValue 
		,CI.GrossWeight 
		,CI.Height 
		,CI.Id 
		,CI.IdCustomer 
		,0 IdItem 
		,CI.IdNo IDNo 
		,CI.JCode 
		,CI.Length 
		,CI.NetWeight 
		,CI.PartNumber 
		,'''' POCustomer 
		,CI.Quantity 
		,'''' QuotationNo 
		,CI.ReferenceNo 
		,CI.SIBNumber 
		,'''' UnitModel 
		,CI.Name 
		,CI.UnitPrice 
		,CI.Sn UnitSN 
		,CI.Uom UnitUom 
		,CI.Volume 
		,CI.Width 
		,CI.WONumber 
		,CI.YearMade';
	END

	SET @sql += ' FROM CiplItem CI WHERE CI.ReferenceNo IN (SELECT F.splitdata FROM [dbo].[fnSplitString](''' + @ColumnValue + ''', '','') F) AND CI.IsDelete = 0 ';

	EXECUTE (@sql);
END
GO
