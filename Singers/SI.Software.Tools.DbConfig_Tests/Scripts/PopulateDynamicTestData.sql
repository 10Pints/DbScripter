-- PopulateDbConfigDynamicTestData.sql
USE [<DB_NAME>]
GO

INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'10000000-9b0f-4026-a192-2c27287b18ea', N'All Data', 1, NULL)
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'10000001-9b0f-4026-a192-2c27287b18ea', N'Company 1', 2, N'10000000-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'10000002-9b0f-4026-a192-2c27287b18ea', N'Company 2', 2, N'10000000-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'11601798-9b0f-4026-a192-2c27287b18ea', N'Phenobooth Camera 1.1.1', 15, N'1160a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'21601798-9b0f-4026-a192-2c27287b18ea', N'Phenobooth Camera 2.1.1', 15, N'2160a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'11141a98-9b0f-4026-a192-2c27287b18ea', N'UV Lighting 1.1.1.1', 11, N'1114a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'12141a98-9b0f-4026-a192-2c27287b18ea', N'UV Lighting 1.2.1.1', 11, N'1214a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'21141a98-9b0f-4026-a192-2c27287b18ea', N'UV Lighting 2.1.1.1', 11, N'2114a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'11602798-9b0f-4026-a192-2c27287b18ea', N'Tray 1.1.1', 16, N'1160a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'21602798-9b0f-4026-a192-2c27287b18ea', N'Tray 2.1.1', 16, N'2160a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'11142b98-9b0f-4026-a192-2c27287b18ea', N'LED Lighting System 1.1.1.1', 12, N'1114a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'12142b98-9b0f-4026-a192-2c27287b18ea', N'LED Lighting System 1.2.1.1', 12, N'1214a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'21142b98-9b0f-4026-a192-2c27287b18ea', N'LED Lighting System 2.1.1.1', 12, N'2114a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'11603798-9b0f-4026-a192-2c27287b18ea', N'Phenobooth Lighting 1.1.1', 17, N'1160a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'21603798-9b0f-4026-a192-2c27287b18ea', N'Phenobooth Lighting 2.1.1', 17, N'2160a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'21604798-9b0f-4026-a192-2c27287b18ea', N'MSM 2.1', 18, N'2000a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1000a798-9b0f-4026-a192-2c27287b18ea', N'LabCube 1', 3, N'10000001-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1100a798-9b0f-4026-a192-2c27287b18ea', N'Pixl 1.1', 5, N'1000a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1200a798-9b0f-4026-a192-2c27287b18ea', N'Pixl 1.2', 5, N'1000a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'2000a798-9b0f-4026-a192-2c27287b18ea', N'LabCube 2', 3, N'10000002-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'2100a798-9b0f-4026-a192-2c27287b18ea', N'Pixl 2.1', 5, N'2000a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1110a798-9b0f-4026-a192-2c27287b18ea', N'Cleaver 1.1.1', 6, N'1100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1210a798-9b0f-4026-a192-2c27287b18ea', N'Cleaver 1.2.1', 6, N'1200a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'2110a798-9b0f-4026-a192-2c27287b18ea', N'Cleaver 2.1.1', 6, N'2100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1111a798-9b0f-4026-a192-2c27287b18ea', N'Gantry 1.1.1', 7, N'1100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1211a798-9b0f-4026-a192-2c27287b18ea', N'Gantry 1.2.1', 7, N'1200a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'2111a798-9b0f-4026-a192-2c27287b18ea', N'Gantry 2.1.1', 7, N'2100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1112a798-9b0f-4026-a192-2c27287b18ea', N'Filament Feed 1.1.1', 8, N'1100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1212a798-9b0f-4026-a192-2c27287b18ea', N'Filament Feed 1.2.1', 8, N'1200a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'2112a798-9b0f-4026-a192-2c27287b18ea', N'Filament Feed 2.1.1', 8, N'2100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1113a798-9b0f-4026-a192-2c27287b18ea', N'Calibration Station 1.1.1', 9, N'1100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1213a798-9b0f-4026-a192-2c27287b18ea', N'Calibration Station 1.2.1', 9, N'1200a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'2113a798-9b0f-4026-a192-2c27287b18ea', N'Calibration Station 2.1.1', 9, N'2100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1114a798-9b0f-4026-a192-2c27287b18ea', N'Lighting 1.1.1', 10, N'1100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1214a798-9b0f-4026-a192-2c27287b18ea', N'Lighting 1.2.1', 10, N'1200a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'2114a798-9b0f-4026-a192-2c27287b18ea', N'Lighting 2.1.1', 10, N'2100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1150a798-9b0f-4026-a192-2c27287b18ea', N'Camera 1.1.1', 13, N'1100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1250a798-9b0f-4026-a192-2c27287b18ea', N'Camera 1.2.1', 13, N'1200a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'2150a798-9b0f-4026-a192-2c27287b18ea', N'Camera 2.1.1', 13, N'2100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1160a798-9b0f-4026-a192-2c27287b18ea', N'Phenobooth 1.1', 4, N'1000a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'2160a798-9b0f-4026-a192-2c27287b18ea', N'Phenobooth 2.1', 4, N'2000a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Node] ([id], [name], [node_type], [parent]) VALUES (N'1170a798-9b0f-4026-a192-2c27287b18ea', N'Rotor 1.1', 19, N'1000a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[User] ([id], [name]) VALUES (N'8f09a892-f44a-437c-9662-9d8ed125d5c9', N'Ben')
GO
INSERT [dbo].[User] ([id], [name]) VALUES (N'84ecd65c-004f-4a06-a336-3f7abedfecca', N'Ellie')
GO
INSERT [dbo].[User] ([id], [name]) VALUES (N'601b85e0-7c2e-468b-b09c-c58d9f50c4f6', N'Harry')
GO
INSERT [dbo].[User] ([id], [name]) VALUES (N'a0beb644-943d-4522-b54e-4d42897b57d6', N'Josh')
GO
INSERT [dbo].[User] ([id], [name]) VALUES (N'0a28651f-533c-43f9-b649-bd5b4c0f12bb', N'Nick')
GO
INSERT [dbo].[User] ([id], [name]) VALUES (N'14776eb3-1a26-4d72-bab2-f46ee04c6191', N'Terry')
GO
INSERT [dbo].[Project] ([id], [name], [user], [top_level_node], [Notes]) VALUES (N'a0123456-1234-5678-9000-123412341234', N'LabCube 1 Run 1', N'8f09a892-f44a-437c-9662-9d8ed125d5c9', N'1000a798-9b0f-4026-a192-2c27287b18ea', N'Test Notes 1')
GO
INSERT [dbo].[Project] ([id], [name], [user], [top_level_node], [Notes]) VALUES (N'c389666a-8772-48b8-bb86-81f8c397e8b4', N'LabCube 2 Run 2', N'8f09a892-f44a-437c-9662-9d8ed125d5c9', N'2000a798-9b0f-4026-a192-2c27287b18ea', N'Test Notes 2')
GO
INSERT [dbo].[Project] ([id], [name], [user], [top_level_node], [Notes]) VALUES (N'0a28651f-533c-43f9-b649-bd5b4c0f12db', N'Pixl 1.1 Run 3', N'0a28651f-533c-43f9-b649-bd5b4c0f12bb', N'1100a798-9b0f-4026-a192-2c27287b18ea', N'Test Notes 3')
GO
SET IDENTITY_INSERT [dbo].[Event] ON 
GO
INSERT [dbo].[Event] ([id], [event_type], [time], [project], [message], [node]) VALUES (10, 1001, CAST(N'2018-08-24T10:05:04.000' AS DateTime), N'a0123456-1234-5678-9000-123412341234', N'Test message 1', N'1111a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Event] ([id], [event_type], [time], [project], [message], [node]) VALUES (11, 1002, CAST(N'2018-08-25T10:05:04.000' AS DateTime), N'a0123456-1234-5678-9000-123412341234', N'Test message 2', N'1212a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Event] ([id], [event_type], [time], [project], [message], [node]) VALUES (12, 1003, CAST(N'2018-08-26T10:05:04.000' AS DateTime), N'a0123456-1234-5678-9000-123412341234', N'Test message 3', N'1210a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Event] ([id], [event_type], [time], [project], [message], [node]) VALUES (13, 1004, CAST(N'2018-08-27T10:05:04.000' AS DateTime), N'a0123456-1234-5678-9000-123412341234', N'Test message 4', N'11603798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Event] ([id], [event_type], [time], [project], [message], [node]) VALUES (14, 1005, CAST(N'2018-08-28T10:05:04.000' AS DateTime), N'a0123456-1234-5678-9000-123412341234', N'Test message 5', N'1170a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Event] ([id], [event_type], [time], [project], [message], [node]) VALUES (15, 1006, CAST(N'2018-08-29T09:05:04.000' AS DateTime), N'a0123456-1234-5678-9000-123412341234', N'Test message 6', N'2100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Event] ([id], [event_type], [time], [project], [message], [node]) VALUES (16, 1007, CAST(N'2018-08-30T10:05:04.000' AS DateTime), N'a0123456-1234-5678-9000-123412341234', N'Test message 7', N'2111a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Event] ([id], [event_type], [time], [project], [message], [node]) VALUES (17, 1008, CAST(N'2018-08-30T11:05:04.000' AS DateTime), N'a0123456-1234-5678-9000-123412341234', N'Test message 8', N'2100a798-9b0f-4026-a192-2c27287b18ea')
GO
INSERT [dbo].[Event] ([id], [event_type], [time], [project], [message], [node]) VALUES (18, 1009, CAST(N'2018-08-30T12:05:04.000' AS DateTime), N'a0123456-1234-5678-9000-123412341234', N'Test message 9', N'2160a798-9b0f-4026-a192-2c27287b18ea')
GO
SET IDENTITY_INSERT [dbo].[Event] OFF
GO

SET IDENTITY_INSERT [dbo].[Property] ON 
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (19, 1, 10, N'136.1')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (20, 5, 10, N'24.2 ')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (21, 5, 11, N'24.2 ')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (22, 1, 11, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (23, 3, 12, N'24.2 ')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (24, 6, 12, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (25, 8, 12, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (26, 9, 13, N'24.2 ')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (27, 2, 13, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (28, 8, 13, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (29, 1, 13, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (30, 5, 14, N'24.2 ')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (31, 1, 14, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (32, 5, 15, N'24.2 ')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (33, 1, 15, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (34, 2, 15, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (35, 4, 15, N'54')
GO
INSERT [dbo].[Property] ([id], [property_type], [event], [value]) VALUES (36, 6, 15, N'54')
GO
SET IDENTITY_INSERT [dbo].[Property] OFF
GO

