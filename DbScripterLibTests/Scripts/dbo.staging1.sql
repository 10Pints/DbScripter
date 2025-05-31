IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging1]') AND type in (N'U'))
    DROP TABLE[dbo].[staging1];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging1]') AND type in (N'U'))
DROP TABLE [dbo].[staging1]
GO
