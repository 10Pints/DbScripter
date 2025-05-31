IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GafGroupStaging]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_GafGroupStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GafGroupStaging]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_GafGroupStaging]
GO
