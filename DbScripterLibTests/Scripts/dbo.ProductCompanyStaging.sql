IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductCompanyStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[ProductCompanyStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProductCompanyStaging]') AND type in (N'U'))
DROP TABLE [dbo].[ProductCompanyStaging]
GO
