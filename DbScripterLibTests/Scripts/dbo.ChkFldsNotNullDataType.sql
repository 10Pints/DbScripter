GO

CREATE TYPE [dbo].[ChkFldsNotNullDataType] AS TABLE(
	[ordinal] [int] NOT NULL,
	[col] [varchar](60) NOT NULL,
	[sql] [varchar](4000) NOT NULL
)

GO
