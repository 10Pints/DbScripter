IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CompanyStaging]') AND type in (N'U'))
    DROP TABLE[dbo].[CompanyStaging];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CompanyStaging]') AND type in (N'U'))
DROP TABLE [dbo].[CompanyStaging]
GO
