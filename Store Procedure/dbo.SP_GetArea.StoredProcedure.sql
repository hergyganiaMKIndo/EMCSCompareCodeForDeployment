USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetArea]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetArea]

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	truncate table MasterArea
Insert into MasterArea ([BAreaCode]
      ,[BAreaName]
      ,[BLatitude]
      ,[BLongitude]
      ,[AreaCode]
      ,[AreaName]
      ,[ALatitude]
      ,[ALongitude]
      ,[IsActive]
	  ,CreateBy
	  ,CreateDate)
  SELECT PLANT [BUSINESS_AREA]
      ,PLANT_NAME  [BUSINESS_AREA_NAME]    
      ,0 [BLATITUDE]
      ,0 [BLONGITUDE]
	  ,Isnull([Area_Code],'')
	  ,[Area_Name]
      ,0 [AREALATITUDE]
      ,0 [AREALONGITUDE]
      , 1 IsActive
	  ,'SYSTEM'
	  ,GETDATE()
  FROM  BI_PROD.[EDW_ANALYTICS].[ECC].[dim_plant_area] WHERE PLANT NOT in ('-2','-1')
END
GO
