IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalActionStaging]') AND type in (N'U'))
    DROP Table[dbo].[ChemicalActionStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalActionStaging]') AND type in (N'U'))
DROP TABLE [dbo].[ChemicalActionStaging]
GO
