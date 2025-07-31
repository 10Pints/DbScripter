SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](28) NULL,
	[iso] [nvarchar](5) NULL,
	[iso2] [nvarchar](5) NULL,
	[un_code] [nvarchar](5) NULL,
	[pop] [float] NULL,
	[median_age] [int] NULL,
	[area] [float] NULL,
	[lock_date] [date] NULL,
	[unlock_date] [date] NULL,
	[continent_nm] [nvarchar](15) NULL,
	[continent_id] [int] NULL,
	[pop_density]  AS (round([pop]/[area],(2))),
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pop / area, K=1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Country', @level2type=N'COLUMN',@level2name=N'pop_density'
GO

