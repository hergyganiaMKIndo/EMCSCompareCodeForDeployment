USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_RDheBI]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hasni
-- Create date: 14/10/2019
-- Description:	SP Devisa Hasil Export (DHE) For Bank Indonesia
-- =============================================
--DROP PROCEDURE [dbo].[SP_RDheBI]
CREATE PROCEDURE [dbo].[SP_RDheBI]
(
	@StartDate nvarchar(50),
	@EndDate nvarchar(50),
	@Category nvarchar(50),
	@ExportType nvarchar(50)
)
AS
BEGIN

DECLARE @SQL as nvarchar(Max)
declare @whereRef nvarchar(max) =''
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	IF @StartDate <>'' 
	BEGIN
    	SET @whereRef=' and NpeDate >= ''' + @StartDate +''' and NpeDate <= ''' + @EndDate +''''
	 END
	 print (@whereRef)
   IF @Category <>''
	BEGIN
    	SET @whereRef+=' and Category = ' + @Category
	 END
	 IF @ExportType <>''
	BEGIN
    	SET @whereRef+=' and ExportType = ' + @ExportType
	 END

SET @SQL ='SELECT *	FROM [dbo].[fn_get_RDheBI]() WHERE NPWP <>''''' + @whereRef
 print @sql
		 exec(@SQL);
		
END
GO
