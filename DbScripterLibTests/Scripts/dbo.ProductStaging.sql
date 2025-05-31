IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[ProductStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductStaging]') AND type in (N'U'))
DROP TABLE [dbo].[ProductStaging]
GO
