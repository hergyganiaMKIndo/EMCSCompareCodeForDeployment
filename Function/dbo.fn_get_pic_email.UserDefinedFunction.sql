USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_pic_email]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_get_pic_email]
(
	-- Add the parameters for the function here
	@AssignmentType nvarchar(100),
	@AssignmentTo nvarchar(100)
)
RETURNS nvarchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(MAX);
	
	IF @AssignmentType = 'Group' 
	BEGIN
		IF @AssignmentTo = 'CKB' 
		BEGIN
			SET @Result = STUFF(
				(SELECT ';' + CAST(Email as NVARCHAR) 
					FROM PartsInformationSystem.[dbo].[UserAccess] where UserType='ext-imex' GROUP BY Email
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')
		END ELSE
		BEGIN	
			SET @Result = STUFF(
				(SELECT ';' + CAST(Email as NVARCHAR) 
					FROM employee where LTRIM(RTRIM(organization_name)) like LTRIM(RTRIM(@AssignmentTo)) GROUP BY Email
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,1,'')
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @Result = Email FROM employee 
		WHERE AD_User = @AssignmentTo 
		AND Employee_Status = 'Active' 
	END

	-- Return the result of the function
	RETURN @Result;
END
GO
