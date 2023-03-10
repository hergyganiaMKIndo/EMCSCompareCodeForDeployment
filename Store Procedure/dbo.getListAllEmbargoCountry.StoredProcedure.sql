USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[getListAllEmbargoCountry]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[getListAllEmbargoCountry]
AS
BEGIN
      select ID, CountryCode, Description from MasterEmbargoCountry 
	  where IsDeleted = 0
END
GO
