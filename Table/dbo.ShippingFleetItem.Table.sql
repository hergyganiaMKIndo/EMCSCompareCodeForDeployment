USE [EMCS_Dev]
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
