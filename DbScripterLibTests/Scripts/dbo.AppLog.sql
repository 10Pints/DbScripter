IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AppLog]') AND type in (N'U'))
    DROP TABLE[dbo].[AppLog];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AppLog]') AND type in (N'U'))
DROP TABLE [dbo].[AppLog]
GO
