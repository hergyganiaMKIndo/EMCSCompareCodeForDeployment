USE [EMCS]
GO
/****** Object:  Table [dbo].[MasterKPBC]    Script Date: 10/03/2023 11:40:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterKPBC](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[AreaID] [bigint] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
	[Propinsi] [nvarchar](max) NOT NULL,
	[Address] [nvarchar](max) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL,
 CONSTRAINT [PK_MasterKPBC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
