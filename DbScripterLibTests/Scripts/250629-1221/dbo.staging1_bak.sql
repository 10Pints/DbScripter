SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [dbo].[staging1_bak](
	[id] [int] NOT NULL,
	[company] [varchar](max) NULL,
	[ingredient] [varchar](max) NULL,
	[product] [varchar](max) NULL,
	[concentration] [varchar](max) NULL,
	[formulation_type] [varchar](max) NULL,
	[uses] [varchar](max) NULL,
	[toxicity_category] [varchar](max) NULL,
	[registration] [varchar](max) NULL,
	[expiry] [varchar](max) NULL,
	[entry_mode] [varchar](max) NULL,
	[crops] [varchar](max) NULL,
	[pathogens] [varchar](max) NULL,
	[rate] [varchar](200) NULL,
	[mrl] [varchar](200) NULL,
	[phi] [varchar](200) NULL,
	[reentry_period] [varchar](250) NULL,
	[notes] [varchar](250) NULL,
 CONSTRAINT [PK_staging1_bak] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
