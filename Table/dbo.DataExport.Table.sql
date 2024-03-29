USE [EMCS]
GO
/****** Object:  Table [dbo].[DataExport]    Script Date: 10/03/2023 11:40:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataExport](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Category] [nvarchar](5) NOT NULL,
	[SoNumber] [bigint] NOT NULL,
	[IdCustomer] [bigint] NOT NULL,
	[ConsgineeName] [nvarchar](200) NOT NULL,
	[City] [nvarchar](200) NOT NULL,
	[PostalCode] [nvarchar](20) NOT NULL,
	[Regional] [nvarchar](10) NULL,
	[Street] [nvarchar](max) NOT NULL,
	[CountryCode] [nvarchar](5) NOT NULL,
	[CountryName] [nvarchar](100) NOT NULL,
	[UnitPrice] [decimal](20, 2) NOT NULL,
	[Currency] [decimal](20, 2) NOT NULL,
	[GrossWeight] [decimal](20, 2) NOT NULL,
	[ModelUnit] [nvarchar](20) NOT NULL,
	[UnitName] [nvarchar](20) NOT NULL,
	[UnitSn] [nvarchar](20) NOT NULL,
	[YearMade] [int] NOT NULL,
	[Volume] [decimal](20, 2) NOT NULL,
	[NetWeight] [decimal](20, 2) NOT NULL,
	[CreateOn] [smalldatetime] NOT NULL,
	[CreateBy] [nvarchar](20) NOT NULL,
	[UpdateOn] [smalldatetime] NULL,
	[UpdateBy] [nvarchar](20) NULL,
	[IsDelete] [bit] NOT NULL,
 CONSTRAINT [PK_DataExport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
