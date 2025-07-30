SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [test].[RtnDetails](
	[qrn] [varchar](90) NULL,
	[schema_nm] [varchar](60) NULL,
	[rtn_nm] [varchar](60) NULL,
	[trn] [int] NULL,
	[cora] [nchar](1) NULL,
	[ad_stp] [bit] NULL,
	[rtn_ty] [varchar](2) NULL,
	[rtn_ty_code] [varchar](2) NULL,
	[is_clr] [bit] NULL,
	[tst_rtn_nm] [varchar](50) NULL,
	[hlpr_rtn_nm] [varchar](50) NULL,
	[max_prm_len] [int] NULL,
	[sc_fn_ret_ty] [varchar](20) NULL,
	[prm_cnt] [int] NULL,
	[display_tables] [bit] NULL
) ON [PRIMARY]
GO

