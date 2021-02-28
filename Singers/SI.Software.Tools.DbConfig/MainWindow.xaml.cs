using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace DbConfig
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void BtnEP2PT_OnClick(object sender, RoutedEventArgs e)
        {
            var dialog = new ET2PTWindow();
            dialog.ShowDialog();
        }

        private void BtnPNT2CNT_OnClick(object sender, RoutedEventArgs e)
        {
            var dialog = new PNT2CNTWindow();
            dialog.ShowDialog();
        }
    }
}
