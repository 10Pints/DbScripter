IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[ChemicalStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalStaging]') AND type in (N'U'))
DROP TABLE [dbo].[ChemicalStaging]
GO
