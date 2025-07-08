SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

GO


-- =============================================
-- Author:      Terry Watts
-- Create date: 29-NOV-2024
-- Description: Pathogen Search Utility
-- =============================================
CREATE   FUNCTION [dbo].[fnFindPathogen](@pathogen VARCHAR(60))
RETURNS
@t TABLE
(
   pathogen_nm       VARCHAR(1000) NULL,
   crop_nm           VARCHAR(100) NULL,
   latin_name        VARCHAR(250)  NULL,
   alt_common_names  VARCHAR(200) NULL,
   alt_latin_names   VARCHAR(200) NULL,
   ph_common_names   VARCHAR(100)  NULL
)
AS
BEGIN
   DECLARE
       @srch   VARCHAR(60) = CONCAT('%', dbo.fnTrim(@pathogen), '%')
      ,@len    INT
      ,@cnt    INT = 0
   ;

   SET @pathogen = dbo.fnTrim(@pathogen);
   SET @srch     = CONCAT('%', dbo.fnTrim(@pathogen), '%')

   SET @len = dbo.fnLen(@pathogen);

   -- Search, and if nothing found so far try lopping off some characters till found
   WHILE @len > 1
   BEGIN
      SET @cnt = @cnt + 1;

      INSERT INTO @t(pathogen_nm,crop_nm, latin_name,alt_common_names,alt_latin_names,ph_common_names)
      SELECT       p.pathogen_nm,crop_nm, latin_name,alt_common_names,alt_latin_names,ph_common_names
      FROM Pathogen p LEFT JOIN CropPathogen cp ON p.pathogen_nm= cp.pathogen_nm
      WHERE p. pathogen_nm LIKE @srch OR alt_common_names like @srch OR latin_name LIKE @srch OR alt_latin_names LIKE @srch;

      if @cnt > 50
         break;

      -- if not found lop off 1 character in srch
      IF @@ROWCOUNT = 0
      BEGIN
         --INSERT INTO @t(pathogen_nm) VALUES(CONCAT('@cnt: ', @cnt, ' @len: ', @len,' @s:[',@srch, ']'));

         SET @srch = CONCAT('%',SUBSTRING( @pathogen, 1, @len), '%');
         SET @len = @len - 1;
      END
      ELSE
      BEGIN
         --INSERT INTO @t(pathogen_nm) VALUES('@@ROWCOUNT <> 0');
         BREAK;
      END
   END

   RETURN;
END
/*
SELECT * FROM dbo.fnFindPathogen('Sigatoka');
SELECT pathogen_nm FROM dbo.fnFindPathogen('Alternaria');
select * pATHOGEN P lEFT JOIN CROP
CREATE OR ALTERnaria*/


GO
