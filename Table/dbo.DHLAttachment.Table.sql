USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[DHLAttachment]    Script Date: 10/03/2023 15:51:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DHLAttachment](
	[DHLAttachmentID] [bigint] IDENTITY(1,1) NOT NULL,
	[DHLShipmentID] [bigint] NOT NULL,
	[ImageFormat] [nvarchar](20) NULL,
	[GraphicImage] [varchar](max) NULL,
	[IsDelete] [int] NULL,
	[CreateBy] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DHLAttachment] PRIMARY KEY CLUSTERED 
(
	[DHLAttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[DHLAttachment]  WITH CHECK ADD  CONSTRAINT [FK_DHLAttachment_DHLShipment] FOREIGN KEY([DHLShipmentID])
REFERENCES [dbo].[DHLShipment] ([DHLShipmentID])
GO
ALTER TABLE [dbo].[DHLAttachment] CHECK CONSTRAINT [FK_DHLAttachment_DHLShipment]
GO
