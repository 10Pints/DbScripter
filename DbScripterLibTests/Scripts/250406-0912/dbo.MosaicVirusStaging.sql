IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MosaicVirusStaging]') AND type in (N'U'))
    DROP Table[dbo].[MosaicVirusStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MosaicVirusStaging]') AND type in (N'U'))
DROP TABLE [dbo].[MosaicVirusStaging]
GO
