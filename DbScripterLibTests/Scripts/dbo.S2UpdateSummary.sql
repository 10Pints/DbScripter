IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[S2UpdateSummary]') AND type in (N'U'))
    DROP TABLE[dbo].[S2UpdateSummary];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[S2UpdateSummary]') AND type in (N'U'))
DROP TABLE [dbo].[S2UpdateSummary]
GO
