IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GafNameStaging]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_GafNameStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GafNameStaging]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_GafNameStaging]
GO
