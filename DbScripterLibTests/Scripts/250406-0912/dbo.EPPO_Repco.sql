IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_Repco]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_Repco];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_Repco]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_Repco]
GO
