USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_update_cipl_to_revise]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_update_cipl_to_revise] (
	@IdCargo nvarchar(100)
)
AS 
BEGIN
	SET NOCOUNT ON;
	UPDATE tab0
	SET 
		tab0.IdStep = tab1.NextStepId,
		tab0.[Status] = tab1.NextStatus
	FROM
	dbo.RequestCipl as tab0 
	INNER JOIN (select 
		t2.Id IdReq
		,CASE 
			WHEN t1.IdFlow = 1
			THEN 10032 
			WHEN t1.IdFlow = 2
			THEN 10033
			WHEN t1.IdFlow = 3
			THEN 10035
		END as NextStepId
		, 'Submit' NextStatus
		FROM dbo.CiplItemUpdateHistory as t0
		INNER JOIN dbo.fn_get_cipl_request_list_all() as t1 on t1.IdCipl = t0.IdCipl
		INNER JOIN dbo.RequestCipl as t2 on t2.IdCipl = t0.IdCipl
		WHERE IsApprove = 0
	) as tab1 on tab1.IdReq = tab0.Id AND tab0.IdCipl IN (
		select tx.IdCipl 
		from dbo.CargoCipl tx
		inner join dbo.CiplItemUpdateHistory ty on ty.IdCipl = tx.IdCipl AND ty.IdCargo = tx.IdCargo AND ty.IsApprove = 0
		where ty.IdCargo = @IdCargo
	)
END

GO
