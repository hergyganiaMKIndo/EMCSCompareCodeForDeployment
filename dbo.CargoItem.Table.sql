USE [EMCS]
GO
/****** Object:  Table [dbo].[CargoItem]    Script Date: 10/03/2023 11:40:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CargoItem](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
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
 CONSTRAINT [PK_CargoItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
