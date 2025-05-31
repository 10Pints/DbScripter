IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CropPathogen]') AND type in (N'U'))
    DROP Table[dbo].[CropPathogen];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CropPathogen]') AND type in (N'U'))
DROP TABLE [dbo].[CropPathogen]
GO
