IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CropStaging]') AND type in (N'U'))
    DROP Table[dbo].[CropStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CropStaging]') AND type in (N'U'))
DROP TABLE [dbo].[CropStaging]
GO
