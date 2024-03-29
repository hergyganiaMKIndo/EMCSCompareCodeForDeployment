USE [EMCS]
GO
/****** Object:  Table [dbo].[DHLMasterProduct]    Script Date: 10/03/2023 11:40:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DHLMasterProduct](
	[DHLMasterProductID] [bigint] IDENTITY(1,1) NOT NULL,
	[ServiceType] [nvarchar](2) NOT NULL,
	[GlobalProductName] [nvarchar](50) NULL,
	[ProductContentCode] [nvarchar](10) NULL,
	[Indicator] [nvarchar](200) NULL,
	[ServiceTime] [nvarchar](20) NULL,
	[IsDelete] [int] NULL,
	[CreateBy] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DHLMasterProduct] PRIMARY KEY CLUSTERED 
(
	[DHLMasterProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
