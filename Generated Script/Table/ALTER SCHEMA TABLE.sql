--Compared from DB EMCS on Development, DB EMCS_QA on QA, DB EMCS_Dev on Development on 10/03/2023
ALTER	TABLE Cargo
ADD		TotalPackageBy NVARCHAR(MAX) NULL

ALTER	TABLE CiplForwader
ADD		Type NVARCHAR(10) NULL,
		ExportShipmentType NVARCHAR(MAX) NULL,
		Vendor NVARCHAR(MAX) NULL

SET ANSI_WARNINGS OFF;
ALTER	TABLE CiplItem
ALTER 	COLUMN Sn NVARCHAR(50)
SET ANSI_WARNINGS ON;

ALTER TABLE [dbo].[DHLAttachment]  WITH CHECK ADD  CONSTRAINT [FK_DHLAttachment_DHLShipment] FOREIGN KEY([DHLShipmentID])
REFERENCES [dbo].[DHLShipment] ([DHLShipmentID])
GO
ALTER TABLE [dbo].[DHLAttachment] CHECK CONSTRAINT [FK_DHLAttachment_DHLShipment]
GO

ALTER TABLE [dbo].[DHLPackage]  WITH CHECK ADD  CONSTRAINT [FK_DHLPackage_DHLShipment] FOREIGN KEY([DHLShipmentID])
REFERENCES [dbo].[DHLShipment] ([DHLShipmentID])
GO
ALTER TABLE [dbo].[DHLPackage] CHECK CONSTRAINT [FK_DHLPackage_DHLShipment]
GO

ALTER TABLE [dbo].[DHLPerson]  WITH CHECK ADD  CONSTRAINT [FK_DHLPerson_DHLShipment] FOREIGN KEY([DHLShipmentID])
REFERENCES [dbo].[DHLShipment] ([DHLShipmentID])
GO
ALTER TABLE [dbo].[DHLPerson] CHECK CONSTRAINT [FK_DHLPerson_DHLShipment]
GO

SET ANSI_WARNINGS OFF;
ALTER 	TABLE DHLPerson
ALTER 	COLUMN PhoneNumber NVARCHAR(20)
SET ANSI_WARNINGS ON;

SET ANSI_WARNINGS OFF;
ALTER 	TABLE DHLPerson
ALTER 	COLUMN EmailAddress NVARCHAR(30)
SET ANSI_WARNINGS ON;

ALTER TABLE [dbo].[DHLTrackingNumber]  WITH CHECK ADD  CONSTRAINT [FK_DHLTrackingNumber_DHLShipment] FOREIGN KEY([DHLShipmentID])
REFERENCES [dbo].[DHLShipment] ([DHLShipmentID])
GO
ALTER TABLE [dbo].[DHLTrackingNumber] CHECK CONSTRAINT [FK_DHLTrackingNumber_DHLShipment]
GO

ALTER TABLE [dbo].[DHLTrackingShipmentEvent]  WITH CHECK ADD  CONSTRAINT [FK_DHLTrackingShipmentEvent_DHLTrackingShipment] FOREIGN KEY([DHLTrackingShipmentID])
REFERENCES [dbo].[DHLTrackingShipment] ([DHLTrackingShipmentID])
GO
ALTER TABLE [dbo].[DHLTrackingShipmentEvent] CHECK CONSTRAINT [FK_DHLTrackingShipmentEvent_DHLTrackingShipment]
GO

ALTER	TABLE MasterVendor
ADD		IsManualEntry BIT

ALTER TABLE [dbo].[MasterVendor] ADD  DEFAULT ((0)) FOR [IsManualEntry]
GO

ALTER	TABLE NpePeb
ADD		NpeDateSubmitToCustomOffice DATETIME NULL,
		IsCancelled INT NULL,
		CancelledDocument NVARCHAR(MAX) NULL

ALTER	TABLE ShippingInstruction
ADD		ExportType NVARCHAR(10) NULL

SET ANSI_WARNINGS OFF;
ALTER TABLE ShippingFleet
ALTER COLUMN IdCipl BIGINT
SET ANSI_WARNINGS ON;