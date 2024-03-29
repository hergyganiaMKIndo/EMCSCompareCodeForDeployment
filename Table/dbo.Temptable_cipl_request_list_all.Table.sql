USE [EMCS]
GO
/****** Object:  Table [dbo].[Temptable_cipl_request_list_all]    Script Date: 10/03/2023 11:40:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temptable_cipl_request_list_all](
	[Id] [bigint] NOT NULL,
	[IdCipl] [nvarchar](20) NOT NULL,
	[IdFlow] [bigint] NOT NULL,
	[IdStep] [bigint] NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Pic] [nvarchar](20) NOT NULL,
	[CreateBy] [nvarchar](20) NOT NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[UpdateBy] [nvarchar](20) NULL,
	[UpdateDate] [smalldatetime] NULL,
	[IsDelete] [bit] NOT NULL,
	[FlowName] [nvarchar](200) NOT NULL,
	[SubFlowType] [nvarchar](50) NOT NULL,
	[IdNextStep] [bigint] NULL,
	[NextStepName] [nvarchar](100) NULL,
	[NextAssignType] [nvarchar](100) NULL,
	[NextStatusViewByUser] [nvarchar](200) NULL,
	[CiplNo] [nvarchar](20) NULL,
	[Category] [nvarchar](100) NOT NULL,
	[ETD] [smalldatetime] NULL,
	[ETA] [smalldatetime] NULL,
	[LoadingPort] [nvarchar](200) NULL,
	[DestinationPort] [nvarchar](200) NULL,
	[ShippingMethod] [nvarchar](30) NULL,
	[Forwader] [nvarchar](200) NULL,
	[ConsigneeCountry] [nvarchar](100) NULL,
	[AssignmentType] [nvarchar](100) NULL,
	[NextAssignTo] [nvarchar](100) NULL,
	[BAreaUser] [nvarchar](4) NULL
) ON [PRIMARY]
GO
