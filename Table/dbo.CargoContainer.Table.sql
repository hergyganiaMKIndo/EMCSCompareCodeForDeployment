USE [EMCS]
GO
/****** Object:  Table [dbo].[CargoContainer]    Script Date: 10/03/2023 11:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CargoContainer](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CargoId] [bigint] NOT NULL,
	[Number] [nvarchar](50) NOT NULL,
	[ContainerType] [nvarchar](50) NULL,
	[SealNumber] [nvarchar](50) NULL,
	[Description] [nvarchar](200) NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
 CONSTRAINT [PK_CargoContainer] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
