USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_date_data]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_get_date_data]
(
	-- Add the parameters for the function here
	@data nvarchar(200)
)
RETURNS nvarchar(200)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result nvarchar(200)
	-- Add the T-SQL statements to compute the return value here

	 SET @Result = LTRIM(
				RTRIM(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(
				REPLACE(RIGHT(@data, 14), ':', '')
						, 'MAY', '-05-')
						, 'APRIL', '-04-')
						, 'JULI' , '-07-')
						, 'MARET' , '-03-')
						, 'JUN' , '-06-')
						, 'APR', '-04-')
						, 'KPP.MP', '') 
						, 'GGAL', '') 
						, 'GAL', '') 
						, 'AL', '') 
						, 'L', '') 
						, '.', '')
						, 'BD', '') 
						, '/', '-') 
						, '-18', '-2018') 
						, '-I', '-') 
						, 'JU', '-07-') 
						, 'JAN', '-01-') 
						, 'DEC', '-12-') 
						, 'FEB', '-02-') 
						, 'MAR', '-03-')
						, 'SEP', '-09-')
						, 'AUG', '-08-')
						, 'OCT', '-10-')
						, 'COT', '-10-')
						, 'NOV', '-11-')
						, 'N', '')
						, 'EP', '-09-')
						, ' -', '-') 
						, '- ', '-') 
						, ' - ', '-')
						, '-012018', '01-2018')
						, '-18', '-2018')
						, '-19', '-2019')
						, '-KPPBC02-2019', '02-2019')
						, '73-KPU01-2019', '01-2019')
						, '77-KPU03-2019', '03-2019')
						, 'A 4-12-2019', '04-12-2019')
						,'PB-KPU02-2019', '02-2019')
						,'E--KPU02-2019', '02-2019')
						,'12 MOV 19', '12 NOV 2019')
						,'PE-KPU02-2019', '02-2019')
						,'A 4-09-2019', '04-09-2019')
						,'02-BO02-2019', '02-2019')
						,'90-KPU01-2019', '01-2019')
						,'38-KPU03-2019', '03-2019')
						,'ya tidak jeas', '')
						,'0200228-306100', '')
						,'K 11-07-2018', '11-07-2018')
						)
					) 

	IF (LEN(@Result) = 7)
	BEGIN
		SET @Result = '01-'+ @Result;
	END

	IF (LEN(@Result) = 8)
	BEGIN
		IF (RIGHT(@Result, 3) = '-18')
		BEGIN
			SET @Result = LEFT(@Result, 5)+REPLACE(RIGHT(@Result, 3), '-18', '-2018');
		END		

		IF (RIGHT(@Result, 3) = '-19')
		BEGIN
			SET @Result = LEFT(@Result, 5)+REPLACE(RIGHT(@Result, 3), '-19', '-2019');
		END

		IF (RIGHT(@Result, 3) = '-20') 
		BEGIN 
			SET @Result = LEFT(@Result, 5)+REPLACE(RIGHT(@Result, 3), '-20', '-2020');
		END
	END

	IF (LEN(@Result) = 9)
	BEGIN
		SET @Result = '0'+ @Result;
	END

	-- Conver data to date format
	
	IF (@Result IS NOT NULL)
	BEGIN
	--	SET @Result = CONVERT(date, @Result, 105);
		SET @Result = @Result;
	END
	ELSE
	BEGIN
		SET @Result = '01-01-1900';
	END
	
	IF (RTRIM(LTRIM(@Result)) = '')
	BEGIN
		SET @Result = '01-01-1900';
	END

	SET @Result = CONVERT(date, '01-01-1900', 105);
	-- Return the result of the function
	RETURN @Result

END
GO
