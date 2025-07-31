SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[myargstable](
	[name] [nvarchar](1000) NULL,
	[type] [nvarchar](1000) NULL,
	[def_val] [nvarchar](1000) NULL,
	[comment] [nvarchar](1000) NULL,
	[out_sym] [bit] NULL,
	[is_chr_ty] [bit] NULL
) ON [PRIMARY]
GO

