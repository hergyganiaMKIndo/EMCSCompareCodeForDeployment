USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[DHLPerson]    Script Date: 10/03/2023 15:51:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DHLPerson](
	[DHLPersonID] [bigint] IDENTITY(1,1) NOT NULL,
	[DHLShipmentID] [bigint] NOT NULL,
	[PersonType] [nvarchar](10) NULL,
	[PersonName] [nvarchar](100) NULL,
	[CompanyName] [nvarchar](200) NULL,
	[PhoneNumber] [nvarchar](20) NULL,
	[EmailAddress] [nvarchar](30) NULL,
	[StreetLines] [nvarchar](255) NULL,
	[City] [nvarchar](100) NULL,
	[PostalCode] [nvarchar](20) NULL,
	[CountryCode] [nvarchar](20) NULL,
	[IsDelete] [int] NULL,
	[CreateBy] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DHLPerson] PRIMARY KEY CLUSTERED 
(
	[DHLPersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DHLPerson]  WITH CHECK ADD  CONSTRAINT [FK_DHLPerson_DHLShipment] FOREIGN KEY([DHLShipmentID])
REFERENCES [dbo].[DHLShipment] ([DHLShipmentID])
GO
ALTER TABLE [dbo].[DHLPerson] CHECK CONSTRAINT [FK_DHLPerson_DHLShipment]
GO
