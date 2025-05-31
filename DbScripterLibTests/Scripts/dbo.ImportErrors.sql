IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ImportErrors]') AND type in (N'U'))
    DROP TABLE[dbo].[ImportErrors];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ImportErrors]') AND type in (N'U'))
DROP TABLE [dbo].[ImportErrors]
GO
