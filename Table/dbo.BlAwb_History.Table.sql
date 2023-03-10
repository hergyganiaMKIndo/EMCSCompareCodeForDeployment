USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[BlAwb_History]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlAwb_History](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdBlAwb] [bigint] NOT NULL,
	[IdCl] [bigint] NOT NULL,
	[Number] [nvarchar](200) NOT NULL,
	[MasterBlDate] [datetime] NULL,
	[HouseBlNumber] [nvarchar](200) NULL,
	[HouseBlDate] [datetime] NULL,
	[Description] [nvarchar](max) NOT NULL,
	[FileName] [nvarchar](200) NULL,
	[Publisher] [nvarchar](50) NOT NULL,
	[BlAwbDate] [smalldatetime] NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[IsDelete] [bit] NOT NULL,
	[Status] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
