IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_NtxLinkStaging]') AND type in (N'U'))
    DROP Table[dbo].[EPPO_NtxLinkStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO_NtxLinkStaging]') AND type in (N'U'))
DROP TABLE [dbo].[EPPO_NtxLinkStaging]
GO
