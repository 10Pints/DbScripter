
namespace SI.Software.Tools.CustomConfiguration.TestConfiguration
{
   /// <summary>
   /// https://stackoverflow.com/questions/2718095/custom-app-config-section-with-a-simple-list-of-add-elements
   /// </summary>
   public class MethodConfigurationElementCollection : RecursiveDatabaseConfigurationElementCollection<MethodConfigurationElement>, IRecursiveDatabaseConfigurationElement
    {
        #region Construction

        public MethodConfigurationElementCollection()
            : base("method", null)
        {
        }

        #endregion
    }
}
