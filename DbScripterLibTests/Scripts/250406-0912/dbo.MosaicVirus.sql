IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MosaicVirus]') AND type in (N'U'))
    DROP Table[dbo].[MosaicVirus];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MosaicVirus]') AND type in (N'U'))
DROP TABLE [dbo].[MosaicVirus]
GO
