IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenTypeStaging]') AND type in (N'U'))
    DROP Table[dbo].[PathogenTypeStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenTypeStaging]') AND type in (N'U'))
DROP TABLE [dbo].[PathogenTypeStaging]
GO
