using System;
using System.Diagnostics;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using SI.Common;
using SI.DataLogging;


namespace DbConfig
{
    /// <summary>
    /// Interaction logic for ET2PTWindow.xaml
    /// </summary>
    public partial class ET2PTWindow : LinkTableView
    {
        public ET2PTWindow() : base("ET2PT", DbConfigViewModel.Instance)
        {
            InitializeComponent();
            Init();
        }

        public DbConfigViewModel vm
        {
            get { return vm1 as DbConfigViewModel; }
            set
            {
                vm1 = value;
                DataContext = vm1;
            }
        }

        private void Init()
        {
            // Bind to the EF ET2PTs (sort first)
            Debug.Assert(vm.ET2PTs != null);
            var items = (from u in vm.ET2PTs select u).ToList();
            items.Sort(new Et2PtComparer());
            dataGrid.ItemsSource = items;
            FillDataGrid();
        }
        private void TestDataGrid_OnRowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            Debug.WriteLine($"TestDataGrid_OnRowEditEnding called");
            var ec = vm.ET2PTs.Count;
            var et2pt = e.Row.Item as ET2PT;
            Debug.Assert(et2pt != null);

            if (et2pt.id == 0)
            {
                // new
                vm.ET2PTs.Add(et2pt);
                // VM saves changes to db in response to the Et2PTs_CollectionChanged property changed event, and on successful save we get the new id allocated by the db
            }
            else
            {
                // Modified?
                var dbet2pt = vm.ET2PTs.FirstOrDefault(x => x.id == et2pt.id);
                Debug.Assert(dbet2pt != null);
                // At this stage the EF et2pt has its raw data updated, {event_type and property_type} but its cached Foreign Data is still pointing to old event type and property type
                // As yet theProperty changed notification event has NOT been sent to the  view model

                try
                {
                    vm.UpdateChanges();
                }
                catch (Exception ex)
                {
                    var msg = ex.GetAllMessages();
                    MessageBox.Show(msg);
                }
            }

            // Deleted?
        }

        private void EP2PT_OnDelete(object sender, RoutedEventArgs e)
        {
            Debug.WriteLine($"EP2PT_OnDelete called");
            var et2pt = (dataGrid.SelectedItem as ET2PT);
            vm.ET2PTs.Remove(et2pt);
            dataGrid.Items.Refresh();
        }

        private void TestDataGrid_OnPreviewKeyDown(object sender, KeyEventArgs e)
        {
            Debug.WriteLine($"TestDataGrid_OnPreviewKeyDown called");

            if (e.Key == Key.Delete)
            {
                var grid = (DataGrid)sender;

                if (grid.SelectedItems.Count > 0)
                {
                    foreach (var row in grid.SelectedItems)
                        vm.ET2PTs.Remove(row as ET2PT);
                }
            }
        }
    }
}
