-- CreateDbConfigSchema.sql
USE [<DB_NAME>]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ET2PT](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[event_type] [int] NOT NULL,
	[property_type] [int] NOT NULL,
 CONSTRAINT [PK_E2PT] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventType](
	[id] [int] NOT NULL,
	[name] [varchar](35) NOT NULL,
	[log_type] [int] NOT NULL,
	[code] [varchar](4) NOT NULL,
	[description] [varchar](max) NULL,
	[remedy] [varchar](max) NULL,
 CONSTRAINT [PK_EventType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyType](
	[id] [int] NOT NULL,
	[name] [varchar](30) NOT NULL,
	[unit] [int] NOT NULL,
 CONSTRAINT [PK_PropertyType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Ep2PtView]
AS
SELECT   TOP 100 PERCENT et.name AS event_type_name, pt.name AS property_type_name, et.id AS event_type_id, pt.id AS property_type_id
FROM      dbo.ET2PT AS e2p INNER JOIN
          dbo.EventType AS et ON e2p.event_type = et.id INNER JOIN
          dbo.PropertyType AS pt ON e2p.property_type = pt.id
ORDER BY event_type_name, property_type_name
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PNT2CNT](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[parent_type] [int] NOT NULL,
	[child_type] [int] NOT NULL,
 CONSTRAINT [PK_EQT2EQT] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NodeType](
	[id] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[is_machine] [bit] NULL,
 CONSTRAINT [PK_NodeType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[PNT2CNTView]
AS
SELECT  TOP 100 PERCENT p.name AS parent_type_name, c.name AS child_type_name, p.id AS parent_type_id, c.id AS child_type_id
FROM    PNT2CNT p2c , NodeType p, NodeType c 
WHERE		p2c.parent_type = p.id AND p2c.child_type = c.id		
ORDER BY parent_type_name, child_type_name
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Event](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[event_type] [int] NOT NULL,
	[time] [datetime] NULL,
	[project] [uniqueidentifier] NOT NULL,
	[message] [varchar](100) NULL,
	[node] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogType](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](12) NOT NULL,
 CONSTRAINT [PK_LogType] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Node](
	[id] [uniqueidentifier] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[node_type] [int] NOT NULL,
	[parent] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Node] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Project](
	[id] [uniqueidentifier] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[user] [uniqueidentifier] NOT NULL,
	[top_level_node] [uniqueidentifier] NOT NULL,
	[Notes] [varchar](100) NULL,
 CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Property](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[property_type] [int] NOT NULL,
	[event] [bigint] NOT NULL,
	[value] [varchar](50) NULL,
 CONSTRAINT [PK_Property] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Unit](
	[id] [int] NOT NULL,
	[name] [varchar](35) NOT NULL,
 CONSTRAINT [PK_Unit] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[id] [uniqueidentifier] NOT NULL,
	[name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NT2PT_event_type] ON [dbo].[ET2PT]
(
	[event_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NT2PT_property_type] ON [dbo].[ET2PT]
(
	[property_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ET2PT_evt_ty_prop_ty] ON [dbo].[ET2PT]
(
	[event_type] ASC,
	[property_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_event_type] ON [dbo].[Event]
(
	[event_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_node] ON [dbo].[Event]
(
	[node] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_project] ON [dbo].[Event]
(
	[project] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventType_code] ON [dbo].[EventType]
(
	[code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_EventType_name] ON [dbo].[EventType]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_LogType] ON [dbo].[LogType]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Node_name] ON [dbo].[Node]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Node_node_type] ON [dbo].[Node]
(
	[node_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Node_parent] ON [dbo].[Node]
(
	[parent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NodeType_is_machine] ON [dbo].[NodeType]
(
	[is_machine] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_NodeType_name] ON [dbo].[NodeType]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PNT2CNT_child_type] ON [dbo].[PNT2CNT]
(
	[child_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PNT2CNT_parent_type] ON [dbo].[PNT2CNT]
(
	[parent_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_PNT2CNT_parent_child] ON [dbo].[PNT2CNT]
(
	[parent_type] ASC,
	[child_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Project_name] ON [dbo].[Project]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Project_top_level_node] ON [dbo].[Project]
(
	[top_level_node] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Project_user] ON [dbo].[Project]
(
	[user] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Property_event] ON [dbo].[Property]
(
	[event] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Property_property_type] ON [dbo].[Property]
(
	[property_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Property] ON [dbo].[Property]
(
	[property_type] ASC,
	[event] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Unit_name] ON [dbo].[Unit]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_User_name] ON [dbo].[User]
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Event] ADD  CONSTRAINT [DF_Event_time]  DEFAULT (getdate()) FOR [time]
GO
ALTER TABLE [dbo].[Node] ADD  CONSTRAINT [DF_Product_id]  DEFAULT (newid()) FOR [id]
GO
ALTER TABLE [dbo].[NodeType] ADD  CONSTRAINT [DF_NodeType_is_machine]  DEFAULT ((0)) FOR [is_machine]
GO
ALTER TABLE [dbo].[Project] ADD  CONSTRAINT [DF_Project_id]  DEFAULT (newid()) FOR [id]
GO
ALTER TABLE [dbo].[User] ADD  CONSTRAINT [DF_User_id]  DEFAULT (newid()) FOR [id]
GO
ALTER TABLE [dbo].[ET2PT]  WITH CHECK ADD  CONSTRAINT [FK_N2PT_EventType] FOREIGN KEY([event_type])
REFERENCES [dbo].[EventType] ([id])
GO
ALTER TABLE [dbo].[ET2PT] CHECK CONSTRAINT [FK_N2PT_EventType]
GO
ALTER TABLE [dbo].[ET2PT]  WITH CHECK ADD  CONSTRAINT [FK_N2PT_PropertyType] FOREIGN KEY([property_type])
REFERENCES [dbo].[PropertyType] ([id])
GO
ALTER TABLE [dbo].[ET2PT] CHECK CONSTRAINT [FK_N2PT_PropertyType]
GO
ALTER TABLE [dbo].[Event]  WITH CHECK ADD  CONSTRAINT [FK_Event_EventType] FOREIGN KEY([event_type])
REFERENCES [dbo].[EventType] ([id])
GO
ALTER TABLE [dbo].[Event] CHECK CONSTRAINT [FK_Event_EventType]
GO
ALTER TABLE [dbo].[Event]  WITH CHECK ADD  CONSTRAINT [FK_Event_Node] FOREIGN KEY([node])
REFERENCES [dbo].[Node] ([id])
GO
ALTER TABLE [dbo].[Event] CHECK CONSTRAINT [FK_Event_Node]
GO
ALTER TABLE [dbo].[Event]  WITH CHECK ADD  CONSTRAINT [FK_Event_Project] FOREIGN KEY([project])
REFERENCES [dbo].[Project] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Event] CHECK CONSTRAINT [FK_Event_Project]
GO
ALTER TABLE [dbo].[EventType]  WITH CHECK ADD  CONSTRAINT [FK_EventType_LogType] FOREIGN KEY([log_type])
REFERENCES [dbo].[LogType] ([id])
GO
ALTER TABLE [dbo].[EventType] CHECK CONSTRAINT [FK_EventType_LogType]
GO
ALTER TABLE [dbo].[Node]  WITH CHECK ADD  CONSTRAINT [FK_Node_Node_Type] FOREIGN KEY([node_type])
REFERENCES [dbo].[NodeType] ([id])
GO
ALTER TABLE [dbo].[Node] CHECK CONSTRAINT [FK_Node_Node_Type]
GO
ALTER TABLE [dbo].[Node]  WITH CHECK ADD  CONSTRAINT [FK_Node_Parent] FOREIGN KEY([parent])
REFERENCES [dbo].[Node] ([id])
GO
ALTER TABLE [dbo].[Node] CHECK CONSTRAINT [FK_Node_Parent]
GO
ALTER TABLE [dbo].[PNT2CNT]  WITH CHECK ADD  CONSTRAINT [FK_PNT2CNT_NodeType_child] FOREIGN KEY([child_type])
REFERENCES [dbo].[NodeType] ([id])
GO
ALTER TABLE [dbo].[PNT2CNT] CHECK CONSTRAINT [FK_PNT2CNT_NodeType_child]
GO
ALTER TABLE [dbo].[PNT2CNT]  WITH CHECK ADD  CONSTRAINT [FK_PNT2CNT_NodeType_parent] FOREIGN KEY([parent_type])
REFERENCES [dbo].[NodeType] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PNT2CNT] CHECK CONSTRAINT [FK_PNT2CNT_NodeType_parent]
GO
ALTER TABLE [dbo].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_Node] FOREIGN KEY([top_level_node])
REFERENCES [dbo].[Node] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Project] CHECK CONSTRAINT [FK_Project_Node]
GO
ALTER TABLE [dbo].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_User] FOREIGN KEY([user])
REFERENCES [dbo].[User] ([id])
GO
ALTER TABLE [dbo].[Project] CHECK CONSTRAINT [FK_Project_User]
GO
ALTER TABLE [dbo].[Property]  WITH CHECK ADD  CONSTRAINT [FK_Property_Event] FOREIGN KEY([event])
REFERENCES [dbo].[Event] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Property] CHECK CONSTRAINT [FK_Property_Event]
GO
ALTER TABLE [dbo].[Property]  WITH CHECK ADD  CONSTRAINT [FK_Property_PropertyType] FOREIGN KEY([property_type])
REFERENCES [dbo].[PropertyType] ([id])
GO
ALTER TABLE [dbo].[Property] CHECK CONSTRAINT [FK_Property_PropertyType]
GO
ALTER TABLE [dbo].[PropertyType]  WITH CHECK ADD  CONSTRAINT [FK_PropertyType_Unit] FOREIGN KEY([unit])
REFERENCES [dbo].[Unit] ([id])
GO
ALTER TABLE [dbo].[PropertyType] CHECK CONSTRAINT [FK_PropertyType_Unit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			Terry Watts
-- Create date: 03-SEP-2018
-- Description:	Returns the NT2PT configuration in human readable form
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_et2pt]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM Ep2PtView;  
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================
-- Author:			Terry Watts
-- Create date: 03-SEP-2018
-- Description:	Graphic representation of the node hierarchy
-- =========================================================
CREATE PROCEDURE [dbo].[sp_get_node_hierarchy] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	;WITH cte AS     
	(
		SELECT	CAST(name AS nvarchar(100)) AS node_name,
			n.id AS node_id,
			parent,
			1 as indent,
			CAST('\' + name as nvarchar(254))  AS sort_order
		FROM Node n 
		WHERE n.name = 'All Data'
	UNION ALL
		SELECT 
			CAST(REPLICATE ('|    ' , indent) + n2.Name as nvarchar(100)), 
			n2.id,
			n2.parent,
			indent+1,
			CAST(sort_order + '\' + name as nvarchar(254))  
		FROM
			cte, Node n2

		WHERE 
			n2.parent = node_id
	)

	SELECT node_name, node_id, parent FROM cte ORDER BY sort_order;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_pnt2cnt]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT p.name as parent_type_name, c.name as child_type_name, p.id as parent_type_id, c.id as child_type_id
	FROM PNT2CNT p2c, NodeType p, NodeType c
	WHERE p2c.parent_type = p.id AND p2c.child_type = c.id
	ORDER BY p.name, c.name
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: CreateSchema.sql|393|0|C:\Dev\WSP0\Shared Projects\Shared Projects\SI.DataLogging.Tests\Database Scripts\CreateSchema.sql
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_property_types_for_event_type] @event_type_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT pt.* 
	FROM EventType et, PropertyType pt, ET2PT
	WHERE et.id = ET2PT.event_type
	  AND pt.id = ET2PT.property_type
	ORDER BY pt.[name]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: CreateSchema.sql|416|0|C:\Dev\WSP0\Shared Projects\Shared Projects\SI.DataLogging.Tests\Database Scripts\CreateSchema.sql

create procedure [dbo].[sp_pkeys_all]
(
    --@table_name      sysname,
    @table_owner     sysname = null,
    @table_qualifier sysname = null
)
as
    declare @table_id           int
    -- quotename() returns up to 258 chars
    --declare @full_table_name    nvarchar(517) -- 258 + 1 + 258

    if @table_qualifier is not null
    begin
        if db_name() <> @table_qualifier
        begin   -- If qualifier doesn't match current database
            raiserror (15250, -1,-1)
            return
        end
    end
/*
    if @table_owner is null
    begin   -- If unqualified table name
        select @full_table_name = quotename(@table_name)
    end
    else
    begin   -- Qualified table name
        if @table_owner = ''
        begin   -- If empty owner name
            select @full_table_name = quotename(@table_owner)
        end
        else
        begin
            select @full_table_name = quotename(@table_owner) + '.' + quotename(@table_name)
        end
    end

    select @table_id = object_id(@full_table_name)
*/
    select
        TABLE_QUALIFIER = convert(sysname,db_name()),
        TABLE_OWNER = convert(sysname,schema_name(o.schema_id)),
        TABLE_NAME = convert(sysname,o.name),
        COLUMN_NAME = convert(sysname,c.name),
/*        KEY_SEQ = convert (smallint,
            case
                when c.name = index_col(@full_table_name, i.index_id,  1) then 1
                when c.name = index_col(@full_table_name, i.index_id,  2) then 2
                when c.name = index_col(@full_table_name, i.index_id,  3) then 3
                when c.name = index_col(@full_table_name, i.index_id,  4) then 4
                when c.name = index_col(@full_table_name, i.index_id,  5) then 5
                when c.name = index_col(@full_table_name, i.index_id,  6) then 6
                when c.name = index_col(@full_table_name, i.index_id,  7) then 7
                when c.name = index_col(@full_table_name, i.index_id,  8) then 8
                when c.name = index_col(@full_table_name, i.index_id,  9) then 9
                when c.name = index_col(@full_table_name, i.index_id, 10) then 10
                when c.name = index_col(@full_table_name, i.index_id, 11) then 11
                when c.name = index_col(@full_table_name, i.index_id, 12) then 12
                when c.name = index_col(@full_table_name, i.index_id, 13) then 13
                when c.name = index_col(@full_table_name, i.index_id, 14) then 14
                when c.name = index_col(@full_table_name, i.index_id, 15) then 15
                when c.name = index_col(@full_table_name, i.index_id, 16) then 16
            end),*/
        PK_NAME = convert(sysname,k.name)
    from
        sys.indexes i,
        sys.all_columns c,
        sys.all_objects o,
        sys.key_constraints k
    where
        --o.object_id = @table_id and
        o.object_id = c.object_id and
        o.object_id = i.object_id and
        k.parent_object_id = o.object_id and 
        k.unique_index_id = i.index_id and 
        i.is_primary_key = 1 
/*				and
        (c.name = index_col (@full_table_name, i.index_id,  1) or
         c.name = index_col (@full_table_name, i.index_id,  2) or
         c.name = index_col (@full_table_name, i.index_id,  3) or
         c.name = index_col (@full_table_name, i.index_id,  4) or
         c.name = index_col (@full_table_name, i.index_id,  5) or
         c.name = index_col (@full_table_name, i.index_id,  6) or
         c.name = index_col (@full_table_name, i.index_id,  7) or
         c.name = index_col (@full_table_name, i.index_id,  8) or
         c.name = index_col (@full_table_name, i.index_id,  9) or
         c.name = index_col (@full_table_name, i.index_id, 10) or
         c.name = index_col (@full_table_name, i.index_id, 11) or
         c.name = index_col (@full_table_name, i.index_id, 12) or
         c.name = index_col (@full_table_name, i.index_id, 13) or
         c.name = index_col (@full_table_name, i.index_id, 14) or
         c.name = index_col (@full_table_name, i.index_id, 15) or
         c.name = index_col (@full_table_name, i.index_id, 16))*/
         
    order by 1, 2, 3, 5
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		  Terry Watts
-- Create date: 03-SEP-2018
-- Description:	Returns the set of events and parameters for a given node and its components
-- =============================================
CREATE PROCEDURE [dbo].[sp_report_events]
	@node_name			 VARCHAR(50),					-- should be specified
	@start_time			 datetime			null,		-- either neither or both of @start_time and@end_time should be defined
	@end_time				 datetime			null,
	@event_type_name VARCHAR(50)	null,
	@node_type_name  VARCHAR(50)	null 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if(@node_name is null) OR(LEN(@node_name) = 0)
	--BEGIN
	THROW 50000, 'node_name not specified', 1;
	--END

;WITH cte AS     
(
  SELECT 
		n.id AS node_id, 
		name as node_name
	FROM 
		Node n 
	WHERE 
		n.name = @node_name COLLATE SQL_Latin1_General_CP1_CI_AS -- anchor member case insensitive search
UNION ALL
	SELECT 
		n2.id, 
		n2.name
	FROM

		cte, 
		Node n2

	WHERE 
		n2.parent = node_id
)
SELECT 
	e.time as event_time, 
	et.name as event_type_name, 
	code as event_code, 
	node_id, 
	node_name, 
	nt.id as node_type_id, 
	nt.name as node_type_name, 
	[message], 
	pt.name as property, 
	p.value
FROM 
	cte,
	[Event] e, 
	EventType et, 
	Property p, 
	PropertyType pt, 
	NodeType nt, 
	Node n
WHERE 
-- LINK CLAUSE
		n.id            = cte.node_id
AND	e.node					= n.id
AND p.event         = e.id
AND p.property_type = pt.id
AND e.event_type    = et.id
AND nt.id           = n.node_type
-- FILTER
AND ((time BETWEEN @start_time AND @end_time)													 OR (@start_time IS NULL))			-- [OPTIONAL FILTER] The OR statements allow us include a variable set of filters without having to recompile the procedure or use dynamic SQL
AND ((et.name = @event_type_name COLLATE SQL_Latin1_General_CP1_CI_AS) OR (@event_type_name IS NULL)) -- [OPTIONAL FILTER] case insensitive search
AND ((nt.name = @node_type_name  COLLATE SQL_Latin1_General_CP1_CI_AS) OR (@node_type_name  IS NULL)) -- [OPTIONAL FILTER] case insensitive search
ORDER BY [time]


END

-- 
--exec dbo.sp_report_events @node_name='LAbCube 1', @start_time='2018-08-25 10:05:04.000', @end_time='2018-08-30 11:05:04.000', @event_type_name=NULL, @node_type_name=NULL;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		  Terry Watts
-- Create date: 03-SEP-2018
-- Description:	Returns the set of events and parameters for a given node and its components
--              This routine allows the caller to issue a query like
--              Give me all the [Nozzle Collision] events for all [Pixl] nodes and their child nodes [in LabCube x]
--
-- N.B. the [] indicate that the criteria parameter is optional - if it is omitted (null) then that criteria is removed from the filter
-- i.e. NULL means ALL for that criteria
-- e.g exec [dbo].[sp_report_events2] @parent_node_type_name='Pixl', @parent_node_name=null, @node_type_name=null, @start_time=null, @end_time=null, @event_type_name=null 
-- would return all the events for all pixl's and their components, regardless of the pixl name or the sub-component, or the time or event type
--
-- Whereas  [dbo].[sp_report_events2] @parent_node_type_name='Pixl', @parent_node_name='Pixl 1.2', @node_type_name='Cleaver', @start_time='2018-08-00 00:00:00.000', @end_time='2018-09-01 00:00:00.000', @event_type_name=null 
-- would return all the events for just the Pixl machine 'Pixl 1.2 Cleaver component For August 2018.
-- =============================================
CREATE PROCEDURE [dbo].[sp_report_events2]
	@parent_node_type_name  VARCHAR(50)	null, 
	@parent_node_name				VARCHAR(50) null,
	@node_type_name					VARCHAR(50)	null, 
	@event_type_name				VARCHAR(50)	null,
	@start_time							DATETIME		null,		-- either neither or both of @start_time and@end_time should be defined
	@end_time								DATETIME		null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
;WITH cte AS     
(
  SELECT n.id AS parent_node_id, n.name as parent_node_name, n.id AS node_id, n.name as node_name, nt.is_machine
	FROM  	Node n, NodeType nt 
	WHERE 	n.node_type = nt.id 
			AND ((nt.name = @parent_node_type_name	COLLATE SQL_Latin1_General_CP1_CI_AS) OR (@parent_node_type_name IS NULL))
			AND ((n.name  = @parent_node_name				COLLATE SQL_Latin1_General_CP1_CI_AS) OR (@parent_node_name IS NULL))
UNION ALL
	SELECT 	 cte.parent_node_id AS parent_node_id, cte.parent_node_name as parent_node_name, n2.id, n2.name, is_machine
	FROM		cte, Node n2
	WHERE 	n2.parent = node_id
)
SELECT 
	e.time as event_time, 
	et.name as event_type_name, 
	code as event_code, 
	parent_node_id,
	parent_node_name,
	node_id, 
	node_name, 
	nt.id as node_type_id, 
	nt.name as node_type_name, 
	nt.is_machine,
	[message], 
	pt.name as property, 
	p.value
FROM 
	cte, 
	[Event] e, 
	EventType et, 
	Property p, 
	PropertyType pt, 
	NodeType nt, 
	Node n
WHERE 
-- LINK CLAUSE
		e.node					= n.id
AND p.event         = e.id
AND p.property_type = pt.id
AND e.event_type    = et.id
AND nt.id           = n.node_type
And n.id            = cte.node_id
-- FILTER
AND ((time BETWEEN @start_time AND @end_time) OR (@start_time IS NULL))
AND ((et.name = @event_type_name COLLATE SQL_Latin1_General_CP1_CI_AS) OR (@event_type_name IS NULL)) -- case insensitive search
AND ((nt.name = @node_type_name  COLLATE SQL_Latin1_General_CP1_CI_AS) OR (@node_type_name  IS NULL)) -- case insensitive search
ORDER BY [time]
END

/*
 exec sp_report_events2 @parent_node_type_name='Pixl', @parent_node_name='Pixl 1.2', @node_type_name=null, @start_time=null, @end_time=null, @event_type_name=null 
 exec sp_report_events2 @parent_node_type_name='Pixl', @parent_node_name='Pixl 1.2', @node_type_name=null, @start_time=null, @end_time=null, @event_type_name=null 
 exec sp_report_events2 @parent_node_type_name='Pixl', @parent_node_name=null, @node_type_name='Cleaver', @start_time=null, @end_time=null, @event_type_name=null 
 exec sp_report_events2 @parent_node_type_name='Pixl', @parent_node_name='Pixl 1.2', @node_type_name='Cleaver', @start_time='2018-08-01 00:00:00.000', @end_time='2018-09-01 00:00:00.000', @event_type_name=null 
 select * from EventType
*/
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'true if it is a machine like a Pixl ot PhenoBooth' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NodeType', @level2type=N'COLUMN',@level2name=N'is_machine'
GO
USE [master]
GO
ALTER DATABASE [DataLoggingTestDb] SET  READ_WRITE 
GO
