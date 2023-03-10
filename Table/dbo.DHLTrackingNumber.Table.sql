USE [EMCS_Dev]
GO
/****** Object:  Table [dbo].[DHLTrackingNumber]    Script Date: 10/03/2023 15:51:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DHLTrackingNumber](
	[DHLTrackingNumberID] [bigint] IDENTITY(1,1) NOT NULL,
	[DHLShipmentID] [bigint] NOT NULL,
	[TrackingNumber] [nvarchar](50) NULL,
	[DescNumber] [nvarchar](50) NULL,
	[IsDelete] [int] NULL,
	[CreateBy] [nvarchar](50) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateBy] [nvarchar](50) NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_DHLTrackingNumber] PRIMARY KEY CLUSTERED 
(
	[DHLTrackingNumberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DHLTrackingNumber]  WITH CHECK ADD  CONSTRAINT [FK_DHLTrackingNumber_DHLShipment] FOREIGN KEY([DHLShipmentID])
REFERENCES [dbo].[DHLShipment] ([DHLShipmentID])
GO
ALTER TABLE [dbo].[DHLTrackingNumber] CHECK CONSTRAINT [FK_DHLTrackingNumber_DHLShipment]
GO
