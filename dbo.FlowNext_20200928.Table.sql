USE [EMCS]
GO
/****** Object:  Table [dbo].[FlowNext_20200928]    Script Date: 10/03/2023 11:40:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FlowNext_20200928](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdStatus] [bigint] NOT NULL,
	[IdStep] [bigint] NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[UpdateDate] [smalldatetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[IsDelete] [bit] NOT NULL
) ON [PRIMARY]
GO
