USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_edi_gritem_edit]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCedure [dbo].[sp_get_edi_gritem_edit] -- exec [dbo].[sp_get_edi_gritem_edit]  '1F18', 1
(
	@area nvarchar(100),
	@idGr nvarchar(100)
)
AS
select * from dbo.Cipl t0
left join dbo.RequestCipl t1 on t1.IdCipl = t0.id AND t1.IsDelete = 0 
left join dbo.fn_get_cipl_request_list_all() t2 on t2.IdCipl = t0.id
where 
t2.IdNextStep IN (14, 10024, 10028) 
AND t0.Area = @area 
AND t1.[Status] = 'Approve' 
AND EdoNo IS NOT NULL AND (t0.Id NOT IN (
	select IdCipl from dbo.GoodsReceiveItem WHERE IsDelete = 0
) OR t0.Id IN (
	select IdCipl from dbo.GoodsReceiveItem WHERE IdGr = @idGr
))
GO
