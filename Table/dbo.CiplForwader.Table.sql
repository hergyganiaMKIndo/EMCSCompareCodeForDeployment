USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[CiplForwader]    Script Date: 10/03/2023 15:51:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CiplForwader](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCipl] [bigint] NOT NULL,
	[Forwader] [nvarchar](200) NOT NULL,
	[Attention] [nvarchar](100) NULL,
	[Company] [nvarchar](200) NOT NULL,
	[Address] [nvarchar](max) NOT NULL,
	[Forwading] [nvarchar](200) NOT NULL,
	[Contact] [nvarchar](200) NOT NULL,
	[Email] [nvarchar](max) NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
	[Branch] [nvarchar](200) NULL,
	[SubconCompany] [nvarchar](200) NULL,
	[Area] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[PostalCode] [nvarchar](200) NULL,
	[FaxNumber] [nvarchar](200) NULL,
	[Type] [nvarchar](10) NULL,
	[ExportShipmentType] [nvarchar](max) NULL,
	[Vendor] [nvarchar](max) NULL,
 CONSTRAINT [PK_CiplForwader] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
