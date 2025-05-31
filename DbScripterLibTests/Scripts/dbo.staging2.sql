IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging2]') AND type in (N'U'))
    DROP TABLE[dbo].[staging2];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging2]') AND type in (N'U'))
DROP TABLE [dbo].[staging2]
GO
