USE [EMCS]
GO
/****** Object:  Table [dbo].[CiplItemUpdateHistory]    Script Date: 10/03/2023 11:40:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CiplItemUpdateHistory](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCipl] [bigint] NOT NULL,
	[IdCargo] [bigint] NOT NULL,
	[IdCiplItem] [bigint] NOT NULL,
	[NewLength] [decimal](20, 2) NULL,
	[NewWidth] [decimal](20, 2) NULL,
	[NewHeight] [decimal](20, 2) NULL,
	[NewGrossWeight] [decimal](20, 2) NULL,
	[NewNetWeight] [decimal](20, 2) NULL,
	[OldLength] [decimal](20, 2) NULL,
	[OldWidth] [decimal](20, 2) NULL,
	[OldHeight] [decimal](20, 2) NULL,
	[OldGrossWeight] [decimal](20, 2) NULL,
	[OldNetWeight] [decimal](20, 2) NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
	[IsApprove] [bit] NOT NULL,
 CONSTRAINT [PK_CiplItemUpdateHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
