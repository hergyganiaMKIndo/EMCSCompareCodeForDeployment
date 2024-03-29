USE [EMCS]
GO
/****** Object:  Table [dbo].[CiplItem_Change]    Script Date: 10/03/2023 11:40:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CiplItem_Change](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCiplItem] [int] NULL,
	[IdCipl] [bigint] NULL,
	[IdReference] [bigint] NOT NULL,
	[ReferenceNo] [nvarchar](100) NOT NULL,
	[IdCustomer] [nvarchar](50) NULL,
	[Name] [nvarchar](200) NOT NULL,
	[Uom] [nvarchar](50) NOT NULL,
	[PartNumber] [nvarchar](50) NOT NULL,
	[Sn] [nvarchar](50) NOT NULL,
	[JCode] [nvarchar](50) NOT NULL,
	[Ccr] [nvarchar](50) NOT NULL,
	[CaseNumber] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[IdNo] [nvarchar](50) NULL,
	[YearMade] [nvarchar](50) NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](20, 2) NOT NULL,
	[ExtendedValue] [decimal](20, 2) NOT NULL,
	[Length] [decimal](20, 2) NULL,
	[Width] [decimal](20, 2) NULL,
	[Height] [decimal](20, 2) NULL,
	[Volume] [decimal](18, 6) NULL,
	[GrossWeight] [decimal](18, 3) NULL,
	[NetWeight] [decimal](18, 3) NULL,
	[Currency] [nvarchar](3) NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
	[CoO] [nvarchar](100) NULL,
	[IdParent] [bigint] NOT NULL,
	[SIBNumber] [nvarchar](200) NOT NULL,
	[WONumber] [nvarchar](200) NOT NULL,
	[Claim] [nvarchar](100) NOT NULL,
	[ASNNumber] [nvarchar](255) NULL,
	[Status] [nvarchar](100) NULL,
 CONSTRAINT [PK__CiplItem__3214EC0762BE9466] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
