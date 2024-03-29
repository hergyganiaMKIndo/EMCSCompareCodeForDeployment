USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_report_problem_history]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec [dbo].[sp_get_report_problem_history] '2020-01-01', '2020-01-01', 'category', 'document', ''
CREATE PROCEDURE [dbo].[sp_get_report_problem_history]
(
	@startDate nvarchar(10),
	@endDate nvarchar(20),
	@type nvarchar(50) = 'reason',
	@category nvarchar(50) = 'document',
	@case nvarchar(50)
)
AS
BEGIN
	IF (@type = 'category')
	BEGIN
		SELECT 
			CAST(ROW_NUMBER() over(order by Category, Category ASC) as bigint) as [Id], 
			* 
		FROM (
			select DISTINCT		
				CAST(0 as bigint) ParentId
				, '-' [ReqType]
				, t1.Category [Category]
				, '-' [Cases]
				, '-' [Causes]
				, '-' [Impact]
				, '0' [TotalCauses]
				, '0' [TotalCases]
				, CAST(ISNULL(Total, 0) as nvarchar(100)) [TotalCategory]
				, CAST(ISNULL(ROUND(((CAST(Total as decimal(18,2)) / CAST(TotalAll as decimal(18,2))) * 100), 2), 0) as nvarchar(100)) [TotalCategoryPercentage]
			From (
				select 
					Category,
					count(*) Total, 
					(
						select count(*) From dbo.ProblemHistory
						where CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
					) TotalAll 
				From dbo.ProblemHistory
				where 
					CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
					AND Category <> 'Delegation'
				Group by Category
			) as t0
			right join dbo.MasterProblemCategory t1 on t1.Category = t0.Category
		) as result
	END
	
	IF (@type = 'case')
	BEGIN
		SELECT
			CAST(ROW_NUMBER() over(order by Category, Category ASC) as bigint) as [ID], 
			CAST(0 as bigint) ParentID
			, '-' [ReqType]
			, Category [Category]
			, [Case] [Cases]
			, '-' [Causes]
			, '-' [Impact]
			, '0' [TotalCauses]
			, CAST(ISNULL(Total, 0) as nvarchar(100)) [TotalCases]
			, '0' [TotalCategory]
			, CAST(ISNULL(ROUND(((CAST(Total as decimal(18,2)) / CAST(TotalAll as decimal(18,2))) * 100), 2), 0) as nvarchar(100)) [TotalCategoryPercentage] 
		From (
				SELECT 
					[Category],
					[Case],
					(select count(*) From dbo.ProblemHistory
						where 
							(CreateDate between CAST(@startDate as date) AND CAST(@endDate as date)) 
							AND Category = @category 
							AND [Case] = @case
					)  Total,  									
					(select count(*) From dbo.ProblemHistory
						where 
							CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
					) TotalAll 
				FROM dbo.MasterProblemCategory
				WHERE Category <> 'Delegation' AND Category = @category
				Group by [Category], [Case]
			) as result;

		--select
		--	CAST(ROW_NUMBER() over(order by Category, Category ASC) as bigint) as [ID], 
		--	CAST(0 as bigint) ParentID
		--	, '-' [ReqType]
		--	, Category [Category]
		--	, [Case] [Cases]
		--	, '-' [Causes]
		--	, '-' [Impact]
		--	, '0' [TotalCauses]
		--	, CAST(ISNULL(Total, 0) as nvarchar(100)) [TotalCases]
		--	, '0' [TotalCategory]
		--	, CAST(ISNULL(ROUND(((CAST(Total as decimal(18,2)) / CAST(TotalAll as decimal(18,2))) * 100), 2), 0) as nvarchar(100)) [TotalCategoryPercentage] 
		--From (
		--	select 
		--	    Category,
		--		[Case],
		--		count(*) Total, 
		--		(
		--			select count(*) From dbo.ProblemHistory
		--			where CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
		--		) TotalAll 
		--	From dbo.ProblemHistory 
		--	WHERE 
		--		Category = @category 
		--		AND CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
		--	Group by [Case], [Category]
		--) as result;
	END 
	
	IF (@type = 'reason')
	BEGIN
		select 
			CAST(ROW_NUMBER() over(order by Category, Category ASC) as bigint) as [ID], 
			CAST(0 as bigint) ParentID
			, '-' [ReqType]
			, Category [Category]
			, [Case] [Cases]
			, Reason [Causes]
			, Impact [Impact]
			, CAST(ISNULL(Total, 0) as nvarchar(100)) [TotalCauses]
			, '0' [TotalCases]
			, '0' [TotalCategory]
			, CAST(ISNULL(ROUND(((CAST(Total as decimal(18,2)) / CAST(TotalAll as decimal(18,2))) * 100), 2), 0) as nvarchar(100)) [TotalCategoryPercentage] 
		From (
			select 
			    Category,
				[Case], 
				[Causes] Reason,
				[Impact] Impact,
				count(*) Total, 
				(
					select count(*) From dbo.ProblemHistory
					where CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
				) TotalAll 
			From dbo.ProblemHistory 
			WHERE 
				Category = @category 
				AND [Case] = @case
				AND CreateDate between CAST(@startDate as date) AND CAST(@endDate as date) 
			Group by [Case], [Category], [Causes], [Impact]
		) as result;
	END 
END
GO
