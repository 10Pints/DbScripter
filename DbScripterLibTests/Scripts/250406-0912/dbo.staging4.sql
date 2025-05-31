IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging4]') AND type in (N'U'))
    DROP Table[dbo].[staging4];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging4]') AND type in (N'U'))
DROP TABLE [dbo].[staging4]
GO
