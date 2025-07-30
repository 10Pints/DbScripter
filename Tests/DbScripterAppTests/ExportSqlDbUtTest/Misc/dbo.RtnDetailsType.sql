GO
CREATE TYPE [dbo].[RtnDetailsType] AS TABLE(
	[schema_nm] [nvarchar](256) NULL,
	[rtn_nm] [nvarchar](256) NULL,
	[rtn_ty_code] [nvarchar](2) NULL,
	[rtn_ty_nm] [nvarchar](60) NULL
)
GO

