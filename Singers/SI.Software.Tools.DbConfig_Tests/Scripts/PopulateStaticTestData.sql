-- PopulateDbConfigStaticData.sql
USE [<DB_NAME>]
GO
SET IDENTITY_INSERT [dbo].[LogType] ON 
GO
INSERT [dbo].[LogType] ([id], [name]) VALUES (3, N'Error')
GO
INSERT [dbo].[LogType] ([id], [name]) VALUES (4, N'Fatal')
GO
INSERT [dbo].[LogType] ([id], [name]) VALUES (1, N'Information')
GO
INSERT [dbo].[LogType] ([id], [name]) VALUES (2, N'Warning')
GO
SET IDENTITY_INSERT [dbo].[LogType] OFF
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1001, N'Plate Guides Not Found', 4, N'C0', N'The plate guides could not be found. Please ensure a plate holder is installed and that the guides are clean and visible.', N'Ensure that the plate guide is installed, and that the guidelines are free from dirt and debris.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1002, N'No Plate Detected', 4, N'C1', N'No plate was detected.', N'Ensure a plate is loaded. Ensure the ultrasonic sensor is calibrated correctly..')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1003, N'Movement Failed To Start', 4, N'R0', N'A movement failed to start.', N'Ensure there is no error on any drive. To do this check on the Festo web visualisation, check the error bit is low. If the error bit is high use the ‘Diagnosis’ tab to find the error code and drive. Check the position of the move is within the limits of the system.Check the connection to the device is active, and the device is powered up.Check the speed, acceleration and deceleration of the movement are not 0.If this occurs on a liquid mix, ensure the radius of the mix is not 0.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1004, N'Movement Failed To Complete', 4, N'R1', N'A movement failed to complete.', N'Ensure there is no error on any drive. To do this check on the Festo web visualisation, check the error bit is low. If the error bit is high use the ‘Diagnosis’ tab to find the error code and drive.Check the position of the move is within the limits of the system.Check the connection to the device is active, and the device is powered up.Check the speed, acceleration and deceleration of the movement are not 0.If this occurs on a liquid mix, ensure the radius of the mix is not 0.Check that the door wasn’t pulled open.If initialising check the both the filament feed and cleaver drive aren’t obstructed or jammed. Manually move both while the system is disabled to check they are clear to move.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1005, N'Movement Failed To Abort', 4, N'R2', N'A movement failed to abort.', N'Check the position of the move is within the limits of the system.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1006, N'Door Opened', 4, N'R3', N'The door was opened during operation.', N'Check the connection to the device is active, and the device is powered up.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1007, N'Nozzle Collision', 4, N'R4', N'The nozzle collided with an object.', N'Check for obstructions that could have resulted in a physical crash.Check the print head solenoid is functioning correctly, holding the nozzle in place.If over the cleaver check the cleaver is open and that filament hasn’t failed to cleave, which could result in print head rising as filament is ejected.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1008, N'Surface Not Found', 4, N'R5', N'The surface could not be found.', N'Check the movement began.Check the print head input is functioning correctly. Check there is a surface to connect with.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1009, N'Sensor Not Found', 4, N'R6', N'The sensor could not be found.', N'ECheck the movement began.Check the input is functioning correctly.If an optical sensor ensure that it is not dirty.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1010, N'Temperature not Achieved', 4, N'R7', N'The desired temperature could not be achieved.', N'Ensure thermistor is functioning correctly.Ensure output is being engaged to engage the filament heater.Ensure the thermal fuse has not blown.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1011, N'Thermal Fuse Error', 4, N'R8', N'The thermal fuse is damaged.', N'Ensure the thermal fuse has not blown.Ensure input on controller is functioning.Ensure there isn’t a short between the thermal fuse and ground.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1012, N'Movement Not Supported', 4, N'R9', N'The requested movement was not supported.', N'Ensure the controller is capable of performing the requested move. The movement that was requested will be available in the log file.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1013, N'Task Failed To Complete', 4, N'R10', N'A task failed to complete before a timeout was reached.', N'Ensure communication between devices is active.If the task was moving a drive ensure that the drive hasn’t stalled, and that there is no error present on the drive or controller.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1014, N'Cleaver Could Not Close', 4, N'R11', N'The cleaver failed to meet the target position.', N'Check there is no obstruction such as off cuts.Check the motor is not faulty.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1015, N'Cleaver Could Not Open', 4, N'R12', N'The cleaver failed to meet the target position.', N'Check there is no obstruction such as off cuts.Check the motor is not faulty.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1016, N'Nozzle Not Detected', 4, N'R13', N'The nozzle could not be detected.', N'Check the nozzle is attached and that the sensor detecting it is functioning correctly. If this is a calibration bay sensor, ensure the sensitivity is set correctly.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1017, N'An unknown error.', 4, N'U0', N'An unknown error.', N'Hard to say!')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1018, N'Connection Error', 4, N'U1', N'The PIXL is not connected.', N'Check connection is active. Check the error LED on the CECC isn’t lit, which could be a runtime error in the embedded software.Check the camera is connected, and check it is present in device manager without any errors.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1019, N'Power Cycle Required', 4, N'U2', N'A power cycle is required. Please shut down the PIXL and retry.', N'Ensure there is no runtime on the CECC - check the error LED.Ensure CAN and EtherCAT bus are up and functioning correctly.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1020, N'Hardware Set-up Failed', 4, N'U3', N'An attached piece of hardware could not be set-up.', N'This depends very much on the hardware that failed. Check it is powered up and communicating with the software.Reset all hardware and software to determine if the problem persists.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1021, N'Hardware Reset Failed', 4, N'U4', N'An attached piece of hardware could not be reset.', N'This depends very much on the hardware that failed. Check it is powered up and communicating with the software.Reset all hardware and software to determine if the problem persists.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1022, N'Hardware Not Connected', 4, N'U5', N'An attached piece of hardware was not connected.', N'Check the input that was entered in the context of the entry. See log for more details.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1023, N'Invalid Input', 4, N'U6', N'The input was invalid.', N'Check the print head input is functioning correctly.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1024, N'Invalid Hardware Input Or Output', 4, N'U7', N'Hardware input or output was invalid.', N'Ensure the index of the input/output was correct and in range.Ensure the value returned from the input or set to the output was scaled correctly.')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (1025, N'Firmware Update Failed', 4, N'U8', N'Updating the firmware has failed.', N'Ensure firmware file is valid. Ensure the path to the firmware file is valid, if applicable.Ensure the device is powered up and not in an error state.Ensure the connection to the device is correctly established')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (2000, N'Plate Guides Not Found (Ph)', 4, N'PH0', N'The plate guides could not be found. Please ensure a plate holder is installed and that the guides are clean and visible.', N'<TBA>')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (2001, N'Camera Not Ready', 4, N'PH1', N'The camera was not ready.', N'<TBA>')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (2002, N'Tray Crash', 4, N'PH2', N'The tray crashed.', N'<TBA>')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (3000, N'MSM Error 1', 4, N'MSM', N'<TBA>', N'<TBA>')
GO
INSERT [dbo].[EventType] ([id], [name], [log_type], [code], [description], [remedy]) VALUES (4000, N'Rotor Error 1', 4, N'ROT0', N'<TBA>', N'<TBA>')
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (1, N'All', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (2, N'Company', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (3, N'LabCube', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (4, N'Phenobooth 1', 1)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (5, N'Pixl', 1)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (6, N'Cleaver', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (7, N'Gantry', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (8, N'Filament Feed', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (9, N'Calibration Station', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (10, N'Pixl Lighting', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (11, N'UV Lighting', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (12, N'LED Lighting System', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (13, N'Pixl Camera', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (15, N'Phenobooth Camera', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (16, N'Tray', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (17, N'Phenobooth Lighting', 0)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (18, N'MSM', 1)
GO
INSERT [dbo].[NodeType] ([id], [name], [is_machine]) VALUES (19, N'Rotor', 1)
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (1, N'°C')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (9, N'°F')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (14, N'amps')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (18, N'Angle °')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (5, N'cm')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (2, N'gm')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (8, N'gm/cm2')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (13, N'Hr')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (3, N'kg')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (7, N'kg/m2')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (6, N'm')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (15, N'milliamps')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (12, N'millisec')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (17, N'millivolts')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (4, N'mm')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (10, N'PSI')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (11, N'sec')
GO
INSERT [dbo].[Unit] ([id], [name]) VALUES (16, N'volts')
GO
INSERT [dbo].[PropertyType] ([id], [name], [unit]) VALUES (1, N'Temperature', 1)
GO
INSERT [dbo].[PropertyType] ([id], [name], [unit]) VALUES (2, N'Timeout', 12)
GO
INSERT [dbo].[PropertyType] ([id], [name], [unit]) VALUES (3, N'Current (A)', 14)
GO
INSERT [dbo].[PropertyType] ([id], [name], [unit]) VALUES (4, N'Current (mA)', 15)
GO
INSERT [dbo].[PropertyType] ([id], [name], [unit]) VALUES (5, N'Voltage', 16)
GO
INSERT [dbo].[PropertyType] ([id], [name], [unit]) VALUES (6, N'Filament Heater Temperature', 1)
GO
INSERT [dbo].[PropertyType] ([id], [name], [unit]) VALUES (7, N'Ambient Temperature', 1)
GO
INSERT [dbo].[PropertyType] ([id], [name], [unit]) VALUES (8, N'Filament Distance', 4)
GO
INSERT [dbo].[PropertyType] ([id], [name], [unit]) VALUES (9, N'Position', 4)
GO
SET IDENTITY_INSERT [dbo].[Property] ON 
GO
SET IDENTITY_INSERT [dbo].[ET2PT] ON 
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (2, 1001, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (41, 1001, 7)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (3, 1002, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (22, 1004, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (9, 1007, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (8, 1008, 4)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (11, 1008, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (13, 1009, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (14, 1010, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (15, 1010, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (16, 1011, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (1, 1011, 3)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (17, 1011, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (18, 1012, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (19, 1012, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (20, 1013, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (21, 1013, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (23, 1015, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (24, 1016, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (46, 1016, 7)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (25, 1017, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (26, 1018, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (42, 1018, 3)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (27, 1019, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (28, 1020, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (29, 1021, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (30, 1022, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (31, 1023, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (32, 1024, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (33, 1025, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (34, 2000, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (35, 2001, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (49, 2001, 9)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (36, 2002, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (37, 2002, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (38, 3000, 1)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (39, 3000, 5)
GO
INSERT [dbo].[ET2PT] ([id], [event_type], [property_type]) VALUES (40, 4000, 5)
GO
SET IDENTITY_INSERT [dbo].[ET2PT] OFF
GO
SET IDENTITY_INSERT [dbo].[PNT2CNT] ON 
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (1, 1, 2)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (2, 2, 3)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (3, 3, 4)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (4, 3, 5)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (5, 3, 18)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (6, 5, 6)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (7, 5, 7)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (8, 5, 8)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (9, 5, 9)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (10, 5, 10)
GO
INSERT [dbo].[PNT2CNT] ([id], [parent_type], [child_type]) VALUES (11, 5, 13)
GO
SET IDENTITY_INSERT [dbo].[PNT2CNT] OFF
GO
