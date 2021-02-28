using System;

namespace SI.Common
{
    /// <summary>
    /// Provides extension functionality for adding Alias to enumerations.
    /// </summary>
    /// <inheritdoc cref="Attribute"/>
    [AttributeUsage(AttributeTargets.Field)]
    public class EnumAliasAttribute : Attribute
    {
        #region Properties

        /// <summary>
        /// Get the alias.
        /// </summary>
        public string Alias { get; }

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the EnumAliasAttribute class.
        /// </summary>
        /// <param name="alias">The alias.</param>
        public EnumAliasAttribute(string alias)
        {
            Alias = alias;
        }

        #endregion

        #region StaticMethods

        /// <summary>
        /// Get the alias for an object.
        /// </summary>
        /// <param name="obj">The object.</param>
        /// <returns>The alias.</returns>
        public static string GetAlias(object obj)
        {
            var member = obj?.GetType().GetMember(obj.ToString());

            if ((member == null) || (member.Length <= 0))
                return null;

            var attribute = GetCustomAttribute(member[0], typeof(EnumAliasAttribute)) as EnumAliasAttribute;
            return attribute?.Alias;
        }

        #endregion
    }
}


