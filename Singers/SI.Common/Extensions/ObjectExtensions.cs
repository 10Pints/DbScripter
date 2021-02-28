using System.Linq;

namespace SI.Common.Extensions
{
    /// <summary>
    /// Extension methods for object.
    /// </summary>
    public static class ObjectExtensions
    {
        /// <summary>
        /// Determine is an object has an attribute.
        /// </summary>
        /// <typeparam name="T">The attribute.</typeparam>
        /// <param name="obj">The object.</param>
        /// <returns>True if the object has the attribute, else false.</returns>
        public static bool HasAttribute<T>(this object obj)
        {
            var a = obj.GetType().GetCustomAttributes(typeof(T), true).FirstOrDefault();
            return a != null;
        }
    }
}
