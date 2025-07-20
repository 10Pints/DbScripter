GO

CREATE TYPE [test].[CodeTbl] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[line] [nvarchar](max) NULL,
	PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)

GO
