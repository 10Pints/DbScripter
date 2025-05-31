IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging1_bak]') AND type in (N'U'))
    DROP Table[dbo].[staging1_bak];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging1_bak]') AND type in (N'U'))
DROP TABLE [dbo].[staging1_bak]
GO
