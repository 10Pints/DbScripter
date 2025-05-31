/*
Parameters:

--------------------------------------------------------------------------------
 Type            : Params
--------------------------------------------------------------------------------
 CreateMode      : Create
 Database        : Dorsu_dev
 DisplayLog      : True
 DisplayScript   : True
 FilePath        : C:\bin\DbScripter\Dorsu_dev.cfg.json
 IndividualFiles : False
 Instance        : 
 IsExprtngData   : False
 LogFile         : D:\Logs\Dorsu_250522-0029.log
 LogLevel        : Info
 Name            : DbScripter-DORSU config
 RequiredSchemas : System.Collections.Generic.List`1[System.String]
 RequiredTypes   : System.Collections.Generic.List`1[DbScripterLibNS.SqlTypeEnum]
 Script Dir      : E:\Backups\iDrive\Dorsu\Db\Dorsu_dev\250522-0029
 Script File     : E:\Backups\iDrive\Dorsu\Db\Dorsu_dev\250522-0029\Dorsu.sql
 ScriptUseDb     : True
 Server          : DEVI9
 AddTimestamp    : True
 Timestamp       : 250522-0029

 RequiredSchemas : 2
	dbo
	test

 RequiredTypes : 8
	Schema
	Assembly
	Table
	Trigger
	Procedure
	Function
	View
	UserDefinedDataType
*/

USE [Dorsu_dev]
GO

CREATE SCHEMA [dbo]

GO
EXEC tSQLt.NewTestClass 'test';
