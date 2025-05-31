IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Chemical]') AND type in (N'U'))
    DROP TABLE[dbo].[Chemical];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Chemical]') AND type in (N'U'))
DROP TABLE [dbo].[Chemical]
GO
