USE [EMCS]
GO
/****** Object:  Table [dbo].[FlowStatus]    Script Date: 10/03/2023 11:40:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FlowStatus](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdStep] [bigint] NOT NULL,
	[Status] [nvarchar](200) NOT NULL,
	[ViewByUser] [nvarchar](200) NULL,
	[CreateBy] [nvarchar](20) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](20) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
 CONSTRAINT [PK_FlowStatus] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
