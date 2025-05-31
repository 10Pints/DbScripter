IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GaiGroup]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_GaiGroup];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GaiGroup]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_GaiGroup]
GO
