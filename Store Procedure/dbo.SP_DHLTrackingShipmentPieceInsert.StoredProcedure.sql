USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[SP_DHLTrackingShipmentPieceInsert]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SP_DHLTrackingShipmentPieceInsert](@dtDHLTrackingPiece DHLTrackingPiece ReadOnly)  

As
Begin  
    insert into DHLTrackingShipmentPiece (DHLTrackingShipmentID, AWBNumber, LicensePlate, PieceNumber, Depth, Width, Height, [Weight], PackageType
										, DimWeight, WeightUnit, IsDelete, CreateBy, CreateDate, UpdateBy, UpdateDate)
	select DHLTrackingShipmentID=a.[DHLTrackingShipmentID], AWBNumber=a.[AWBNumber], LicensePlate=a.[LicensePlate], PieceNumber=a.[PieceNumber], Depth=a.[Depth]
		 , Width=a.[Width], Height=a.[Height], [Weight]=a.[Weight], PackageType=a.[PackageType], DimWeight=a.[DimWeight], WeightUnit=a.[WeightUnit]
		 , IsDelete=0, CreateBy=a.[UserID], CreateDate=GETDATE(), UpdateBy=NULL, UpdateDate =NULL
	from @dtDHLTrackingPiece a
	left join DHLTrackingShipmentPiece b on a.DHLTrackingShipmentID=b.DHLTrackingShipmentID and a.LicensePlate=b.LicensePlate
	Where b.DHLTrackingShipmentID is NULL
End  
GO
