using System;
using System.ComponentModel.Composition.Hosting;
using System.Reflection;

namespace RSS
{
    /// <summary>
    /// Represents any object that is a service locator.
    /// </summary>
    public interface IServiceLocator
    {
        /// <summary>
        /// Register assemblies.
        /// </summary>
        /// <param name="assemblies">The assemblies to register.</param>
        void Register(params Assembly[] assemblies);
        /// <summary>
        /// Register assemblies.
        /// </summary>
        /// <param name="types">The types whose assemblies to register.</param>
        void Register(params Type[] types);
        /// <summary>
        /// Resolve a type.
        /// </summary>
        /// <typeparam name="T">The object to resolve for.</typeparam>
        /// <returns>The resolved instance.</returns>
        T Resolve<T>() where T : class;
        /// <summary>
        /// Resolve an instance.
        /// </summary>
        /// <param name="instance">The instance to resolve.</param>
        void Resolve(object instance);
        /// <summary>
        /// Resolve for a type.
        /// </summary>
        /// <param name="type">The type to resolve for.</param>
        /// <returns>The resolved instance.</returns>
        object Resolve(Type type);
        /// <summary>
        /// Resolve an export.
        /// </summary>
        /// <param name="type">The type to resolve for.</param>
        /// <returns>The resolved instance.</returns>
        object ResolveExport(Type type);
        /// <summary>
        /// Resolve all objects for a type.
        /// </summary>
        /// <param name="type">The type to resolve all for.</param>
        /// <returns>The resolved instances.</returns>
        object[] ResolveAll(Type type);
        /// <summary>
        /// Resolve for a type of object.
        /// </summary>
        /// <typeparam name="T">The type of object to resolve.</typeparam>
        /// <returns>The resolved instance.</returns>
        T ResolveByType<T>() where T : class;
        /// <summary>
        /// Add an assembly catalog.
        /// </summary>
        /// <param name="catalog">The catalog to add.</param>
        void AddAssemblyCatalog(AssemblyCatalog catalog);
        /// <summary>
        /// Get an assembly catalog for a type.
        /// </summary>
        /// <typeparam name="T">The type to get the assembly catalog for.</typeparam>
        /// <param name="typeFilter">A filter to use for filtering types.</param>
        /// <returns>The assembly catalog.</returns>
        AssemblyCatalog GetAssemblyCatalogForType<T>(Predicate<Type> typeFilter);
        /// <summary>
        /// Add an assembly catalog for a type.
        /// </summary>
        /// <typeparam name="T">The type to add the assembly catalog for.</typeparam>
        /// <param name="typeFilter">A filter to use for filtering types.</param>
        void AddAssemblyCatalogForType<T>(Predicate<Type> typeFilter);
    }
}
