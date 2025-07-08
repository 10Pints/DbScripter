GO

CREATE TYPE [dbo].[CmdsTbl] AS TABLE(
	[ordinal] [int] IDENTITY(1,1) NOT NULL,
	[sql] [nvarchar](max) NULL
)

GO
