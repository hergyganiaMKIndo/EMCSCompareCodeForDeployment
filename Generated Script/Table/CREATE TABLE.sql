/****** Object:  Table [dbo].[BastNumber]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BastNumber](
	[BastNo] [numeric](38, 0) NULL,
	[ReferenceNo] [varchar](40) NULL
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nomor BAST (DA) untuk RUE dari SAP (EDW_STG_SAP_ECC_DAILY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BastNumber'
GO

/****** Object:  Table [dbo].[BlAwb_Change]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlAwb_Change](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdBlAwb] [bigint] NOT NULL,
	[IdCl] [bigint] NOT NULL,
	[Number] [nvarchar](200) NOT NULL,
	[MasterBlDate] [datetime] NULL,
	[HouseBlNumber] [nvarchar](200) NULL,
	[HouseBlDate] [datetime] NULL,
	[Description] [nvarchar](max) NOT NULL,
	[FileName] [nvarchar](200) NULL,
	[Publisher] [nvarchar](50) NOT NULL,
	[BlAwbDate] [smalldatetime] NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[UpdateDate] [smalldatetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[IsDelete] [bit] NOT NULL,
	[Status] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlAwb_History]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlAwb_History](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdBlAwb] [bigint] NOT NULL,
	[IdCl] [bigint] NOT NULL,
	[Number] [nvarchar](200) NOT NULL,
	[MasterBlDate] [datetime] NULL,
	[HouseBlNumber] [nvarchar](200) NULL,
	[HouseBlDate] [datetime] NULL,
	[Description] [nvarchar](max) NOT NULL,
	[FileName] [nvarchar](200) NULL,
	[Publisher] [nvarchar](50) NOT NULL,
	[BlAwbDate] [smalldatetime] NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[IsDelete] [bit] NOT NULL,
	[Status] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[BlAwbDocumentHistory]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlAwbDocumentHistory](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdBlAwb] [bigint] NOT NULL,
	[FileName] [nvarchar](max) NOT NULL,
	[CreateDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[CargoDocument]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CargoDocument](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCargo] [bigint] NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[DocumentName] [nvarchar](max) NOT NULL,
	[Filename] [nvarchar](max) NULL,
	[CreateBy] [nvarchar](500) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateBy] [nvarchar](max) NULL,
	[UpdateDate] [datetime] NULL,
	[IsDelete] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[CargoItem_Change]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CargoItem_Change](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCargoItem] [bigint] NOT NULL,
	[IdCargo] [bigint] NOT NULL,
	[ContainerNumber] [nvarchar](100) NULL,
	[ContainerType] [nvarchar](50) NULL,
	[ContainerSealNumber] [nvarchar](50) NULL,
	[IdCipl] [bigint] NOT NULL,
	[IdCiplItem] [bigint] NOT NULL,
	[InBoundDa] [nvarchar](500) NULL,
	[Length] [decimal](20, 2) NULL,
	[Width] [decimal](20, 2) NULL,
	[Height] [decimal](20, 2) NULL,
	[Net] [decimal](20, 2) NULL,
	[Gross] [decimal](20, 2) NULL,
	[CreateBy] [nvarchar](20) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](20) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[isDelete] [bit] NOT NULL,
	[NewLength] [decimal](20, 2) NULL,
	[NewWidth] [decimal](20, 2) NULL,
	[NewHeight] [decimal](20, 2) NULL,
	[NewNet] [decimal](20, 2) NULL,
	[NewGross] [decimal](20, 2) NULL,
	[Status] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[CiplItem_Change]    Script Date: 10/03/2023 11:40:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CiplItem_Change](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCiplItem] [int] NULL,
	[IdCipl] [bigint] NULL,
	[IdReference] [bigint] NOT NULL,
	[ReferenceNo] [nvarchar](100) NOT NULL,
	[IdCustomer] [nvarchar](50) NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Uom] [nvarchar](50) NOT NULL,
	[PartNumber] [nvarchar](50) NOT NULL,
	[Sn] [nvarchar](50) NOT NULL,
	[JCode] [nvarchar](50) NOT NULL,
	[Ccr] [nvarchar](50) NOT NULL,
	[CaseNumber] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[IdNo] [nvarchar](50) NULL,
	[YearMade] [nvarchar](50) NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](20, 2) NOT NULL,
	[ExtendedValue] [decimal](20, 2) NOT NULL,
	[Length] [decimal](20, 2) NULL,
	[Width] [decimal](20, 2) NULL,
	[Height] [decimal](20, 2) NULL,
	[Volume] [decimal](18, 6) NULL,
	[GrossWeight] [decimal](18, 3) NULL,
	[NetWeight] [decimal](18, 3) NULL,
	[Currency] [nvarchar](3) NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
	[CoO] [nvarchar](100) NULL,
	[IdParent] [bigint] NOT NULL,
	[SIBNumber] [nvarchar](200) NOT NULL,
	[WONumber] [nvarchar](200) NOT NULL,
	[Claim] [nvarchar](100) NOT NULL,
	[ASNNumber] [nvarchar](255) NULL,
	[Status] [nvarchar](100) NULL,
 CONSTRAINT [PK__CiplItem__3214EC0762BE9466] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[GoodsReceiveArmadaNew]    Script Date: 10/03/2023 15:51:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GoodsReceiveArmadaNew](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[DoNo] [nvarchar](100) NULL,
	[IdGr] [bigint] NULL,
	[PicName] [nvarchar](100) NULL,
	[PhoneNumber] [nvarchar](100) NULL,
	[KtpNumber] [nvarchar](100) NULL,
	[SimNumber] [nvarchar](100) NULL,
	[SimExpiryDate] [smalldatetime] NULL,
	[StnkNumber] [nvarchar](100) NULL,
	[KirNumber] [nvarchar](50) NULL,
	[KirExpire] [smalldatetime] NULL,
	[NoPolNumber] [nvarchar](100) NULL,
	[EstimationTimePickup] [smalldatetime] NULL,
	[Apar] [bit] NULL,
	[Apd] [bit] NULL,
	[DoReference] [nvarchar](255) NULL,
	[Notes] [nvarchar](max) NULL,
	[VehicleType] [nvarchar](100) NULL,
	[VehicleMark] [nvarchar](100) NULL,
 CONSTRAINT [PK_GoodsReceiveArmadaNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[GoodsReceiveDocument]    Script Date: 10/03/2023 15:51:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GoodsReceiveDocument](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdGr] [bigint] NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[DocumentName] [nvarchar](max) NOT NULL,
	[Filename] [nvarchar](max) NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateBy] [nvarchar](max) NULL,
	[UpdateDate] [datetime] NULL,
	[IsDelete] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[GoodsReceiveNew]    Script Date: 10/03/2023 15:51:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GoodsReceiveNew](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[GrNo] [nvarchar](20) NULL,
	[Vendor] [nvarchar](100) NULL,
	[PickupPoint] [nvarchar](100) NULL,
	[PickupPic] [nvarchar](100) NULL,
	[Notes] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[CreateDate] [smalldatetime] NULL,
	[UpdateDate] [smalldatetime] NULL,
 CONSTRAINT [PK_GoodsReceiveNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[MasterSubConCompany]    Script Date: 10/03/2023 15:51:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterSubConCompany](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Value] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](max) NULL,
	[UpdatedBy] [nvarchar](max) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[RequestForChange]    Script Date: 10/03/2023 15:51:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RequestForChange](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RFCNumber] [nvarchar](150) NULL,
	[FormType] [nvarchar](150) NULL,
	[FormId] [int] NULL,
	[FormNo] [nvarchar](150) NULL,
	[Status] [int] NOT NULL,
	[Reason] [nvarchar](max) NULL,
	[CreateBy] [nvarchar](150) NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateBy] [nvarchar](150) NULL,
	[Approver] [nvarchar](150) NULL,
	[UpdateDate] [datetime] NULL,
	[ReasonIfRejected] [nvarchar](max) NULL,
 CONSTRAINT [PK_RequestForChange] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[RequestForChange] ADD  CONSTRAINT [DF_RequestForChange_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[RequestForChange] ADD  CONSTRAINT [DF_RequestForChange_CreateDate]  DEFAULT (getutcdate()) FOR [CreateDate]
GO

/****** Object:  Table [dbo].[RFCItem]    Script Date: 10/03/2023 15:51:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RFCItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RFCID] [int] NULL,
	[TableName] [nvarchar](100) NULL,
	[LableName] [nvarchar](100) NULL,
	[FieldName] [nvarchar](100) NULL,
	[BeforeValue] [nvarchar](max) NULL,
	[AfterValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_RFCItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[ShippingFleet_Change]    Script Date: 10/03/2023 15:51:29 ******/
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

/****** Object:  Table [dbo].[ShippingFleet_History]    Script Date: 10/03/2023 15:51:29 ******/
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

/****** Object:  Table [dbo].[ShippingFleet]    Script Date: 10/03/2023 15:51:19 ******/
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

/****** Object:  Table [dbo].[ShippingFleetDocumentHistory]    Script Date: 10/03/2023 15:51:29 ******/
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

/****** Object:  Table [dbo].[ShippingFleetItem]    Script Date: 10/03/2023 15:51:29 ******/
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

/****** Object:  Table [dbo].[ShippingFleetRefrence]    Script Date: 10/03/2023 15:51:21 ******/
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

/****** Object:  Table [dbo].[Type]    Script Date: 10/03/2023 15:51:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Type](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](10) NULL,
 CONSTRAINT [PK_Type] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
