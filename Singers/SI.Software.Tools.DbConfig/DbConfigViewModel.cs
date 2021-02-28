using System;
using System.Windows;
using System.Collections.ObjectModel;
//using System.Data.Entity;
using System.Diagnostics;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Windows.Controls;
using SI.Common;
using SI.DataLogging;


namespace DbConfig
{
    internal interface IDbConfigViewModel
    {
        EventTypeCollection                 EventTypes      { get; set; }
        PropertyTypeCollection              PropertyTypes   { get; set; }
        NodeTypeCollection                  NodeTypes       { get; set; }

        ObservableCollection<ET2PT>         ET2PTs          { get; set; }
        ObservableCollection<PNT2CNT>       PNT2CNTs        { get; set; }
    }

    /// <summary>
    /// View Model class for 
    /// </summary>
    public class DbConfigViewModel : LinkTableViewModel, IDbConfigViewModel
    {
        private NodeTypeCollection                  nodeTypes;
        private ObservableCollection<ET2PT>         et2PTs;
        private ObservableCollection<PNT2CNT>       pnt2cnts;

        private DataLoggingEntities _ctx;
        protected DataLoggingEntities ctx
        {
            get { return _ctx; }
            set
            { _ctx = value;
                dbctx = value;
            }
        }

        /// <summary>
        /// Singleton
        /// </summary>
        private static DbConfigViewModel instance = null;
        public static DbConfigViewModel Instance
        {
            get
            {
                if(instance == null)
                    instance = new DbConfigViewModel();

                return instance;
            }
        }

        public NodeTypeCollection NodeTypes
        {
            get
            {
                Debug.Assert(nodeTypes.Count>0);
                return nodeTypes;
            }
            set
            {
                nodeTypes = value;
                OnPropertyChanged();
            }
        }

        private object _id;
        public object ID
        {
            get
            {
                return _id;
            }
            set
            {
                _id = value;
                OnPropertyChanged();
            }
        }

        private object _selectedItem;
        public object SelectedItem
        {
            get
            {
                return _selectedItem;
            }
            set
            {
                _selectedItem = value;
                OnPropertyChanged();
            }
        }

        public EventTypeCollection EventTypes
        {
            get
            {
                Debug.Assert(eventTypes.Count > 0);
                return eventTypes;
            }
            set
            {
                eventTypes = value;
                OnPropertyChanged();
            }
        }
        private EventTypeCollection eventTypes;

        public PropertyTypeCollection PropertyTypes
        {
            get
            {
                Debug.Assert(propertyTypes.Count > 0);
                return propertyTypes;
            }
            set
            {
                propertyTypes = value;
                OnPropertyChanged();
            }
        }
        private PropertyTypeCollection propertyTypes;

        public ObservableCollection<ET2PT> ET2PTs
        {
            get
            {
                //Debug.Assert(et2PTs.Count > 0);
                return et2PTs;
            }
            set
            {
                if (et2PTs != null)
                    et2PTs.CollectionChanged -= CollectionChanged;

                et2PTs = value;

                if (et2PTs != null)
                    et2PTs.CollectionChanged += CollectionChanged;

                OnPropertyChanged();
            }
        }

        public ObservableCollection<PNT2CNT> PNT2CNTs
        {
            get
            {
                //Debug.Assert(et2PTs.Count > 0);
                return pnt2cnts;
            }
            set
            {
                if (pnt2cnts != null)
                    pnt2cnts.CollectionChanged -= CollectionChanged;

                pnt2cnts = value;

                if (pnt2cnts != null)
                    pnt2cnts.CollectionChanged += CollectionChanged;

                OnPropertyChanged();
            }
        }

        private void PNT2CNTs_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            Debug.WriteLine("PNT2CNTs_CollectionChanged called");

            try
            {
                ctx.SaveChanges();
            }
            catch (Exception ex)
            {
                var msg = $"Caught exception whilst saving PNT2CNT changes to database: {ex.GetAllMessages()}";
                Debug.WriteLine(msg);
                MessageBox.Show(msg);
            }
        }

        [SuppressMessage("ReSharper", "ReturnValueOfPureMethodIsNotUsed")]
        protected DbConfigViewModel()
        {
            ctx = new DataLoggingEntities();
            // Force population of the EF cache from database
            ctx.NodeTypes    .ToList();
            ctx.EventTypes   .ToList();
            ctx.PropertyTypes.ToList();
            ctx.ET2PT        .ToList();
            ctx.PNT2CNT      .ToList();

            // ASSERTION: EF cache loaded

            // Directly access the backing field to avoid the Property get populated check
            eventTypes    = Application.Current.Resources["EventTypeSource"]    as EventTypeCollection;
            nodeTypes     = Application.Current.Resources["NodeTypeSource"]     as NodeTypeCollection;
            propertyTypes = Application.Current.Resources["PropertyTypeSource"] as PropertyTypeCollection;

            // Internal code check
            Debug.Assert(eventTypes     != null);
            Debug.Assert(nodeTypes      != null);
            Debug.Assert(propertyTypes  != null);

            // Populate the node types
            foreach (var item in ctx.NodeTypes.Local)
                nodeTypes.Add(item);

            // Populate the event types
            foreach (var item in ctx.EventTypes.Local)
                eventTypes.Add(item);

            // Populate the property types
            foreach (var item in ctx.PropertyTypes.Local)
                propertyTypes.Add(item);

            // Add the Combo sources sorted in name order
            Application.Current.Resources["EventTypeSource"]    = eventTypes.   OrderBy(x => x.name);
            Application.Current.Resources["PropertyTypeSource"] = propertyTypes.OrderBy(x => x.name); ;
            Application.Current.Resources["NodeTypeSource"]     = nodeTypes.    OrderBy(x => x.name);
            ET2PTs = ctx.ET2PT.Local;
            PNT2CNTs = ctx.PNT2CNT.Local;
        }

        private GridInfo GetComboGridInfo(ComboBox cb)
        {
            GridInfo gi = new GridInfo();
            gi.row = GetRow(cb, out gi.cell);

            if (gi.row == null)
                return null;

            gi.grid = ItemsControl.ItemsControlFromItemContainer(gi.row) as DataGrid;

            if (gi.grid != null)
            {
                gi.colIndex = gi.cell.Column.DisplayIndex;
                gi.rowIndex = gi.grid.ItemContainerGenerator.IndexFromContainer(gi.row);
            }

            return gi;
        }

        private DataGridRow GetRow(ComboBox cb, out DataGridCell cell)
        {
            cell = cb.Parent as DataGridCell;

            if (cell == null)
            {
                Debug.WriteLine($"** could not determine cell from combo (parent is not a DataGridCell)");
                return null;
            }

            return DataGridRow.GetRowContainingElement(cell);
        }

    }

    public class DbConfigDesignViewModel : IDbConfigViewModel
    {
        #region Implementation of IDbConfigViewModel

        public EventTypeCollection                  EventTypes      { get; set; }
        public PropertyTypeCollection               PropertyTypes   { get; set; }
        public NodeTypeCollection                   NodeTypes       { get; set; }

        public ObservableCollection<ET2PT>          ET2PTs          { get; set; }
        public ObservableCollection<PNT2CNT>        PNT2CNTs        { get; set; }

        #endregion
    }

}
