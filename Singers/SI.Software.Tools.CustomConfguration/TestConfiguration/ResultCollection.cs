using System.Configuration;

namespace SI.Software.Tools.CustomConfiguration.TestConfiguration
{
   public class ResultCollection : ConfigurationElementCollection
   {
      protected override ConfigurationElement CreateNewElement()
      {
         return new ResultElement();
      }

      protected override object GetElementKey(ConfigurationElement element)
      {
         //set to whatever Element Property you want to use for a key
         return ((ResultElement)element).Name;
      }
   }
}