USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_RAchievement]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<hasni,Sandi>
-- Create date: <20191007>
-- Update date: <20220929>
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
	MasterCycle.[Name] [Cycle], 
	CONCAT(ISNULL(MasterCycle.[TargetDays], 0), ' Days') [Target], 
	CONCAT(ISNULL(Actual, 0), ' Days') [Actual], 
	CAST(ISNULL([Achieved], 0) as varchar) [Achieved], 
	CAST(ISNULL([TotalData], 0) as varchar) [TotalData], 
	--(TotalData - Achieved) [Unachieved], 
	SUBSTRING(CAST(CASE WHEN TotalData > 0 THEN (
		(
			ROUND(
				CAST(Achieved as decimal) / CAST(TotalData as decimal) *100
				, 2
			)
		) 
	) ELSE 100 END as varchar), 0, 6) [Achievement]
FROM 
	(SELECT [Value], [Name], [Description] [TargetDays]
			FROM MasterParameter
			WHERE [group]='Achievement') MasterCycle
	LEFT JOIN (
	--cipl approved
	SELECT 
		MIN(t3.[Name]) [Name],
		max(t3.[TargetDays]) [TargetDays],
		CAST(AVG(
			CAST(
				CAST(DATEDIFF(hour,t1x.[SubmitDate],t1.ApprovedDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual],
		SUM(CASE WHEN (CAST(
				CAST(DATEDIFF(hour,t1x.[SubmitDate],t1.ApprovedDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			) <= t3.TargetDays) THEN 1 ELSE 0 END) [Achieved],
		COUNT(t1.IdCipl) as [TotalData]
	FROM
		Cipl t0
		JOIN (
			SELECT max(CreateDate) as [ApprovedDate], IdCipl, '1' as [Name]
				FROM [EMCS].[dbo].[CiplHistory] t0
			where Status = 'Approve' AND Step = 'Approval By Superior'
			GROUP BY IdCipl) as t1 on t1.IdCipl = t0.id
		JOIN (
			SELECT min(CreateDate) as [SubmitDate], IdCipl as [IdCiplx], '1' as [Name]
				FROM [EMCS].[dbo].[CiplHistory] t0
			where Status = 'Submit' 
			GROUP BY IdCipl) as t1x on t1x.IdCiplx = t0.id
		JOIN (SELECT [Value], [Name], [Description] [TargetDays]
			FROM MasterParameter
			WHERE [group]='Achievement' AND [Value] = 1) t3 ON 1 = 1
	WHERE [ApprovedDate] BETWEEN @StartDate AND @EndDate
	GROUP BY t1.[Name]

	UNION 

	--pickup goods
	SELECT
		MIN(t3.[Name]) [Name],
		max(t3.[TargetDays]) [TargetDays],
		CAST(AVG(
			CAST(
				CAST(DATEDIFF(hour,t2x.[SubmitDate], t2.ApprovedDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual],
		SUM(CASE WHEN (CAST(
				CAST(DATEDIFF(hour,t2x.[SubmitDate], t2.ApprovedDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			) <= t3.TargetDays) THEN 1 ELSE 0 END) [Achieved],
		COUNT(t2.EdoNo) as [TotalData]
	FROM
	ShippingFleet t0
	--JOIN ShippingFleetItem t1 on t1.IdShippingFleet = t0.Id
	JOIN (
		SELECT max(t0.CreateDate) as [SubmitDate], EdoNo, '2' as [Name]
			FROM [EMCS].[dbo].CiplHistory t0
			join Cipl t1 on t1.id = t0.IdCipl
		where Status = 'Submit'
		GROUP BY EdoNo) as t2x on t2x.EdoNo = t0.DoNo
	JOIN (
		SELECT max(t0.CreateDate) as [ApprovedDate], EdoNo, '2' as [Name]
			FROM [EMCS].[dbo].CiplHistory t0
			join Cipl t1 on t1.id = t0.IdCipl
		where Status = 'Approve'
		GROUP BY EdoNo) as t2 on t2.EdoNo = t0.DoNo
	JOIN (SELECT [Value], [Name], [Description] [TargetDays]
		FROM MasterParameter
		WHERE [group]='Achievement' AND [Value] = 2) t3 ON 1 = 1
	WHERE [ApprovedDate] BETWEEN @StartDate AND @EndDate
	GROUP BY t2.Name
	
	UNION 

	--NPE PEB
	SELECT 
		MIN(t3.[Name]) [Name],
		max(t3.[TargetDays]) [TargetDays],
		CAST(AVG(
			CAST(
			    CAST(DATEDIFF(hour,t0.NpeDateSubmitToCustomOffice, t0.NpeDate) as decimal(18,3)) 
				--CAST(DATEDIFF(hour,t0.NpeDate,t0.BlDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual],
		SUM(CASE WHEN (CAST(
				CAST(DATEDIFF(hour,t0.NpeDate,t0.NpeDateSubmitToCustomOffice) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			) <= t3.TargetDays) THEN 1 ELSE 0 END) [Achieved],
		COUNT(t0.NpeDate) as [TotalData]
	FROM
		(SELECT N.NpeDateSubmitToCustomOffice, N.NpeDate, '3' [Name] FROM NpePeb N 
		INNER JOIN BlAwb B ON B.IdCl = N.IdCl 
		INNER JOIN RequestCl RCL ON RCL.IdCl = B.IdCl 
		--INNER JOIN RequestCl RCLx ON (RCLx.IdCl = B.IdCl AND Rclx.CreateDate BETWEEN @StartDate AND @EndDate)
		WHERE
		RCL.IdStep = 10022 AND RCL.Status = 'Approve'  ) t0
		JOIN (SELECT [Value], [Name], [Description] [TargetDays]
			FROM MasterParameter
			WHERE [group]='Achievement' AND [Value] = 3) t3 ON 1 = 1
		WHERE t0.NpeDate is NOT NULL 
			AND (t0.NpeDateSubmitToCustomOffice<>'1900-01-01 00:00:00' AND t0.NpeDateSubmitToCustomOffice IS NOT NULL)
			AND t0.NpeDate BETWEEN @StartDate AND @EndDate
	GROUP BY t0.[Name]

	UNION

	--BL/AWB
	SELECT 
		MIN(t3.[Name]) [Name],
		max(t3.[TargetDays]) [TargetDays],
		CAST(AVG(
			CAST(
			    CAST(DATEDIFF(hour,t0.NpeDate,t0.MasterBlDate) as decimal(18,3)) 
				--CAST(DATEDIFF(hour,t0.NpeDate,t0.BlDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			)
		) as decimal(18,1)) as [Actual],
		SUM(CASE WHEN (CAST(
				CAST(DATEDIFF(hour,t0.NpeDate,t0.MasterBlDate) as decimal(18,3)) 
				/ CAST('24' as decimal(18,3)) as decimal(18,2)
			) <= t3.TargetDays) THEN 1 ELSE 0 END) [Achieved],
		COUNT(t0.MasterBlDate) as [TotalData]
	FROM
		(SELECT N.NpeDate, B.MasterBlDate, '4' [Name] FROM NpePeb N
		INNER JOIN BlAwb B ON B.IdCl = N.IdCl 
		INNER JOIN Cargo cl ON cl.id = B.IdCl
		INNER JOIN RequestCl RCL ON RCL.IdCl = B.IdCl 
		--INNER JOIN RequestCl RCLx ON (RCLx.IdCl = B.IdCl AND Rclx.CreateDate BETWEEN @StartDate AND @EndDate)
		WHERE
		RCL.IdStep = 10022 AND RCL.Status = 'Approve' AND ShippingMethod <> 'Air' ) t0
		JOIN (SELECT [Value], [Name], [Description] [TargetDays]
			FROM MasterParameter
			WHERE [group]='Achievement' AND [Value] = 4) t3 ON 1 = 1
		--(SELECT NPEDate, BlDate, '4' [Name] FROM Cargo) t0
		WHERE t0.MasterBlDate is NOT NULL 
			AND t0.NpeDate<>'1900-01-01 00:00:00'
			AND t0.MasterBlDate BETWEEN @StartDate AND @EndDate
	GROUP BY t0.[Name]
	) [DataAchievement] ON MasterCycle.[Name] = [DataAchievement].[Name]
END
GO
