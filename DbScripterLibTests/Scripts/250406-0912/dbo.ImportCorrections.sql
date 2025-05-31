IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ImportCorrections]') AND type in (N'U'))
    DROP Table[dbo].[ImportCorrections];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ImportCorrections]') AND type in (N'U'))
DROP TABLE [dbo].[ImportCorrections]
GO
