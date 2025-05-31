IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalProductStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[ChemicalProductStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalProductStaging]') AND type in (N'U'))
DROP TABLE [dbo].[ChemicalProductStaging]
GO
