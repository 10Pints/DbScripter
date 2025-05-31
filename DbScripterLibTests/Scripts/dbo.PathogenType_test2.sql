IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenType_test2]') AND type in (N'U'))
    DROP TABLE[dbo].[PathogenType_test2];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenType_test2]') AND type in (N'U'))
DROP TABLE [dbo].[PathogenType_test2]
GO
