USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_cipl_businessarea_list]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_get_cipl_businessarea_list]
(	
	@PlantCode nvarchar(50) = ''
)
RETURNS TABLE 
AS
RETURN 
(
		SELECT
		  MasterPlant.PlantCode
		  ,MasterPlant.PlantName
		  ,MasterArea.BAreaCode
		  ,MasterArea.BAreaName
	  FROM [EMCS].[dbo].[MasterPlant]
	  join MasterArea on MasterPlant.PlantCode = MasterArea.BAreaCode
	  WHERE PlantCode =IIF(ISNULL(@PlantCode, '') = '', PlantCode, @PlantCode )
	 
		 
)
GO
