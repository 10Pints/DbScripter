using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics.CodeAnalysis;
using C5;
using SI.Software.Tools.CustomConfiguration.TestConfiguration;

namespace SI.Software.Tools.CustomConfiguration
{
   [SuppressMessage("ReSharper", "IdentifierTypo")]
   [SuppressMessage("ReSharper", "StringLiteralTypo")]
   public class DatabaseConfigurationSection : RecursiveConfigurationSection, IDatabaseConfigurationElement, IRecursiveConfigurationElement
   {
      #region Properties

      internal DatabaseConfigurationElementElementBase AggregatedDatabaseElementElement => AggregatedElement as DatabaseConfigurationElementElementBase;

      #endregion Properties
      #region Construction

      protected DatabaseConfigurationSection(string childPropertyName)
      : base(childPropertyName)
      {
      }

      public override void Init_()
      {
         AggregatedElement = new DatabaseConfigurationElementElementBase();
         AggregatedDatabaseElementElement.Init_(this);
      }

      #endregion Construction
      #region Implementation of IDatabaseConfigurationElement

      /// <inheritdoc />
      [ConfigurationProperty("server", IsRequired = false)]
      public string Server => AggregatedDatabaseElementElement.Server;

      /// <inheritdoc />
      [ConfigurationProperty("instance", IsRequired = false)]
      public string Instance => AggregatedDatabaseElementElement.Instance;

      /// <inheritdoc />
      [ConfigurationProperty("database", IsRequired = false)]
      public string Database => AggregatedDatabaseElementElement.Database;

      /// <inheritdoc />
      [ConfigurationProperty("database_type", IsRequired = false)]
      public string DatabaseType => AggregatedDatabaseElementElement.DatabaseType;

      /// <inheritdoc />
      [ConfigurationProperty("check_db_state", IsRequired = false)]
      public bool? CheckDbState => AggregatedDatabaseElementElement.CheckDbState;

      /// <inheritdoc />
      // ReSharper disable once IdentifierTypo
      [ConfigurationProperty("dont_create", IsRequired = false)]
      public bool? DontCreate => AggregatedDatabaseElementElement.DontCreate;

      /// <inheritdoc />
      [ConfigurationProperty("drop_first", IsRequired = false)]
      public bool? DropFirst => AggregatedDatabaseElementElement.DropFirst;

      /// <inheritdoc />
      [ConfigurationProperty("drop_after", IsRequired = false)]
      public bool? DropAfter => AggregatedDatabaseElementElement.DropAfter;

      /// <inheritdoc />
      [ConfigurationProperty("populate_static_data", IsRequired = false)]
      public bool? PopulateStaticData => AggregatedDatabaseElementElement.PopulateStaticData;

      /// <inheritdoc />
      [ConfigurationProperty("populate_dynamic_data", IsRequired = false)]
      public bool? PopulateDynamicData => AggregatedDatabaseElementElement.PopulateDynamicData;

      /// <inheritdoc />
      [ConfigurationProperty("script_files", IsRequired = false)]
      public IEnumerable<string> ScriptFiles => AggregatedDatabaseElementElement.ScriptFiles;

      /// <inheritdoc />
      [ConfigurationProperty("static_data_tables", IsRequired = false)]
      public IEnumerable<string> StaticDataTables => AggregatedDatabaseElementElement.StaticDataTables;

      /// <inheritdoc />
      public void GetDatabases(TreeSet<string> set)
      {
         AggregatedDatabaseElementElement.GetDatabases(set);
      }

      #endregion
   }
}