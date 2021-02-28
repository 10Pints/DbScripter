using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using DbScripterLib;
using static DbScripterLib.Params;
using RSS;

namespace RSS.Test
{
   [TestClass]
   public class ParamsTests
   {
      public ParamsTests()
      { 
         Init();
      }

      /// <summary>
      /// PRECONDITIONS: 
      ///   
      /// POSTCONDITIONS: 
      ///   POST 1: returns null if rs is null, empty
      ///   POST 2: returns null if rs contains no schemas
      ///   POST 3: returns all the required schemas in rs in the returned collection
      ///   POST 4: contains no empty schemas
      ///   POST 5: Server, Instance Database exist
      ///   POST 6: the schemas found should exist in the database
      ///           AND match the Case of the Db Schema name
      /// "{dbo, [ teSt]}"
      /// </summary>
      [TestMethod()]
      //[ExpectedException typeof(ArgumentException)]
      public void ParseRequiredSchemasTestWhen2SchemasThenOk()
      {
         //var exportScriptPath = @"C:\temp\PareseRequiredschemasTest.sql";
         Params p = new Params(
             prms              : null
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1" 
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : "{dbo, [ teSt]}"// should handle more than 1 schema and crappy formatting
            ,requiredTypes     : null
            ,dbOpType          : null
            ,sqlType           : null
            ,createMode        : null
            ,scriptUseDb       : null
            ,addTimestamp      : null
         );

         var requiredSchemas = p.RequiredSchemas;
         Assert.IsNotNull(requiredSchemas);
         Assert.AreEqual(2,      requiredSchemas.Count);
         Assert.AreEqual("dbo",  requiredSchemas[0]);
         Assert.AreEqual("test", requiredSchemas[1]);
      }

      [TestMethod()]
      public void UpdatePropertyIfNeccessaryTest()
      {
         // all pop inheriting null exp: all pop
         if(!p11_exp.Equals(p11_act))
         { 
            Console.WriteLine("p11_exp.Equals(p11_act) failed\r\nexp:");
            Console.WriteLine(p11_exp.ToString());
            Console.WriteLine("\r\nact:");
            Console.WriteLine(p11_exp.ToString());
            Assert.IsTrue(p11_exp.Equals(p11_act)); // Params Equals failed:
         }

         // null inheriting all pop exp: all pop
         if(!p20_exp.Equals(p20_act))
         { 
            Console.WriteLine("p20_exp.Equals(p20_act) failed\r\nexp:");
            Console.WriteLine(p20_exp.ToString());
            Console.WriteLine("\r\nact:");
            Console.WriteLine(p20_act.ToString());
            Assert.IsTrue(p20_exp.Equals(p20_act)); // Params Equals failed:
         }
      }

      // test overlapping inherirtance append
      [TestMethod()]
      public void OverlappingAppendTest()
      {
         Params P21_overlap_exp = new Params  (
             prms              : null
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "P21 db" 
            ,exportScriptPath  : "P21 export path"
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
            ,dbOpType          : DbOpTypeEnum.CreateSchema
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Alter
            ,scriptUseDb       : false
            ,addTimestamp      : true
            );

         Params P21_overlap_act = new Params
            (
                prms              : p11_exp           // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
                                                      // op:CreateSchema, sqlTy:SqlTypeEnum.Undefined,crtMod:Alter, usedb:false, adtmstmp:true
               ,databaseName      : "P21 db"          // replaces "Covid_T2"
               ,exportScriptPath  : "P21 export path" // replaces null
               ,dbOpType          : null              // replaces DbOpTypeEnum.CreateSchema
            );
         // Params Equals failed: a ServerName      :DESKTOP-UAULS0U\SQLEXPRESS b servername      :
         //
         if(!P21_overlap_exp.Equals(P21_overlap_act))
         { 
            Console.WriteLine("P21_overlap_exp.Equals(P21_overlap_act) failed\r\nexp:");
            Console.WriteLine(P21_overlap_exp.ToString());
            Console.WriteLine("\r\nact:");
            Console.WriteLine(P21_overlap_act.ToString());
            Assert.IsTrue(P21_overlap_exp.Equals(P21_overlap_act));
         }
      }
    
/*      
p11_ source                                           P21_overlap_inp : p11_exp                       act:   P21_overlap_exp                      
,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"    serverName      : DESKTOP-UAULS0U\SQLEXPRESS    serverName      : DESKTOP-UAULS0U\SQLEXPRESS
,instanceName      : "SQLEXPRESS"                     instanceName    : SQLEXPRESS                    instanceName    : SQLEXPRESS                
,databaseName      : "Covid_T1"                       databaseName    : P21 db                        databaseName    : P21 db                    
,exportScriptPath  : null                             exportScriptPath: P21 export path               exportScriptPath: P21 export path           
,newSchemaName     : null                             newSchemaName   :                               newSchemaName   : null                      
,requiredSchemas   : null                             requiredSchemas :                               requiredSchemas : null                      
,requiredTypes     : null                             requiredTypes   :                               requiredTypes   : null                      
,dbOpType          : DbOpTypeEnum.CreateSchema        dbOpType        :                               dbOpType        : CreateSchema              
,sqlType           : SqlTypeEnum.Undefined            sqlType         : default                       sqlType         : null                      
,createMode        : CreateModeEnum.Alter             createMode      : default                       createMode      : null                      
,scriptUseDb       : False                            scriptUseDb     : True                          scriptUseDb     : True                      
,addTimestamp      : True);                           addTimestamp    : False                         addTimestamp    : False                     
*/
      [TestMethod()]
      public void OverlappingOverwriteTest()
      {
         // overwrite will replace all specified parameters even those that are defaults not supplied**
         Params P21_overlap_ovrwrt_exp = new Params  (
             prms              : null              // was 
            ,serverName        : @"FRED"           // was DESKTOP-UAULS0U\SQLEXPRESS
            ,instanceName      : "SQLEXPRESS"      // was same
            ,databaseName      : "P21 db"          // was Covid_T1
            ,exportScriptPath  : "P21 export path" // was null
            ,newSchemaName     : null              // was null
            ,requiredSchemas   : null              // was null                     
            ,requiredTypes     : null              // was null                     
            ,dbOpType          : null              // was DbOpTypeEnum.CreateSchema
            ,sqlType           : null              // was SqlTypeEnum.Undefined    
            ,createMode        : null              // was CreateModeEnum.Alter     
            ,scriptUseDb       : true              // was false                    
            ,addTimestamp      : false             // was true                     
            );;

         Params P21_overlap_ovrwrt_act = new Params (
             prms              : p11_exp           // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
            ,serverName        : @"FRED"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "P21 db" 
            ,exportScriptPath  : "P21 export path"
            //newSchemaName                        // param not specified in this call so it will be set to null
            ,dbOpType          : null              // replaces DbOpTypeEnum.CreateSchema with a specified null value
            //sqlType          default             // param not specified in this call so it will be set to null
            //createMode       default             // param not specified in this call so it will be set to null
            ,scriptUseDb       : true
            ,addTimestamp      : false
            );

         if(!P21_overlap_ovrwrt_exp.Equals(P21_overlap_ovrwrt_act))
         { 
            Console.WriteLine("P21_overlap_exp.Equals(P21_overlap_ovrwrt_act) failed\r\nexp:");
            Console.WriteLine(P21_overlap_ovrwrt_exp.ToString());
            Console.WriteLine("\r\nact:");
            Console.WriteLine(P21_overlap_ovrwrt_act.ToString());
            Assert.IsTrue(P21_overlap_ovrwrt_exp.Equals(P21_overlap_ovrwrt_act));
         }
      }

      [TestMethod()]
      public void ParseRequiredTypesTest()
      {
         Params p = new Params();
         Assert.IsNull( p.ParseRequiredTypes(null));
         Assert.IsNull( p.ParseRequiredTypes(""));

         var act = p.ParseRequiredTypes("tFPvs");

         Console.WriteLine("------------- ParseRequiredTypesTest --------------");
         foreach(SqlTypeEnum item in act)
            Console.WriteLine($"got req ty: {item.GetAlias()}");
         Console.WriteLine("---------------------------------------------------");

         Assert.AreEqual(5, act.Count);
         Assert.AreEqual(SqlTypeEnum.Table      , act[0], act[0].GetAlias());
         Assert.AreEqual(SqlTypeEnum.Function   , act[1], act[1].GetAlias());
         Assert.AreEqual(SqlTypeEnum.Procedure  , act[2], act[2].GetAlias());
         Assert.AreEqual(SqlTypeEnum.View       , act[3], act[3].GetAlias());
         Assert.AreEqual(SqlTypeEnum.Schema     , act[4], act[4].GetAlias());
      }

      [TestMethod()]
      [ExpectedException((typeof(ArgumentException)))]
      public void ParseRequiredTypesBadInputTest()
      {
         Params p = new Params();
         Utils.AssertThrows<ArgumentException>(() => p.ParseRequiredTypes("tFPvA"), "Unrecognised SQL type A");
      }
   
      [TestMethod()]
      public void ParseRequiredSchemasOrMtTest()
      {
         Params p = new Params();
         // POST 1,2
         Assert.IsNull( p.ParseRequiredSchemas(null));
         Assert.IsNull( p.ParseRequiredSchemas(""));
         //   POST 3: returns all schemas in rs in the returned ary
         //   POST 4: contains no []
      }
   
      private void Init()
      {
         p10_null = new Params(
             prms              : null
            ,serverName        : null
            ,instanceName      : null
            ,databaseName      : null
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
            ,dbOpType          : null
            ,sqlType           : null
            ,createMode        : null
            ,scriptUseDb       : null
            ,addTimestamp      : null
         );

         p11_all_inp = new Params(
             prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : @"C:\tmp\T002_InitTest_export.sql"
            ,newSchemaName     : "New Schema Name"
            ,requiredSchemas   : "{dbo, test}"
            ,requiredTypes     : "F,P"
            ,dbOpType          : DbOpTypeEnum.CreateSchema
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Alter
            ,scriptUseDb       : false
            ,addTimestamp      : true
         );

         p11_exp = new Params(
             prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
            ,dbOpType          : DbOpTypeEnum.CreateSchema
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Alter
            ,scriptUseDb       : false
            ,addTimestamp      : true
            );

         p11_act = new Params(
             prms              : p10_null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
            ,dbOpType          : DbOpTypeEnum.CreateSchema
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Alter
            ,scriptUseDb       : false
            ,addTimestamp      : true
         );

         p20_exp = new Params(
             prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : @"C:\tmp\T002_InitTest_export.sql"
            ,newSchemaName     : "New Schema Name"
            ,requiredSchemas   : "{dbo, test}"
            ,requiredTypes     : "F,P"
            ,dbOpType          : DbOpTypeEnum.CreateSchema
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Alter
            ,scriptUseDb       : false
            ,addTimestamp      : true
         );
        
         p20_act= new Params(
             prms              : p11_all_inp
            ,serverName        : null
            ,instanceName      : null
            ,databaseName      : null
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
            ,dbOpType          : null
            ,sqlType           : null
            ,createMode        : null
            ,scriptUseDb       : null
            ,addTimestamp      : null
         );

      }

      Params p10_null   = null;
      Params p11_all_inp= null;
      Params p11_exp    = null;
      Params p11_act    = null;
      Params p20_act    = null;
      Params p20_exp    = null;
   }
}
