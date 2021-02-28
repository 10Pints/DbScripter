using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using C5;
using SI.Software.Tools.CustomConfiguration.TestConfiguration;

namespace SI.Software.Tools.CustomConfiguration
{
   internal class DatabaseConfigurationElementElementBase : ConfigurationElementBase, IDatabaseConfigurationElement
   {
      #region Construction

      public DatabaseConfigurationElementElementBase()//ConfigurationElement that)
      {
         //DatabaseConfigurationElement = databaseConfigurationElement;
      }

      #endregion Construction

      #region Properties

      //private DatabaseConfigurationElement DatabaseConfigurationElement { get; }

      #endregion Properties

      #region Implementation of IDatabaseConfigurationElement

      /// <inheritdoc />
      public string Server
      {
         get
         {
            Debug.Fail("Test this");
            return null; //return DatabaseConfigurationElement.Server;
         }
      }

      /// <inheritdoc />
      public string Instance
      {
         get
         {
            Debug.Fail("Test this");
            return null; //return DatabaseConfigurationElement.Instance;
         }
      }

      /// <inheritdoc />
      public string Database
      {
         get
         {
            Debug.Fail("Test this");
            return null; //return DatabaseConfigurationElement.Database;
         }
      }

      /// <inheritdoc />
      public string DatabaseType
      {
         get
         {
            Debug.Fail("Test this");
            return null; //return DatabaseConfigurationElement.DatabaseType;
         }
      }

      /// <inheritdoc />
      public bool? CheckDbState
      {
         get
         {
            Debug.Fail("Test this");
            return null; //return DatabaseConfigurationElement.CheckDbState;
         }
      }

      /// <inheritdoc />
      public bool? DontCreate
      {
         get
         {
            Debug.Fail("Test this");
            return null; //return DatabaseConfigurationElement.DontCreate;
         }
      }

      /// <inheritdoc />
      public bool? DropFirst
      {
         get
         {
            Debug.Fail("Test this");
            return null; //return DatabaseConfigurationElement.DropFirst;
         }
      }

      /// <inheritdoc />
      public bool? DropAfter
      {
         get
         {
            Debug.Fail("Test this");
            return null; //return DatabaseConfigurationElement.DropAfter;
         }
      }

      /// <inheritdoc />
      public bool? PopulateStaticData
      {
         get
         {
            Debug.Fail("Test this");
            return null; //return DatabaseConfigurationElement.PopulateStaticData;
         }
      }

      /// <inheritdoc />
      public bool? PopulateDynamicData
      {
         get
         {
            Debug.Fail("Test this");
            return null; //DatabaseConfigurationElement.PopulateDynamicData;
         }
      }

      /// <inheritdoc />
      public IEnumerable<string> ScriptFiles
      {
         get
         {
            Debug.Fail("Test this");
            //return DatabaseConfigurationElement.ScriptFiles;
            return null;
         }
      }

      /// <inheritdoc />
      public IEnumerable<string> StaticDataTables
      {
         get
         {
            Debug.Fail("Test this");
            return null; //DatabaseConfigurationElement.StaticDataTables;
         }
      }

      /// <inheritdoc />
      public void GetDatabases(TreeSet<string> set)
      {
         Debug.Fail("Test this");
         //DatabaseConfigurationElement.GetDatabases(set);
      }

      #endregion
   }
}