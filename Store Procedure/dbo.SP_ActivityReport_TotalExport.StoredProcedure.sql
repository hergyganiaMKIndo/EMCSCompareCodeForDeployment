USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActivityReport_TotalExport]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ActivityReport_TotalExport]
       @year int
AS
BEGIN
       declare @invoice TABLE (month int, count int, peb int)
       insert into @invoice
       select 
              Month(CreatedDate), 
              count(distinct IdCipl), 
              count(distinct AjuNumber) 
              from(
              select 
                     ci.IdCargo, 
                     ci.Id as IdCargoItem, 
                     cpi.Id as IdCiplItem, 
                     cp.id as IdCipl, 
                     peb.AjuNumber, 
                     CONVERT(VARCHAR(10), 
                     rc.CreateDate, 120) as CreatedDate
              from fn_get_cl_request_list_all() rc
              left join NpePeb peb on rc.IdCl = peb.IdCl
              left join CargoItem ci on rc.IdCl = ci.IdCargo
              left join CiplItem cpi on ci.IdCiplItem = cpi.Id
              left join Cipl cp on cpi.IdCipl = cp.id
              left join MasterParameter p on cp.ExportType = p.Name
              where (YEAR(rc.CreateDate) = @year) and
                     ((rc.IdStep = 10020 and rc.Status = 'Approve') or rc.IdStep = 10021 or (rc.IdStep = 10022 and (rc.Status = 'Submit' or rc.Status = 'Approve')))
       )data group by Month(CreatedDate)

       declare @outstanding TABLE (month int, count int)
       insert into @outstanding
       select Month(CreatedDate), count(distinct IdCipl) from(
              select 
                     ci.IdCargo, 
                     ci.Id as IdCargoItem, 
                     cpi.Id as IdCiplItem, 
                     cp.id as IdCipl, 
                     CONVERT(VARCHAR(10), 
                     rc.CreateDate, 120) as CreatedDate
                     --, fs.Step
              from fn_get_cl_request_list_all() rc
              --RequestCl rc 
              --inner join FlowStep fs on rc.IdStep = fs.Id
              left join CargoItem ci on rc.IdCl = ci.IdCargo
              left join CiplItem cpi on ci.IdCiplItem = cpi.Id
              left join Cipl cp on cpi.IdCipl = cp.id
              where (YEAR(rc.CreateDate) = @year or @year = 0) and 
                     ((IdStep = 10020 and (Status not in ('Approve', 'Reject'))) or (IdStep not in (10020, 10021, 10022) and Status <> 'Reject'))
              --fs.Step <> 'Approve NPE & PEB'
       )data group by Month(CreatedDate)

       declare @monthly_tbl table(MonthNumber int, MonthName nvarchar(10))
       declare @month int = 1
       WHILE @month <= 12
       BEGIN
          insert into @monthly_tbl 
          select @month, LEFT(DATENAME(MONTH , DATEADD(MONTH, @month , -1)), 3)
          SET @month = @month + 1;
       END;

       select 
              m.MonthName as Month, 
              ISNULL(i.count, 0) as Invoice, 
              ISNULL(i.peb, 0) as PEB, 
              ISNULL(o.count, 0) as Outstanding 
       from @monthly_tbl m
       left join @invoice i on m.MonthNumber = i.month
       left join @outstanding o on m.MonthNumber = o.month

END
GO
