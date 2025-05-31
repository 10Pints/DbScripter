IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductUseStaging]') AND type in (N'U'))
    DROP Table[dbo].[ProductUseStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductUseStaging]') AND type in (N'U'))
DROP TABLE [dbo].[ProductUseStaging]
GO
