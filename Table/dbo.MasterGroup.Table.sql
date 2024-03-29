USE [EMCS]
GO
/****** Object:  Table [dbo].[MasterGroup]    Script Date: 10/03/2023 11:40:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterGroup](
	[ID] [bigint] NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [smalldatetime] NULL,
	[UpdatedBy] [int] NULL,
	[UpdatedOn] [smalldatetime] NULL
) ON [PRIMARY]
GO
