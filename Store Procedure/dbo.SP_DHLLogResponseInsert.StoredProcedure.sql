USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_DHLLogResponseInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[SP_DHLLogResponseInsert]
@DHLLogRequestID bigint,
@ReqStatus varchar(50),
@ResponseCode varchar(50),
@ResponseMsg varchar(MAX),
@UserId varchar(50)

As
Set Nocount On

Insert into DHLLogResponse(DHLLogRequestID,ReqStatus,ResponseCode,ResponseMsg,CreateBy,CreateDate,UpdateBy,UpdateDate)
Values (@DHLLogRequestID, @ReqStatus, @ResponseCode, @ResponseMsg, @UserId, GETDATE(), NULL, NULL)
GO
