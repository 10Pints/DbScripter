IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenChemical]') AND type in (N'U'))
    DROP Table[dbo].[PathogenChemical];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenChemical]') AND type in (N'U'))
DROP TABLE [dbo].[PathogenChemical]
GO
