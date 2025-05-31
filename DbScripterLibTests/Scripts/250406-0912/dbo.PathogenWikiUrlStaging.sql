IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenWikiUrlStaging]') AND type in (N'U'))
    DROP Table[dbo].[PathogenWikiUrlStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenWikiUrlStaging]') AND type in (N'U'))
DROP TABLE [dbo].[PathogenWikiUrlStaging]
GO
