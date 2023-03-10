USE [EMCS]
GO
/****** Object:  Table [dbo].[RequestGr]    Script Date: 10/03/2023 11:40:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RequestGr](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdGr] [nvarchar](20) NOT NULL,
	[IdFlow] [bigint] NOT NULL,
	[IdStep] [bigint] NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Pic] [nvarchar](20) NOT NULL,
	[CreateBy] [nvarchar](20) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](20) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
 CONSTRAINT [PK_RequestGr] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
