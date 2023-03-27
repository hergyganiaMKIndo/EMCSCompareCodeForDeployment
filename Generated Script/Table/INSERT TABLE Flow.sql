SET IDENTITY_INSERT [dbo].[Flow] ON 

INSERT [dbo].[Flow] ([Id], [Name], [Type], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete]) VALUES (17, N'PebNpe', N'', N'System', CAST(N'2022-10-21T10:40:00' AS SmallDateTime), NULL, NULL, 0)
SET IDENTITY_INSERT [dbo].[Flow] OFF

SET IDENTITY_INSERT [dbo].[FlowNext] ON 

INSERT [dbo].[FlowNext] ([Id], [IdStatus], [IdStep], [CreateDate], [CreateBy], [UpdateDate], [UpdateBy], [IsDelete]) VALUES (40125, 40151, 30074, CAST(N'2022-10-11T15:04:00' AS SmallDateTime), N'System', CAST(N'2022-10-11T15:04:00' AS SmallDateTime), N'System', 0)
INSERT [dbo].[FlowNext] ([Id], [IdStatus], [IdStep], [CreateDate], [CreateBy], [UpdateDate], [UpdateBy], [IsDelete]) VALUES (40126, 40152, 30075, CAST(N'2022-10-11T15:04:00' AS SmallDateTime), N'System', CAST(N'2022-10-11T15:04:00' AS SmallDateTime), N'System', 0)
INSERT [dbo].[FlowNext] ([Id], [IdStatus], [IdStep], [CreateDate], [CreateBy], [UpdateDate], [UpdateBy], [IsDelete]) VALUES (40127, 40153, 30076, CAST(N'2022-10-11T15:04:00' AS SmallDateTime), N'System', CAST(N'2022-10-11T15:04:00' AS SmallDateTime), N'System', 0)
INSERT [dbo].[FlowNext] ([Id], [IdStatus], [IdStep], [CreateDate], [CreateBy], [UpdateDate], [UpdateBy], [IsDelete]) VALUES (40129, 40146, 30072, CAST(N'2022-10-11T15:04:00' AS SmallDateTime), N'System', CAST(N'2022-10-11T15:04:00' AS SmallDateTime), N'System', 0)
SET IDENTITY_INSERT [dbo].[FlowNext] OFF

SET IDENTITY_INSERT [dbo].[FlowStatus] ON 

INSERT [dbo].[FlowStatus] ([Id], [IdStep], [Status], [ViewByUser], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete]) VALUES (40151, 30074, N'CancelRequest', N'Request Cancel', N'System', CAST(N'2022-10-21T10:48:00' AS SmallDateTime), NULL, NULL, 0)
INSERT [dbo].[FlowStatus] ([Id], [IdStep], [Status], [ViewByUser], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete]) VALUES (40152, 30075, N'CancelApproval', N'waiting for beacukai approval', N'System', CAST(N'2022-10-21T10:48:00' AS SmallDateTime), NULL, NULL, 0)
INSERT [dbo].[FlowStatus] ([Id], [IdStep], [Status], [ViewByUser], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete]) VALUES (40153, 30076, N'Cancel', N'Cancelled', N'System', CAST(N'2022-10-21T10:48:00' AS SmallDateTime), NULL, NULL, 0)
SET IDENTITY_INSERT [dbo].[FlowStatus] OFF

UPDATE	FlowStep
SET		AssignType = 'Group',
		AssignTo = 'Import Export'
WHERE	Id = 10021

UPDATE	FlowStep
SET		AssignTo = 'Import Export'
WHERE	Id = 30071

UPDATE	FlowStep
SET		AssignTo = 'Import Export'
WHERE	Id = 30072

SET IDENTITY_INSERT [dbo].[FlowStep] ON 
INSERT [dbo].[FlowStep] ([Id], [IdFlow], [Step], [AssignType], [AssignTo], [Sort], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete]) VALUES (30074, 4, N'CancelRequest', N'Group', N'', 0, N'System', CAST(N'2022-10-21T11:11:00' AS SmallDateTime), NULL, NULL, 0)
INSERT [dbo].[FlowStep] ([Id], [IdFlow], [Step], [AssignType], [AssignTo], [Sort], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete]) VALUES (30075, 4, N'CancelApproval', N'Group', N'', 0, N'System', CAST(N'2022-10-21T11:11:00' AS SmallDateTime), NULL, NULL, 0)
INSERT [dbo].[FlowStep] ([Id], [IdFlow], [Step], [AssignType], [AssignTo], [Sort], [CreateBy], [CreateDate], [UpdateBy], [UpdateDate], [IsDelete]) VALUES (30076, 4, N'Cancel', N'Group', N'', 0, N'System', CAST(N'2022-10-21T11:11:00' AS SmallDateTime), NULL, NULL, 0)
SET IDENTITY_INSERT [dbo].[FlowStep] OFF