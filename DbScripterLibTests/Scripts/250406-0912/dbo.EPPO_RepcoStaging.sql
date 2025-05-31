IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_RepcoStaging]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_RepcoStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_RepcoStaging]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_RepcoStaging]
GO
