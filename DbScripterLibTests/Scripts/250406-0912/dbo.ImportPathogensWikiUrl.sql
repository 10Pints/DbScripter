SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO
-- ====================================================================
-- Procedure:   sp_pathogens_wiki_urls
-- Description: soft imports the wikipedia data for the Pathogen table
-- EXEC tSQLt.Run 'test.test_nnn_sp_pathogens_wiki_urls';
-- Design:      
-- Tests:       
-- Author:      Terry watts
-- Create date: 20-JAN-2025
/*
id	pathogen_nm	url	image	taxonomy	binomial_nm	synonyms	status	
506		315	315	253	194	152	156	is OK status i.e. ''
		62%	62%	50%	38%	30%	31%	
1	28 spotted beetle	https://en.wikipedia.org/wiki/Henosepilachna_vigintioctopunctata	https://upload.wikimedia.org/wikipedia/commons/c/c8/Epilachna_vigintioctopunctata_01.jpg	Domain:Eukaryota,Kingdom:Animalia,Phylum:Arthropoda,Class:Insecta,Order:Coleoptera,Infraorder:Cucujiformia,Family:Coccinellidae,Genus:Henosepilachna	Henosepilachna vigintioctopunctata	Coccinella 28-punctata,Coccinella sparsa,Epilachna gradaria,Epilachna territa,Epilachna vigintioctopunctata,Epilachna sparsa		
*/
-- 
-- expects a tsv file
-- row 1: is the header
-- row 2: gives the count of non null items
-- row 3: gives the % of rows with data for the column
-- row 4: is the first data row
-- ====================================================================
ALTER PROCEDURE [dbo].[ImportPathogensWikiUrl]
    @file             VARCHAR(500)
   ,@display_table    BIT  = 0
   ,@row_cnt          INT  = NULL OUT
AS
BEGIN
   SET NOCOUNT ON;
   DECLARE
    @fn           VARCHAR(35) = N'ImportPathogensWikiUrl'
   ,@tab          CHAR(1)     = CHAR(9)
   ,@delta        INT
   ,@update_cnt   INT         = 0
   ;

   EXEC sp_log 1, @fn, '000: starting:
file            :[',@file              ,']
';

   BEGIN TRY
      EXEC sp_import_txt_file
          @table           = 'PathogenWikiUrlStaging'
         ,@file            = @file
         ,@field_terminator= @tab
         ,@first_row       = 4
         ,@clr_first       = 1
         ,@expect_rows     = 1
         ,@non_null_flds   = 'pathogen_nm'
         ,@display_table   = @display_table
         ,@row_cnt         = @row_cnt OUT
      ;

   -- Merge the data into the Pathogen table
   EXEC sp_log 1, @fn, '010: imported PathogenWikiUrlStaging ', @row_cnt,' rows from ', @file;
   EXEC sp_log 1, @fn, '015: updating the Pathogen table';

   -- Only import the urls if they dont exist in the urls field and add a semi colon if necessary
   UPDATE Pathogen
   SET urls = CONCAT(p.urls, iif(dbo.fnLen(p.urls)>0, ';',''), w.url)
   FROM Pathogen p JOIN PathogenWikiUrlStaging w ON p.pathogen_nm = w.pathogen_nm
   WHERE charindex(w.url,p.urls)=0;

   SET @delta = @@ROWCOUNT;
   SET @update_cnt = @update_cnt + @delta;
   EXEC sp_log 1, @fn, '020: updated ', @delta,' urls';

   UPDATE Pathogen
   SET [image] = CONCAT(p.image, iif(dbo.fnLen(p.image)>0, ';',''), w.[image])
   FROM Pathogen p JOIN PathogenWikiUrlStaging w ON p.pathogen_nm = w.pathogen_nm
   WHERE charindex(w.image,p.image)=0;

   SET @delta = @@ROWCOUNT;
   SET @update_cnt = @update_cnt + @delta;
   EXEC sp_log 1, @fn, '030: updated ', @delta,' images';

   UPDATE Pathogen
   SET taxonomy = w.taxonomy
   FROM Pathogen p JOIN PathogenWikiUrlStaging w ON p.pathogen_nm = w.pathogen_nm
   WHERE p.taxonomy IS NULL;

   SET @delta = @@ROWCOUNT;
   SET @update_cnt = @update_cnt + @delta;
   EXEC sp_log 1, @fn, '040: updated ', @delta,' taxonomies';

   UPDATE Pathogen
   SET binomial_nm = w.binomial_nm
   FROM Pathogen p JOIN PathogenWikiUrlStaging w ON p.pathogen_nm = w.pathogen_nm
   WHERE p.binomial_nm IS NULL;

   SET @delta = @@ROWCOUNT;
   SET @update_cnt = @update_cnt + @delta;
   EXEC sp_log 1, @fn, '050: updated ', @delta,' binomial names';

   UPDATE Pathogen
   SET [synonyms] = w.[synonyms]
   FROM Pathogen p JOIN PathogenWikiUrlStaging w ON p.pathogen_nm = w.pathogen_nm
   WHERE p.[synonyms] IS NULL;

   SET @delta = @@ROWCOUNT;
   SET @update_cnt = @update_cnt + @delta;
   EXEC sp_log 1, @fn, '060: updated ', @delta,' synonyms';

   END TRY
   BEGIN CATCH
      EXEC sp_log_exception @fn; --, ' launching notepad++ to display the error files';
      --SET @cmd = CONCAT('EXEC xp_cmdshell ''notepad++ ', @error_file, '''');
      --EXEC (@cmd);
      --SET @cmd = CONCAT('EXEC xp_cmdshell ''notepad++ ', @error_file, '.Error.txt''');
      --EXEC (@cmd);
      THROW;
   END CATCH

   EXEC sp_log 1, @fn, '999: leaving, imported ', @row_cnt,' rows from: ',@file, ' updated ',@update_cnt, ' urls, images, binomial names';
END
/*
EXEC ImportPathogensWikiUrl 'D:\Dev\WebScrapers\WikiScraper\pathogens_wiki_urls.txt', 1;
EXEC ImportPathogensWikiUrl 'D:\dev\farming\data\pathogens_wiki_urls3.txt', 1;

EXEC tSQLt.RunAll;
EXEC tSQLt.Run 'test.test_070_ImportPathogensWikiUrl';
EXEC test.sp__crt_tst_rtns 'dbo.ImportPathogensWikiUrl';
*/

GO
