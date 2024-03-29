USE [EMCS]
GO
/****** Object:  Table [dbo].[MasterBranchCkb]    Script Date: 10/03/2023 11:40:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MasterBranchCkb](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[Area] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[PostalCode] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](255) NULL,
	[FaxNumber] [nvarchar](255) NULL,
	[CreateBy] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
	[IsDelete] [bit] NOT NULL,
 CONSTRAINT [PK_MasterBranchCkb] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBranchCkb] ADD  CONSTRAINT [DF_MasterBranchCkb_IsDelete]  DEFAULT ((0)) FOR [IsDelete]
GO
