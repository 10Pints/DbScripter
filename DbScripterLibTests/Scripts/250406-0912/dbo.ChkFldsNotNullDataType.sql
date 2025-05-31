IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChkFldsNotNullDataType]') AND type in (N'U'))
    DROP UserDefinedDataType[dbo].[ChkFldsNotNullDataType];
GO
CREATE TYPE [dbo].[ChkFldsNotNullDataType] AS TABLE(
	[ordinal] [int] NOT NULL,
	[col] [varchar](60) NOT NULL,
	[sql] [varchar](4000) NOT NULL
)
GO
