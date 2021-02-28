using System;
using System.Collections.Generic;

namespace SI.Logging
{
    /// <summary>
    /// Represents a class for providing feedback logging functionality.
    /// </summary>
    public static class FeedbackComponentProvider
    {
        #region StaticProperties

        /// <summary>
        /// Get or the providers.
        /// </summary>
        private static readonly Dictionary<Type, object> Providers = new Dictionary<Type, object>();

        #endregion

        #region StaticMethods

        /// <summary>
        /// Find a feedback provider for a known type of object.
        /// </summary>
        /// <param name="type">The type of object to find the provider for.</param>
        /// <returns>The relevant feedback provider.</returns>
        public static object FindProvider(Type type)
        {
            // if there is no defined handler for this type, check back until we find an appropriate handler
            while ((type != null) && (type != typeof(object)) && (!Providers.ContainsKey(type)))
                type = type.BaseType;

            if (type == null)
                return null;

            return Providers.ContainsKey(type) ? Providers[type] : null;
        }

        /// <summary>
        /// Ensure a type has a valid provider.
        /// </summary>
        /// <param name="type">The type of object to ensure has a valid provider.</param>
        private static void EnsureValidProviderForType(Type type)
        {
            var provider = FindProvider(type) ?? new ObjectFeedbackLog();
            if (!Providers.ContainsKey(type))
                Providers.Add(type, provider);
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="entry">The entry to add.</param>
        public static void Append<T>(T entry)
        {
            Append(null, null, entry);
        }

        /// <summary>
        /// Append a new entry.
        /// </summary>
        /// <param name="sender">The sending object.</param>
        /// <param name="context">The context of the entry.</param>
        /// <param name="entry">The entry to add.</param>
        public static void Append<T>(object sender, object context, T entry)
        {
            var type = entry.GetType();
            EnsureValidProviderForType(type);
            var provider = Providers[type];

            if (provider is IFeedbackLog<T>)
            {
                var providerOfKnownType = provider as IFeedbackLog<T>;

                if ((sender != null) || (context != null))
                    providerOfKnownType.Append(sender, context, entry);
                else
                    providerOfKnownType.Append(entry);
            }
            else
            {
                var providerOfKnownType = provider as IFeedbackLog<object>;
                if (providerOfKnownType == null)
                    throw new NullReferenceException($"No feedback provider for type {type} implements IFeedbackLog<T>.");

                if ((sender != null) || (context != null))
                    providerOfKnownType.Append(sender, context, entry);
                else
                    providerOfKnownType.Append(entry);
            }
        }

        /// <summary>
        /// Get if there is a provider for a type.
        /// </summary>
        /// <param name="type">The type.</param>
        /// <returns>True if there is a provider for the type, else false.</returns>
        public static bool HasProvider(Type type)
        {
            return Providers?.ContainsKey(type) ?? false;
        }

        /// <summary>
        /// Register a provider.
        /// </summary>
        /// <param name="type">The type the provider provides feedback for.</param>
        /// <param name="provider">The provider.</param>
        public static void RegisterProvider(Type type, object provider)
        {
            Providers.Add(type, provider);
        }

        /// <summary>
        /// Un-register a provider.
        /// </summary>
        /// <param name="type">The type the to un-register feedback for.</param>
        public static void UnregisterProvider(Type type)
        {
            Providers.Remove(type);
        }

        /// <summary>
        /// Get all providers.
        /// </summary>
        /// <returns>The providers.</returns>
        public static Dictionary<Type, object> GetProviders()
        {
            return Providers;
        }

        #endregion
    }
}
