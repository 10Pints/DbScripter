SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[staging3](
	[id] [int] NOT NULL,
	[company] [varchar](60) NULL,
	[ingredient] [varchar](100) NULL,
	[product] [varchar](50) NULL,
	[concentration] [varchar](50) NULL,
	[formulation_type] [varchar](50) NULL,
	[uses] [varchar](50) NULL,
	[toxicity_category] [varchar](50) NULL,
	[registration] [varchar](100) NULL,
	[expiry] [varchar](100) NULL,
	[entry_mode] [varchar](60) NULL,
	[crops] [varchar](200) NULL,
	[pathogens] [varchar](200) NULL,
	[rate] [varchar](200) NULL,
	[mrl] [varchar](200) NULL,
	[phi] [varchar](200) NULL,
	[phi_resolved] [varchar](120) NULL,
	[reentry_period] [varchar](250) NULL,
	[notes] [varchar](250) NULL,
	[comments] [varchar](500) NULL,
	[created] [datetime] NULL,
 CONSTRAINT [PK_staging3] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'resolved to days' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'staging3', @level2type=N'COLUMN',@level2name=N'phi_resolved'

GO
