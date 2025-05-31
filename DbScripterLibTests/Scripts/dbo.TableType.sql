IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TableType]') AND type in (N'U'))
    DROP TABLE[dbo].[TableType];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TableType]') AND type in (N'U'))
DROP TABLE [dbo].[TableType]
GO
