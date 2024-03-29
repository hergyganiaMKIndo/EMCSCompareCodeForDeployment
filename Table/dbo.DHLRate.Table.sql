USE [EMCS]
GO
/****** Object:  Table [dbo].[DHLRate]    Script Date: 10/03/2023 11:40:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DHLRate](
	[DHLRateID] [bigint] IDENTITY(1,1) NOT NULL,
	[DHLShipmentID] [bigint] NOT NULL,
	[ServiceType] [nvarchar](10) NULL,
	[Currency] [nvarchar](10) NULL,
	[ChargeCode] [nvarchar](50) NULL,
	[ChargeType] [nvarchar](100) NULL,
	[ChargeAmount] [decimal](18, 2) NULL,
	[DeliveryTime] [nvarchar](100) NULL,
	[CutoffTime] [nvarchar](100) NULL,
	[NextBusinessDay] [nvarchar](10) NULL,
	[IsDelete] [int] NULL,
	[CreateBy] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DHLRate] PRIMARY KEY CLUSTERED 
(
	[DHLRateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
