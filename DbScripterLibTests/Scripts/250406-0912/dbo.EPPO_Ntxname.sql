IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_Ntxname]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_Ntxname];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_Ntxname]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_Ntxname]
GO
