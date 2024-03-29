USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_RSailingEstimation]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[Fn_RSailingEstimation]
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT DISTINCT t3.ClNo,
		ISNULL(t0.ConsigneeCountry, t0.SoldToCountry) [DestinationCountry] 
		, t4.AreaName [OriginCity]
		, t3.[PortOfLoading] [PortOrigin]
		, t0.[ShippingMethod]
		, t3.[PortOfDestination] [PortDestination]
		, ISNULL(CONVERT(VARCHAR(9), t3.ArrivalDestination, 6), '-') ETA
		, ISNULL(CONVERT(VARCHAR(9), t3.SailingSchedule, 6), '-') ETD
		, CAST(DATEDIFF(day, t3.SailingSchedule, t3.ArrivalDestination) as varchar(18)) [Estimation] 
    FROM Cipl t0
	JOIN CargoCipl t2 on t2.IdCipl = t0.id
	JOIN Cargo t3 on t3.Id = t2.IdCargo   
	JOIN MasterArea t4 ON Right(t0.Area,3) = RighT(t4.BAreaCode,3)
	WHERE 
		t0.IsDelete = 0
		And t3.IsDelete = 0
		AND t0.CreateBy<>'System'
		AND  t3.ArrivalDestination is not null
)
GO
