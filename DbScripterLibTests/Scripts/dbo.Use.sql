IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Use]') AND type in (N'U'))
    DROP TABLE[dbo].[Use];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Use]') AND type in (N'U'))
DROP TABLE [dbo].[Use]
GO
