USE [EMCS]
GO
/****** Object:  Table [dbo].[ErrorEmailLog]    Script Date: 10/03/2023 11:40:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorEmailLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[RequestID] [bigint] NOT NULL,
	[Module] [nvarchar](50) NOT NULL,
	[RecipientType] [nvarchar](50) NOT NULL,
	[ErrorDescription] [nvarchar](max) NOT NULL,
	[ErrorDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ErrorEmailLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
