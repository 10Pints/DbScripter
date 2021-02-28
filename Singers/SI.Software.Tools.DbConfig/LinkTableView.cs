using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using SI.Common;

namespace DbConfig
{
    public interface ILinkTableView
    {
        void RefreshView();
        void InitializeComponent();

    }

    public abstract class LinkTableView : Window
    {
        #region protected fields
        protected object         vm1; // View model

        protected SqlConnection  connection = new SqlConnection(ConfigurationManager.ConnectionStrings["SqlConnectionString"].ConnectionString);
        protected string         sql = "SELECT * From ET2PT";
        protected SqlDataAdapter sda;
        protected DataTable      dt;
        #endregion

        #region constructors and initialisation

        protected LinkTableView(string tableName, object viewModel)
        {
            dt = new DataTable(tableName);
            string sql = $"SELECT * From [{tableName}]";
            var sqlCommand = new SqlCommand(sql, connection);
            sda = new SqlDataAdapter(sqlCommand);
            dt = new DataTable("ET2PT");
            vm1 = vm1 = viewModel;
            DataContext = vm1;
        }




        protected void FillDataGrid()
        {
            try
            {
                sda.Fill(dt);
            }
            catch
            {
                MessageBox.Show("Unable to communicate with Database\nPlease check your connection and try again.");
            }
        }


        #endregion
    }
}
