IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_PflLinkStaging]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_PflLinkStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_PflLinkStaging]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_PflLinkStaging]
GO
