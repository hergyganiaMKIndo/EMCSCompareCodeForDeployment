USE [EMCS]
GO
/****** Object:  Table [dbo].[MasterAirSeaPort]    Script Date: 10/03/2023 11:40:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterAirSeaPort](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Country] [nvarchar](200) NULL,
	[Type] [nvarchar](50) NULL,
	[CountryId] [bigint] NULL,
	[CreateDate] [datetime] NOT NULL,
	[CreateBy] [nvarchar](100) NOT NULL,
	[UpdateDate] [datetime] NULL,
	[UpdateBy] [nvarchar](100) NULL,
	[IsDelete] [bit] NOT NULL,
 CONSTRAINT [PK_MasterAirSeaPort] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
