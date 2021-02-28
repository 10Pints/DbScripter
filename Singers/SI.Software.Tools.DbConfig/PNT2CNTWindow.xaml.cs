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
    /// Interaction logic for Et2PTGrid.xaml
    /// </summary>
    public partial class PNT2CNTWindow : LinkTableView
    {
        public PNT2CNTWindow() : base("PNT2CNT", DbConfigViewModel.Instance)
        {
            InitializeComponent();
            Init();
        }

        private void Init()
        {
            RefreshView();
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

        private void RefreshView()
        {
            // Bind to the EF PNT2CNTs (sort first)
            Debug.Assert(vm.PNT2CNTs != null);
            var items = (from u in vm.PNT2CNTs select u).ToList();
            items.Sort(new PNT2CNTComparer());
            dataGrid.ItemsSource = items;
            FillDataGrid();
        }

        private void OnRowEditEnding(object sender, DataGridRowEditEndingEventArgs e)
        {
            Debug.WriteLine($"TestDataGrid_OnRowEditEnding called");
            var ec = vm.PNT2CNTs.Count;
            var pnt2cnt = e.Row.Item as PNT2CNT;
            Debug.Assert(pnt2cnt != null);

            if (pnt2cnt.id == 0)
            {
                // new
                vm.PNT2CNTs.Add(pnt2cnt);
                // VM saves changes to db in response to the Et2PTs_CollectionChanged property changed event, and on successful save we get the new id allocated by the db
            }
            else
            {
                // Modified?
                var dbet2pt = vm.PNT2CNTs.FirstOrDefault(x => x.id == pnt2cnt.id);
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

        private void PNT2CNT_OnDelete(object sender, RoutedEventArgs e)
        {
            Debug.WriteLine($"PNT2CNT_OnDelete called");
            var item = (dataGrid.SelectedItem as PNT2CNT);
            vm.PNT2CNTs.Remove(item);
            RefreshView();
        }

        private void OnPreviewKeyDown(object sender, KeyEventArgs e)
        {
            Debug.WriteLine($"TestDataGrid_OnPreviewKeyDown called");

            if (e.Key == Key.Delete)
            {
                var grid = (DataGrid)sender;

                if (grid.SelectedItems.Count > 0)
                {
                    foreach (var row in grid.SelectedItems)
                        vm.PNT2CNTs.Remove(row as PNT2CNT);
                }
            }
        }
    }
}
