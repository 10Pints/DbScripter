using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.ComponentModel.Composition.Hosting;
using System.ComponentModel.Composition.Registration;
using System.Linq;
using System.Reflection;

namespace RSS
{
    /// <summary>
    /// Represents a MEF service locator.
    /// </summary>
    public class ServiceLocator : IServiceLocator
    {
        #region StaticFields

        private static readonly object syncLock = new object();
        private static volatile IServiceLocator serviceLocator;
        
        /// <summary>
        /// Get the singleton instance of ServiceLocator.
        /// </summary>
        public static IServiceLocator Instance
        {
            get
            {
                if (serviceLocator == null)
                {
                    lock (syncLock)
                    {
                        if (serviceLocator == null)
                        {
                            serviceLocator = new ServiceLocator();
                        }
                    }
                }

                return serviceLocator;
            }
        }

        #endregion

        #region Fields

        private CompositionContainer Container;
        private readonly AggregateCatalog Catalog = new AggregateCatalog();

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the ServiceLocator class.
        /// </summary>
        private ServiceLocator()
        {
            // create the CompositionContainer with the parts in the catalog
            Container = new CompositionContainer(Catalog);
        }

        #endregion

        #region Methods

        /// <summary>
        /// Get the generic GetExport<!--T-->>() function of the MEF container.
        /// </summary>
        /// <param name="type">The generic type.</param>
        /// <returns>The generic method info.</returns>
        protected MethodInfo GetGenericGetExportMethod(Type type)
        {
            var method = Container.GetType().GetMethods(BindingFlags.Instance | BindingFlags.Public).First(x => x.Name == "GetExport");
            return method.MakeGenericMethod(type);
        }

        /// <summary>
        /// Get the generic GetExports<!--T-->>() function of the MEF container.
        /// </summary>
        /// <param name="type">The generic type.</param>
        /// <returns>The generic method info.</returns>
        protected MethodInfo GetGenericGetExportsMethod(Type type)
        {
            var method = Container.GetType().GetMethods(BindingFlags.Instance | BindingFlags.Public).First(x => ((x.Name == "GetExports") && (x.IsGenericMethod)));
            return method.MakeGenericMethod(type);
        }

        #endregion

        #region Implementation of IServiceLocator
        
        /// <summary>
        /// Register assemblies.
        /// </summary>
        /// <param name="assemblies">The assemblies to register.</param>
        public void Register(params Assembly[] assemblies)
        {
            // iterate all assemblies and add a catalog for each
            foreach (var assembly in assemblies)
                AddAssemblyCatalog(new AssemblyCatalog(assembly));
        }

        /// <summary>
        /// Register assemblies.
        /// </summary>
        /// <param name="types">The types whose assemblies to register.</param>
        public void Register(params Type[] types)
        {
            var assemblies = new List<Assembly>();

            foreach (var type in types)
            {
                if (!assemblies.Contains(type.Assembly))
                    assemblies.Add(type.Assembly);
            }

            Register(assemblies.ToArray());
        }

        /// <summary>
        /// Resolve a type.
        /// </summary>
        /// <typeparam name="T">The object to resolve for.</typeparam>
        /// <returns>The resolved instance.</returns>
        public T Resolve<T>() where T : class
        {
            // resolve the dependencies
            return Resolve(typeof(T)) as T;
        }

        /// <summary>
        /// Resolve an instance.
        /// </summary>
        /// <param name="instance">The instance to resolve.</param>
        public void Resolve(object instance)
        {
            // resolve dependencies via MEF
            Container.ComposeParts(instance);
        }

        /// <summary>
        /// Resolve an export.
        /// </summary>
        /// <param name="type">The type to resolve for.</param>
        /// <returns>The resolved instance.</returns>
        public object ResolveExport(Type type)
        {
            // resolve dependencies via MEF
            var generic = GetGenericGetExportMethod(type);

            // GetExport<T> will return Lazy<T>
            dynamic lazyInstance = generic.Invoke(Container, null);

            // force initialization of the instance
            var instance = lazyInstance.Value;

            return instance;
        }

        /// <summary>
        /// Resolve all objects for a type.
        /// </summary>
        /// <param name="type">The type to resolve all for.</param>
        /// <returns>The resolved instances.</returns>
        public object[] ResolveAll(Type type)
        {
            var generic = GetGenericGetExportsMethod(type);

            // GetExports<T> will return IEnumerable<Lazy<T>>
            dynamic lazyInstances = generic.Invoke(Container, null);

            var instances = new List<object>();

            foreach (var lazyInstance in lazyInstances)
            {
                // force initialization of the instance
                instances.Add(lazyInstance.Value);
            }

            return instances.ToArray();
        }

        /// <summary>
        /// Resolve for a type.
        /// </summary>
        /// <param name="type">The type to resolve for</param>
        /// <returns>The resolved instance.</returns>
        public object Resolve(Type type)
        {
            // create the instance - requires empty constructor
            var instance = Activator.CreateInstance(type);

            // resolve dependencies via MEF
            // http://stackoverflow.com/questions/5810274/how-to-resolve-the-error-currently-composing-another-batch-in-this-composablepa
            // alternatively we can protect this code with lock
            Container.SatisfyImportsOnce(instance);

            return instance;
        }

        /// <summary>
        /// Resolve for a type of object.
        /// </summary>
        /// <typeparam name="T">The type of object to resolve.</typeparam>
        /// <returns>The resolved instance.</returns>
        public T ResolveByType<T>() where T : class
        {
            // resolve dependencies via MEF
            var export = Container.GetExport<T>();

            // force initialization of the instance
            var instance = export?.Value;

            return instance;
        }

        /// <summary>
        /// Add an assembly catalog.
        /// </summary>
        /// <param name="catalog">The catalog to add.</param>
        public void AddAssemblyCatalog(AssemblyCatalog catalog)
        {
            // don't allow assemblies that have already been registered to be registered again
            if (Catalog.Catalogs.Select(x => x as AssemblyCatalog).Any(assemblyCat => assemblyCat?.Assembly == catalog.Assembly))
                return;

            // add the catalog
            Catalog.Catalogs.Add(catalog);

            // re-create the CompositionContainer with the parts in the catalog
            Container = new CompositionContainer(Catalog);
        }

        /// <summary>
        /// Get an assembly catalog for a type.
        /// </summary>
        /// <typeparam name="T">The type to get the assembly catalog for.</typeparam>
        /// <param name="typeFilter">A filter to use for filtering types.</param>
        /// <returns>The assembly catalog.</returns>
        public AssemblyCatalog GetAssemblyCatalogForType<T>(Predicate<Type> typeFilter)
        {
            // based on https://stackoverflow.com/questions/19681374/mef-registrationbuilder-export-specific-interface-implementation

            var registrationBuilder = new RegistrationBuilder();
            registrationBuilder.ForTypesMatching<T>(typeFilter).ExportInterfaces();
            return new AssemblyCatalog(typeof(T).Assembly, registrationBuilder);
        }

        /// <summary>
        /// Add an assembly catalog for a type.
        /// </summary>
        /// <typeparam name="T">The type to add the assembly catalog for.</typeparam>
        /// <param name="typeFilter">A filter to use for filtering types.</param>
        public void AddAssemblyCatalogForType<T>(Predicate<Type> typeFilter)
        {
            var catalog = GetAssemblyCatalogForType<T>(typeFilter);
            if (catalog != null)
                AddAssemblyCatalog(catalog);
        }

        #endregion
    }
}
