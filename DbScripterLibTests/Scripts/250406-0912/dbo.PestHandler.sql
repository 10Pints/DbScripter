IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PestHandler]') AND type in (N'U'))
    DROP Table[dbo].[PestHandler];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PestHandler]') AND type in (N'U'))
DROP TABLE [dbo].[PestHandler]
GO
