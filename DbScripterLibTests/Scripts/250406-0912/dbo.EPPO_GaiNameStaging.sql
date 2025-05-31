IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GaiNameStaging]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_GaiNameStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GaiNameStaging]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_GaiNameStaging]
GO
