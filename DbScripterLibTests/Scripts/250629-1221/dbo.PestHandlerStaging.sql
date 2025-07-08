SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[PestHandlerStaging](
	[id] [int] NULL,
	[region] [varchar](50) NULL,
	[province] [varchar](50) NULL,
	[city] [varchar](50) NULL,
	[address] [varchar](250) NULL,
	[company_nm] [varchar](50) NULL,
	[owner] [varchar](50) NULL,
	[activity] [varchar](50) NULL,
	[type] [varchar](50) NULL,
	[license_app_ty] [varchar](50) NULL,
	[expiry] [varchar](50) NULL,
	[license_num] [varchar](50) NULL
) ON [PRIMARY]

GO
