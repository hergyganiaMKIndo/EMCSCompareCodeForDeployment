USE [EMCS_Dev]
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplitStringRFC]    Script Date: 10/03/2023 15:51:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE  FUNCTION [dbo].[fnSplitStringRFC](  
    @RowData varchar(8000),  
    @SplitOn nvarchar(5)  
) RETURNS @RtnValue table (  
    Id int identity(1,1),  
    Data nvarchar(100)  
)   
AS    
BEGIN   
    Declare @Cnt int  
    Set @Cnt = 1  
  
    While (Charindex(@SplitOn,@RowData)>0)  
    Begin  
        Insert Into @RtnValue (data)
        Select   
            Data = ltrim(rtrim(Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))  

        Set @RowData = Substring(@RowData,Charindex(@SplitOn,@RowData)+1,len(@RowData))  
        Set @Cnt = @Cnt + 1  
    End  
  
    Insert Into @RtnValue (data)  
    Select Data = ltrim(rtrim(@RowData))  
  
    Return  
END
GO
