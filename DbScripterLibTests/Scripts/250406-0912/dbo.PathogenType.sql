IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenType]') AND type in (N'U'))
    DROP Table[dbo].[PathogenType];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PathogenType]') AND type in (N'U'))
DROP TABLE [dbo].[PathogenType]
GO
