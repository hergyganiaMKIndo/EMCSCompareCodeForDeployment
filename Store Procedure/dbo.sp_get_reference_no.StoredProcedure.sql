USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_reference_no]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_reference_no] -- EXEC [sp_get_reference_no] 'PP', '', 'ReferenceNo'
(
	@Category nvarchar(100), 
	@ReferenceNo nvarchar(100) = '',
	@CategoryReference nvarchar(100),
	@LastReference nvarchar(100) = '',
	@IdCustomer nvarchar(100) = ''
)
AS
BEGIN
-- select * from dbo.Reference
	SET NOCOUNT ON;
	DECLARE @SQL nvarchar(max);
	IF(@Category = 'REMAN') 
	BEGIN 
		SET @SQL = 'select DISTINCT TOP 25"'+@CategoryReference+'" as ReferenceNo, IdCustomer, Category, null AS LastReference, IdCustomer from dbo.Reference where 1=1 and AvailableQuantity > 0';
	END
	ELSE
	BEGIN 
		SET @SQL = 'select DISTINCT TOP 25"'+@CategoryReference+'" as ReferenceNo, IdCustomer, Category, null AS LastReference, IdCustomer from dbo.Reference where 1=1 and AvailableQuantity > 0';	
	END
	

	IF (ISNULL(@Category, '') <> '')
	BEGIN
		SET @SQL = @SQL + ' AND Category='''+@Category+'''';
	END

	IF (ISNULL(@IdCustomer, '') <> '')
	BEGIN
		SET @SQL = @SQL + ' AND IdCustomer='''+@IdCustomer+'''';
	END

	IF (ISNULL(@ReferenceNo, '') <> '')
	BEGIN
		SET @SQL = @SQL + ' AND "'+@CategoryReference+'" like ''%'+@ReferenceNo+'%''';
	END

	IF (ISNULL(@LastReference, '') <> '')
	BEGIN
		SELECT @LastReference = REPLACE(@LastReference, ',', ''',''');
		SET @SQL = @SQL + ' AND "'+@CategoryReference+'" not in ('''+@LastReference+''')';
	END

	EXECUTE(@SQL);
END


GO
