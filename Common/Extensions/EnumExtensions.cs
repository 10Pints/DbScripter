using System;
using System.Collections.Generic;
using System.Linq;
using RSS.Common;

namespace RSS
{ 
    /// <summary>
    /// This class is part of a mechanism to provide a friendly name to display.
    /// </summary>
    public static class EnumExtensions
    {
        #region Notes

        /* 
         * Example Usage:
         *  public enum TestE
         *  {
         *      [EnumAlias("Emp")]
         *      A,
         *      [EnumAlias("New York")]
         *      B,
         *      [EnumAlias("South Carolina")]
         *      C,
         *      D // No Alias
         *  };
         *
         *  static class Program
         *  {
         *      private static void Main(string[] args)
         *      {
         *          Helper(TestE.A);
         *          Helper(TestE.B);
         *          Helper(TestE.C);
         *          Helper(TestE.D);
         *      }
         *
         *      private static void Helper(Enum e)
         *      {
         *          Console.WriteLine($"{e.ToString()} {e} alias: {e.GetAlias()}");
         *      }
         *
         *  >>>>>>>>>> OUTPUT:
         *  
         *   A A alias: Emp
         *   B B alias: New York
         *   C C alias: South Carolina
         *   D D alias: D
         */

        #endregion

        /// <summary>
        /// Get an alias.
        /// </summary>
        /// <param name="value">The value.</param>
        /// <returns>The alias.</returns>
        public static string GetAlias(this Enum value)
        {
            string alias = null;
            var type = value.GetType();
            var fi = type.GetField(value.ToString());
            var attrs = fi.GetCustomAttributes(typeof(EnumAliasAttribute), false) as EnumAliasAttribute[];

            if (attrs?.Length > 0)
                alias = attrs[0].Alias;

            return alias ?? value.ToString();
        }

        /// <summary>
        /// Get values. Throws a NotSupportedException if type is not an enum.
        /// </summary>
        /// <typeparam name="T">Required enum type.</typeparam>
        /// <param name="t">The type.</param>
        /// <returns>The values.</returns>
        public static IEnumerable<T> GetValues<T>(this Type t)
        {
            if(!t.IsEnum)
                throw new NotSupportedException();

            return Enum.GetValues(t).Cast<T>();
        }

        /// <summary>
        /// Gets an enum from its Alias. Returns the first enum value whose alias = the Alias- case and culture insensitive. Throws a NotSupportedException if type is not an enum.
        /// </summary>
        /// <typeparam name="T">Required enum type.</typeparam>
        /// <param name="alias">The alias.</param>
        /// <returns>The values.</returns>
        public static T FindEnumByAliasExact<T>(this string alias)
        {
            var values = GetValues<T>(typeof(T));

            foreach (var item in values)
            {
                var e = item as Enum;
                var itemAlias = e.GetAlias();

                if (string.Compare(itemAlias, alias, StringComparison.OrdinalIgnoreCase) == 0)
                    return item;
            }

            return default(T);
        }

        /// <summary>
        /// Gets an enum from its Alias case insensitive. This is useful when the full enum alias cannot be derived at the request time. Throws a NotSupportedException if type is not an enum.
        /// </summary>
        /// <typeparam name="T">Required enum type.</typeparam>
        /// <param name="alias">The alias.</param>
        /// <returns>The enum value.</returns>
        public static T FindEnumByAlias<T>(this string alias) where T: Enum
        {
            var values = GetValues<T>(typeof(T));
            var strToFind = alias.ToLower();
         Enum e = null;

            foreach (var item in values)
            {
                e = item as Enum;
                var itemAlias = e.GetAlias().ToLower();

                if (itemAlias.Contains(strToFind))
                    return item;
            }

            throw new Exception($"alias [{alias}] not found foe enum [{e.GetType().ToString()}]");
            //return default(T);
        }
    }
}
