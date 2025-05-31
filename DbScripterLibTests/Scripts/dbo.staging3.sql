IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging3]') AND type in (N'U'))
    DROP TABLE[dbo].[staging3];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[staging3]') AND type in (N'U'))
DROP TABLE [dbo].[staging3]
GO
