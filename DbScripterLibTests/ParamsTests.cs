using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using DbScripterLib;
using static RSS.Common.Logger;
using static RSS.Common.Utils;
using RSS.Common;
using System.IO;
using System.Diagnostics;

namespace RSS.Test
{
   [TestClass]
   public class ParamsTests : UnitTestBase
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
      public void SetExportFlagsFromSqlTypeTest()
      {
         // 1: test from cstr
         ParamsTestable p = new ParamsTestable(
             name              : "ParseRequiredSchemasTestWhen2SchemasThenOk param"
            ,prms              : null
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1" 
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : "{dbo}"
            ,requiredTypes     : null
            ,sqlType           : null
            ,createMode        : null
            ,scriptUseDb       : null
            ,addTimestamp      : null
         );

         // Clear all the is exporting state flags
         p.SetExportFlagState(null);
         p.IsExprtngDb   = true;//   isxDb, isxS,  isxFn, isxp,  isxTbls,isxTTy, isxVw, isxData
         Assert.IsTrue(Checkflags(p, true,  null,  null,  null,  null,   null,   null,  null));
         p.SetExportFlagState(false);
         p.IsExprtngSchema = true;
         Assert.IsTrue(Checkflags(p, false, true,  false, false, false,  false,  false, false));
         p.SetExportFlagState(true);
         p.IsExprtngFns = false;
         Assert.IsTrue(Checkflags(p, true,  true,  false, true,  true,   true,   true,  true));
         p.SetExportFlagState(null);
         p.IsExprtngProcs = false;
         Assert.IsTrue(Checkflags(p, null,  null,  null,  false, null,   null,   null,  null));

         p.SetExportFlagState(null);
         p.IsExprtngTbls = true;
         p.IsExprtngTTys = false;
         Assert.IsTrue(Checkflags(p, null,  null,  null,  null,  true,   false,  null,  null));

         p.SetExportFlagState(false); 
         p.IsExprtngVws  = null;
         p.IsExprtngData = true;
         Assert.IsTrue(Checkflags(p, false, false, false, false, false,  false,  null,  true));
      }

      bool Checkflags(Params p
                     ,bool? isExprtngDb
                     ,bool? isExprtngSchema
                     ,bool? isExprtngFns
                     ,bool? isExprtngProcs
                     ,bool? isExprtngTbls
                     ,bool? isExprtngTTys
                     ,bool? isExprtngVws
                     ,bool? isExprtngData
                     )
      {
         bool ret = true;
         if(p.IsExprtngDb     != isExprtngDb    ) ret = false;
         if(p.IsExprtngSchema != isExprtngSchema) ret = false;
         if(p.IsExprtngFns    != isExprtngFns   ) ret = false;
         if(p.IsExprtngProcs  != isExprtngProcs ) ret = false;
         if(p.IsExprtngTbls   != isExprtngTbls  ) ret = false;
         if(p.IsExprtngTTys   != isExprtngTTys  ) ret = false;
         if(p.IsExprtngVws    != isExprtngVws   ) ret = false;
         if(p.IsExprtngData   != isExprtngData  ) ret = false;

         return ret;
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
      public void ParseRequiredSchemasTestWhen2SchemasThenOk()
      {
         //var exportScriptPath = @"C:\temp\PareseRequiredschemasTest.sql";
         Params p = new Params(
             name              : "ParseRequiredSchemasTestWhen2SchemasThenOk param"
            ,prms              : null
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1" 
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : "{dbo, [ teSt]}"// should handle more than 1 schema and crappy formatting
            ,requiredTypes     : null
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
         ChkEquals(p11_exp, p11_act, "UpdatePropertyIfNeccessaryTest");
         ChkEquals(p20_exp, p20_act, "UpdatePropertyIfNeccessaryTest");
      }

      // test overlapping inherirtance append
      [TestMethod()]
      public void OverlappingTest()
      {
         Params P21_overlap_exp = new Params  (
             name              : "Overlap test param exp"
            ,prms              : null
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "P21 db" 
            ,exportScriptPath  : "P21 export path"
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
            ,sqlType           : SqlTypeEnum.Undefined
            ,createMode        : CreateModeEnum.Undefined
            ,scriptUseDb       : false
            ,addTimestamp      : true
            );

         Params P21_overlap_act = new Params(
             name              : "Overlap test param act"
            ,prms              : p11_exp           // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
                                                      // op:CreateSchema, sqlTy:SqlTypeEnum.Undefined,crtMod:Alter, usedb:false, adtmstmp:true
            ,databaseName      : "P21 db"          // replaces "Covid_T2"
            ,exportScriptPath  : "P21 export path" // replaces null
         );
         // Params Equals failed: a ServerName      :DESKTOP-UAULS0U\SQLEXPRESS b servername      :
         //
         ChkEquals(P21_overlap_exp, P21_overlap_act, "OverlappingTest");
/*
         if(!P21_overlap_exp.Equals(P21_overlap_act))
         { 
            Console.WriteLine("P21_overlap_exp.Equals(P21_overlap_act) failed\r\nexp:");
            Console.WriteLine(P21_overlap_exp.ToString());
            Console.WriteLine("\r\nact:");
            Console.WriteLine(P21_overlap_act.ToString());
            Assert.IsTrue(P21_overlap_exp.Equals(P21_overlap_act));
         }*/
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
      public void Overlapping2Test()
      {
         // D:\Dev\Repos\DbScripter\TestResults
         // @"..\..\..\TestResults"
         var dir = Directory.GetCurrentDirectory();
         // overwrite will replace all specified parameters even those that are defaults not supplied**
         Params P21_overlap_ovrwrt_exp = new Params  (
             name              : "P21_overlap_ovrwrt_exp"
            ,prms              : null                    // was 
            ,serverName        : @"FRED"                 // was DESKTOP-UAULS0U\SQLEXPRESS
            ,instanceName      : "SQLEXPRESS"            // was same
            ,databaseName      : "P21 db"                // was Covid_T1
            ,exportScriptPath  : "P21 export path"       // was null
            ,newSchemaName     : null                    // was null
            ,requiredSchemas   : null                    // was null                     
            ,requiredTypes     : null                    // was null                     
//          ,dbOpType          : DbOpTypeEnum.Undefined  // was DbOpTypeEnum.CreateSchema
            ,sqlType           : SqlTypeEnum.Undefined   // was SqlTypeEnum.Undefined    
            ,createMode        : CreateModeEnum.Undefined// was CreateModeEnum.Alter     
            ,scriptUseDb       : true                    // was false                    
            ,addTimestamp      : false                   // was true                     
            );;

         Params P21_overlap_ovrwrt_act = new Params (
             name              : "P21_overlap_ovrwrt_act:p11_exp"
            ,prms              : p11_exp           // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
            ,serverName        : @"FRED"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "P21 db" 
            ,exportScriptPath  : "P21 export path"
            //newSchemaName                        // param not specified in this call so it will be set to null
            //bOpType          : null              // replaces DbOpTypeEnum.CreateSchema with a specified null value
            //sqlType          default             // param not specified in this call so it will be set to SqlTypeEnum.Undefined
            //createMode       default             // param not specified in this call so it will be set to CreateModeEnum.Undefined
            ,scriptUseDb       : true
            ,addTimestamp      : false
            );

         ChkEquals(P21_overlap_ovrwrt_exp, P21_overlap_ovrwrt_act, "Overlapping2Test");
      }

      [TestMethod()]
      public void ParseRequiredTypesTest()
      {
         Params p = new Params();
         Assert.IsNull( p.ParseRequiredTypes(null));
         Assert.IsNull( p.ParseRequiredTypes(""));

         var act = p.ParseRequiredTypes("t,F,P,v,s");

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
         AssertThrows<ArgumentException>(() => p.ParseRequiredTypes("t,F,P,v,A"), "Unrecognised SQL type A");
      }
   
      [TestMethod()]
      [ExpectedException((typeof(ArgumentException)))]
      public void ParseRequiredSchemasNullTest()
      {
         Params p = new Params();
         // POST 1,2 required schemas must be specified
         p.ParseRequiredSchemas(null);
         //   POST 3: returns all schemas in rs in the returned ary
         //   POST 4: contains no []
      }
   
      [TestMethod()]
      [ExpectedException((typeof(ArgumentException)))]
      public void ParseRequiredSchemasMtTest()
      {
         Params p = new Params();
         // POST 1,2 required schemas must be specified
         p.ParseRequiredSchemas("");
         //   POST 3: returns all schemas in rs in the returned ary
         //   POST 4: contains no []
      }
   
      private void Init()
      {
         p10_null = new Params(
             name              : "p10_null"
            ,prms              : null
            ,serverName        : null
            ,instanceName      : null
            ,databaseName      : null
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
         // ,dbOpType          : null
            ,sqlType           : null
            ,createMode        : null
            ,scriptUseDb       : null
            ,addTimestamp      : null
         );

         p11_all_inp = new Params(
             name              : "p11_all_inp"
            ,prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : @"C:\tmp\T002_InitTest_export.sql"
            ,newSchemaName     : "New Schema Name"
            ,requiredSchemas   : "{dbo, test}"
            ,requiredTypes     : "F,P"
      //    ,dbOpType          : DbOpTypeEnum   .Undefined
            ,sqlType           : SqlTypeEnum    .Undefined
            ,createMode        : CreateModeEnum .Undefined
            ,scriptUseDb       : false
            ,addTimestamp      : true
         );

         p11_exp = new Params(
             name              : "p11_exp"
            ,prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
    //      ,dbOpType          : DbOpTypeEnum   .Undefined
            ,sqlType           : SqlTypeEnum    .Undefined
            ,createMode        : CreateModeEnum .Undefined
            ,scriptUseDb       : false
            ,addTimestamp      : true
            );

         p11_act = new Params(
             name              : "p11_act:p10_null"
            ,prms              : p10_null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
     //     ,dbOpType          : DbOpTypeEnum   .Undefined
            ,sqlType           : SqlTypeEnum    .Undefined
            ,createMode        : CreateModeEnum .Undefined
            ,scriptUseDb       : false
            ,addTimestamp      : true
         );

         p20_exp = new Params(
             name              : "p20_exp"
            ,prms              : null // Use this state to start with and update with the subsequent parameters
            ,serverName        : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instanceName      : "SQLEXPRESS"
            ,databaseName      : "Covid_T1"
            ,exportScriptPath  : @"C:\tmp\T002_InitTest_export.sql"
            ,newSchemaName     : "New Schema Name"
            ,requiredSchemas   : "{dbo, test}"
            ,requiredTypes     : "F,P"
     //     ,dbOpType          : DbOpTypeEnum   .Undefined
            ,sqlType           : SqlTypeEnum    .Undefined
            ,createMode        : CreateModeEnum .Undefined
            ,scriptUseDb       : false
            ,addTimestamp      : true
         );
        
         p20_act= new Params(
             name              : "p20_act:p11_all_inp"
            ,prms              : p11_all_inp
            ,serverName        : null
            ,instanceName      : null
            ,databaseName      : null
            ,exportScriptPath  : null
            ,newSchemaName     : null
            ,requiredSchemas   : null
            ,requiredTypes     : null
      //    ,dbOpType          : null
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
