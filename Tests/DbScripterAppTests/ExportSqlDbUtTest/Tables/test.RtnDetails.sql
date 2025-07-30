SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [test].[RtnDetails](
	[qrn] [nvarchar](90) NULL,
	[schema_nm] [nvarchar](60) NULL,
	[rtn_nm] [nvarchar](60) NULL,
	[trn] [int] NULL,
	[cora] [nchar](1) NULL,
	[ad_stp] [bit] NULL,
	[tst_mode] [bit] NULL,
	[stop_stage] [int] NULL,
	[rtn_ty] [nvarchar](50) NULL,
	[rtn_ty_code] [nvarchar](2) NULL,
	[is_clr] [bit] NULL,
	[tst_rtn_nm] [nvarchar](50) NULL,
	[hlpr_rtn_nm] [nvarchar](50) NULL,
	[max_prm_len] [int] NULL,
	[sc_fn_ret_ty] [nvarchar](20) NULL
) ON [PRIMARY]
GO

