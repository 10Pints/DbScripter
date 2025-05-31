IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CorFiles]') AND type in (N'U'))
    DROP Table[dbo].[CorFiles];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CorFiles]') AND type in (N'U'))
DROP TABLE [dbo].[CorFiles]
GO
