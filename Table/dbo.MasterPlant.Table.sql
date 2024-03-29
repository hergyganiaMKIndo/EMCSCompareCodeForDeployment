USE [EMCS]
GO
/****** Object:  Table [dbo].[MasterPlant]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterPlant](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[PlantCode] [nvarchar](50) NOT NULL,
	[PlantName] [nvarchar](max) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL,
 CONSTRAINT [PK_MasterPlant] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
