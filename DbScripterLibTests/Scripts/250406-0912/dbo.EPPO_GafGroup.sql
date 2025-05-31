IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GafGroup]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_GafGroup];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_GafGroup]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_GafGroup]
GO
