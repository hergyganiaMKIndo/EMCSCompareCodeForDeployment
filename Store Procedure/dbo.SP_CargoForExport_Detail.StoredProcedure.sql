USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_CargoForExport_Detail]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CargoForExport_Detail]  -- exec [SP_CargoForExport_Detail] 41784
 @CargoID bigint  
AS  
BEGIN  
  
 SELECT   
 CAST(ROW_NUMBER() over (order by a.CaseNumber) as varchar(5)) as ItemNo   
 , a.ContainerNumber  
 , a.SealNumber  
 , a.ContainerType  
 , CAST(ISNULL(COUNT(a.TotalCaseNumber), 0) as varchar(5)) AS TotalCaseNumber  
 , a.CaseNumber  
 , a.Do  
 , a.InBoundDa  
 , a.[Description]  
 , CAST(FORMAT(ISNULL(SUM(a.NetWeight), 0), '#,0.00') as varchar(20))  AS NetWeight  
 , CAST(FORMAT(ISNULL(SUM(GrossWeight), 0), '#,0.00') as varchar(20))  AS GrossWeight  
 FROM  
 ( select   
   ISNULL(ci.ContainerNumber, '-') as ContainerNumber  
   , ISNULL(ci.ContainerSealNumber, '-') as SealNumber  
   , ISNULL(ct.Name, '-') as ContainerType  
   , CAST(ISNULL(container.CaseNumber, 0) as varchar(5)) as TotalCaseNumber  
   , cpi.CaseNumber  
   , ISNULL(cp.EdoNo, '-') as Do  
   , ISNULL(ci.InBoundDa, '-') as InBoundDa  
   , ISNULL(cp.Category, '-') as Description  
   , ISNULL(ci.NewNet, ci.Net) as NetWeight  
  , ISNULL(ci.NewGross, ci.Gross) as GrossWeight  
  from Cargo c   
  --left join CargoContainer cc on c.Id = cc.CargoId  
  left join CargoItem ci on c.Id = ci.IdCargo  
  left join CiplItem cpi on ci.IdCiplItem = cpi.Id  
  left join Cipl cp on cpi.IdCipl = cp.id  
  left join (  
   select c.Id as CargoID, cpi.IdCipl, count(ISNULL(cpi.CaseNumber, 0)) as CaseNumber  
   from Cargo c   
   left join CargoItem ci on c.Id = ci.IdCargo  
   left join CiplItem cpi on ci.IdCiplItem = cpi.Id  
   where ci.isDelete = 0 and cpi.IsDelete = 0  
   group by c.Id, cpi.IdCipl  
  ) container on c.Id = container.CargoID and cp.id = container.IdCipl  
  left join (select Value, Name from MasterParameter where [Group] = 'ContainerType') ct on ci.ContainerType = ct.Value  
  outer apply(  
   select top 1 * from CargoHistory where IdCargo = c.id order by id desc  
  ) ch  
  where c.Id = @CargoID and ci.isDelete = 0 and cpi.IsDelete = 0  
 ) a  
 GROUP BY a.casenumber, a.ContainerNumber, a.SealNumber, a.ContainerType, a.Do, a.InBoundDa, a.[Description]  
 order by a.CaseNumber  
END  

GO
