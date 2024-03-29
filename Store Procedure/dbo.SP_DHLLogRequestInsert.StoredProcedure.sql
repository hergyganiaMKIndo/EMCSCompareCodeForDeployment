USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_DHLLogRequestInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[SP_DHLLogRequestInsert]
@ReqType varchar(50),
@DHLShipmentID bigint,
@DHLTrackingShipmentID bigint,
@Param varchar(MAX),
@UserId varchar(50)

As
Set Nocount On

Declare @DHLLogRequestID bigint 

Insert into DHLLogRequest(DHLShipmentID,DHLTrackingShipmentID,ReqType,[Param],CreateBy,CreateDate,UpdateBy,UpdateDate)
Values (@DHLShipmentID, @DHLTrackingShipmentID, @ReqType, @Param, @UserId, GETDATE(), NULL, NULL)

Select @DHLLogRequestID = Convert(bigint, SCOPE_IDENTITY())

Select @DHLLogRequestID As DHLLogRequestID
GO
