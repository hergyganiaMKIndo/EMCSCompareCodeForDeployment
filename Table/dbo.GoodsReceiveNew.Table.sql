USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[GoodsReceiveNew]    Script Date: 10/03/2023 15:51:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GoodsReceiveNew](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[GrNo] [nvarchar](20) NULL,
	[Vendor] [nvarchar](100) NULL,
	[PickupPoint] [nvarchar](100) NULL,
	[PickupPic] [nvarchar](100) NULL,
	[Notes] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[UpdatedBy] [nvarchar](50) NULL,
	[CreateDate] [smalldatetime] NULL,
	[UpdateDate] [smalldatetime] NULL,
 CONSTRAINT [PK_GoodsReceiveNew] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
