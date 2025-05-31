IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IdNmTbl]') AND type in (N'U'))
    DROP UserDefinedDataType[dbo].[IdNmTbl];
GO
CREATE TYPE [dbo].[IdNmTbl] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
	[val] [varchar](4000) NULL,
	PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
