IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GaiLinkStaging]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_GaiLinkStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GaiLinkStaging]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_GaiLinkStaging]
GO
