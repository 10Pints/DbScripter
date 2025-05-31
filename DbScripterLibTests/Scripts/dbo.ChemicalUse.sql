IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalUse]') AND type in (N'U'))
    DROP TABLE[dbo].[ChemicalUse];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalUse]') AND type in (N'U'))
DROP TABLE [dbo].[ChemicalUse]
GO
