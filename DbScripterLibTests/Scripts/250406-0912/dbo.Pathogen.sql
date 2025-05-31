IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pathogen]') AND type in (N'U'))
    DROP Table[dbo].[Pathogen];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pathogen]') AND type in (N'U'))
DROP TABLE [dbo].[Pathogen]
GO
