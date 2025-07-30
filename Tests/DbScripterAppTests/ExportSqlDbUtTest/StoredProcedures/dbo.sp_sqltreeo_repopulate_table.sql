SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Template generated from Template Explorer using:
--
-- Use the Specify Values for Template Parameters 
-- =============================================
-- Author:      Terry Watts
-- Create date: 14-MAY-2020
-- Description: repopulates the SQLTreeOConfig table and rereshes folders
-- =============================================
CREATE PROCEDURE [dbo].[sp_sqltreeo_repopulate_table]
AS
BEGIN
TRUNCATE TABLE SQLTreeOConfig;
INSERT INTO SQLTreeOConfig (name, value) VALUES
 ('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~ScalarValuedFunction|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~ScalarValuedFunction|~test','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~ScalarValuedFunction|~tsqlt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tsqlt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~_tests 000-099','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 0%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~_tests 100-199','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 1%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~_tests 200-299','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 2%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test helpers 000-099','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.helper T0%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test helpers 100-199','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.helper T1%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test helpers 200-299','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.helper T2%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test support','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.sp_tst%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~tsqlt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tsqlt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~Table|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~Table|~test','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~Table|~tsqlt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tsqlt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~TableValuedFunction|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~TableValuedFunction|~test','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~TableValuedFunction|~tsqlt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tsqlt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~View|~dbo','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~View|~test','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~View|~tSQLt','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">tSQLt.%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('Dian','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">Dian</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~Global|~Database|~Dian','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">Dian%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test setup','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test_setup%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~Covid|~Table|~Hopkins','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">dbo.Hopkins%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test_close','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test_close %</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test_setup','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test_setup%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test 000-099','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 0%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test 100-199','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 1%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>')
,('SQLTreeo|~DESKTOP-UAULS0U\SQLEXPRESS|~TPCTest|~StoredProcedure|~test 200-299','<?xml version="1.0" encoding="utf-16"?>  <ArrayOfFolderPropertiesRulesRule>    <FolderPropertiesRulesRule Type="SQL">test.test 2%</FolderPropertiesRulesRule>  </ArrayOfFolderPropertiesRulesRule>');
END
/*
EXEC sp_sqltreeo_restore_folders
SELECT * FROM SQLTreeOConfig;
*/
GO

