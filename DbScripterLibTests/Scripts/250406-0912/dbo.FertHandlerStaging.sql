IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FertHandlerStaging]') AND type in (N'U'))
    DROP Table[dbo].[FertHandlerStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FertHandlerStaging]') AND type in (N'U'))
DROP TABLE [dbo].[FertHandlerStaging]
GO
