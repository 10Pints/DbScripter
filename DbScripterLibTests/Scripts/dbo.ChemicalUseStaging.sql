IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalUseStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[ChemicalUseStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalUseStaging]') AND type in (N'U'))
DROP TABLE [dbo].[ChemicalUseStaging]
GO
