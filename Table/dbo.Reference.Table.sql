USE [EMCS]
GO
/****** Object:  Table [dbo].[Reference]    Script Date: 10/03/2023 11:40:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reference](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ReferenceNo] [nvarchar](50) NOT NULL,
	[QuotationNo] [nvarchar](50) NOT NULL,
	[POCustomer] [nvarchar](50) NOT NULL,
	[Date] [date] NULL,
	[IdCustomer] [nvarchar](50) NOT NULL,
	[ConsigneeName] [nvarchar](max) NOT NULL,
	[City] [nvarchar](max) NOT NULL,
	[PostalCode] [nvarchar](50) NOT NULL,
	[Regional] [nvarchar](max) NOT NULL,
	[Street] [nvarchar](max) NOT NULL,
	[CountryName] [nvarchar](50) NOT NULL,
	[Telephone] [nvarchar](50) NOT NULL,
	[Fax] [nvarchar](50) NOT NULL,
	[PIC] [nvarchar](max) NOT NULL,
	[ContactPerson] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](max) NOT NULL,
	[UnitPrice] [decimal](24, 2) NULL,
	[Currency] [nvarchar](50) NOT NULL,
	[GrossWeight] [decimal](18, 3) NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitModel] [nvarchar](50) NOT NULL,
	[UnitName] [nvarchar](max) NOT NULL,
	[UnitUom] [nvarchar](50) NOT NULL,
	[UnitSN] [nvarchar](50) NOT NULL,
	[YearMade] [nvarchar](50) NOT NULL,
	[ExtendedValue] [decimal](18, 3) NOT NULL,
	[Length] [decimal](18, 3) NOT NULL,
	[Width] [decimal](18, 3) NOT NULL,
	[Height] [decimal](18, 3) NOT NULL,
	[Volume] [decimal](18, 3) NOT NULL,
	[NetWeight] [decimal](18, 3) NOT NULL,
	[JCode] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[CCR] [nvarchar](50) NOT NULL,
	[CaseNumber] [nvarchar](50) NOT NULL,
	[PartNumber] [nvarchar](50) NOT NULL,
	[IDNo] [nvarchar](50) NOT NULL,
	[CoO] [nvarchar](50) NOT NULL,
	[AvailableQuantity] [int] NOT NULL,
	[SIBNumber] [nvarchar](50) NOT NULL,
	[WONumber] [nvarchar](50) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[CreateBy] [nvarchar](50) NULL,
	[CreateDate] [date] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [date] NULL,
	[Claim] [nvarchar](100) NULL,
	[FileName] [nvarchar](max) NULL,
	[ETLDate] [datetime] NULL,
 CONSTRAINT [PK_Reference] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_ReferenceNo]  DEFAULT ('') FOR [ReferenceNo]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_QuotationNo]  DEFAULT ('') FOR [QuotationNo]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_POCustomer]  DEFAULT ('') FOR [POCustomer]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_IdCustomer]  DEFAULT ('') FOR [IdCustomer]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_ConsigneeName]  DEFAULT ('') FOR [ConsigneeName]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_City]  DEFAULT ('') FOR [City]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_PostalCode]  DEFAULT ('') FOR [PostalCode]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Regional]  DEFAULT ('') FOR [Regional]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Street]  DEFAULT ('') FOR [Street]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_CountryName]  DEFAULT ('') FOR [CountryName]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Telephone]  DEFAULT ('') FOR [Telephone]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Fax]  DEFAULT ('') FOR [Fax]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_PIC]  DEFAULT ('') FOR [PIC]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_ContactPerson]  DEFAULT ('') FOR [ContactPerson]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Email]  DEFAULT ('') FOR [Email]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_UnitPrice]  DEFAULT ((0)) FOR [UnitPrice]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Currency]  DEFAULT ('') FOR [Currency]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_GrossWeight]  DEFAULT ((0)) FOR [GrossWeight]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Quantity]  DEFAULT ((0)) FOR [Quantity]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_UnitModel]  DEFAULT ('') FOR [UnitModel]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_UnitName]  DEFAULT ('') FOR [UnitName]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_UnitUom]  DEFAULT ('') FOR [UnitUom]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_UnitSN]  DEFAULT ('') FOR [UnitSN]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_YearMade]  DEFAULT ('') FOR [YearMade]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_ExtendedValue]  DEFAULT ((0)) FOR [ExtendedValue]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Length]  DEFAULT ((0)) FOR [Length]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Width]  DEFAULT ((0)) FOR [Width]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Height]  DEFAULT ((0)) FOR [Height]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Volume]  DEFAULT ((0)) FOR [Volume]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_NetWeight]  DEFAULT ((0)) FOR [NetWeight]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_JCode]  DEFAULT ('') FOR [JCode]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Name]  DEFAULT ('') FOR [Name]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_CCR]  DEFAULT ('') FOR [CCR]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_CaseNumber]  DEFAULT ('') FOR [CaseNumber]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_PartNumber]  DEFAULT ('') FOR [PartNumber]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_IDNo]  DEFAULT ('') FOR [IDNo]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_CoO]  DEFAULT ('') FOR [CoO]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_AvailableQuantity_1]  DEFAULT ((0)) FOR [AvailableQuantity]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_SIBNumber]  DEFAULT ('') FOR [SIBNumber]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_DlrWO]  DEFAULT ('') FOR [WONumber]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_Category]  DEFAULT ('') FOR [Category]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF__Reference__Claim__7C062918]  DEFAULT ('') FOR [Claim]
GO
ALTER TABLE [dbo].[Reference] ADD  CONSTRAINT [DF_Reference_ETLDate]  DEFAULT (getdate()) FOR [ETLDate]
GO
