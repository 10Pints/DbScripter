IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CropStaging_Test]') AND type in (N'U'))
    DROP Table[dbo].[CropStaging_Test];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CropStaging_Test]') AND type in (N'U'))
DROP TABLE [dbo].[CropStaging_Test]
GO
