USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[Sp_RFCItem_Insert]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Sp_RFCItem_Insert]  
  
@RFCID INT  
,@TableName NVARCHAR(250) = NULL  
,@LableName NVARCHAR(250) = NULL  
,@FieldName NVARCHAR(350) = NULL  
,@BeforeValue NVARCHAR(MAX) = NULL  
,@AfterValue NVARCHAR(MAX) = NULL  
AS  
BEGIN  
  
DECLARE @ResultId INT  
  
Insert Into RFCItem   
(RFCID,  
TableName,  
LableName,  
FieldName,  
BeforeValue,  
AfterValue)   
VALUES   
(@RFCID,  
@TableName,  
@LableName,  
@FieldName,  
@BeforeValue,  
@AfterValue)  
  
SET @ResultId = SCOPE_IDENTITY()  
  
SELECT @ResultId  
END
GO
