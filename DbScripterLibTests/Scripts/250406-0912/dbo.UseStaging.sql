IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UseStaging]') AND type in (N'U'))
    DROP Table[dbo].[UseStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UseStaging]') AND type in (N'U'))
DROP TABLE [dbo].[UseStaging]
GO
