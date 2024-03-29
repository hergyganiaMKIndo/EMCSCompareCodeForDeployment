USE [EMCS_Dev]
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
