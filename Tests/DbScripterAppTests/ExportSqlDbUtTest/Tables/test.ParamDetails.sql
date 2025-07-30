SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [test].[ParamDetails](
	[ordinal] [int] IDENTITY(1,1) NOT NULL,
	[param_nm] [nvarchar](50) NULL,
	[type_nm] [nvarchar](32) NULL,
	[parameter_mode] [nvarchar](10) NULL,
	[is_chr_ty] [bit] NULL,
	[is_result] [bit] NULL,
	[is_output] [bit] NULL,
	[is_nullable] [bit] NULL,
	[tst_ty] [nchar](3) NULL,
	[is_out_col] [bit] NULL,
 CONSTRAINT [PK_ParamDetails] PRIMARY KEY CLUSTERED 
(
	[ordinal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [test].[ParamDetails] ADD  CONSTRAINT [DF_ParamDetails_is_out_col]  DEFAULT ((0)) FOR [is_out_col]
GO

