IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FertHandler]') AND type in (N'U'))
    DROP Table[dbo].[FertHandler];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FertHandler]') AND type in (N'U'))
DROP TABLE [dbo].[FertHandler]
GO
