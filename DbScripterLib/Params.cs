
#nullable enable 
#pragma warning disable CS8604//	Possible null reference argument for parameter 'rs' in 'SqlTypeEnum[]? Params.ParseRequiredTypes(string rs)'.	DbScripterLib	D:\Dev\C#\Db\Ut\DbScriptExporter\DbScripterLib\Params.cs	263	Active
#pragma warning disable CS8602// Dereference of a possibly null reference.

using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using RSS.Common;
using static RSS.Common.Utils;
using static RSS.Common.Logger;

namespace DbScripterLibNS
{
   /// <summary>
   /// class to simplify the passing of a number of scripter config parameters
   /// </summary>
   public class Params
   {
      public string Name { get; set; }
      public string? LogFile { get; set; }
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
         set => _newSchemaName = value;
      }

      private bool? _displayScript = null;
      public bool? DisplayScript
      {
         get => _displayScript;
         set => _displayScript = value;
      }

      private List<string> _requiredSchemas = new();
      public List<string>? RequiredSchemas
      {
         get => _requiredSchemas;
         set => _requiredSchemas = value ?? (new());
      }


      /// <summary>
      /// There is only 1 root type
      /// which is the parent of the required child TargetChildTypes 
      /// Can only be Database or schema
      /// </summary>
      public SqlTypeEnum? RootType
      {
         get => _rootType;

         set
         {
            _rootType = value;
            SetExportFlagsFromRootType();
         }
      }
      private SqlTypeEnum? _rootType = null;


      /// <summary>
      /// the target types are 1 or more required child types
      /// under the root
      /// 
      /// INVARIANT: cannot be empty after init
      /// </summary>
      public List<SqlTypeEnum>? TargetChildTypes
      {
         get => _targetTypes;
         set => _targetTypes = value ?? (new());
      }
      private List<SqlTypeEnum> _targetTypes = new();

      public CreateModeEnum? CreateMode
      {
         get => _createMode;
         set => _createMode = value;
      }
      private CreateModeEnum? _createMode =null;

      public bool? ScriptUseDb
      {
         get => _scriptUseDb;
         set => _scriptUseDb = value;
      }
      private bool? _scriptUseDb = null;

      public bool? AddTimestamp
      {
         get => _addTimestamp;
         set => _addTimestamp = value;
      }
      private bool? _addTimestamp = null;


      /// <summary>
      /// Checks the general criteria first like: server, instance, create type, sql type
      /// Returns true if the necessary state is set to do the required Export, false otherewise
      ///
      /// Utils.PreconditionS:
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
      public bool IsValid(out string msg)
      {
         msg = "";
         bool ret = false;

         // -------------------------
         // Validate Utils.Preconditions
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
            if(RootType?.Equals(SqlTypeEnum.Undefined) ?? false)
            {
               msg = "Sql Type";
               break;
            }

            // POST 6: if exporting tables dont specify alter - or the Microsoft scripter will silently fail to emit the script
            if((RootType == SqlTypeEnum.Table && CreateMode == CreateModeEnum.Alter))
            {
               msg = "if exporting tables dont specify alter";//  POST 1: 
               break;
            }

            if(string.IsNullOrEmpty(LogFile))
            {
               msg = "Log File";
               break;
            }

            // ASSERTION:     conditions validated
            ret = true;
         } while(false);

         // -------------------------
         // Validate postconditions
         // -------------------------
         // POST 1: server   name specified
         Utils.Postcondition((ret == false) || (!string.IsNullOrEmpty(ServerName)));
         // POST 2: instance name specified
         Utils.Postcondition((ret == false) || (!string.IsNullOrEmpty(InstanceName)));
         // POST 3: database name specified
         Utils.Postcondition((ret == false) || (!string.IsNullOrEmpty(DatabaseName)));
         // POST 4: create   type specified
         Utils.Postcondition((ret == false) || (!(CreateMode?.Equals(CreateModeEnum.Undefined) ?? true)));
         // POST 5: sql      type specified
         Utils.Postcondition((ret == false) || (!(RootType   ?.Equals(SqlTypeEnum.Undefined   ) ?? true)));

         // -----------------------------------------
         // ASSERTION: postconditions validated
         // -----------------------------------------

         return ret;
      }

      public override bool Equals( object obj )
      {
         Params? b = obj as Params;
         Utils.Assertion(b != null);
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

            if((TargetChildTypes == null) && (b.TargetChildTypes != null) ||
               (TargetChildTypes != null) && (b.TargetChildTypes == null)) { msg = $"a TargetChildTypes   :{TargetChildTypes   } b TargetChildTypes   :{b.TargetChildTypes   }"; break; }

            if((TargetChildTypes != null) && (b.TargetChildTypes != null))
            {
               if(TargetChildTypes.Count != b.TargetChildTypes.Count) { msg = $"a TargetChildTypes   :{TargetChildTypes   } b TargetChildTypes   :{b.TargetChildTypes   }"; break; }

               foreach(var item in TargetChildTypes)
                  if(!b.TargetChildTypes.Contains(item)) { msg = $"a TargetChildTypes   :{TargetChildTypes   } b TargetChildTypes   :{b.TargetChildTypes   }"; break; }
            }

            if(RootType     != b.RootType)    { msg = $"a RootType     :{RootType     } b RootType     :{b.RootType    }"; break; }
            if(CreateMode   != b.CreateMode)  { msg = $"a CreateMode   :{CreateMode   } b CreateMode   :{b.CreateMode  }"; break; }
            if(ScriptUseDb  != b.ScriptUseDb) { msg = $"a ScriptUseDb  :{ScriptUseDb  } b ScriptUseDb  :{b.ScriptUseDb }"; break; }
            if(AddTimestamp != b.AddTimestamp){ msg = $"a AddTimestamp :{AddTimestamp } b AddTimestamp :{b.AddTimestamp}"; break; }

            // Assertion if here then all equality tests passeds
            return true;
         } while(false);

         Logger.Log($"Params Equals failed: { msg}");
         //Assertion if here then a check failed
         return false;
      }

      public override string ToString()
      {
         string Line = new string('-', 80);
         StringBuilder s = new StringBuilder();

         s.Append("\r\n");
         s.AppendLine(Line);
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
         s.AppendLine($" TargetChildTypes : ");
         foreach(var item in TargetChildTypes)
            s.AppendLine($"\t{item}"); 

         s.AppendLine();
         s.AppendLine($" RootType        : {RootType         }");
         s.AppendLine($" CreateMode      : {CreateMode       }");
         s.AppendLine($" ScriptUseDb     : {ScriptUseDb      }");
         s.AppendLine($" AddTimestamp    : {AddTimestamp     }");
         s.AppendLine($" LogFile         : {LogFile          }");
         s.AppendLine($" IsExprtngData   : {IsExprtngData    }");
         s.AppendLine($" IsExprtngDb     : {IsExprtngDb      }");
         s.AppendLine($" IsExprtngSchema : {IsExprtngSchema  }");
         s.AppendLine($" IsExprtngProcs  : {IsExprtngProcs   }");
         s.AppendLine($" IsExprtngFns    : {IsExprtngFns     }");
         s.AppendLine($" IsExprtngTbls   : {IsExprtngTbls    }");
         s.AppendLine($" IsExprtngFKeys  : {IsExprtngFKeys   }");
         s.AppendLine($" IsExprtngVws    : {IsExprtngVws     }");
         s.AppendLine($" IsExprtngTTys   : {IsExprtngTTys    }");
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
         ,string?          logFile         = null
         ,bool?            isExprtngData   = null
         ,bool?            isExprtngDb     = null
         ,bool?            isExprtngFKeys  = null
         ,bool?            isExprtngFns    = null
         ,bool?            isExprtngProcs  = null
         ,bool?            isExprtngSchema = null
         ,bool?            isExprtngTbls   = null
         ,bool?            isExprtngTTys   = null
         ,bool?            isExprtngVws    = null
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
            ,logFile          : logFile
            ,isExprtngData    : isExprtngData
            ,isExprtngDb      : isExprtngDb
            ,isExprtngFKeys   : isExprtngFKeys
            ,isExprtngFns     : isExprtngFns
            ,isExprtngProcs   : isExprtngProcs
            ,isExprtngSchema  : isExprtngSchema
            ,isExprtngTbls    : isExprtngTbls
            ,isExprtngTTys    : isExprtngTTys
            ,isExprtngVws     : isExprtngVws
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
         TargetChildTypes  = null;
         RootType          = SqlTypeEnum     .Undefined;
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
         LogFile           = null;
         DisplayScript        = null;
      }

      /// <summary>
      /// Description takes a comma separated list of type codes
      /// e.g.: F,P,TTy
      /// 
      ///   F : function
      ///   P : procedure
      ///   T : table
      ///   V : view
      ///   TTy: Table type
      /// Utils.PreconditionS:
      /// none
      /// POSTCONDITIONS:
      /// Returns an array of SqlTypeEnum based on  the characters in 
      /// the supplied string.
      /// Each characters is a key to th etype as defined in the map spec'd below
      /// asserts that all characters in the string are legal types
      /// </summary>
      /// <param name="rs">like:  'FTPV'</param>
      /// <returns></returns>
      public List<SqlTypeEnum>? ParseRequiredTypes( string? rts )
      {
        LogS();

        if(string.IsNullOrEmpty(rts))
            return null;

         rts = rts.ToUpper();

         // trim and remove surrounding {}
         rts = rts.Trim(new[] { ' ', '{', '}' });
         var reqTypes = rts.Split(',');

         List<SqlTypeEnum> list = new List<SqlTypeEnum>();

         // get the types, throw if not found
         foreach (var item in reqTypes)
            list.Add(item.FindEnumByAlias2Exact<SqlTypeEnum>( true));

         LogL($"Found {list.Count} items");
         return list;
      }


      /// <summary>
      /// Handles strings like:
      ///   "{test, [dbo]", "dbo",  "", null}
      ///   "   {   dbo    }   ", "" null
      /// 
      /// Utils.PreconditionS: 
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
         Utils.Precondition<ArgumentException>(!string.IsNullOrEmpty(ServerName  ), "Server must be specified");
         Utils.Precondition<ArgumentException>(!string.IsNullOrEmpty(InstanceName), "instance must be specified");

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
            Utils.Postcondition<ArgumentException>(string.IsNullOrEmpty(item) == false, "POST 4: should contain no empty schemas");

         // POST 5: Server, Instance Database exist
         // Currently: OpenServer throws this:
         // Microsoft.Data.SqlClient.resources, Version=2.0.20168.4, Culture=en-GB, PublicKeyToken=23ec7fc2d6eaa4a5' or one of its dependencies. 
         // The system cannot find the file specified."
         Server? svr = Utils.CreateAndOpenServer( ServerName, InstanceName);
         Utils.Assertion(svr != null);
         Database? db = svr?.Databases["Covid_T1"];
         Utils.Assertion(db != null);
         SchemaCollection? actSchemas = db?.Schemas;
         int cnt = actSchemas?.Count ?? 0;
         Utils.Assertion((cnt != 0));

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
               Utils.Assertion( false, $"Schema {reqSchemaName} does not exist in the database");
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
            ,string?          logFile           = null

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
            ,logFile:         logFile
            ,isExprtngData  : isExprtngData  
            ,isExprtngDb    : isExprtngDb    
            ,isExprtngFKeys : isExprtngFKeys 
            ,isExprtngFns   : isExprtngFns   
            ,isExprtngProcs : isExprtngProcs 
            ,isExprtngSchema: isExprtngSchema
            ,isExprtngTbls  : isExprtngTbls  
            ,isExprtngTTys  : isExprtngTTys  
            ,isExprtngVws   : isExprtngVws 
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
             ,string?         logFile           = null
             ,bool?           isExprtngData     = null
             ,bool?           isExprtngDb       = null
             ,bool?           isExprtngFKeys    = null
             ,bool?           isExprtngFns      = null
             ,bool?           isExprtngProcs    = null
             ,bool?           isExprtngSchema   = null
             ,bool?           isExprtngTbls     = null
             ,bool?           isExprtngTTys     = null
             ,bool?           isExprtngVws      = null
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
         //UpdatePropertyIfNeccessary("TargetChildTypes",   requiredTypes);
         UpdatePropertyIfNeccessary("RootType",        sqlType); 
         UpdatePropertyIfNeccessary("CreateMode",      createMode);
         UpdatePropertyIfNeccessary("ScriptUseDb",     scriptUseDb); 
         UpdatePropertyIfNeccessary("AddTimestamp",    addTimestamp);
         UpdatePropertyIfNeccessary("LogFile",         logFile);
         

         UpdatePropertyIfNeccessary("IsExprtngData",   isExprtngData);
         UpdatePropertyIfNeccessary("IsExprtngDb",     isExprtngDb);
         UpdatePropertyIfNeccessary("IsExprtngFKeys",  isExprtngFKeys);
         UpdatePropertyIfNeccessary("IsExprtngFns",    isExprtngFns);
         UpdatePropertyIfNeccessary("IsExprtngProcs",  isExprtngProcs);
         UpdatePropertyIfNeccessary("IsExprtngSchema", isExprtngSchema);
         UpdatePropertyIfNeccessary("IsExprtngTbls",   isExprtngTbls);
         UpdatePropertyIfNeccessary("IsExprtngTTys",   isExprtngTTys);
         UpdatePropertyIfNeccessary("IsExprtngVws",    isExprtngVws);

         // Only Get the schemas once we have the svr name and db
         if(!string.IsNullOrEmpty(requiredSchemas))
            RequiredSchemas = ParseRequiredSchemas(requiredSchemas) ?? null;

         if(!string.IsNullOrEmpty(requiredTypes))
            TargetChildTypes   = ParseRequiredTypes  (requiredTypes)   ?? null;

         SetExportFlagsFromRootType();
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
            Utils.Assertion(property != null, $"UpdatePropertyIfNeccessary({propertyName}) failed to get the property");

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
         TargetChildTypes  = p.TargetChildTypes;
         RootType          = p.RootType;
         CreateMode        = p.CreateMode;
         ScriptUseDb       = p.ScriptUseDb;
         AddTimestamp      = p.AddTimestamp;
         DisplayScript        = p.DisplayScript;
         LogFile           = p.LogFile;
         IsExprtngData     = p.IsExprtngData;
         IsExprtngDb       = p.IsExprtngDb;
         IsExprtngFKeys    = p.IsExprtngFKeys;
         IsExprtngFns      = p.IsExprtngFns;
         IsExprtngProcs    = p.IsExprtngProcs;
         IsExprtngSchema   = p.IsExprtngSchema;
         IsExprtngTbls     = p.IsExprtngTbls;
         IsExprtngTTys     = p.IsExprtngTTys;
         IsExprtngVws      = p.IsExprtngVws;

         SetExportFlagsFromRootType();
     }

      /// <summary>
      /// Configures the IsExporting flags basedon the SQL Expoty type
      /// </summary>
      protected void SetExportFlagsFromRootType()
      {
         // set the is exporting flags based on the type
         if(RootType == SqlTypeEnum.Database)  IsExprtngDb     = true;
         if(RootType == SqlTypeEnum.Schema)    IsExprtngSchema = true;
         if(RootType == SqlTypeEnum.Function)  IsExprtngFns    = true;
         if(RootType == SqlTypeEnum.Procedure) IsExprtngProcs  = true;
         if(RootType == SqlTypeEnum.Table)    {IsExprtngTbls   = true; IsExprtngTTys   = true;}
         if(RootType == SqlTypeEnum.TableType) IsExprtngTTys   = true;
         if(RootType == SqlTypeEnum.View)      IsExprtngVws    = true;
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
