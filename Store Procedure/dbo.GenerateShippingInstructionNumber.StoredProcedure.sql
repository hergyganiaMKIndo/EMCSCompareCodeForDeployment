USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[GenerateShippingInstructionNumber]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GenerateShippingInstructionNumber]
(

@ID bigint , @CreateBy nvarchar(10) 
)
AS
BEGIN
	   
       DECLARE @YEAR nvarchar(2), @MONTH nvarchar(2), @DATE nvarchar(2), @SINO nvarchar(20), @LASTNUMBER nvarchar(20), 
	   @NEXTNUMBER int, @LASTVAL nvarchar(20), @DEPT nvarchar(2)
	   SET @YEAR = YEAR(GETDATE())%100
	   SET @MONTH = RIGHT( '0' + CAST( MONTH( GETDATE() ) AS varchar(2) ), 2 )  
	   SET @DATE = RIGHT( '0' + CAST( DAY( GETDATE() ) AS varchar(2) ), 2 ) 
	   
	   SELECT @LASTNUMBER = ISNULL(MAX(SUBSTRING(C.SlNo,10,4)),0) FROM dbo.ShippingInstruction C
	   SET @NEXTNUMBER = CAST(@LASTNUMBER as int) + 1;
	   SET @LASTVAL = right('0000' + convert(varchar(4),@NEXTNUMBER),4) 

	   SELECT @DEPT = E.Dept_Code  FROM employee E WHERE E.AD_User = @CreateBy
	   SELECT @SINO = 'SI.' + @DATE + @MONTH + @YEAR + @LASTVAL + @DEPT

	   UPDATE dbo.ShippingInstruction SET SlNo = @SINO WHERE id = @ID

END
GO
