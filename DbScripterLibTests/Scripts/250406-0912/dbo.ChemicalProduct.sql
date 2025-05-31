IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalProduct]') AND type in (N'U'))
    DROP Table[dbo].[ChemicalProduct];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalProduct]') AND type in (N'U'))
DROP TABLE [dbo].[ChemicalProduct]
GO
