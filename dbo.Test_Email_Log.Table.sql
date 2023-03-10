USE [EMCS]
GO
/****** Object:  Table [dbo].[Test_Email_Log]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test_Email_Log](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[To] [nvarchar](max) NULL,
	[Content] [nvarchar](max) NOT NULL,
	[Subject] [nvarchar](max) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Test_Email_Log] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
