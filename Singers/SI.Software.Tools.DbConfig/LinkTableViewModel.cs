using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using SI.Common;
using SI.Software.SharedControls;

namespace DbConfig
{
    public class LinkTableViewModel : ViewModel
    {
        protected DbContext dbctx;

        protected LinkTableViewModel()
        {
        }

        protected void CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            Debug.WriteLine("CollectionChanged called");

            try
            {
                dbctx.SaveChanges();
            }
            catch (Exception ex)
            {
                var msg = $"Caught exception whilst saving changes to database: {ex.GetAllMessages()}";
                Debug.WriteLine(msg);
                MessageBox.Show(msg);
            }
        }

        public void UpdateChanges()
        {
            dbctx.SaveChanges();
        }

    }
}
