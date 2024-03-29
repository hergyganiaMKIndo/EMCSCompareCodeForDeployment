USE [EMCS]
GO
/****** Object:  Table [dbo].[NotificationQueue]    Script Date: 10/03/2023 11:40:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotificationQueue](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Module] [nvarchar](50) NOT NULL,
	[RequestId] [bigint] NOT NULL,
	[RecipientType] [nvarchar](50) NULL,
	[NotificationTo] [nvarchar](50) NOT NULL,
	[NotificationSubject] [nvarchar](200) NOT NULL,
	[NotificationContent] [nvarchar](max) NOT NULL,
	[CreatedBy] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[UpdatedDate] [datetime] NULL,
	[IsRead] [bit] NOT NULL,
	[IsDelete] [bit] NOT NULL,
 CONSTRAINT [PK_NotificationQueue] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
