USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[NpePeb]    Script Date: 10/03/2023 15:51:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NpePeb](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCl] [bigint] NOT NULL,
	[AjuNumber] [nvarchar](200) NOT NULL,
	[AjuDate] [smalldatetime] NOT NULL,
	[PebNumber] [nvarchar](50) NULL,
	[PebDate] [smalldatetime] NULL,
	[NpeNumber] [nvarchar](200) NOT NULL,
	[NpeDate] [smalldatetime] NOT NULL,
	[FileName] [nvarchar](100) NULL,
	[Npwp] [nvarchar](50) NULL,
	[ReceiverName] [nvarchar](100) NULL,
	[PassPabeanOffice] [nvarchar](100) NULL,
	[Dhe] [decimal](20, 2) NULL,
	[PebFob] [decimal](20, 2) NULL,
	[Valuta] [nvarchar](20) NULL,
	[DescriptionPassword] [nvarchar](100) NULL,
	[DocumentComplete] [bit] NULL,
	[WarehouseLocation] [nvarchar](max) NULL,
	[Rate] [decimal](18, 0) NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
	[FreightPayment] [decimal](18, 2) NOT NULL,
	[InsuranceAmount] [decimal](18, 2) NOT NULL,
	[DraftPeb] [bit] NOT NULL,
	[RegistrationNumber] [nvarchar](max) NOT NULL,
	[NpeDateSubmitToCustomOffice] [datetime] NULL,
	[IsCancelled] [int] NULL,
	[CancelledDocument] [nvarchar](max) NULL,
 CONSTRAINT [PK_NpePeb] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[NpePeb] ADD  CONSTRAINT [DF__NpePeb__DraftPeb__75C33FDD]  DEFAULT ((0)) FOR [DraftPeb]
GO
ALTER TABLE [dbo].[NpePeb] ADD  CONSTRAINT [DF__NpePeb__Registra__3E3E00C9]  DEFAULT ('') FOR [RegistrationNumber]
GO
