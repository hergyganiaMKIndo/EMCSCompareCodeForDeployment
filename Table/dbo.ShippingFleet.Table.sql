USE [EMCS_Dev]
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
