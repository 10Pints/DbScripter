-- create database template.sql v1.0.0.0
USE [master]
GO

CREATE DATABASE [<DB_NAME>]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'<DB_NAME>', FILENAME = N'<PATH_TAG>\<DB_NAME>.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'<DB_NAME>_log', FILENAME = N'<PATH_TAG>\<DB_NAME>_log.ldf' , SIZE = 139264KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [<DB_NAME>] SET COMPATIBILITY_LEVEL = 120
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [<DB_NAME>].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [<DB_NAME>] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [<DB_NAME>] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [<DB_NAME>] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [<DB_NAME>] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [<DB_NAME>] SET ARITHABORT OFF 
GO
ALTER DATABASE [<DB_NAME>] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [<DB_NAME>] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [<DB_NAME>] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [<DB_NAME>] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [<DB_NAME>] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [<DB_NAME>] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [<DB_NAME>] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [<DB_NAME>] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [<DB_NAME>] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [<DB_NAME>] SET  DISABLE_BROKER 
GO
ALTER DATABASE [<DB_NAME>] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [<DB_NAME>] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [<DB_NAME>] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [<DB_NAME>] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [<DB_NAME>] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [<DB_NAME>] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [<DB_NAME>] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [<DB_NAME>] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [<DB_NAME>] SET  MULTI_USER 
GO
ALTER DATABASE [<DB_NAME>] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [<DB_NAME>] SET DB_CHAINING OFF 
GO
ALTER DATABASE [<DB_NAME>] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [<DB_NAME>] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [<DB_NAME>] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [<DB_NAME>] SET QUERY_STORE = OFF
GO
USE [<DB_NAME>]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
ALTER DATABASE [<DB_NAME>] SET  READ_WRITE 
GO
