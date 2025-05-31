IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_PflGroupStaging]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_PflGroupStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_PflGroupStaging]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_PflGroupStaging]
GO
