SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RtnInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

