USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingNumberInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SP_DHLTrackingNumberInsert](@dtDHLDataType DHLDataType ReadOnly)  

As
Begin  
    insert into DHLTrackingNumber(DHLShipmentID, TrackingNumber, DescNumber, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	select DHLShipmentID=[ID], TrackingNumber=[ItemValue], DescNumber=[ItemCode], IsDelete=0, CreateBy=UserId, CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate =NULL
	from @dtDHLDataType  
End  
GO
