-- drop database template.sql v1.0.0.0
USE [master]
-- Kick all other users out:
ALTER DATABASE [<DB_NAME>] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- Drop the database
DROP DATABASE [<DB_NAME>]
GO
