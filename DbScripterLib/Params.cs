
#nullable enable 
#pragma warning disable CS8604//	Possible null reference argument for parameter 'rs' in 'SqlTypeEnum[]? Params.ParseRequiredTypes(string rs)'.	DbScripterLib	D:\Dev\C#\Db\Ut\DbScriptExporter\DbScripterLib\Params.cs	263	Active
#pragma warning disable CS8602// Dereference of a possibly null reference.

using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using static RSS.Common.Utils;
using static RSS.Common.Logger;

namespace DbScripterLib
{
   /// <summary>
   /// class to simplify the passing of a number of scripter config parameters
   /// </summary>
   public class Params
   {
      public string Name { get; set; }
      // Export flags
      private bool ? _isExprtngData   = null;
      public bool ? IsExprtngData
      {
         get => _isExprtngData;
         set => _isExprtngData = value;
      }

      private bool ? _isExprtngDb     = null;
      public bool ? IsExprtngDb 
      {
         get => _isExprtngDb;
         set => _isExprtngDb = value;
      }

      private bool ? _isExprtngFKeys  = null;
      public bool ? IsExprtngFKeys 
      {
         get => _isExprtngFKeys;
         set => _isExprtngFKeys = value;
      }

      private bool ? _isExprtngFns    = null;
      public bool ? IsExprtngFns
      {
         get => _isExprtngFns;
         set => _isExprtngFns = value;
      }

      private bool ? _isExprtngProcs  = null;
      public bool ? IsExprtngProcs
      {
         get => _isExprtngProcs;
         set => _isExprtngProcs = value;
      }

      private bool ? _isExprtngSchema = null;
      public bool ? IsExprtngSchema
      {
         get => _isExprtngSchema;
         set => _isExprtngSchema = value;
      }

      private bool ? _isExprtngTbls   = null;
      public bool ? IsExprtngTbls
      {
         get => _isExprtngTbls;
         set => _isExprtngTbls= value;
      }

      private bool ? _isExprtngTTys   = null;
      public bool ? IsExprtngTTys 
      {
         get => _isExprtngTTys;
         set => _isExprtngTTys = value;
      }

      private bool ? _isExprtngVws    = null;
      public bool ? IsExprtngVws 
      {
         get => _isExprtngVws;
         set => _isExprtngVws = value;
      }

      private string? _serverName = null;
      public string? ServerName
      {
         get => _serverName;
         set => _serverName = value;
      }

      private string? _instanceName = null;
      public string? InstanceName
      {
         get => _instanceName;
         set => _instanceName= value;
      }

      private string? _databaseName = null;
      public string? DatabaseName
      {
         get => _databaseName;
         set => _databaseName = value?.Trim(new [] { '[',']'});
      }

      private string? _exportScriptPath = null;
      public string? ExportScriptPath
      {
         get => _exportScriptPath;
         set => _exportScriptPath = value;
      }
 
      private string? _newSchemaName = null;
      public string? NewSchemaName
      {
         get => _newSchemaName;
         set =>_newSchemaName = value;
      }

      private List<string> _requiredSchemas = new();
      public List<string>? RequiredSchemas
      {
         get => _requiredSchemas;
         set => _requiredSchemas = value ?? (new());
      }

      private List<SqlTypeEnum> _requiredTypes = new();
      public List<SqlTypeEnum>? RequiredTypes
      {
         get => _requiredTypes;
         set => _requiredTypes = value ?? (new());
      }

      private SqlTypeEnum? _sqlType = null;
      public SqlTypeEnum? SqlType
      {
         get => _sqlType;

         set
         {
            _sqlType = value;
            SetExportFlagsFromSqlType();
         }
      }

      private CreateModeEnum? _createMode =null;
      public CreateModeEnum? CreateMode
      {
         get => _createMode;
         set => _createMode = value;
      }

      private bool? _scriptUseDb = null;
      public bool? ScriptUseDb
      {
         get => _scriptUseDb;
         set => _scriptUseDb = value;
      }
      private bool? _addTimestamp = null;
      public bool? AddTimestamp
      {
         get => _addTimestamp;
         set => _addTimestamp = value;
      }


      /// <summary>
      /// Checks the general criteria first like: server, instance, create type, sql type
      /// Returns true if the necessary state is set to do the required Export, false otherewise
      ///
      /// PRECONDITIONS:
      ///
      /// POSTCONDITIONS: Returns true if the necessary state is set to do the required Export, false otherewise
      /// POST 1: server   name specified
      /// POST 2: instance name specified
      /// POST 3: database name specified
      /// POST 4: create type   specified
      /// POST 5: sql type      specified
      /// POST 6: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
      /// 
      /// </summary>
      /// <returns></returns>
      public bool IsValid(out string? msg)
      {
         msg = null;
         bool ret = false;

         // -------------------------
         // Validate preconditions
         // -------------------------
 
         // -----------------------------------------
         // ASSERTION: postconditions validated
         // -----------------------------------------

         do
         {
            // POST 1: server   name specified
            if(string.IsNullOrEmpty(ServerName))
            {
               msg = "Server Name";
               break;
            }

            // POST 2: instance name specified
            if(string.IsNullOrEmpty(InstanceName))
            {
               msg = "Instance Name";
               break;
            }

            // POST 3: database name specified
            if(string.IsNullOrEmpty(DatabaseName))
            {
               msg = "Database Name";
               break;
            }

            // POST 4: create type   specified
            if(CreateMode?.Equals(CreateModeEnum.Undefined) ?? false)
            {
               msg = "Create Mode";
               break;
            }

            // POST 5: sql type      specified
            if(SqlType?.Equals(SqlTypeEnum.Undefined) ?? false)
            {
               msg = "Sql Type";
               break;
            }

            // POST 6: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
            if((SqlType == SqlTypeEnum.Table && CreateMode == CreateModeEnum.Alter))
            {
               msg = "if exporting tables dont specify alter";//  POST 1: 
               break;
            }

            // ASSERTION:     conditions validated
            ret = true;
         } while(false);

         // -------------------------
         // Validate postconditions
         // -------------------------
         // POST 1: server   name specified
         Postcondition((ret == false) || (!string.IsNullOrEmpty(ServerName)));
         // POST 2: instance name specified
         Postcondition((ret == false) || (!string.IsNullOrEmpty(InstanceName)));
         // POST 3: database name specified
         Postcondition((ret == false) || (!string.IsNullOrEmpty(DatabaseName)));
         // POST 4: create   type specified
         Postcondition((ret == false) || (!(CreateMode?.Equals(CreateModeEnum.Undefined) ?? true)));
         // POST 5: sql      type specified
         Postcondition((ret == false) || (!(SqlType   ?.Equals(SqlTypeEnum.Undefined   ) ?? true)));

         // -----------------------------------------
         // ASSERTION: postconditions validated
         // -----------------------------------------

         return ret;
      }

      public override bool Equals( object obj )
      {
         Params? b = obj as Params;
         Assertion(b != null);
         string msg = "";

         do
         {
            if(ServerName        != b.ServerName      ) { msg = $"a ServerName      :{ServerName      } b servername      :{b.ServerName      }"; break; }
            if(InstanceName      != b.InstanceName    ) { msg = $"a InstanceName    :{InstanceName    } b InstanceName    :{b.InstanceName    }"; break; }
            if(DatabaseName      != b.DatabaseName    ) { msg = $"a DatabaseName    :{DatabaseName    } b DatabaseName    :{b.DatabaseName    }"; break; }
            if(ExportScriptPath  != b.ExportScriptPath) { msg = $"a ExportScriptPath:{ExportScriptPath} b ExportScriptPath:{b.ExportScriptPath}"; break; }
            if(NewSchemaName     != b.NewSchemaName   ) { msg = $"a NewSchemaName   :{NewSchemaName   } b NewSchemaName   :{b.NewSchemaName   }"; break; }

            if((RequiredSchemas == null) && (b.RequiredSchemas != null) ||
               (RequiredSchemas != null) && (b.RequiredSchemas == null)) { msg = $"a RequiredSchemas :{RequiredSchemas   } b RequiredSchemas   :{b.RequiredSchemas   }"; break; }

            // Assertion: either both are null or both are not null
            if((RequiredSchemas != null) && (b.RequiredSchemas != null))
            {
               if(RequiredSchemas.Count != b.RequiredSchemas.Count) { msg = $"a RequiredSchemas :{RequiredSchemas   } b RequiredSchemas   :{b.RequiredSchemas   }"; break; }

               foreach(var item in RequiredSchemas)
               {
                  if(!b.RequiredSchemas.Contains(item)) 
                  {
                     msg = $"a RequiredSchemas :{RequiredSchemas   } b RequiredSchemas   :{b.RequiredSchemas   }"; 
                     break; 
                  }
               }
            }

            if((RequiredTypes == null) && (b.RequiredTypes != null) ||
               (RequiredTypes != null) && (b.RequiredTypes == null)) { msg = $"a RequiredTypes   :{RequiredTypes   } b RequiredTypes   :{b.RequiredTypes   }"; break; }

            if((RequiredTypes != null) && (b.RequiredTypes != null))
            {
               if(RequiredTypes.Count != b.RequiredTypes.Count) { msg = $"a RequiredTypes   :{RequiredTypes   } b RequiredTypes   :{b.RequiredTypes   }"; break; }

               foreach(var item in RequiredTypes)
                  if(!b.RequiredTypes.Contains(item)) { msg = $"a RequiredTypes   :{RequiredTypes   } b RequiredTypes   :{b.RequiredTypes   }"; break; }
            }

            if(SqlType      != b.SqlType)     { msg = $"a SqlType      :{SqlType      } b SqlType      :{b.SqlType     }"; break; }
            if(CreateMode   != b.CreateMode)  { msg = $"a CreateMode   :{CreateMode   } b CreateMode   :{b.CreateMode  }"; break; }
            if(ScriptUseDb  != b.ScriptUseDb) { msg = $"a ScriptUseDb  :{ScriptUseDb  } b ScriptUseDb  :{b.ScriptUseDb }"; break; }
            if(AddTimestamp != b.AddTimestamp){ msg = $"a AddTimestamp :{AddTimestamp } b AddTimestamp :{b.AddTimestamp}"; break; }

            // Assertion if here then all equality tests passeds
            return true;
         } while(false);

         Log($"Params Equals failed: { msg}");
         //Assertion if here then a check failed
         return false;
      }

      public override string ToString()
      {
         string Line = new string('-', 200) + "\r\n";
         StringBuilder s = new StringBuilder();

         s.Append("\r\n");
         s.Append(Line);
         s.AppendLine($" Type            : {GetType().Name   }");
         s.AppendLine($" Name            : {Name             }");
         s.AppendLine(Line);
         s.AppendLine($" ServerName      : {ServerName       }");
         s.AppendLine($" InstanceName    : {InstanceName     }");
         s.AppendLine($" DatabaseName    : {DatabaseName     }");
         s.AppendLine($" ExportScriptPath: {ExportScriptPath }");
         s.AppendLine();
         s.AppendLine($" RequiredSchemas :");

         foreach(var item in RequiredSchemas)
            s.AppendLine($"\t{item}"); 

         s.AppendLine();
         s.AppendLine($" RequiredTypes : ");
         foreach(var item in RequiredTypes)
            s.AppendLine($"\t{item}"); 

         s.AppendLine();
         s.AppendLine($" SqlType         : {SqlType          }");
         s.AppendLine($" CreateMode      : {CreateMode       }");
         s.AppendLine($" ScriptUseDb     : {ScriptUseDb      }");
         s.AppendLine($" AddTimestamp    : {AddTimestamp     }");
         s.AppendLine($" IsExprtngData   : {IsExprtngData    }");
         s.AppendLine($" IsExprtngDb     : {IsExprtngDb      }");
         s.AppendLine($" IsExprtngFKeys  : {IsExprtngFKeys   }");
         s.AppendLine($" IsExprtngFns    : {IsExprtngFns     }");
         s.AppendLine($" IsExprtngProcs  : {IsExprtngProcs   }");
         s.AppendLine($" IsExprtngSchema : {IsExprtngSchema  }");
         s.AppendLine($" IsExprtngTbls   : {IsExprtngTbls    }");
         s.AppendLine($" IsExprtngTTys   : {IsExprtngTTys    }");
         s.AppendLine($" IsExprtngVws    : {IsExprtngVws     }");
         s.AppendLine($" NewSchemaName   : {NewSchemaName    }");
         s.AppendLine(Line);
         return s.ToString();
      }

      // Warning	CS0659	'Params' overrides Object.Equals(object o) but does not override Object.GetHashCode()	DbScripterLib	D:\Dev\Db\Ut\DbScriptExporter\DbScripterLib\Params.cs	11	Active

      public override int GetHashCode()
      {
         return base.GetHashCode();
      }

      public Params
      (
          string           name            = ""
         ,Params?          prms            = null // Use this initial state to start with 
         ,string?          serverName      = null // and update with the subsequent parameters
         ,string?          instanceName    = null 
         ,string?          databaseName    = null 
         ,string?          exportScriptPath= null 
         ,string?          newSchemaName   = null 
         ,string?          requiredSchemas = null 
         ,string?          requiredTypes   = null 
         ,SqlTypeEnum?     sqlType         = SqlTypeEnum    .Undefined
         ,CreateModeEnum?  createMode      = CreateModeEnum .Undefined
         ,bool?            scriptUseDb     = null
         ,bool?            addTimestamp    = null
         ,bool?            isExprtngData   = null
         ,bool?            isExprtngDb     = null
         ,bool?            isExprtngFKeys  = null
         ,bool?            isExprtngFns    = null
         ,bool?            isExprtngProcs  = null
         ,bool?            isExprtngSchema = null
         ,bool?            isExprtngTbls   = null
         ,bool?            isExprtngTTys   = null
         ,bool?            isExprtngViews  = null
      )
      {
         Name = name;
         
         // if prms specified then start with prms state
         if(prms != null)
            CopyFrom(prms);   // force copy

         // Only append if specified not null
         PopFrom
         (
             serverName       : serverName
            ,instanceName     : instanceName
            ,databaseName     : databaseName
            ,exportScriptPath : exportScriptPath
            ,newSchemaName    : newSchemaName
            ,requiredSchemas  : requiredSchemas
            ,requiredTypes    : requiredTypes
            ,sqlType          : sqlType
            ,createMode       : createMode
            ,scriptUseDb      : scriptUseDb
            ,addTimestamp     : addTimestamp
            ,isExprtngData    : isExprtngData
            ,isExprtngDb      : isExprtngDb
            ,isExprtngFKeys   : isExprtngFKeys
            ,isExprtngFns     : isExprtngFns
            ,isExprtngProcs   : isExprtngProcs
            ,isExprtngSchema  : isExprtngSchema
            ,isExprtngTbls    : isExprtngTbls
            ,isExprtngTTys    : isExprtngTTys
            ,isExprtngViews   : isExprtngViews
         );
      }


      public void ClearState()
      {
         ServerName        = null;
         InstanceName      = null;
         DatabaseName      = null;
         ExportScriptPath  = null;
         NewSchemaName     = null;
         RequiredSchemas   = null;
         RequiredTypes     = null;
         SqlType           = SqlTypeEnum     .Undefined;
         CreateMode        = CreateModeEnum  .Undefined;
         ScriptUseDb       = false;
         AddTimestamp      = false;
         IsExprtngData     = false;
         IsExprtngDb       = false;
         IsExprtngFKeys    = false;
         IsExprtngFns      = false;
         IsExprtngProcs    = false;
         IsExprtngSchema   = false;
         IsExprtngTbls     = false;
         IsExprtngTTys     = false;
         IsExprtngVws      = false;
      }

      /// <summary>
      /// PRECONDITIONS:
      /// none
      /// POSTCONDITIONS:
      /// Returns an array of SqlTypeEnum based on  the characters in 
      /// the supplied string.
      /// Each characters is a key to th etype as defined in the map spec'd below
      /// asserts that all characters in the string are legal types
      /// 
      /// Key mapping:
      ///   F : function
      ///   P : procedure
      ///   T : table
      ///   V : view
      ///   TTy: Table type
      /// </summary>
      /// <param name="rs">like:  'FTPV'</param>
      /// <returns></returns>
      public List<SqlTypeEnum>? ParseRequiredTypes( string rs )
      {
         if(string.IsNullOrEmpty(rs))
            return null;

         var validTypes = "F,P,S,T,TTY,V".Split(',').ToList();
         rs = rs.ToUpper();

         // trim and remove surrounding {}
         rs = rs.Trim(new[] { ' ', '{', '}' });
         var reqTypes = rs.Split(',');

         List<SqlTypeEnum> list = new List<SqlTypeEnum>();
         int ndx = -1;

         // get the types, chk if valid
         foreach (var item in reqTypes)
         {
            ndx = validTypes.IndexOf(item);
            switch(ndx)
            {
            case 0: list.Add(SqlTypeEnum.Function) ; break;
            case 1: list.Add(SqlTypeEnum.Procedure); break;
            case 2: list.Add(SqlTypeEnum.Schema)   ; break;
            case 3: list.Add(SqlTypeEnum.Table)    ; break;
            case 4: list.Add(SqlTypeEnum.TableType); break;
            case 5: list.Add(SqlTypeEnum.View)     ; break;

            default:
               throw new ArgumentException($"Unrecognised SQL type {item}");
            }
         }

         return list;
      }


      /// <summary>
      /// Handles strings like:
      ///   "{test, [dbo]", "dbo",  "", null}
      ///   "   {   dbo    }   ", "" null
      /// 
      /// PRECONDITIONS: 
      ///   PRE 1: Server must be specified
      ///   PRE 2: instance must be specified
      ///   
      /// POSTCONDITIONS: 
      ///   POST 1: returns null if rs is null, empty
      ///   POST 2: returns null if rs contains no schemas
      ///   POST 3: returns all the required schemas in rs in the returned collection
      ///   POST 4: contains no empty schemas
      ///   POST 5: Server, Instance Database exist
      ///   POST 6: required schemas do exist in the database
      ///           AND they match the Case of the Db Schema name
      ///
      /// Method:
      ///   trim
      ///   remove surrounding {}
      ///   split on ,
      ///   for each schema: remove any []and trim
      /// </summary>
      /// <param name="rs">required_schemas</param>
      /// <returns>string array of the unwrapped schemas in rs</returns>
      public List<string>? ParseRequiredSchemas( string? rs )
      {
         Precondition<ArgumentException>(!string.IsNullOrEmpty(ServerName  ), "Server must be specified");
         Precondition<ArgumentException>(!string.IsNullOrEmpty(InstanceName), "instance must be specified");

         //   POST 1: returns null if rs is null, empty
         if(string.IsNullOrEmpty(rs))
            return null;

         // trim and remove surrounding {}
         rs = rs.Trim(new[] { ' ', '{', '}' });

         // split on ,
         var rschemasNames = rs.Split(new []{ ',', '[', ']'}, StringSplitOptions.RemoveEmptyEntries);
         var requiredSchemaList    = new List<string>();

         // for each schema:  any [] and trim
         for(int i = 0; i < rschemasNames.Length; i++)
         {
            var rschemaName = rschemasNames[i];
            rschemaName = rschemaName.Trim(new[] { ' ', '[', ']' });
            
            if(!string.IsNullOrEmpty(rschemaName))
               requiredSchemaList.Add(rschemaName);
         }

         // POST 2: returns null if rs contains no schemas
         if(requiredSchemaList.Count == 0)
            return null;

         // POST 3: returns all the required schemas in rs in the returned collection
         // POST 4: contains no empty schemas
         foreach(var item in requiredSchemaList)
            Postcondition<ArgumentException>(string.IsNullOrEmpty(item) == false, "POST 4: should contain no empty schemas");

         // POST 5: Server, Instance Database exist
         Server? svr = CreateAndOpenServer( ServerName, InstanceName);
         Assertion(svr != null);
         Database? db = svr?.Databases["Covid_T1"];
         Assertion(db != null);
         SchemaCollection? actSchemas = db?.Schemas;
         int cnt = actSchemas?.Count ?? 0;
         Assertion((cnt != 0));

         // POST 6: the schemas found should exist in the database
         //         AND match the Case of the Db Schema name
         List<string> actDbSchemaNames = new List<string>();

         // Get a list of exisitng schema names
         foreach(Schema item in actSchemas)
            actDbSchemaNames.Add(item.Name);

         // try to match the schema names - if found use the actuak schema name (case correct)
         for( int i = 0; i< requiredSchemaList.Count; i++)//dbSchemaName in dbSchemas)
         {
            var reqSchemaName = requiredSchemaList[i];
            var ndx = actDbSchemaNames.FindIndex(x => x.Equals(reqSchemaName, StringComparison.OrdinalIgnoreCase));

            if(ndx>-1)
               requiredSchemaList[i] = actDbSchemaNames[ndx];
            else
               Assertion( false, $"Schema {reqSchemaName} does not exist in the database");
         }

         // POST 6: asserted: the required schemas do exist in the database
         //         AND they match the case of the Db Schema name
         return requiredSchemaList;
      }

      public static Params PopParams
         (
             string           name              = ""
            ,Params?          prms              = null // Use this state to start with and update with the subsequent parameters
            ,string?          serverName        = null
            ,string?          instanceName      = null
            ,string?          databaseName      = null
            ,string?          exportScriptPath  = null
            ,string?          newSchemaName     = null
            ,string?          requiredSchemas   = null
            ,string?          requiredTypes     = null
            ,SqlTypeEnum?     sqlType           = SqlTypeEnum     .Undefined
            ,CreateModeEnum?  createMode        = CreateModeEnum  .Undefined
            ,bool?            scriptUseDb       = null
            ,bool?            addTimestamp      = null
            ,bool?            isExprtngData     = null
            ,bool?            isExprtngDb       = null
            ,bool?            isExprtngFKeys    = null
            ,bool?            isExprtngFns      = null
            ,bool?            isExprtngProcs    = null
            ,bool?            isExprtngSchema   = null
            ,bool?            isExprtngTbls     = null
            ,bool?            isExprtngTTys     = null
            ,bool?            isExprtngVws      = null
         )
      {
         Params p = new Params();

         p.PopFrom(
             prms:            prms
            ,serverName:      serverName
            ,instanceName:    instanceName
            ,databaseName:    databaseName
            ,exportScriptPath:exportScriptPath
            ,newSchemaName:   newSchemaName
            ,requiredSchemas: requiredSchemas
            ,requiredTypes:   requiredTypes
            ,sqlType:         sqlType
            ,createMode:      createMode
            ,scriptUseDb:     scriptUseDb
            ,addTimestamp:    addTimestamp
            ,isExprtngData  : isExprtngData  
            ,isExprtngDb    : isExprtngDb    
            ,isExprtngFKeys : isExprtngFKeys 
            ,isExprtngFns   : isExprtngFns   
            ,isExprtngProcs : isExprtngProcs 
            ,isExprtngSchema: isExprtngSchema
            ,isExprtngTbls  : isExprtngTbls  
            ,isExprtngTTys  : isExprtngTTys  
            ,isExprtngViews : isExprtngVws 
         );

         p.Name = name;
         return p;
      }


      public void PopFrom
          (
              Params?         prms              = null // Use this state to start with and update with the subsequent parameters
             ,string?         serverName        = null
             ,string?         instanceName      = null
             ,string?         databaseName      = null
             ,string?         exportScriptPath  = null
             ,string?         newSchemaName     = null
             ,string?         requiredSchemas   = null
             ,string?         requiredTypes     = null
            ,SqlTypeEnum?     sqlType           = null // must be null to avoid overwriting prms if set
            ,CreateModeEnum?  createMode        = null // must be null to avoid overwriting prms if set
             ,bool?           scriptUseDb       = null
             ,bool?           addTimestamp      = null
             ,bool?           isExprtngData     = null
             ,bool?           isExprtngDb       = null
             ,bool?           isExprtngFKeys    = null
             ,bool?           isExprtngFns      = null
             ,bool?           isExprtngProcs    = null
             ,bool?           isExprtngSchema   = null
             ,bool?           isExprtngTbls     = null
             ,bool?           isExprtngTTys     = null
             ,bool?           isExprtngViews    = null
          )
      {
         // overwite 
         // overwrite specified parameters if not null
         // If prms is supplied use it as the default configuration
         if(prms != null)
            CopyFrom(prms);

         // Update state if overwrite or param is defined
         // if (over write and not yet updated) OR (append and (param not null OR not already updated)
         UpdatePropertyIfNeccessary("ServerName",      serverName);
         UpdatePropertyIfNeccessary("InstanceName",    instanceName);
         UpdatePropertyIfNeccessary("DatabaseName",    databaseName);
         UpdatePropertyIfNeccessary("ExportScriptPath",exportScriptPath);
         UpdatePropertyIfNeccessary("NewSchemaName",   newSchemaName);
         //UpdatePropertyIfNeccessary("RequiredSchemas", requiredSchemas);
         //UpdatePropertyIfNeccessary("RequiredTypes",   requiredTypes);
         UpdatePropertyIfNeccessary("SqlType",         sqlType); 
         UpdatePropertyIfNeccessary("CreateMode",      createMode);
         UpdatePropertyIfNeccessary("ScriptUseDb",     scriptUseDb); 
         UpdatePropertyIfNeccessary("AddTimestamp",    addTimestamp);

         UpdatePropertyIfNeccessary("IsExprtngData",   isExprtngData);
         UpdatePropertyIfNeccessary("IsExprtngDb",     isExprtngDb);
         UpdatePropertyIfNeccessary("IsExprtngFKeys",  isExprtngFKeys);
         UpdatePropertyIfNeccessary("IsExprtngFns",    isExprtngFns);
         UpdatePropertyIfNeccessary("IsExprtngProcs",  isExprtngProcs);
         UpdatePropertyIfNeccessary("IsExprtngSchema", isExprtngSchema);
         UpdatePropertyIfNeccessary("IsExprtngTbls",   isExprtngTbls);
         UpdatePropertyIfNeccessary("IsExprtngTTys",   isExprtngTTys);
         UpdatePropertyIfNeccessary("IsExprtngVws",    isExprtngViews);

         // Only Get the schemas once we have the svr name and db
         if(!string.IsNullOrEmpty(requiredSchemas))
            RequiredSchemas = ParseRequiredSchemas(requiredSchemas) ?? null;

         if(!string.IsNullOrEmpty(requiredTypes))
            RequiredTypes   = ParseRequiredTypes  (requiredTypes)   ?? null;

         SetExportFlagsFromSqlType();
      }

      /// <summary>
      /// Used to flag if update or not
      /// if (over write and not yet updated) OR (append and (param not null OR not already updated)
      /// </summary>
      /// <param name="append"></param>
      /// <param name=""></param>
      /// <returns></returns>
      public bool UpdatePropertyIfNeccessary<T>( string propertyName, T _param )
      {
         bool ret = false;

         if(propertyName == "DbOpType")
            ret = false;

         // if (over write and not yet updated) OR (append and param not null) // if(((!append) && (updatedMap[propertyName] == false)
         if(_param != null)
         {
            var property = this.GetType().GetProperty(propertyName);
            Assertion(property != null, $"UpdatePropertyIfNeccessary({propertyName}) failed to get the property");

            if(property != null)
            {
               Type t = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
               object? safeValue = (_param == null) ? null : Convert.ChangeType(_param, t);
               property.SetValue(this, safeValue, null);
            }
         }

         return ret;
      }

      /// <summary>
      /// Full copy all state from p bar status
      /// </summary>
      /// <param name="p"></param>
      public void CopyFrom( Params p )
      {
         ServerName        = p.ServerName;
         InstanceName      = p.InstanceName;
         DatabaseName      = p.DatabaseName;
         ExportScriptPath  = p.ExportScriptPath;
         NewSchemaName     = p.NewSchemaName;
         RequiredSchemas   = p.RequiredSchemas;
         RequiredTypes     = p.RequiredTypes;
         SqlType           = p.SqlType;
         CreateMode        = p.CreateMode;
         ScriptUseDb       = p.ScriptUseDb;
         AddTimestamp      = p.AddTimestamp;
         IsExprtngData     = p.IsExprtngData;
         IsExprtngDb       = p.IsExprtngDb;
         IsExprtngFKeys    = p.IsExprtngFKeys;
         IsExprtngFns      = p.IsExprtngFns;
         IsExprtngProcs    = p.IsExprtngProcs;
         IsExprtngSchema   = p.IsExprtngSchema;
         IsExprtngTbls     = p.IsExprtngTbls;
         IsExprtngTTys     = p.IsExprtngTTys;
         IsExprtngVws      = p.IsExprtngVws;

         SetExportFlagsFromSqlType();
     }

      /// <summary>
      /// Configures teh IsExporting flags basedon the SQL Expoty type
      /// </summary>
      protected void SetExportFlagsFromSqlType()
      {
         // set the is exporting flags based on the type
         if(SqlType == SqlTypeEnum.Database)  IsExprtngDb     = true;
         if(SqlType == SqlTypeEnum.Schema)    IsExprtngSchema = true;
         if(SqlType == SqlTypeEnum.Function)  IsExprtngFns    = true;
         if(SqlType == SqlTypeEnum.Procedure) IsExprtngProcs  = true;
         if(SqlType == SqlTypeEnum.Table)    {IsExprtngTbls   = true; IsExprtngTTys   = true;}
         if(SqlType == SqlTypeEnum.TableType) IsExprtngTTys   = true;
         if(SqlType == SqlTypeEnum.View)      IsExprtngVws    = true;
      }

      /// <summary>
      /// Configures the IsExporting flags basedon the SQL Expoty type
      /// </summary>
      protected void SetExportFlagState(bool? st = null)
      {
         // set the is exporting flags based on the type
         IsExprtngDb     = st;
         IsExprtngSchema = st;
         IsExprtngFns    = st;
         IsExprtngProcs  = st;
         IsExprtngTbls   = st;
         IsExprtngTTys   = st;
         IsExprtngVws    = st;
         IsExprtngData   = st;
      }
   }
}
