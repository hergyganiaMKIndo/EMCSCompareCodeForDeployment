--Compared from DB EMCS on Development, DB EMCS_QA on QA, DB EMCS_Dev on Development on 10/03/2023
ALTER	TABLE Cargo
ADD		TotalPackageBy NVARCHAR(MAX) NULL

ALTER	TABLE CiplForwader
ADD		Type NVARCHAR(10) NULL,
		ExportShipmentType NVARCHAR(MAX) NULL,
		Vendor NVARCHAR(MAX) NULL

ALTER	TABLE CiplItem
ALTER 	COLUMN Sn NVARCHAR(50)

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

ALTER 	TABLE DHLPerson
ALTER 	COLUMN PhoneNumber NVARCHAR(20)

ALTER 	TABLE DHLPerson
ALTER 	COLUMN EmailAddress NVARCHAR(30)

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
ADD		IsManualEntry BIT NOT NULL

ALTER TABLE [dbo].[MasterVendor] ADD  DEFAULT ((0)) FOR [IsManualEntry]
GO

ALTER	TABLE NpePeb
ADD		NpeDateSubmitToCustomOffice DATETIME NULL,
		IsCancelled INT NULL,
		CancelledDocument NVARCHAR(MAX) NULL

ALTER	TABLE ShippingInstruction
ADD		ExportType NVARCHAR(10) NULL

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingFleet_Change](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdShippingFleet] [bigint] NOT NULL,
	[IdGr] [bigint] NOT NULL,
	[IdCipl] [nvarchar](max) NULL,
	[DoNo] [nvarchar](max) NULL,
	[DaNo] [nvarchar](50) NOT NULL,
	[PicName] [nvarchar](100) NOT NULL,
	[PhoneNumber] [nvarchar](100) NULL,
	[KtpNumber] [nvarchar](100) NULL,
	[SimNumber] [nvarchar](100) NULL,
	[SimExpiryDate] [datetime] NULL,
	[StnkNumber] [nvarchar](100) NULL,
	[KirNumber] [nvarchar](50) NULL,
	[KirExpire] [datetime] NULL,
	[NopolNumber] [nvarchar](100) NULL,
	[EstimationTimePickup] [datetime] NULL,
	[Apar] [bit] NULL,
	[Apd] [bit] NULL,
	[FileName] [nvarchar](max) NULL,
	[Bast] [nvarchar](max) NULL,
	[Status] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingFleet_History](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdShippingFleet] [bigint] NOT NULL,
	[IdGr] [bigint] NOT NULL,
	[IdCipl] [nvarchar](max) NULL,
	[DoNo] [nvarchar](max) NULL,
	[DaNo] [nvarchar](50) NOT NULL,
	[PicName] [nvarchar](100) NOT NULL,
	[PhoneNumber] [nvarchar](100) NULL,
	[KtpNumber] [nvarchar](100) NULL,
	[SimNumber] [nvarchar](100) NULL,
	[SimExpiryDate] [datetime] NULL,
	[StnkNumber] [nvarchar](100) NULL,
	[KirNumber] [nvarchar](50) NULL,
	[KirExpire] [datetime] NULL,
	[NopolNumber] [nvarchar](100) NULL,
	[EstimationTimePickup] [datetime] NULL,
	[Apar] [bit] NULL,
	[Apd] [bit] NULL,
	[FileName] [nvarchar](max) NULL,
	[Bast] [nvarchar](max) NULL,
	[Status] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingFleet](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdGr] [bigint] NOT NULL,
	[IdCipl] [bigint] NULL,
	[DoNo] [nvarchar](max) NULL,
	[DaNo] [nvarchar](50) NOT NULL,
	[PicName] [nvarchar](100) NOT NULL,
	[PhoneNumber] [nvarchar](100) NULL,
	[KtpNumber] [nvarchar](100) NULL,
	[SimNumber] [nvarchar](100) NULL,
	[SimExpiryDate] [smalldatetime] NULL,
	[StnkNumber] [nvarchar](100) NULL,
	[KirNumber] [nvarchar](50) NULL,
	[KirExpire] [smalldatetime] NULL,
	[NopolNumber] [nvarchar](100) NULL,
	[EstimationTimePickup] [smalldatetime] NULL,
	[Apar] [bit] NULL,
	[Apd] [bit] NULL,
	[FileName] [nvarchar](max) NULL,
	[Bast] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingFleetDocumentHistory](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdShippingFleet] [bigint] NOT NULL,
	[FileName] [nvarchar](max) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingFleetItem](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdShippingFleet] [bigint] NOT NULL,
	[IdGr] [bigint] NOT NULL,
	[IdCipl] [bigint] NOT NULL,
	[IdCiplItem] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShippingFleetRefrence](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdShippingFleet] [bigint] NOT NULL,
	[IdGr] [bigint] NOT NULL,
	[IdCipl] [bigint] NOT NULL,
	[DoNo] [nvarchar](max) NOT NULL,
	[CreateDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE ShippingFleet
ALTER COLUMN IdCipl BIGINT