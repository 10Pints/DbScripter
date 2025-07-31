GO
CREATE TYPE [dbo].[ParamTableType] AS TABLE(
	[rtn_nm] [nvarchar](60) NULL,
	[rtn_id] [int] NULL,
	[schema_nm] [nvarchar](25) NULL,
	[param_nm] [nvarchar](60) NULL,
	[ordinal_position] [int] NULL,
	[param_ty_nm] [nvarchar](25) NULL,
	[param_ty_nm_full] [nvarchar](25) NULL,
	[param_ty_id] [int] NULL,
	[param_ty_len] [int] NULL,
	[is_output] [bit] NULL,
	[has_default_value] [bit] NULL,
	[default_value] [sql_variant] NULL,
	[is_nullable] [bit] NULL,
	[rtn_ty_nm] [nvarchar](25) NULL,
	[rtn_ty_code] [nchar](2) NULL,
	[col2_st] [int] NULL,
	[col3_st] [int] NULL,
	[col4_st] [int] NULL,
	[error_num] [int] NULL,
	[error_msg] [nvarchar](500) NULL
)
GO

