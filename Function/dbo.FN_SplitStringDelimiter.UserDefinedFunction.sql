USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_SplitStringDelimiter]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FN_SplitStringDelimiter]
(
    @Text VARCHAR(MAX),
    @Delimiter VARCHAR(100),
    @Index INT
)
RETURNS VARCHAR(MAX)
AS 
BEGIN
    DECLARE @A TABLE (ID INT IDENTITY, V VARCHAR(MAX));
    DECLARE @R VARCHAR(MAX);
    WITH CTE AS
    (
		SELECT 0 A, 1 B
		UNION ALL
		SELECT B, CONVERT(INT,CHARINDEX(@Delimiter, @Text, B) + LEN(@Delimiter))
		FROM CTE
		WHERE B > A
    )
    INSERT @A(V)
    SELECT SUBSTRING(@Text,A,CASE WHEN B > LEN(@Delimiter) THEN B-A-LEN(@Delimiter) ELSE LEN(@Text) - A + 1 END) VALUE      
    FROM CTE WHERE A >0

    SELECT @R = V
    FROM @A
    WHERE ID = @Index + 1
    RETURN @R
END
GO
