namespace RSS.Test
{
    public class AssemblyCollection : ConfigurationElementCollectionTemplate<AssemblyElement>
    {
        //internal TestConfigurationSection Section { get; set; }

        public AssemblyCollection() : base("assembly")
        {
        }
    }
}
