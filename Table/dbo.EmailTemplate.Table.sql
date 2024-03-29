USE [EMCS]
GO
/****** Object:  Table [dbo].[EmailTemplate]    Script Date: 10/03/2023 11:40:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmailTemplate](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Module] [nvarchar](50) NULL,
	[Status] [nvarchar](50) NULL,
	[RecipientType] [nvarchar](50) NULL,
	[Subject] [nvarchar](200) NULL,
	[Message] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[CreatedDate] [smalldatetime] NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedDate] [smalldatetime] NULL,
 CONSTRAINT [PK_EmailTemplate] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
