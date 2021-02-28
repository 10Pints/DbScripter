using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.CompilerServices;
using SI.Common.Configuration;

namespace SI.Common
{
    /// <summary>
    /// Provides common utilities.
    /// </summary>
    public static class Utils
    {
        /// <summary>
        /// Get the product name.
        /// </summary>
        public static string ProductName { get; set; }

        /// <summary>
        /// Get the product version.
        /// </summary>
        public static Version ProductVersion { get; set; }

        /// <summary>
        /// Precondition is used to validate the method preconditions - by logging an error message.
        /// </summary>
        /// <returns>The predicate for convenience.</returns>
        /// <param name="predicate">Is the predicate to check.</param>
        /// <param name="msg">An optional message to log.</param>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void Assertion<T>(bool predicate, string msg = "") where T : Exception, new()
        {
            if (!predicate)
               throw (T)Activator.CreateInstance(typeof(T), msg);
        }

        /// <summary>
        /// Precondition is used to validate the method preconditions - by logging an error message.
        /// </summary>
        /// <returns>the predicate for convenience.</returns>
        /// <param name="predicate">is the predicate to check.</param>
        /// <param name="msg"> optional message to log.</param>
        /// <returns>true if predicate is true, false if predicate is false but _throw is false.</returns>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void Assertion(bool predicate, string msg = "")
        {
            Assertion<Exception>(predicate, msg);
        }

        /// <summary>
        /// Precondition is used to validate the method preconditions - by logging an error message.
        /// </summary>
        /// <param name="predicate">The predicate to check.</param>
        /// <param name="msg">An optional message.</param>
        /// <returns>The predicate for convenience.</returns>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void Precondition<T>(bool predicate, string msg = "") where T : Exception, new()
        {
            if (!predicate)
            {
                var _msg = msg ?? "";
                throw (T)Activator.CreateInstance(typeof(T), msg);
            }
        }

        /// <summary>
        /// Precondition is used to validate the method preconditions - by logging an error message.
        /// </summary>
        /// <param name="predicate">The predicate to check.</param>
        /// <param name="msg">An optional message.</param>
        /// <returns>The predicate for convenience.</returns>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void Precondition(bool predicate, string msg = "Precondition violation")
        {
            if (!predicate)
                throw new Exception(msg);
        }

        /// <summary>
        /// Postcondition is used to validate the method postconditions - by logging an error message
        /// </summary>
        /// <returns>the predicate for convenience</returns>
        /// <param name="predicate">is the predicate to check</param>
        /// <param name="msg"> optional message</param>
        [MethodImpl(MethodImplOptions.NoInlining)]
        public static void Postcondition(bool predicate, string msg = "Postcondition violation")
        {
            if (!predicate)
                throw new Exception(msg);
        }

        /// <summary>
        /// Compares 2 maps case insensitively.
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <returns>true if a is a subset of b</returns>
        public static bool CompareMaps(Dictionary<string, string> a, Dictionary<string, string> b)
        {
            if (a.Count > b.Count)
                return false;

            foreach (var i in a.Keys)
            {
                if (!b.ContainsKey(i))
                    return false;

                if (!a[i].Equals(b[i], StringComparison.OrdinalIgnoreCase))
                    return false;
            }

            return true;
        }

        /// <summary>
        /// Replacement for the old Windows.Forms method to get the Users AppData path
        /// Standard Format: C:\Users\YOUR NAME\AppData\Roaming\COMPANY NAME\APPLICATION NAME\APPLICATION VERSION
        /// 
        /// E.G.
        /// C:\Users\TerryWatts\AppData\Roaming\Singer Instrument Company Limited\1.0.0.0 
        /// </summary>
        /// <returns></returns>
        public static string GetUserAppDataPath()
        {
            // Get the .EXE assembly
            var assembly = Assembly.GetEntryAssembly();
            string path;

            // Not available in unit testing
            // Get a collection of custom attributes from the .EXE assembly
            if (assembly != null)
            {
                var companyAttributes = assembly.GetCustomAttributes(typeof(AssemblyCompanyAttribute), false);
                // Get the Company Attribute
                var ct = ((AssemblyCompanyAttribute)(companyAttributes[0]));
                var assemblyFileVersionAttributes = assembly.GetCustomAttributes(typeof(AssemblyFileVersionAttribute), false);
                var fileVersionAttribute = (AssemblyFileVersionAttribute)assemblyFileVersionAttributes[0];
                var fileVersion = fileVersionAttribute.Version;
                var assemblyProductAttributes = assembly.GetCustomAttributes(typeof(AssemblyProductAttribute), false);
                var assemblyProductAttribute = (AssemblyProductAttribute)assemblyProductAttributes[0];
                // Build the User App Data Path
                path = $"{Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData)}\\{ct.Company}\\{assemblyProductAttribute.Product}\\{fileVersion}";
            }
            else
            {
                // Use test defaults
                // Standard Format: C:\Users\YOUR NAME\AppData\Roaming\COMPANY NAME\APPLICATION NAME\APPLICATION VERSION
                path = $"{Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData)}\\{CompanyConfig.CompanyName}\\{ProductName}{ProductVersion}";
            }

            return path;
        }

        /// <summary>
        /// In-lines the TryParse method
        /// </summary>
        /// <typeparam name="TEnum"></typeparam>
        /// <param name="s"></param>
        /// <param name="_default"></param>
        /// <returns></returns>
        public static TEnum Parse<TEnum>(string s, int _default = 0) where TEnum : struct
        {
            TEnum result;

            if (!Enum.TryParse<TEnum>(s, true, out result))
                result = (TEnum)(object)_default;

            return result;
        }

        /// <summary>
        /// Determines if a type is a simple data type like string or integer and not a class
        /// </summary>
        /// <param name="type">Type being assessed</param>
        /// <returns>true if simple, false otherwise</returns>
        public static bool IsSimpleType(Type type)
        {
            var typeInfo = type.GetTypeInfo();

            if (typeInfo.IsGenericType && typeInfo.GetGenericTypeDefinition() == typeof(Nullable<>))
            {
                // null-able type, check if the nested type is simple.
                return IsSimpleType((typeInfo.GetGenericArguments()[0]).GetTypeInfo());
            }

            if (typeInfo.IsPrimitive)
                return true;

            if (typeInfo.IsEnum)
                return true;

            if (typeInfo == typeof(string))
                return true;

            if (typeInfo == typeof(decimal))
                return true;

            return false;
        }


        /// <summary>
        /// Generic homogeneous assignment
        /// We have 2 types of assignment to deal with in testing
        /// 1: Assign T1 a to T1 b
        /// 2: Assign T1 a to T2 b where T1 and T2 have a common subset of fields 
        /// (fields of the same name and type)
        /// 
        /// This method handles the former case
        /// </summary>
        /// <typeparam name="T">Type being compared</typeparam>
        /// <param name="to">Instance being assigned to</param>
        /// <param name="from">Instance being assigned from</param>
        public static void AssignFrom<T>(T to, T from) where T : class, new()
        {
            var ty = typeof(T);
            var properties1 = ty.GetProperties();

            foreach (var property1 in properties1)
            {
                var propName = property1.Name;

                if (!IsSimpleType(property1.PropertyType))
                    continue;

                var property2 = ty.GetProperty(propName);

                if (property2 == null)
                    continue; // match

                var p1 = property1.GetValue(@from);
                property2.SetValue(to, p1);
            }
        }

        /// <summary>
        /// Determines if a type is null-able
        /// Convert() does not like null-able
        /// When Comparing Property values that are null-able with non null-able there is an extra level of indirection
        /// involved to get the value.
        /// This can be a pain in the ass dealing with Database types and EF's over simplistic but enforced approach.
        /// </summary>
        /// <param name="type"></param>
        /// <returns>True if type is null-able, false otherwise</returns>
        public static bool IsNullableType(Type type)
        {
            return type.IsGenericType && type.GetGenericTypeDefinition().Equals(typeof(Nullable<>));
        }

        /// <summary>
        /// Generic heterogeneous assignment
        /// Will assign common properties
        /// We have 2 types of assignment to deal with in testing
        /// 1: Assign T1 a to T1 b
        /// 2: Assign T1 a to T2 b where T1 and T2 have a common subset of fields 
        /// (fields of the same name and type)
        /// 
        /// This method handles the latter case
        /// The common field pairs must have types that are convertible from/to
        /// </summary>
        /// <typeparam name="T1">Type for the instance being assigned to</typeparam>
        /// <typeparam name="T2">Type for the instance being assigned from</typeparam>
        /// <param name="to">Instance being assigned to</param>
        /// <param name="from">Instance being assigned from</param>
        public static void AssignFrom<T1, T2>(T1 to, T2 from) where T1 : class, new() where T2 : class, new()
        {
            var tyTo = typeof(T1);
            var tyFrom = typeof(T2);
            var propertiesFrom = tyFrom.GetProperties();
            object valueFrom = null;
            object valueTo = null;

            foreach (var propertyFrom in propertiesFrom)
            {
                var propName = propertyFrom.Name;

                if (!IsSimpleType(propertyFrom.PropertyType))
                    continue;

                var propertyTo = tyTo.GetProperty(propName);

                if (propertyTo == null)
                    continue; // not found

                try
                {
                    valueFrom = propertyFrom.GetValue(@from);

                    // if the property to type is null-able, we need to get the underlying type of the property
                    var propertyToType = propertyTo.PropertyType;

                    if (IsNullableType(propertyToType))
                        propertyToType = Nullable.GetUnderlyingType(propertyToType);

                    if (propertyToType != null)
                    {
                        valueTo = Convert.ChangeType(valueFrom, propertyToType);
                        propertyTo.SetValue(to, valueTo);
                    }
                }
                catch (Exception e)
                {
                    Console.WriteLine($"Caught exception: {GetAllMessages(e)}\nTo type: {tyTo.FullName}\nFrom type: {tyFrom.FullName}\npropName: {propName} {valueFrom?.ToString() ?? "<null>"}");
                    throw;
                }
            }
        }

        /// <summary>
        /// Microsoft Exceptions often have information buried in inner exceptions, and it can be in an inconsistent manner
        /// This short recursive extension method gets all the messages (including the inner exception messages)
        /// and separates them by a /
        /// </summary>
        /// <param name="e">Exception instance to get messages from</param>
        /// <returns>all the messages from the exception and its inner exceptions recursively</returns>
        public static string GetAllMessages(this Exception e)
        {
            var msg = e.Message;

            if (e.InnerException != null)
                msg += $" / {e.InnerException.GetAllMessages()}";

            return msg;
        }
    }
}