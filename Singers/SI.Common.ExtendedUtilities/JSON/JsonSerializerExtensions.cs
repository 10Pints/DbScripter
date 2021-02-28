using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace SI.Common.ExtendedUtilities.JSON
{
    #region Notes

    /*
     It can exclude properties of the main type, and properties of properties recursively
     The property filter works by specifying a set of properties to exclude for a type
     is keyed on the type to exclude the properties from, rather than a "property path" to the property
     So if you apply a filter properties of a sub type X - All properties of type X will be filtered
     So it is possible to apply a deep filter on sub properties
     
     E.G.:
     string oldObjectDump = obj.ToJsonString(new Dictionary&lt;Type, string&gt;()
             {
                 { app.GetType(), "Version,AppInitState,Thread,Hardware" },
                 { typeof(SomeOtherType), "Configuration"}
             });
     
     This will exclude the version, AppInitState Thread and hardware properties of an app object
     and the Configuration property of the app's SomeOtherType property.
     
     This is extremely useful in testing where we want only to test a subset of important properties - 
     excluding volatile properties that are unpredictable as they change at run time.
    */
    
    #endregion

    /// <summary>
    /// Provides serialisation functionality to JSON.
    /// </summary>
    public static class JsonSerializerExtensions
    {
        /// <summary>
        /// Serialise to a JSON string.
        /// </summary>
        /// <param name="target">The object to serialise.</param>
        /// <param name="csvPropertiesToIgnoreForTypeMap">A map of type to CSV file set of properties to ignore for that type.</param>
        /// <param name="ignoreNulls">True if ignoring null, else false.</param>
        /// <returns>The serialised JSON string.</returns>
        public static string ToJsonString(this object target, Dictionary<Type, string> csvPropertiesToIgnoreForTypeMap = null, bool ignoreNulls = true)
        {
            var jsonSerializer = new JsonSerializer();

            // add a time converter so that  we get a time string and not a time serial number
            var isoDateTimeConverter = new IsoDateTimeConverter { DateTimeFormat = "yyyy-MM-dd hh:mm:ss" };
            jsonSerializer.Converters.Add(isoDateTimeConverter);

            // configure null handling
            jsonSerializer.NullValueHandling = ignoreNulls ? NullValueHandling.Ignore : NullValueHandling.Include;

            // want a pretty print style output that is formatted nicely, rather than a single line
            jsonSerializer.Formatting = Formatting.Indented;
            var separators = ",".ToArray();

            // set up the ignore converters
            if (csvPropertiesToIgnoreForTypeMap != null)
            {
                foreach (var key in csvPropertiesToIgnoreForTypeMap.Keys)
                {
                    var propertiesToListToIgnoreForType = csvPropertiesToIgnoreForTypeMap[key].Split(separators).ToList();
                    jsonSerializer.Converters.Add(new ExtendedUtilities.JSON.JsonPropertyExclusionConverter(key, propertiesToListToIgnoreForType, ignoreNulls));
                }
            }

            string serialised;

            using (var textWriter = new StringWriter())
            {
                // do the real work now we have configured the serialiser to handle dates and ignore specific properties
                jsonSerializer.Serialize(textWriter, target);

                // set serialised string
                serialised = textWriter.ToString();
            }

            return serialised;
        }
    }
}
