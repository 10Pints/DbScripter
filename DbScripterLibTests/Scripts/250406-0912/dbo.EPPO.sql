IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EPPO]') AND type in (N'U'))
    DROP UserDefinedDataType[dbo].[EPPO];
GO
CREATE TYPE [dbo].[EPPO] AS TABLE(
	[ordinal] [int] NULL,
	[table] [varchar](250) NOT NULL,
	[exp_row_cnt] [int] NULL,
	PRIMARY KEY CLUSTERED 
(
	[table] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
