USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_RAchievement]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<hasni>
-- Create date: <20191007>
-- =============================================
--EXEC PROCEDURE [dbo].[SP_RAchievement] '2020-02-11', '2020-01-01'
CREATE PROCEDURE [dbo].[SP_RAchievement]
(
	@StartDate nvarchar(50),
	@EndDate nvarchar(50)
)	
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		t3.[Name] [Cycle],
		CONCAT(t3.TargetDays, ' Days') [Target],
		CONCAT(
			ISNULL(CAST(CASE WHEN t1.Actual < 0 THEN 0 ELSE t1.Actual END as varchar(50)), 0) , ' Days'
		) [Actual],
		
			ISNULL(
				CAST(
					CAST(IIF(t1.Actual = NULL, 0, IIF(t1.Actual <= t3.TargetDays, 100, t3.TargetDays/t1.Actual*100)) as decimal(18,0))
				as varchar(50))
			, 0)
		 [Achievement]
	FROM
	(SELECT [Value], [Name], [Description] [TargetDays]
		FROM MasterParameter
		WHERE [group]='Achievement') t3
	LEFT JOIN 
	(
	--cipl approved
	SELECT 
		t1.[Name],
		CAST(AVG(
			CAST(
				CAST(DATEDIFF(hour,t0.CreateDate,t1.ApprovedDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual]
	FROM
		Cipl t0
		JOIN (
			SELECT max(CreateDate) as [ApprovedDate], IdCipl, '1' as [Name]
			  FROM [EMCS].[dbo].[CiplHistory] t0
			where Status = 'Approve'
			GROUP BY IdCipl) as t1 
		on t1.IdCipl = t0.id
		WHERE t1.ApprovedDate is NOT NULL
	GROUP BY t1.[Name]

	UNION 

	--pickup goods
	SELECT 
		t2.[Name],
		CAST(AVG(
			CAST(
			    --CAST(DATEDIFF(hour,t2.ApprovedDate, t0.ActualTimePickup) as decimal(18,3)) 
				CAST(DATEDIFF(hour,t2.ApprovedDate, t0.EstimationTimePickup) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual] 
	FROM
	GoodsReceive t0
	JOIN GoodsReceiveItem t1 on t1.IdGr = t0.Id
	JOIN (
		SELECT max(t0.CreateDate) as [ApprovedDate], EdoNo, '2' as [Name]
		  FROM [EMCS].[dbo].CiplHistory t0
		  join Cipl t1 on t1.id = t0.IdCipl
		where Status = 'Approve'
		GROUP BY EdoNo) as t2
	on t2.EdoNo = t1.DoNo
	WHERE t0.EstimationTimePickup is NOT NULL
	GROUP BY t2.Name
	
	UNION 

	--NPE PEB
	SELECT 
		t0.[Name],
		CAST(AVG(
			CAST(
			    CAST(DATEDIFF(hour,t0.NpeDate,t0.MasterBlDate) as decimal(18,3)) 
				--CAST(DATEDIFF(hour,t0.NpeDate,t0.BlDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual]
	FROM
		(SELECT N.NpeDate, B.MasterBlDate, '3' [Name] FROM NpePeb N 
		INNER JOIN BlAwb B ON B.IdCl = N.IdCl 
		INNER JOIN RequestCl RCL ON RCL.IdCl = B.IdCl 
		WHERE
		RCL.IdStep = 10022 AND RCL.Status = 'Approve'  ) t0
		--(SELECT NPEDate, BlDate, '4' [Name] FROM Cargo) t0
		WHERE t0.MasterBlDate is NOT NULL  AND t0.NpeDate<>'1900-01-01 00:00:00'
	GROUP BY t0.[Name]


	UNION 

	--BL/AWB
	SELECT 
		t0.[Name],
		CAST(AVG(
			CAST(
			    CAST(DATEDIFF(hour,t0.NpeDate,t0.MasterBlDate) as decimal(18,3)) 
				--CAST(DATEDIFF(hour,t0.NpeDate,t0.BlDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual]
	FROM
		(SELECT N.NpeDate, B.MasterBlDate, '4' [Name] FROM NpePeb N 
		INNER JOIN BlAwb B ON B.IdCl = N.IdCl 
		INNER JOIN RequestCl RCL ON RCL.IdCl = B.IdCl 
		WHERE
		RCL.IdStep = 10022 AND RCL.Status = 'Approve'  ) t0
		--(SELECT NPEDate, BlDate, '4' [Name] FROM Cargo) t0
		WHERE t0.MasterBlDate is NOT NULL  AND t0.NpeDate<>'1900-01-01 00:00:00'
	GROUP BY t0.[Name]

	) as t1 on t3.Value = t1.[Name]
END
GO
