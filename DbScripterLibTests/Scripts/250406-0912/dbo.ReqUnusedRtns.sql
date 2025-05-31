IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReqUnusedRtns]') AND type in (N'U'))
    DROP Table[dbo].[ReqUnusedRtns];
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReqUnusedRtns]') AND type in (N'U'))
DROP TABLE [dbo].[ReqUnusedRtns]
GO
