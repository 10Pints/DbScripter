IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Import]') AND type in (N'U'))
    DROP Table[dbo].[Import];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Import]') AND type in (N'U'))
DROP TABLE [dbo].[Import]
GO
