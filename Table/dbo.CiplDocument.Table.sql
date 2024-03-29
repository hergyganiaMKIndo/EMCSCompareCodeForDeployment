USE [EMCS]
GO
/****** Object:  Table [dbo].[CiplDocument]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CiplDocument](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCipl] [bigint] NOT NULL,
	[DocumentDate] [datetime] NOT NULL,
	[DocumentName] [nvarchar](max) NOT NULL,
	[Filename] [nvarchar](max) NULL,
	[CreateBy] [nvarchar](500) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateBy] [nvarchar](max) NULL,
	[UpdateDate] [datetime] NULL,
	[IsDelete] [bit] NULL,
 CONSTRAINT [PK_CiplDocument] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
