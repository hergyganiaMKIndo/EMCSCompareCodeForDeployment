USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[CargoDocument]    Script Date: 10/03/2023 15:51:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CargoDocument](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCargo] [bigint] NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[DocumentName] [nvarchar](max) NOT NULL,
	[Filename] [nvarchar](max) NULL,
	[CreateBy] [nvarchar](500) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateBy] [nvarchar](max) NULL,
	[UpdateDate] [datetime] NULL,
	[IsDelete] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
