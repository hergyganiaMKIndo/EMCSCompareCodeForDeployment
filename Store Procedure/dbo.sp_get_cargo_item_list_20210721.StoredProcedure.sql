USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_list_20210721]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_cargo_item_list_20210721] -- [dbo].[sp_get_cargo_item_list] '', 1
(
	@Search nvarchar(100),
	@IdCargo nvarchar(100),
	@isTotal bit = 0,
	@sort nvarchar(100) = 'Id',
	@order nvarchar(100) = 'ASC',
	@offset nvarchar(100) = '0',
	@limit nvarchar(100) = '10'
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @sql nvarchar(max);  
	SET @sort = 't0.'+@sort;

	SET @sql = 'SELECT ';
	IF (@isTotal <> 0)
		BEGIN
			SET @sql += 'count(*) total '
		END 
	ELSE
		BEGIN
			SET @sql += 'ROW_NUMBER() OVER ( ORDER BY t0.Id ) RowNo
						,t0.Id ID                 
						,t0.IdCipl                 
						,t3.CiplNo                 
						,t2.Incoterms IncoTerm                 
						,t2.Incoterms IncoTermNumber                 
						,t1.CaseNumber                 
						,t3.EdoNo                 
						,t4.DaNo InboundDa                 
						,t0.Length                 
						,t0.Width                 
						,t0.Height                
						,t0.Net NetWeight                 
						,t1.Sn        
						,t1.PartNumber        
						,t1.Ccr        
						,t1.Quantity        
						,t1.Name ItemName        
						,t1.JCode        
						,t1.ReferenceNo              
						,t0.Gross GrossWeight                 
						,CAST(1 as bit) state        
						,t2.Category CargoDescription        
						,t0.ContainerNumber
						,t5.Description ContainerType
						,t0.ContainerSealNumber'
		END
			SET @sql +='
					FROM dbo.CargoItem t0
					JOIN dbo.CiplItem t1 on t1.Id = t0.IdCiplItem AND t1.isdelete = 0
					JOIN dbo.Cargo t2 on t2.Id = t0.IdCargo AND t2.isdelete = 0
					JOIN dbo.Cipl t3 on t3.id = t1.IdCipl AND t3.isdelete = 0
					LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo AND t4.isdelete = 0
					LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''
					WHERE 1=1 AND t0.isdelete = 0 AND t0.IdCargo='+@IdCargo+' ';
	--IF @isTotal = 0 
	--BEGIN
	--	SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';
	--END 
	--select @sql;
	EXEC(@sql);
END



GO
