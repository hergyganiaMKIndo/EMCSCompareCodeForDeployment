USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[Cargo]    Script Date: 10/03/2023 15:51:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cargo](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Consignee] [nvarchar](100) NULL,
	[NotifyParty] [nvarchar](100) NULL,
	[ExportType] [nvarchar](100) NULL,
	[Category] [nvarchar](100) NULL,
	[Incoterms] [nvarchar](100) NULL,
	[ShippingMethod] [nvarchar](100) NULL,
	[CargoType] [nvarchar](100) NULL,
	[ClNo] [nvarchar](100) NULL,
	[SsNo] [nvarchar](20) NULL,
	[StuffingDateStarted] [smalldatetime] NULL,
	[StuffingDateFinished] [smalldatetime] NULL,
	[ETA] [smalldatetime] NULL,
	[ETD] [smalldatetime] NULL,
	[VesselFlight] [nvarchar](30) NULL,
	[ConnectingVesselFlight] [nvarchar](30) NULL,
	[VoyageVesselFlight] [nvarchar](30) NULL,
	[VoyageConnectingVessel] [nvarchar](30) NULL,
	[PortOfLoading] [nvarchar](max) NULL,
	[PortOfDestination] [nvarchar](max) NULL,
	[SailingSchedule] [smalldatetime] NULL,
	[ArrivalDestination] [smalldatetime] NULL,
	[BookingNumber] [nvarchar](20) NULL,
	[BookingDate] [smalldatetime] NULL,
	[Liner] [nvarchar](max) NULL,
	[PebNo] [nvarchar](100) NULL,
	[PebDate] [smalldatetime] NULL,
	[NpeNo] [nvarchar](200) NULL,
	[NpeDate] [smalldatetime] NULL,
	[BlAwbNo] [nvarchar](200) NULL,
	[BlDate] [smalldatetime] NULL,
	[SpecialInstruction] [nvarchar](200) NULL,
	[Status] [nvarchar](200) NOT NULL,
	[Referrence] [nvarchar](max) NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[CreateBy] [nvarchar](20) NOT NULL,
	[UpdateDate] [smalldatetime] NULL,
	[UpdateBy] [nvarchar](20) NULL,
	[IsDelete] [bit] NOT NULL,
	[TotalPackageBy] [nvarchar](max) NULL,
 CONSTRAINT [PK_Cargo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
