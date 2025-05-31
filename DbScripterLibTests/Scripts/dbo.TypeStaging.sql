IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TypeStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[TypeStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TypeStaging]') AND type in (N'U'))
DROP TABLE [dbo].[TypeStaging]
GO
