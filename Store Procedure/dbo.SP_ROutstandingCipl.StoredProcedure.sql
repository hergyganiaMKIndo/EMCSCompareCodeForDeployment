USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_ROutstandingCipl]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ROutstandingCipl]
(
	@startdate varchar(50),
	@enddate varchar(50)
)	
AS
BEGIN
	SELECT 
		'' Cycle
		, t1.Employee_Name PICName
		, t1.Dept_Name Department
		, t2.BAreaName Branch
		, t0.CiplNo
		, ISNULL(CONVERT(VARCHAR(9), t0.CreateDate, 6), '-') SubmitDate
		,(SELECT top 1 Status  FROM [EMCS].[dbo].[CiplHistory] t3
				where t3.IdCipl = t0.id) status
    FROM Cipl t0 
	inner join employee t1 on t0.CreateBy = t1.AD_User
	inner join MasterArea t2 on t2.BAreaCode = t0.Branch
	WHERE t0.id NOT IN (
				SELECT IdCipl  FROM [EMCS].[dbo].[CiplHistory] t0
				where Status = 'Approve'
			GROUP BY IdCipl)
		
		and t0.CreateDate between @startdate and @enddate
END
GO
