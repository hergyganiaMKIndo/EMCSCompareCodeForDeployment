USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_cargo_item_list]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[sp_get_cargo_item_list] -- [dbo].[sp_get_cargo_item_list] '', 1    
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
	SET @sql = 'WITH CTE AS ( SELECT '
	SET @sql += 'DISTINCT
		  t0.Id ID
		  ,t0.IdCipl                     
		  ,t3.CiplNo                     
		  ,t2.Incoterms IncoTerm                     
		  ,t2.Incoterms IncoTermNumber                     
		  ,t1.CaseNumber                     
		  ,t3.EdoNo                     
		  --,t6.DaNo InboundDa 
		  ,(SELECT STUFF((SELECT '','' + DaNo FROM ShippingFleet WHERE IdCargo = t0.IdCargo AND DoNo = t4.DoNo FOR XML PATH('''')), 1, 1, '''')) as InboundDa                      
		  ,ISNULL(t0.NewLength, t0.Length) Length                    
		  ,ISNULL(t0.NewWidth,t0.Width) Width                     
		  ,ISNULL(t0.NewHeight,t0.Height) Height                    
		  ,ISNULL(t0.NewNet,t0.Net) NetWeight                
		  ,ISNULL(t0.NewGross,t0.Gross) GrossWeight                     
		  ,t0.NewLength                     
		  ,t0.NewWidth                     
		  ,t0.NewHeight                    
		  ,t0.NewNet NewNetWeight                  
		  ,t0.NewGross NewGrossWeight                   
		  ,t1.Sn            
		  ,t1.PartNumber            
		  ,t1.Ccr            
		  ,t1.Quantity            
		  ,t1.Name ItemName            
		  ,t1.JCode            
		  ,t1.ReferenceNo                    
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
    LEFT JOIN dbo.ShippingFleetRefrence t4 on t4.DoNo = t3.EdoNo  
 Left JOIN dbo.ShippingFleet t6 on t6.Id = t4.IdShippingFleet  
 -- LEFT JOIN dbo.GoodsReceiveItem t4 on t4.DoNo = t3.EdoNo AND t4.isdelete = 0    
     LEFT JOIN dbo.MasterParameter t5 on t5.Value = t0.ContainerType AND t5.[Group] = ''ContainerType''    
     WHERE 1=1 AND t0.isdelete = 0 AND t0.IdCargo='+@IdCargo+''; 
	SET @sql += ' ) SELECT	ROW_NUMBER() OVER ( ORDER BY CTE.ID ) RowNo, CTE.*
			FROM	CTE'   
 --IF @isTotal = 0     
 --BEGIN    
 -- SET @sql += ' ORDER BY '+@sort+' '+@order+' OFFSET '+@offset+' ROWS FETCH NEXT '+@limit+' ROWS ONLY';    
 --END     
 --select @sql;    
 EXEC(@sql);    
END    
    
    
    
GO
