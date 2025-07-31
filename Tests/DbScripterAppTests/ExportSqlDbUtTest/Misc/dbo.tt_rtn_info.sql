GO
CREATE TYPE [dbo].[tt_rtn_info] AS TABLE(
	[so_nm] [sysname] NOT NULL,
	[schema_nm] [sysname] NOT NULL,
	[object_id] [int] NULL,
	[so_principal_id] [int] NULL,
	[ss_principal_id] [int] NULL,
	[so_schema_id] [int] NULL,
	[parent_object_id] [int] NULL,
	[type] [char](2) NULL,
	[type_desc] [nvarchar](60) NULL,
	[create_date] [datetime] NULL,
	[modify_date] [datetime] NULL,
	[is_ms_shipped] [bit] NULL,
	[is_published] [bit] NULL,
	[is_schema_published] [bit] NULL,
	PRIMARY KEY CLUSTERED 
(
	[so_nm] ASC,
	[schema_nm] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

