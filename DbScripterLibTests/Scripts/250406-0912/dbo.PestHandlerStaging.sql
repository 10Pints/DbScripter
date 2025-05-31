IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PestHandlerStaging]') AND type in (N'U'))
    DROP Table[dbo].[PestHandlerStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PestHandlerStaging]') AND type in (N'U'))
DROP TABLE [dbo].[PestHandlerStaging]
GO
