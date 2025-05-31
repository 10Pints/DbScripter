IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmp]') AND type in (N'U'))
    DROP Table[dbo].[tmp];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmp]') AND type in (N'U'))
DROP TABLE [dbo].[tmp]
GO
