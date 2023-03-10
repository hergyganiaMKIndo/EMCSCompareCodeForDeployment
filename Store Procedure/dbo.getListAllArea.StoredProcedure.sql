USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[getListAllArea]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getListAllArea]
AS
BEGIN
      select a.ID, a.Area, v.Employee_Name PICArea from MasterArea a 
	  left join [dbo].[vEmployeeMaster] v on a.PICArea = v.Employee_xupj collate DATABASE_DEFAULT
	  where a.IsActive = 1
END
GO
