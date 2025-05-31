IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalAction]') AND type in (N'U'))
    DROP TABLE[dbo].[ChemicalAction];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChemicalAction]') AND type in (N'U'))
DROP TABLE [dbo].[ChemicalAction]
GO
