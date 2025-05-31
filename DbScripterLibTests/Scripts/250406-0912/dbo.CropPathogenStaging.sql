IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CropPathogenStaging]') AND type in (N'U'))
    DROP Table[dbo].[CropPathogenStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CropPathogenStaging]') AND type in (N'U'))
DROP TABLE [dbo].[CropPathogenStaging]
GO
