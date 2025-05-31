IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CorrectionLog]') AND type in (N'U'))
    DROP Table[dbo].[CorrectionLog];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CorrectionLog]') AND type in (N'U'))
DROP TABLE [dbo].[CorrectionLog]
GO
