USE [EMCS]
GO
/****** Object:  Table [dbo].[DHLShipment]    Script Date: 10/03/2023 11:40:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DHLShipment](
	[DHLShipmentID] [bigint] IDENTITY(1,1) NOT NULL,
	[DropOffType] [nvarchar](50) NULL,
	[ServiceType] [nvarchar](50) NULL,
	[PaymentInfo] [nvarchar](50) NULL,
	[Account] [nvarchar](30) NULL,
	[Currency] [nvarchar](10) NULL,
	[TotalNet] [decimal](18, 2) NULL,
	[UnitOfMeasurement] [nvarchar](10) NULL,
	[PackagesCount] [int] NULL,
	[LabelType] [nvarchar](50) NULL,
	[LabelTemplate] [nvarchar](50) NULL,
	[ShipTimestamp] [datetime] NULL,
	[PickupLocation] [nvarchar](100) NULL,
	[PickupLocTime] [nvarchar](50) NULL,
	[SpcPickupInstruction] [nvarchar](255) NULL,
	[CommoditiesDesc] [nvarchar](255) NULL,
	[CommoditiesContent] [nvarchar](255) NULL,
	[IdentifyNumber] [nvarchar](50) NULL,
	[ConfirmationNumber] [nvarchar](50) NULL,
	[PackagesQty] [int] NULL,
	[PackagesPrice] [decimal](18, 2) NULL,
	[Referrence] [nvarchar](255) NULL,
	[IsDelete] [int] NULL,
	[CreateBy] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DHLShipment] PRIMARY KEY CLUSTERED 
(
	[DHLShipmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
