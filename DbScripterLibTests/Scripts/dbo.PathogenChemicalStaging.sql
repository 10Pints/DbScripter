IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenChemicalStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[PathogenChemicalStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenChemicalStaging]') AND type in (N'U'))
DROP TABLE [dbo].[PathogenChemicalStaging]
GO
