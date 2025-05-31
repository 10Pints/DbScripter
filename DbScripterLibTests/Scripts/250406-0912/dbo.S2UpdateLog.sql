IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[S2UpdateLog]') AND type in (N'U'))
    DROP Table[dbo].[S2UpdateLog];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[S2UpdateLog]') AND type in (N'U'))
DROP TABLE [dbo].[S2UpdateLog]
GO
