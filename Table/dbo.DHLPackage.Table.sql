USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[DHLPackage]    Script Date: 10/03/2023 15:51:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DHLPackage](
	[DHLPackageID] [bigint] IDENTITY(1,1) NOT NULL,
	[DHLShipmentID] [bigint] NOT NULL,
	[PackageNumber] [int] NULL,
	[Insured] [decimal](18, 2) NULL,
	[Weight] [decimal](18, 2) NULL,
	[Length] [decimal](18, 2) NULL,
	[Width] [decimal](18, 2) NULL,
	[Height] [decimal](18, 2) NULL,
	[CustReferences] [nvarchar](250) NULL,
	[CaseNumber] [nvarchar](50) NULL,
	[CiplNumber] [nvarchar](50) NULL,
	[IsDelete] [int] NULL,
	[CreateBy] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DHLPackage] PRIMARY KEY CLUSTERED 
(
	[DHLPackageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DHLPackage]  WITH CHECK ADD  CONSTRAINT [FK_DHLPackage_DHLShipment] FOREIGN KEY([DHLShipmentID])
REFERENCES [dbo].[DHLShipment] ([DHLShipmentID])
GO
ALTER TABLE [dbo].[DHLPackage] CHECK CONSTRAINT [FK_DHLPackage_DHLShipment]
GO
