using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SI.DataLogging;
using SI.Software.TestHelpers.Database.SQL;

namespace DbConfig_Tests
{
    [TestClass]
    public class DbConfigUnitTests : DbUnitTestBase
    {
        #region Tests
        // SpReportEventsHelper(string parent_node_type_name = null, string parent_node_name = null, string node_type_name = null, string event_type_name = null, int? event_id = null,          DateTime? start_time = null,          DateTime? end_time = null)
        /*	@parent_node_type_name=NULL,
	        @parent_node_name     =NULL,
	        @node_type_name       =NULL,
	        @event_type_name      =NULL,
	        @event_id             =NULL,
	        @start_time           =NULL,
	        @end_time             =NULL
        */
        #region ReportEvent tests
        [TestMethod]
        public void GivenSpReportEventsWhenNoParamsThenOk()
        {
            var items = SpReportEventsHelper(expected_row_count: 83);
            Assert.AreEqual(items.Count, 83);
        }

        // Expect 15 rows for node type  "Cleaver"
        //	@parent_node_type_name
        [TestMethod]
        public void GivenSpReportEvents_WhenParentNodeTypeNameIsCleaverThenExpect3Rows()
        {
            SpReportEventsHelper(parent_node_type_name: "Cleaver", expected_row_count: 3);
        }

        // Expect 2 rows for node parent "Gantry 1.1.1"
        // @parent_node_name
        [TestMethod]
        public void GivenSpReportEvents_WhenParentNodeIsGant111ThenExpect2Rows()
        {
            SpReportEventsHelper( parent_node_name: "Gantry 1.1.1", expected_row_count: 2);
        }

        // Expect 15 rows for node type  "Cleaver"
        // @node_type_name
        [TestMethod]
        public void GivenSpReportEvents_WhenNodeTypeNameIsPixlThenExpect20Rows()
        {
            SpReportEventsHelper( node_type_name: "Pixl", expected_row_count: 20);
        }

        // @event_type_name
        [TestMethod]
        public void GivenSpReportEvents_WhenEventTypeNameIsDoorOpenedThenExpect20Rows()
        {
            SpReportEventsHelper( event_type_name: "Door Opened", expected_row_count: 20);
        }

        // @event_id
        [TestMethod]
        public void GivenSpReportEvents_WhenEventIdIs11ThenExpect10Rows()
        {
            SpReportEventsHelper( event_id: 11, expected_row_count: 10);
        }

        // @start_time
        [TestMethod]
        public void GivenSpReportEvents_WhenStartTimeIs150826_100504ThenExpect63Rows()
        {
            SpReportEventsHelper( start_time: DateTime.Parse("2018-08-26 10:05:04.000"), expected_row_count: 63);
        }

        // @end_time
        [TestMethod]
        public void GivenSpReportEvents_WhenEndTimeIs150826_100504ThenExpect35Rows()
        {
            SpReportEventsHelper(end_time: DateTime.Parse("2018-08-26 10:05:04.000"), expected_row_count: 35);
        }

        // @start_time and @end_time
        [TestMethod]
        public void GivenSpReportEvents_WhenTimeIsBetween180826_100504And180827_100504_ThenExpect35Rows()
        {
            SpReportEventsHelper(start_time: DateTime.Parse("2018-08-26 10:05:04.000"), end_time: DateTime.Parse("2018-08-27 10:05:04.000"), expected_row_count: 35);
        }

        #endregion

        /* This test will display the compete test node hierarchy
         * If the counts are not as expected - check the parent fields in the node data
         */
        [TestMethod]
        public void GivenSpGetNodeHierarchy_WhenRootEqualsAll_ThenDisplayHierarchyAndExpect24Nodes()
        {
            var res = ctx.sp_get_node_hierarchy("All Data");
            var items = res.ToList();
            Assert.IsTrue(items.Count == 42);

            foreach(var item in items)
                Console.WriteLine(item.node_name);
        }

        /// <summary>
        /// Displays the current list
        /// </summary>
        [TestMethod]
        public void GivenEp2PtView_WhenNormalState_ThenDisplayList()
        {
            foreach(var i in ctx.Ep2PtView)
                Console.WriteLine($"e id: {i.event_type_id} p id: {i.property_type_id} e nm: {i.event_type_name} p nm {i.property_type_name}");
        }

        [TestMethod]
        public void GivenPNT2CNTView_WhenNormalState_ThenDisplayList()
        {
            foreach (var i in ctx.PNT2CNTView)
                Console.WriteLine($"PT id: {i.parent_type_id} CT id: {i.child_type_id} PT nm: {i.parent_type_name} CT nm {i.child_type_name}");
        }

        #endregion
        //--------------------------------------------------------------- end Tests ------------------------------------------------
        #region Helper methods
        /// <summary>
        /// 
        /// </summary>
        /// <param name="parent_node_type_name"></param>
        /// <param name="parent_node_name"></param>
        /// <param name="node_type_name"></param>
        /// <param name="event_type_name"></param>
        /// <param name="event_id"></param>
        /// <param name="start_time"></param>
        /// <param name="end_time"></param>
        /// <param name="expected_row_count">optional if supplied will assert the returned row count is this</param>
        /// <returns></returns>
        private List<sp_report_events_Result> SpReportEventsHelper(string parent_node_type_name = null, string parent_node_name = null, string node_type_name = null, string event_type_name = null, int? event_id = null,          DateTime? start_time = null,          DateTime? end_time = null, int? expected_row_count=null)
        {
            var items = ctx.sp_report_events(parent_node_type_name, parent_node_name, node_type_name, event_type_name, event_id, start_time, end_time).ToList();

            foreach (var i in items)
                Console.WriteLine($"{i.event_time} {i.parent_node_name,-10}{i.node_name,-26} {i.event_type_name,-30} property: {i.property.PadRight(24).Substring(0, 24),-25} value: {i.value}");

            if (expected_row_count != null)
                Assert.AreEqual(expected_row_count, items.Count);

            return items;
        }

        #endregion
        #region Test Set-up, constructors & properties

        /// <summary>
        /// DbUnitTestBase() will set up the logger and get the db name from the app configuration if it exists
        /// </summary>
        public DbConfigUnitTests()
        {
            ctx = new DataLoggingEntities("DataLoggingEntities");
        }

        public DataLoggingEntities ctx { get; set; }

        [TestInitialize]
        public override void TestSetup()
        {
        }

        [TestCleanup]
        public override void TestCleanup()
        {
        }

        /// <summary>
        /// Called once before any of the tests
        /// </summary>
        /// <param name="testContext"></param>
        [ClassInitialize]
        public new static void ClassSetup(TestContext testContext)
        {
            //DatabaseName = DbHelper.GetDatabaseNameFromConfig();
            //DbHelper.CreateDatabase(DatabaseName, true, ".\\Scripts\\CreateDbConfigSchema.sql", ".\\Scripts\\PopulateDbConfigStaticData.sql", ".\\Scripts\\PopulateDbConfigDynamicTestData.sql");
            DbUnitTestBase.ClassSetup(testContext);
        }

        [ClassCleanup]
        public static new void ClassCleanup()
        {
            DbUnitTestBase.ClassCleanup();
        }

        #endregion
        //--------------------------------------------------------------- end Helper methods ------------------------------------------------
    }
}
