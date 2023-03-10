USE [EMCS]
GO
/****** Object:  Table [dbo].[TempBArea]    Script Date: 10/03/2023 11:40:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TempBArea](
	[BUSINESS_AREA] [nvarchar](255) NOT NULL,
	[BUSINESS_AREA_NAME] [nvarchar](255) NULL,
	[AREA_CODE] [nvarchar](255) NULL,
	[AREA_NAME] [nvarchar](255) NULL,
	[LATITUDE] [float] NULL,
	[LONGITUDE] [float] NULL,
	[AREA_LATITUDE] [float] NULL,
	[AREA_LONGITUDE] [float] NULL,
	[ETL_DATE] [smalldatetime] NULL,
	[SOS_LAB] [nvarchar](255) NULL
) ON [PRIMARY]
GO
