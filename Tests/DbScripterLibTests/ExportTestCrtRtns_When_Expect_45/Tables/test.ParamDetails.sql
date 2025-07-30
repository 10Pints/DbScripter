SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [test].[ParamDetails](
	[ordinal] [int] IDENTITY(1,1) NOT NULL,
	[param_nm] [varchar](50) NULL,
	[type_nm] [varchar](32) NULL,
	[parameter_mode] [varchar](10) NULL,
	[is_chr_ty] [bit] NULL,
	[is_result] [bit] NULL,
	[is_output] [bit] NULL,
	[is_nullable] [bit] NULL,
	[tst_ty] [nchar](3) NULL,
	[is_exception] [bit] NULL,
 CONSTRAINT [PK_ParamDetails] PRIMARY KEY CLUSTERED 
(
	[ordinal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

