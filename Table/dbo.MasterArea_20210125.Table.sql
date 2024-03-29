USE [EMCS]
GO
/****** Object:  Table [dbo].[MasterArea_20210125]    Script Date: 10/03/2023 11:40:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterArea_20210125](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProvinsiCode] [int] NULL,
	[BAreaCode] [nvarchar](50) NOT NULL,
	[BAreaName] [nvarchar](200) NOT NULL,
	[BLatitude] [nvarchar](50) NULL,
	[BLongitude] [nvarchar](50) NULL,
	[AreaCode] [nvarchar](50) NOT NULL,
	[AreaName] [nvarchar](200) NULL,
	[ALatitude] [nvarchar](50) NULL,
	[ALongitude] [nvarchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL
) ON [PRIMARY]
GO
