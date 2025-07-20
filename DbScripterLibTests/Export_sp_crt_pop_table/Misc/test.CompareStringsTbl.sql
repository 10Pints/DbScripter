GO

CREATE TYPE [test].[CompareStringsTbl] AS TABLE(
	[A] [varchar](max) NULL,
	[B] [varchar](max) NULL,
	[SA] [varchar](max) NULL,
	[SB] [varchar](max) NULL,
	[CA] [varchar](max) NULL,
	[CB] [varchar](max) NULL,
	[msg] [varchar](max) NULL,
	[match] [bit] NULL,
	[status_msg] [varchar](120) NULL,
	[code] [int] NULL,
	[ndx] [int] NULL,
	[log] [varchar](max) NULL
)

GO
