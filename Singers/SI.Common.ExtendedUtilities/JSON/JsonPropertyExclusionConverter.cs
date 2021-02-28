using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace SI.Common.ExtendedUtilities.JSON
{
    /// <summary>
    /// Provides filtering functionality to make sure that a list of properties are ignored. See JsonSerializerExtensions class ToJsonString() method for usage.
    /// </summary>
    public class JsonPropertyExclusionConverter : JsonConverter
    {
        #region Properties

        /// <summary>
        /// Get if nulls are ignored.
        /// </summary>
        public bool IgnoreNulls { get; }
        
        /// <summary>
        /// Get the parent type.
        /// </summary>
        public Type Type { get; }

        /// <summary>
        /// Get a list of properties that should be ignored.
        /// </summary>
        public List<string> PropertiesToIgnore { get; }

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the JsonPropertyExclusionConverter class.
        /// </summary>
        /// <param name="type">The parent Type to filter its properties.</param>
        /// <param name="propertiesToIgnore">A list of property names to ignore in the parent type.</param>
        /// <param name="ignoreNulls">If true will ignore properties that are null.</param>
        public JsonPropertyExclusionConverter(Type type, List<string> propertiesToIgnore, bool ignoreNulls)
        {
            IgnoreNulls = ignoreNulls;
            Type = type;
            PropertiesToIgnore = propertiesToIgnore ?? new List<string>();
        }

        /// <summary>
        /// Initializes a new instance of the JsonPropertyExclusionConverter class.
        /// </summary>
        /// <param name="type">The parent Type to filter its properties</param>
        /// <param name="ignoreNulls">if true will ignore properties that are null</param>
        public JsonPropertyExclusionConverter(Type type, bool ignoreNulls) : this(type, null, ignoreNulls) { }

        #endregion

        #region Overrides of JsonConverter

        /// <summary>
        /// Determines whether this instance can convert the specified object type.
        /// </summary>
        /// <param name="type">Type of the object.</param>
        /// <returns>True if this instance can convert the specified object type; otherwise, false.</returns>
        public override bool CanConvert(Type type)
        {
            if ((type == null) || (Type == null))
                return false;

            return Type == type;
        }

        /// <summary>
        /// Reads the JSON representation of the object.
        /// </summary>
        /// <param name="reader">The Newtonsoft.Json.JsonReader to read from.</param>
        /// <param name="objectType">Type of the object.</param>
        /// <param name="existingValue">The existing value of object being read.</param>
        /// <param name="serializer">The calling serialiser.</param>
        /// <returns>The object value.</returns>
        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Writes the JSON representation of the object.
        /// </summary>
        /// <param name="writer">The Newtonsoft.Json.JsonWriter to write to.</param>
        /// <param name="value">The value.</param>
        /// <param name="serializer">The calling serialiser.</param>
        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            var jo = new JObject();
            var valueType = value.GetType();
            jo.Add("type", valueType.Name);

            foreach (var propertyInfo in valueType.GetProperties())
            {
                if (!propertyInfo.CanRead)
                    continue;

                if (PropertiesToIgnore.Contains(propertyInfo.Name))
                    continue;

                var propVal = propertyInfo.GetValue(value, null);

                if (propVal != null)
                    jo.Add(propertyInfo.Name, JToken.FromObject(propVal, serializer));
            }

            jo.WriteTo(writer);
        }

        #endregion
    }
}