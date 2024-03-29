USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_update_cargo_ByApprover]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[sp_update_cargo_ByApprover]    
(    
 @CargoID BIGINT,    
 @Consignee NVARCHAR(200),    
 @NotifyParty NVARCHAR(200),    
 @ExportType NVARCHAR(200),    
 @Category NVARCHAR(200),    
 @Incoterms NVARCHAR(200),    
 @StuffingDateStarted datetime = NULL,--='02-02-2019',    
 @StuffingDateFinished datetime = NULL,--='12-12-2019',    
 @ETA datetime = NULL,--='02-02-2019',    
 @ETD datetime = NULL,--='12-12-2019',    
 @VesselFlight NVARCHAR(30),--='vessel',    
 @ConnectingVesselFlight NVARCHAR(30),--='con vessel',    
 @VoyageVesselFlight NVARCHAR(30),--='voy vessel',    
 @VoyageConnectingVessel NVARCHAR(30),--='voy con',    
 @PortOfLoading NVARCHAR(30),--='start',    
 @PortOfDestination NVARCHAR(30),--='end',    
 @SailingSchedule datetime = NULL,--='09-09-2019',    
 @ArrivalDestination datetime = NULL,--='10-10-2019',    
 @BookingNumber NVARCHAR(20) = '',--='1122',    
 @BookingDate datetime = NULL,--='11-11-2019',    
 @Liner NVARCHAR(20) = '',--='linear'    
 @Status NVARCHAR(20) = '',    
 @ActionBy NVARCHAR(20) = '',    
 @Referrence NVARCHAR(MAX) = '',    
 @CargoType NVARCHAR(50) = '',    
 @ShippingMethod NVARCHAR(50) = ''    
)    
AS    
BEGIN    
     
 declare @ID BIGINT;    
     
  UPDATE [dbo].[Cargo]    
  SET [Consignee] = @Consignee    
   ,[NotifyParty] = @NotifyParty    
   ,[ExportType] = @ExportType    
   ,[Category] = @Category    
   ,[Incoterms] = @Incoterms    
   ,[StuffingDateStarted] = @StuffingDateStarted    
   ,[StuffingDateFinished] = @StuffingDateFinished    
   ,[ETA] = @ETA    
   ,[ETD] = @ETD    
   ,[VesselFlight] = @VesselFlight    
   ,[ConnectingVesselFlight] = @ConnectingVesselFlight    
   ,[VoyageVesselFlight] = @VoyageVesselFlight    
   ,[VoyageConnectingVessel] = @VoyageConnectingVessel    
   ,[PortOfLoading] = @PortOfLoading    
   ,[PortOfDestination] = @PortOfDestination    
   ,[SailingSchedule] = @SailingSchedule    
   ,[ArrivalDestination] = @ArrivalDestination    
   ,[BookingNumber] = @BookingNumber    
   ,[BookingDate] = @BookingDate    
   ,[Liner] = @Liner    
   ,[UpdateDate] = GETDATE()    
   ,[UpdateBy] = @ActionBy    
   ,[Referrence] = @Referrence    
   ,[ShippingMethod] = @ShippingMethod    
   ,[CargoType] = @CargoType    
  WHERE Id = @CargoID    
    
  SET @ID = @CargoID    
    
 SELECT CAST(@ID as BIGINT) as ID    
    
END    
GO
