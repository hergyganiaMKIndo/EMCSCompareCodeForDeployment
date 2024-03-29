USE [EMCS]
GO
/****** Object:  Table [dbo].[Temptable_gr_request_list_all]    Script Date: 10/03/2023 11:40:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temptable_gr_request_list_all](
	[Id] [bigint] NOT NULL,
	[IdGr] [nvarchar](20) NOT NULL,
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
	[GrNo] [nvarchar](20) NULL,
	[PicName] [nvarchar](100) NOT NULL,
	[PhoneNumber] [nvarchar](100) NULL,
	[SimNumber] [nvarchar](100) NULL,
	[StnkNumber] [nvarchar](100) NULL,
	[NopolNumber] [nvarchar](100) NULL,
	[EstimationTimePickup] [smalldatetime] NULL,
	[AssignmentType] [nvarchar](100) NULL,
	[NextAssignTo] [nvarchar](100) NULL
) ON [PRIMARY]
GO
