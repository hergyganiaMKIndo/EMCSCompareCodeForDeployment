USE [EMCS]
GO
/****** Object:  Table [dbo].[GoodsReceive]    Script Date: 10/03/2023 11:40:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GoodsReceive](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[GrNo] [nvarchar](20) NULL,
	[PicName] [nvarchar](100) NOT NULL,
	[PhoneNumber] [nvarchar](100) NULL,
	[KtpNumber] [nvarchar](100) NULL,
	[SimNumber] [nvarchar](100) NULL,
	[StnkNumber] [nvarchar](100) NULL,
	[NopolNumber] [nvarchar](100) NULL,
	[EstimationTimePickup] [smalldatetime] NULL,
	[Vendor] [nvarchar](100) NULL,
	[KirNumber] [nvarchar](50) NULL,
	[KirExpire] [smalldatetime] NULL,
	[Apar] [bit] NULL,
	[Apd] [bit] NULL,
	[Notes] [nvarchar](max) NULL,
	[VehicleType] [nvarchar](100) NULL,
	[VehicleMerk] [nvarchar](100) NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
	[SimExpiryDate] [smalldatetime] NULL,
	[ActualTimePickup] [smalldatetime] NULL,
	[Status] [nvarchar](50) NULL,
	[PickupPoint] [nvarchar](100) NULL,
	[PickupPic] [nvarchar](100) NULL,
 CONSTRAINT [PK_GoodsReceive] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
