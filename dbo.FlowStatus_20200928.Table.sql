USE [EMCS]
GO
/****** Object:  Table [dbo].[FlowStatus_20200928]    Script Date: 10/03/2023 11:40:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FlowStatus_20200928](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdStep] [bigint] NOT NULL,
	[Status] [nvarchar](200) NOT NULL,
	[ViewByUser] [nvarchar](200) NULL,
	[CreateBy] [nvarchar](20) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](20) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL
) ON [PRIMARY]
GO
