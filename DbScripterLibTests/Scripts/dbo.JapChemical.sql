IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[JapChemical]') AND type in (N'U'))
    DROP TABLE[dbo].[JapChemical];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[JapChemical]') AND type in (N'U'))
DROP TABLE [dbo].[JapChemical]
GO
