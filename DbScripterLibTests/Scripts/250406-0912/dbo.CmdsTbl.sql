IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CmdsTbl]') AND type in (N'U'))
    DROP UserDefinedDataType[dbo].[CmdsTbl];
GO
CREATE TYPE [dbo].[CmdsTbl] AS TABLE(
	[ordinal] [int] IDENTITY(1,1) NOT NULL,
	[sql] [nvarchar](max) NULL
)
GO
