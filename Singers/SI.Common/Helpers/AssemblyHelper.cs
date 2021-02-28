using System;
using System.Reflection;

namespace SI.Common.Helpers
{
    /// <summary>
    /// Provides helper functionality for the getting of file and product version information of the top level (executing) assembly.
    /// </summary>
    public static class AssemblyHelper
    {
        /// <summary>
        /// Get the file version of the executing assembly.
        /// </summary>
        /// <returns>The file version of the top level (executing) assembly.</returns>
        public static Version GetFileVersion()
        {
            var assembly = Assembly.GetExecutingAssembly();
            var x = (AssemblyFileVersionAttribute)Attribute.GetCustomAttribute(assembly, typeof(AssemblyFileVersionAttribute), false);
            var versionStr = x.Version;
            var version = Version.Parse(versionStr);
            return version;
        }

        /// <summary>
        /// Get the product version of the executing assembly.
        /// </summary>
        /// <returns>The product version of the top level (executing) assembly.</returns>
        public static Version GetProductVersion()
        {
            var assembly = Assembly.GetExecutingAssembly();
            var version = assembly.GetName().Version;
            return version;
        }

        /// <summary>
        /// Get the full assembly name for a type.
        /// </summary>
        /// <param name="t">The type.</param>
        /// <returns>The full assembly name.</returns>
        public static string GetAssemblyName(Type t)
        {
            var assemblyFullName = t.Assembly.FullName;

            // assembly names have to be trimmed to exclude version etc, which starts after first ,
            if (assemblyFullName.Contains(","))
                assemblyFullName = assemblyFullName.Remove(assemblyFullName.IndexOf(",", StringComparison.Ordinal));

            return assemblyFullName;
        }
    }
}
