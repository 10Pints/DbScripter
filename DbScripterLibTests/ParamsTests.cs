
#nullable enable 

using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using DbScripterLibNS;
using RSS.Common;
using System.IO;
using static RSS.Common.Logger;
using static RSS.Common.Utils;
using System.Collections.Generic;

namespace RSS.Test
{
   [TestClass]
   public class ParamsTests : UnitTestBase
   {
      /// <summary>
      /// This test the basic inheritance principle used in the test parameter objects
      /// There are 4 scenarios
      /// 
      ///   Scenario    Parent   Parameter   Child
      ///   1           null     null        null
      ///   2           v1       null        v1
      ///   3           null     v2          v2
      ///   4           v1       v2          v2
      ///   
      /// </summary>
      [TestMethod()]
      public void UpdatePropertyIfNeccessaryTest2()
      {
         //   Scenario    Parent   Parameter   Child
         //   1           null     null        null
         Params parent = new();
         Params child  = new(prms: parent);
         Assert.IsNull(parent.Server);
         Assert.IsNull(child .Server);

         //   Scenario    Parent   Parameter   Child
         //   2           v1       null        v1
         parent = new Params(svrNm: "parent svr");
         child  = new Params(prms: parent);
         Assert.AreEqual("parent svr", parent.Server);

         //   Scenario    Parent   Parameter   Child
         //   3           null     v2          v2
         parent = new Params();
         child  = new Params(prms: parent, svrNm: "parent svr");

         Assert.AreEqual("parent svr", child.Server);

         //   Scenario    Parent   Parameter   Child
         //   4           v1       v2          v2
         parent = new Params(svrNm: "parent svr");
         child  = new Params(prms: parent, svrNm: "child svr");
         Assert.AreEqual("child svr", child.Server);
      }

      [TestMethod()]
      public void SetDefaultsWhenNewTest()
      {
         var p = new ParamsTestable();
         p.SetDefaults();

         // Check defaults
         Assert.IsFalse    ( p.AddTimestamp,                               "AddTimestamp"             );
         Assert.AreEqual   ( CreateModeEnum.Alter, p.CreateMode,           "CreateMode"               );
         Assert.IsFalse    ( p.DisplayScript,                              "DisplayScript"            );
         Assert.IsFalse    ( p.ScriptUseDb,                                "ScriptUseDb"              );
         Assert.AreEqual   ( "SQLEXPRESS",         p.Instance,             "Instance"                 );
         Assert.IsNull     ( p.IsExprtngData,                              "IsExprtngData"            );
         Assert.IsFalse    ( p.IsExprtngDb,                                "IsExprtngDb"              );
         Assert.IsTrue     ( p.IsExprtngFns,                               "IsExprtngFns"             );
         Assert.IsTrue     ( p.IsExprtngProcs,                             "IsExprtngProcs"           );
         Assert.IsFalse    ( p.IsExprtngSchema,                            "IsExprtngSchema"          ); // false because create mode is set to its default: alter
         Assert.IsFalse    ( p.IsExprtngTbls,                              "IsExprtngTbls"            );
         Assert.IsFalse    ( p.IsExprtngTTys,                              "IsExprtngTTys"            );
         Assert.IsFalse    ( p.IsExprtngVws,                               "IsExprtngVws"             );
         Assert.IsNull     ( p.IsExprtngData,                              "AddTimestamp"             );
         Assert.IsNotNull  ( p.LogFile,                                    "LogFile"                  );
         Assert.IsNotNull  ( p.ScriptPath,                                 "LogFile"                  );
         Assert.IsNull     ( p.NewSchema,                                  "NewSchema"                );
         Assert.IsNotNull  ( p.RequiredSchemas,                            "RequiredSchemas null"     );
         Assert.AreEqual   ( 1, p.RequiredSchemas.Count,                   "RequiredSchemas.Count, 1" );
         Assert.AreEqual   ( "dbo", p.RequiredSchemas[0],                  "RequiredSchemas[0]"       );
         Assert.AreEqual   ( @"DESKTOP-UAULS0U\SQLEXPRESS", p.Server,      "Server"                   );
         Assert.IsNotNull  ( p.TargetChildTypes,                           "TargetChildTypes"         );
         Assert.AreEqual   ( 2,  p.TargetChildTypes.Count,                 "TargetChildTypes.Count"   );
         Assert.AreEqual   ( SqlTypeEnum.Function,  p.TargetChildTypes[0], "TargetChildTypes[1]"      );
         Assert.AreEqual   ( SqlTypeEnum.Procedure, p.TargetChildTypes[1], "TargetChildTypes[1]"      );
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
      /// Utils.PreconditionS: 
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
         
         p11_exp = new Params(
             prms      : null // Use this state to start with and update with the subsequent parameters
            ,nm        : "p11_exp"
            ,svrNm     : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instNm    : "SQLEXPRESS"
            ,dbNm      : "Covid_T1"
            ,xprtScrpt : null
            ,cm        : null
            ,rss       : null
            ,rts       : null
            ,newSchNm  : null
            ,log       : null
            ,useDb     : false
            ,addTs     : true
            );

         Params p = new Params(
             prms      : null
            ,nm        : "ParseRequiredSchemasTestWhen2SchemasThenOk param"
            ,svrNm     : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instNm    : "SQLEXPRESS"
            ,dbNm      : "Covid_T1" 
            ,xprtScrpt : null
            ,cm        : null
            ,rss       : "{dbo, [ teSt]}"// should handle more than 1 schema and crappy formatting
            ,rts       : null
            ,useDb     : null
            ,newSchNm  : null
            ,addTs     : null
         );

         var requiredSchemas = p.RequiredSchemas;
         Assert.IsNotNull(requiredSchemas);
         Assert.AreEqual(2,      requiredSchemas.Count);
         Assert.AreEqual("dbo",  requiredSchemas[0]);
         Assert.AreEqual("teSt", requiredSchemas[1]);
      }

      [TestMethod()]
      public void UpdatePropertyIfNeccessaryTest()
      {
         // all pop inheriting null exp: all pop
         ChkEquals(p11_exp, p11_act, "UpdatePropertyIfNeccessaryTest");
         ChkEquals(p20_exp, p20_act, "UpdatePropertyIfNeccessaryTest");
      }

      /// <summary>
      /// test overlapping inherirtance append
      /// </summary>
      [TestMethod()]
      public void OverlappingTestNoBaseColls()
      {
         // Create the test objects

         Params prm_base = new Params(
             prms      : null // Use this state to start with and update with the subsequent parameters
            ,nm        : "prm_base"
            ,svrNm     : "base svr"
            ,instNm    : "base instance"
            ,dbNm      : "base db"
            ,xprtScrpt : null
            ,cm        : null
            ,rss       : null
            ,rts       : null
            ,useDb     : false
            ,addTs     : true
            ,newSchNm  : null
            );

         Params prm_exp = new Params(
             prms      : null
            ,nm        : "prm_exp"
            ,svrNm     : "ovr svr"
            ,instNm    : "base instance"
            ,dbNm      : "ovr db" 
            ,xprtScrpt : "ovr script path" // base is null
            ,cm        : null
            ,rss       : "{dbo, test}" 
            ,rts       : "table, function" 
            ,useDb     : false
            ,addTs     : true
            ,newSchNm  : null
            );

         Params prm_act = new Params(
             prms       : prm_base          // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
            ,nm         : "prm act"
            ,svrNm      : "ovr svr"
            ,instNm     : null
            ,dbNm       : "ovr db"          // replaces "Covid_T2"
            ,xprtScrpt  : "ovr script path" // replaces null
            ,cm         : null
            ,rss        : "{dbo, test}" 
            ,rts        : "table, function" 
            );

         ChkEquals(prm_exp, prm_act, "OverlappingTest");
      }

      /// <summary>
      /// test overlapping inherirtance append
      /// </summary>
      [TestMethod()]
      public void OverlappingTestBaseCollSpecd()
      {
         // Create the test objects

         Params prm_base = new Params(
             prms      : null // Use this state to start with and update with the subsequent parameters
            ,nm        : "prm_base"
            ,svrNm     : "base svr"
            ,instNm    : "base instance"
            ,dbNm      : "base db"
            ,xprtScrpt : null
            ,cm        : null
            ,rss       : "{base sch 1}" 
            ,rts       : "procedure, function" 
            ,useDb     : false
            ,addTs     : true
            ,newSchNm  : null
            );

         Params prm_exp = new Params(
             prms      : null
            ,nm        : "prm_exp"
            ,svrNm     : "ovr svr"
            ,instNm    : "base instance"
            ,dbNm      : "ovr db" 
            ,xprtScrpt : "ovr script path" // base is null
            ,cm        : null
            ,rss       : "{dbo, test}" 
            ,rts       : "table, database" 
            ,useDb     : false
            ,addTs     : true
            ,newSchNm  : null
            );

         Params prm_act = new Params(
             prms       : prm_base          // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
            ,nm         : "prm act"
            ,svrNm      : "ovr svr"
            ,instNm     : null
            ,dbNm       : "ovr db"          // replaces "Covid_T2"
            ,xprtScrpt  : "ovr script path" // replaces null
            ,cm         : null
            ,rss        : "{dbo, test}" 
            ,rts        : "table, database" 
            );

         ChkEquals(prm_exp, prm_act, "OverlappingTestBaseCollSpecd");
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
         var dir = Directory.GetCurrentDirectory();

         // overwrite will replace all specified parameters even those that are defaults not supplied**
         Params P21_overlap_ovrwrt_exp = new Params  (
             prms       : null                    // was 
            ,nm         : "P21_overlap_ovrwrt_exp"
            ,svrNm      : @"FRED"                 // was DESKTOP-UAULS0U\SQLEXPRESS
            ,instNm     : "SQLEXPRESS"            // was same
            ,dbNm       : "P21 db"                // was Covid_T1
            ,xprtScrpt  : "P21 export path"       // was null
            ,cm         : null
            ,rss        : null                    // was null                     
            ,rts        : null                    // was null                     
            ,useDb      : true                    // was false                    
            ,addTs      : false                   // was true                     
            ,newSchNm   : null                    // was null
            );

         Params P21_overlap_ovrwrt_act = new Params (
             prms       : p11_exp           // sets SVR:UAULS0U\SQLEXPRESS, inst:UAULS0U\SQLEXPRESS, db:Covid_T1, {expth, newschma,requiredSchemas,requiredTypes} :null
            ,nm         : "P21_overlap_ovrwrt_act:p11_exp"
            ,svrNm      : @"FRED"
            ,instNm     : "SQLEXPRESS"
            ,dbNm       : "P21 db" 
            ,xprtScrpt  : "P21 export path"
            ,useDb      : true
            ,addTs      : false
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

         LogDirect("------------- ParseRequiredTypesTest --------------");
         Assert.IsNotNull(act);

         foreach(SqlTypeEnum item in act)
            LogDirect($"got req ty: {item.GetAlias()}");

         LogDirect("---------------------------------------------------");

         Assert.AreEqual(5, act.Count);
         Assert.AreEqual(SqlTypeEnum.Table      , act[0], act[0].GetAlias());
         Assert.AreEqual(SqlTypeEnum.Function   , act[1], act[1].GetAlias());
         Assert.AreEqual(SqlTypeEnum.Procedure  , act[2], act[2].GetAlias());
         Assert.AreEqual(SqlTypeEnum.View       , act[3], act[3].GetAlias());
         Assert.AreEqual(SqlTypeEnum.Schema     , act[4], act[4].GetAlias());
      }

      [TestMethod()]
      [ExpectedException((typeof(Exception)), AllowDerivedTypes =true)]
      public void ParseRequiredTypesBadInputTest()
      {
         Params p = new Params();
         Utils.AssertThrows<ArgumentException>(() => p.ParseRequiredTypes("t,F,P,v,A"), "Unrecognised SQL type A");
      }
   
      [TestMethod()]
      public void ParseRequiredSchemasNullTest()
      {
         Params p = new Params();
         // POST 1,2 required schemas must be specified
         List<string>? rs = p.ParseRequiredSchemas(null);
         Assert.IsNull(rs);
         //   POST 3: returns all schemas in rs in the returned ary
         //   POST 4: contains no []
      }
   
      [TestMethod()]
      public void ParseRequiredSchemasMtTest()
      {
         Params p = new Params();
         List<string>? rs = p.ParseRequiredSchemas("");
         Assert.IsNull(rs);
         // POST 1,2 required schemas must be specified
         //   POST 3: returns all schemas in rs in the returned ary
         //   POST 4: contains no []
      }
   
      private void CreateTestObjects()
      {
         p10_null = new Params(
             prms       : null
            ,nm         : "p10_null"
            ,svrNm      : null
            ,instNm     : null
            ,dbNm       : null
            ,xprtScrpt  : null
            ,cm         : null
            ,rss        : null
            ,rts        : null
            ,useDb      : null
            ,addTs      : null
            ,newSchNm   : null
         );

         p11_all_inp = new Params(
             prms       : null // Use this state to start with and update with the subsequent parameters
            ,nm         : "p11_all_inp"
            ,svrNm      : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instNm     : "SQLEXPRESS"
            ,dbNm       : "Covid_T1"
            ,xprtScrpt  : @"C:\tmp\T002_InitTest_export.sql"
            ,cm         : null
            ,rss        : "{dbo, test}"
            ,rts        : "F,P"
            ,useDb      : false
            ,addTs      : true
            ,newSchNm   : "New Schema Name"
         );

         p11_exp = new Params(
             prms       : null // Use this state to start with and update with the subsequent parameters
            ,nm         : "p11_exp"
            ,svrNm      : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instNm     : "SQLEXPRESS"
            ,dbNm       : "Covid_T1"
            ,xprtScrpt  : null
            ,cm         : null
            ,rss        : null
            ,rts        : null
            ,useDb      : false
            ,addTs      : true
            ,newSchNm   : null
            );

         p11_act = new Params(
             prms      : p10_null // Use this state to start with and update with the subsequent parameters
            ,nm        : "p11_act:p10_null"
            ,svrNm     : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instNm    : "SQLEXPRESS"
            ,dbNm      : "Covid_T1"
            ,xprtScrpt : null
            ,cm        : null
            ,rss       : null
            ,rts       : null
            ,useDb     : false
            ,addTs     : true
            ,newSchNm  : null
         );

         p20_exp = new Params(
             prms       : null // Use this state to start with and update with the subsequent parameters
            ,nm         : "p20_exp"
            ,svrNm      : @"DESKTOP-UAULS0U\SQLEXPRESS"
            ,instNm     : "SQLEXPRESS"
            ,dbNm       : "Covid_T1"
            ,xprtScrpt  : @"C:\tmp\T002_InitTest_export.sql"
            ,cm         : null
            ,rss        : "{dbo, test}"
            ,rts        : "F,P"
            ,useDb      : false
            ,addTs      : true
            ,newSchNm   : "New Schema Name"
         );
        
         p20_act= new Params(
             prms      : p11_all_inp
            ,nm        : "p20_act:p11_all_inp"
            ,svrNm     : null
            ,instNm    : null
            ,dbNm      : null
            ,xprtScrpt : null
            ,cm        : null
            ,rss       : null
            ,rts       : null
            ,useDb     : null
            ,addTs     : null
            ,newSchNm  : null
         );

      }

      public override void TestSetup_()
      {
      }

      public override void TestCleanup_()
      {
      }

      Params? p10_null   = null;
      Params? p11_all_inp= null;
      Params? p11_exp    = null;
      Params? p11_act    = null;
      Params? p20_act    = null;
      Params? p20_exp    = null;


      public override string TestDataDir { get =>_testDataDir; set{ _testDataDir=value;} }
   }
}
