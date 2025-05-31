IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TableDef]') AND type in (N'U'))
    DROP Table[dbo].[TableDef];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TableDef]') AND type in (N'U'))
DROP TABLE [dbo].[TableDef]
GO
