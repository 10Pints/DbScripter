IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_NtxNameStaging]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_NtxNameStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_NtxNameStaging]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_NtxNameStaging]
GO
