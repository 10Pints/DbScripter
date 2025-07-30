SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Terry Watts
-- Create date: 08-JAN-2020
-- Description: sp depends fix
-- =============================================
CREATE PROCEDURE [dbo].[sp_i_depend_on_them]
   @objname   nvarchar(776)  -- the object we want to check
AS
BEGIN
declare @objid int   -- the id of the object we want
       ,@found_some bit   -- flag for dependencies found
       ,@dbname    sysname
--  Make sure the @objname is local to the current database.
--select @dbname = parsename(@objname,3)
if @dbname is not null and @dbname <> db_name()
 begin
  raiserror(15250,-1,-1)
  return (1)
 end
--  See if @objname exists.
select @objid = object_id(@objname)
if @objid is null
 begin
  select @dbname = db_name()
  raiserror(15009,-1,-1,@objname,@dbname)
  return (1)
 end
--  Initialize @found_some to indicate that we haven't seen any dependencies.  
select @found_some = 0
set nocount on
--  Print out the particulars about the local dependencies.  
if exists (select *
  from sysdepends
   where id = @objid)
begin
 raiserror(15459,-1,-1)
 select   'name' = (s6.name+ '.' + o1.name),
   type = substring(v2.name, 5, 66)  -- spt_values.name is nvarchar(70)
--    updated = substring(u4.name, 1, 7),
--    selected = substring(w5.name, 1, 8),
--             'column' = col_name(d3.depid, d3.depnumber)
  from  sys.objects  o1
   ,master.dbo.spt_values v2
   ,sysdepends  d3
   ,master.dbo.spt_values u4
   ,master.dbo.spt_values w5 --11667
   ,sys.schemas  s6
  where  o1.object_id = d3.depid
  and  o1.type = substring(v2.name,1,2) collate CATALOG_DEFAULT and v2.type = 'O9T'
  and  u4.type = 'B' and u4.number = d3.resultobj
  and  w5.type = 'B' and w5.number = d3.readobj|d3.selall
  and  d3.id = @objid
  and  o1.schema_id = s6.schema_id
  and deptype < 2
 select @found_some = 1
end
set nocount off
return (0) -- sp_depends
END
/*
*/
GO

