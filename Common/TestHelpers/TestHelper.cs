
#nullable enable 
#pragma warning disable CS8602, CS8603
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using RSS.Common;
using static RSS.Common.Logger;

namespace RSS.Test
{
   /// <summary>
   /// Provides helper methods for unit tests.
   /// </summary>
   public static class TestHelper
   {
      #region Constants

      /// <summary>
      /// Get the epsilon value. Floating point differences less than epsilon are considered insignificant.
      /// </summary>
      public const double Epsilon = 1E-05;

      /// <summary>
      /// Get a standard limit for errors.
      /// </summary>
      public const int MaxErrors = 30;

      #endregion

      /// <summary>
      /// Relative location of the script files
      /// N.B DbHelper uses the same location
      /// </summary>
      public static string ScriptDir
      {
         get { return ".\\Scripts"; }
      }

      /// <summary>
      /// Relative location of the script files
      /// N.B DbHelper uses the same location
      /// </summary>
      public static string ResultsDir
      {
         get
         {
            var resultsDir = @"..\..\..\TestResults";
            resultsDir = Path.GetFullPath(resultsDir);
            Utils.Assertion(Directory.Exists(resultsDir));
            return resultsDir;
         }
      }

      #region Public methods
      #region Public Static Methods

      /// <summary>
      /// Makes a copy of an object using reflection.
      /// </summary>
      /// <typeparam name="T">Type being cloned.</typeparam>
      /// <param name="a">Instance being cloned.</param>
      /// <returns>A  Clone of A (N.B.: only Properties are copied).</returns>
      public static T Clone<T>( object a ) where T : new()
      {
         var b = new T();
         var type = typeof(T);
         var properties = type.GetProperties();

         foreach(var property in properties)
         {
            var v = property.GetValue(a);
            property.SetValue(b, v);
         }

         return b;
      }

      /// <summary>
      /// Only compares only the simple typed fields of a type not fields that are class types.
      /// Intended to deal with the issues of the EF classes having extra fields that are complex objects 
      /// and not simple data types e.g. FKs into related objects.
      /// </summary>
      /// <typeparam name="T">Type being compared.</typeparam>
      /// <param name="a">instance a being compared.</param>
      /// <param name="b">instance b being compared with a.</param>
      /// <returns>True if match, false otherwise.</returns>
      public static bool Equals<T>( T a, T b )
      {
         var type = typeof(T);
         var properties = type.GetProperties();

         foreach(var property in properties)
         {
            if(!Utils.IsSimpleType(property.PropertyType))
               continue;

            var pa = property.GetValue(a);
            var pb = property.GetValue(b);

            if(pa == null)
            {
               if(pb == null)
                  continue; // both false

               LogD($" a.{property.Name}:is null but b.{property.Name} is not null - returning false");
               return false;
            }

            // ASSERTION: pa NOT NULL
            if(pb == null)
            {
               LogD($" a.{property.Name}:is not null but b.{property.Name} is null - returning false");
               return false;
            }

            if(!pa.Equals(pb))
            {
               LogD($"Mismatch on field {property.Name}: expected:[{pb}] actual:[{pa}] ");
               return false;
            }
         }

         return true;
      }

      /// <summary>
      /// Returns a T2 populated from T1 argument.
      /// T2 may be a subset of T1 properties.
      /// </summary>
      /// <typeparam name="T1">Type converted from.</typeparam>
      /// <typeparam name="T2">Type converted to.</typeparam>
      /// <param name="a">T1 instance being converted.</param>
      /// <returns>True if a's simply Properties are matched in b false otherwise.</returns>
      public static T2 AssignFrom<T1, T2>( T1 a ) where T2 : new()
      {
         var t1 = typeof(T1);
         var t2 = typeof(T2);
         var properties1 = t1.GetProperties();
         var b = new T2();

         foreach(var property1 in properties1)
         {
            var propertyName = property1.Name;

            if(!Utils.IsSimpleType(property1.PropertyType))
               continue;

            // Not all A properties may exist in B and vice versa
            var property2 = t2.GetProperty(propertyName);

            if(property2 != null)
            {
               PropertyInfo? propertyInfo = GetPropertyInfo<T2>(propertyName);
               Utils.Assertion(propertyInfo != null);
               propertyInfo?.SetValue(b, property1.GetValue(a));
            }
         }

         return b;
      }

      /// <summary>
      /// Overload that assigns and instance of type T2 from an instance of type T1.
      /// The types need to be sufficiently similar to be meaningful in the test.
      /// </summary>
      /// <typeparam name="T1">Type of value assigned from (assignee).</typeparam>
      /// <typeparam name="T2">Type of value assigned to.</typeparam>
      /// <param name="a">(assignee) instance of type 1.</param>
      /// <param name="propertyMap">properties to assign.</param>
      /// <returns>The result.</returns>
      public static T2 AssignFrom<T1, T2>( T1 a, Dictionary<string, string> propertyMap ) where T2 : new()
      {
         var t1 = typeof(T1);
         var t2 = typeof(T2);
         var properties1 = t1.GetProperties();
         var b = new T2();

         foreach(var property1 in properties1)
         {
            var propertyName = property1.Name;
            var propertyName2 = property1.Name;

            // Translate the name
            if(propertyMap.ContainsKey(propertyName))
               propertyName2 = propertyMap[propertyName];

            if(!Utils.IsSimpleType(property1.PropertyType))
               continue;

            // Not all A properties may exist in B and vice versa
            var property2 = t2.GetProperty(propertyName2);

            if(property2 != null)
            {
               var propertyInfo = GetPropertyInfo<T2>(propertyName);
               propertyInfo.SetValue(b, property1.GetValue(a));
            }
         }

         return b;
      }

      /// <summary>
      /// Only compares simple property types not class types - intended for data testing.
      /// Use this when comparing different types.
      /// The property set of T2 should be a superset of T1.
      /// Note it would not be hard to extend this to compare complex properties (Class Types) 
      /// by recursively calling this method for each Class typed property.
      /// </summary>
      /// <typeparam name="T1"></typeparam>
      /// <typeparam name="T2"></typeparam>
      /// <param name="a"></param>
      /// <param name="b"></param>
      /// <returns>True if a's simply Properties are matched in b false otherwise.</returns>
      public static bool Equals<T1, T2>( T1 a, T2 b )
      {
         var t1 = typeof(T1);
         var t2 = typeof(T2);
         var properties1 = t1.GetProperties();
         int commonFieldCount = 0;

         foreach(var property1 in properties1)
         {
            var propertyName = property1.Name;

            if(!Utils.IsSimpleType(property1.PropertyType))
               continue;

            var property2 = t2.GetProperty(propertyName);

            if(property2 == null)
               continue; // match

            // We have a matching property
            commonFieldCount++;

            if(!CompareProperty(propertyName, a, b))
            {
               LogE($"Mismatch on field: {propertyName} object a: {Dump(a)} \nobject b: {Dump(b)}");
               return false;
            }
         }

         return (commonFieldCount > 0);
      }

      /// <summary>
      /// Only compares simple property types not class types - intended for data testing.
      /// Use this when comparing different types.
      /// The property set of T2 should be a superset of T1.
      /// Note it would not be hard to extend this to compare complex properties (Class Types) 
      /// by recursively calling this method for each Class typed property.
      /// </summary>
      /// <typeparam name="T1"></typeparam>
      /// <typeparam name="T2"></typeparam>
      /// <param name="a"></param>
      /// <param name="b"></param>
      /// <param name="propertyMap">used to map property name from a to b</param>
      /// <returns></returns>
      public static bool Equals<T1, T2>( T1 a, T2 b, Dictionary<string, string> propertyMap )
      {
         var t1 = typeof(T1);
         var t2 = typeof(T2);
         var properties1 = t1.GetProperties();
         int commonFieldCount = 0;

         foreach(var property1 in properties1)
         {
            var propertyName = property1.Name;

            if(!Utils.IsSimpleType(property1.PropertyType))
               continue;

            // Try to map the property name to the lookup, if not use the same name
            var propertyName2 = propertyName;

            if(propertyMap.ContainsKey(propertyName))
               propertyName2 = propertyMap[propertyName];

            var property2 = t2.GetProperty(propertyName2);

            if(property2 == null)
               continue; // match

            // We have a matching property
            commonFieldCount++;

            if(!CompareProperty(propertyName, a, b, propertyName2))
            {
                LogE($"Mismatch on field: {propertyName} object a: {Dump(a)} \nobject b: {Dump(b)}");
               return false;
            }
         }

         return (commonFieldCount > 0);
      }

      /// <summary>
      /// Gets the [propertyName] property from instance - converted to type TFld.
      /// This works on properties not fields.
      /// </summary>
      /// <typeparam name="TCls">The instance type.</typeparam>
      /// <typeparam name="TFld">The property type.</typeparam>
      /// <param name="instance">The instance to take the field from.</param>
      /// <param name="propertyName">The name of the property.</param>
      /// <returns>The value of the property as type TFld.</returns>
      public static TFld GetProperty<TCls, TFld>( TCls instance, string propertyName )
      {
         var fldType = typeof(TFld);
         var value = GetProperty(instance, propertyName);

         if(value != null)
         {
            var actFieldtype = value.GetType();

            if(actFieldtype != fldType)
               value = Convert.ChangeType(value, fldType);
         }

         return (TFld)(value);
      }

      /// <summary>
      /// Use to convert from T to T?
      /// </summary>
      /// <param name="type"></param>
      /// <returns></returns>
      public static Type GetNullableType( Type type )
      {
         // Use Nullable.GetUnderlyingType() to remove the Nullable<T> wrapper if type is already nullable.
         type = Nullable.GetUnderlyingType(type) ?? type; // avoid type becoming null
         if(type.IsValueType)
            return typeof(Nullable<>).MakeGenericType(type);
         else
            return type;
      }

      /// <summary>
      /// Gets the [propertyName] property value from instance
      /// if not found returns null
      /// </summary>
      /// <typeparam name="T"></typeparam>
      /// <param name="instance"></param>
      /// <param name="propertyName"></param>
      /// <returns>Returns the [propertyName] property value from instance or if propertyName not found then returns null</returns>
      public static object GetProperty<T>( T instance, string propertyName )
      {
         var propertyInfo = GetPropertyInfo<T>(propertyName);
         return (propertyInfo == null) ? null : propertyInfo.GetValue(instance);
      }

      /// <summary>
      /// Sets the property value of a specified object.
      /// Exceptions: 
      ///  ArgumentException:                    accessor is not found or the value cannot be converted to the property type
      ///  Reflection.TargetException:           the type of obj does not match the target type, or a property is an instance property but obj is null.
      ///  MethodAccessException:                there was an illegal attempt to access a private or protected method inside a class.
      ///  Reflection.TargetInvocationException  an error occurred while setting the property value. The InnerException property indicates the reason for the error.
      /// </summary>
      /// <typeparam name="TCls">instance type</typeparam>
      /// <param name="instance">The object whose property value will be set.</param>
      /// <param name="propertyName">name of the property to set</param>
      /// <param name="val">The new property value to set.</param>
      public static void SetProperty<TCls>( TCls instance, string propertyName, object val )
      {
         var propertyInfo = GetPropertyInfo<TCls>(propertyName);
         propertyInfo.SetValue(instance, val);
      }

      /// <summary>
      /// 
      /// </summary>
      /// <typeparam name="TCls">instance type</typeparam>
      /// <param name="propertyName">name of the property</param>
      /// <returns>The property info for the property</returns>
      public static PropertyInfo? GetPropertyInfo<TCls>( string propertyName )
      {
         var clsType = typeof(TCls);
         var propertyInfo = clsType.GetProperty(propertyName);

         if(propertyInfo == null)
             LogW($"Could not get Property infor for property named [{propertyName}]");

         return propertyInfo;
      }

      /// <summary>
      /// Compares 2 objects with a common property
      /// It handles the case where a null-able type is being compared with a non null-able type of the same underlying type
      /// This is particularly an issue with NULLABLE database fields - e.g in EF
      /// </summary>
      /// <param name="propertyNameA">the name of the property to compare</param>
      /// <param name="propertyNameB">optional property name for object b</param>
      /// <param name="a">instance 1 being compared</param>
      /// <param name="b">instance 2 being compared</param>
      /// <returns>true if a == b, false otherwise</returns>
      public static bool CompareProperty( string propertyNameA
                                        , object? a
                                        , object? b
                                        , string? propertyNameB = null )
      {
         bool ret;

         if(propertyNameB == null)
            propertyNameB = propertyNameA;

         try
         {
            Type typeA = a.GetType();
            var typeB = b.GetType();
            var propertyInfoA = typeA.GetProperty(propertyNameA);
            var propertyInfoB = typeB.GetProperty(propertyNameB);

            if(propertyInfoA == null)
               Assert.IsNotNull(propertyInfoA, $"A.Property info {propertyNameA} is null");

            if(propertyInfoB == null)
               Assert.IsNotNull(propertyInfoB, $"B.Property info {propertyNameB} is null");

            var propertyTypeA = propertyInfoA.PropertyType;
            var propertyTypeB = propertyInfoB.PropertyType;
            var propertyA = propertyInfoA.GetValue(a);
            var propertyB = propertyInfoB.GetValue(b);
            // Convert.ChangeType does not handle conversion to null-able types
            // if the property type is null-able, we need to get the underlying type of the property
            var targetTypeA = Utils.IsNullableType(propertyTypeA) ? Nullable.GetUnderlyingType(propertyTypeA) : propertyTypeA;
            var targetTypeB = Utils.IsNullableType(propertyTypeB) ? Nullable.GetUnderlyingType(propertyTypeB) : propertyTypeB;
            Assert.IsNotNull(targetTypeA, $"targetType for A property {propertyNameA} is null");
            Assert.IsNotNull(targetTypeB, $"targetType for B property  {propertyNameB} is null");
            propertyA = Convert.ChangeType(propertyA, targetTypeA);
            propertyB = Convert.ChangeType(propertyB, targetTypeB);
            Assert.IsNotNull(propertyA, $"A.Property {propertyNameA} is null");
            Assert.IsNotNull(propertyB, $"B.Property {propertyNameB} is null");
            ret = CompareProperty(propertyTypeA, propertyA, propertyTypeB, propertyB);

            if(!ret)
                LogE($"Mismatch on  a.{propertyNameA}:{propertyA} b.{propertyNameB}:{b} ");
         }
         catch(Exception e)
         {
             LogE($"Caught exception {e.GetAllMessages()}");
            throw;
         }

         return ret;
      }


      /// <summary>
      /// Only compares simple types not class types - intended for data testing
      /// Compares only the specified fields
      /// </summary>
      /// <typeparam name="T">Type of the objects being compared</typeparam>
      /// <param name="a">Instance a of type T being compared</param>
      /// <param name="b">Instance b of type T being compared</param>
      /// <param name="ignoreProperties">possibly empty list of properties to ignore</param>
      /// <returns>true if match, false otherwise</returns>
      public static bool EqualsNotFields<T>( T a, T b, string[] ignoreProperties )
      {
         var type = typeof(T);
         var properties = type.GetProperties();

         foreach(var property in properties)
         {
            var propertyName = property.Name;

            if(!Utils.IsSimpleType(property.PropertyType))
               continue;

            // If not fields specified then if this field is specified not to be checked then skip
            if((ignoreProperties != null) && (ignoreProperties.Contains(propertyName)))
               continue;

            var pa = property.GetValue(a);
            var pb = property.GetValue(b);

            if(pa == null)
               return false;

            if(!pa.Equals(pb))
               return false;
         }

         return true;
      }

      /// <summary>
      /// Serialises t to a string, useful in testing and debugging
      /// </summary>
      /// <typeparam name="T">Type of t</typeparam>
      /// <param name="t">instance</param>
      /// <param name="_sb">optional string builder - e.g. is enumerating a collection of wows</param>
      /// <returns>A string serialization of t </returns>
      public static string Dump<T>( T t, StringBuilder? _sb = null )
      {
         const int tabSize = 15;
         const string padding = "                ";
         var type = typeof(T);
         var properties = type.GetProperties();
         var sb = _sb ?? new StringBuilder($"Dumping {type.Name}:\n");
         sb.Append("{\n");

         foreach(var property in properties)
         {
            var propertyName = property.Name;

            if(!Utils.IsSimpleType(property.PropertyType))
               continue;

            var value = property.GetValue(t).ToString();
            var len = Math.Max(tabSize - propertyName.Length, 0);
            sb.Append($"\t{propertyName}: {padding.Substring(0, len)} [{value}]\n");
         }

         sb.Append("}\n");
         return sb.ToString();
      }
      /// <summary>
      /// Use this to check for 1 or more clauses in a returned message
      /// Very useful in testing when we want to check for a set of sub-strings in an exception
      /// </summary>
      /// <param name="actualMessage">message to check the expected clauses exist in</param>
      /// <param name="expectedClauses">tab or separators separated list of expected clauses to look for</param>
      /// <param name="separators">a list of separators used to split the expectedClauses list in to separate clauses
      /// defaulting to tab, but could use , or ; etc.</param>
      /// <returns>true if all clauses found in message, false otherwise</returns>
      public static bool CheckMessages( string actualMessage, string expectedClauses, string separators = "\t" )
      {
         if(separators != null)
         {
            foreach(var expectedClause in expectedClauses.Split(separators.ToCharArray()))
               if(!CheckMessage(actualMessage, expectedClause))
                  return false;
         }
         else
         {
            if(!CheckMessage(actualMessage, expectedClauses))
               return false;
         }

         return true;
      }

      /// <summary>
      /// Called by CheckMessages it checks that the one expected message
      /// is a substring of the actual message.
      /// This is primarily used in checking exceptions during testing
      /// </summary>
      /// <param name="actualMessage"> string to check for the existence of the expected message</param>
      /// <param name="expectedClause">the expected clause</param>
      /// <returns>true if expectedClause is null or empty
      ///               else (expectedClause populate) 
      ///                 returns true if the actual message contains the expectedClause as a simple substring
      ///                 false otherwise</returns>
      public static bool CheckMessage( string actualMessage, string expectedClause )
      {
         var ret = true;

         if(!String.IsNullOrEmpty(expectedClause))
         {
            if(!actualMessage.Contains(expectedClause))
            {
                LogE($"Missing message clause: {expectedClause}");
               ret = false;
            }
         }

         return ret;
      }

      /// <summary>
      /// Checks the exists or not exists as specified be the expectExist parameter
      /// </summary>
      /// <param name="path"></param>
      /// <param name="expectExist">if true then check exists, if false then check file does not exist</param>
      /// <returns>True if path exists as an absolute or relative path, false otherwise</returns>
      public static bool CheckPathExists( string path, bool expectExist = true )
      {
         // Handles Files or Directories
         var exists = Exists(path, false);
         var phrase = expectExist ? "not" : "unexpectedly";

         if(exists != expectExist)
             LogE($"File {phrase} found: {path}");

         return (exists == expectExist);
      }

      /// <summary>
      /// Simple generic routine that can be used for both files or directories
      /// To check the existence of the supplied file or directory
      /// </summary>
      /// <param name="path"></param>
      /// <param name="logFailure">log if not found</param>
      /// <returns>True if exists, false otherwise</returns>
      public static bool Exists( string path, bool logFailure = true )
      {
         if(File.Exists(path))
            return true;

         return Directory.Exists(path);
      }

      /// <summary>
      /// Replaces the tags  - keys with their respective values in the map
      /// </summary>
      /// <param name="s">initial string holding the keys</param>
      /// <param name="tagReplacementMap">map of keys to replace with their associated values</param>
      /// <returns>string substituted with all the tags</returns>
      public static string ReplaceTags( string s, Dictionary<string, string> tagReplacementMap )
      {
         var s2 = s;

         foreach(var pair in tagReplacementMap)
            s2 = s2.Replace(pair.Key, pair.Value);

         return s2;
      }

      /// <summary>
      /// Compares the scripts, it does NOT do any substitution
      /// DbTestHelper CompareScriptsDatabaseScripts() performs some substituion, 
      /// then uses this method to do the comparison
      /// PRE: CompareDatabaseScripts() expects all substitution done,
      /// </summary>
      /// <param name="expectedScript">expected script</param>
      /// <param name="actualScript"> actual script </param>
      /// <param name="errorMsg">error message </param>
      /// <returns></returns>
      public static bool CompareScripts( string expectedScript, string actualScript, out string errorMsg )
      {
         var stringSeparators = new[] { Environment.NewLine };
         var actualLines = actualScript.Split(stringSeparators, StringSplitOptions.None);
         var expectedLines = expectedScript.Split(stringSeparators, StringSplitOptions.None);
         var actualCount = actualLines.Length;
         var expectedCount = expectedLines.Length;
         bool match = true; // optimistic
         errorMsg = "";

         if(actualCount != expectedCount)
         {
            errorMsg = $"Scripts don't match: line count: (e/a) {expectedCount}/{actualCount}";
             LogE(errorMsg);
            match = false;
         }

         for(var i = 0; i < Math.Min(actualCount, expectedCount); i++)
         {
            if(!actualLines[i].Equals(expectedLines[i]))
            {
               errorMsg = $"Scripts don't match at line {i + 1} \nExpected: [{expectedLines[i]}]\nActual:   [{actualLines[i]}]";
                LogE(errorMsg);
               return false;
            }
         }

         return match;
      }

      public static bool CompareScriptFiles( string expectedScriptPath, string actualScriptPath, out string errorMsg )
      {
         var stringSeparators = new[] { Environment.NewLine };
         var expectedScript = File.ReadAllText(expectedScriptPath);
         var expectedLines = expectedScript.Split(stringSeparators, StringSplitOptions.None);

         var actualScript = File.ReadAllText(actualScriptPath);
         Assert.IsTrue(!string.IsNullOrEmpty(actualScript));
         var actualLines = actualScript.Split(stringSeparators, StringSplitOptions.None);

         var actualCount = actualLines.Length;
         var expectedCount = expectedLines.Length;
         bool match = true; // optimistic
         errorMsg = "";

         if(actualCount != expectedCount)
         {
            errorMsg = $"Scripts don't match: line count: (e/a) {expectedCount}/{actualCount}";
             LogE(errorMsg);
            match = false;
         }

         for(var i = 0; i < Math.Min(actualCount, expectedCount); i++)
         {
            if(!actualLines[i].Equals(expectedLines[i]))
            {
               errorMsg = $"Scripts don't match at line {i + 1} \nExpected: [{expectedLines[i]}]\nActual:   [{actualLines[i]}]";
                LogE(errorMsg);
               return false;
            }
         }

         return match;
      }

      public static void LogFileNames( string actualScriptFilePath, string expectedScriptFilePath, string message = "" )
      {
         var line = "---------------------------------------------------------------------------------------------------------------";
          LogI($"\n\n{line}\nScripts don't match: {message} \nactual script file  : [{actualScriptFilePath}]\nexpected script file: [{expectedScriptFilePath}]\n{line}\n\n\n");
      }

      #endregion Public Static Methods
      #region Public Non Static Methods

      #endregion Public Non Static Methods
      #endregion Public Methods
      #region Protected Methods
      #endregion Protected Methods

      #region Private Methods
      /// <summary>
      /// Worker routine to compare a property - particularly it handles floating point types 
      /// differently.
      /// This sort of approach is needed as there is limited type information on objects
      /// So Convert() wont work
      /// </summary>
      /// <param name="propertyTypeA">Type of property a</param>
      /// <param name="propertyAValue">Property a value</param>
      /// <param name="propertyTypeB">Type of property b</param>
      /// <param name="propertyBValue">Property a value</param>
      /// <returns>true if property values match, false otherwise</returns>
      private static bool CompareProperty( Type propertyTypeA, object propertyAValue, Type propertyTypeB, object propertyBValue )
      {
         bool ret;
         Assert.IsNotNull(propertyTypeA);
         Assert.IsNotNull(propertyTypeB);

         if(Utils.IsNullableType(propertyTypeA))
            propertyTypeA = Nullable.GetUnderlyingType(propertyTypeA);

         if(Utils.IsNullableType(propertyTypeB))
            propertyTypeB = Nullable.GetUnderlyingType(propertyTypeB);

         // Match if both null
         if(propertyAValue == null)
            return propertyBValue == null;

         if(propertyBValue == null)
            return false;

         // ReSharper disable once PossibleNullReferenceException
         if((propertyTypeA.Name == "Single") || (propertyTypeA.Name == "Double"))
         {
            double dA, dB;

            if(propertyTypeA.Name == "Single")
               dA = (float)propertyAValue;
            else
               dA = (double)propertyAValue;

            // ReSharper disable once PossibleNullReferenceException
            if((propertyTypeB != null) && (propertyTypeB.Name == "Single"))
               dB = (float)propertyBValue;
            else
               dB = (double)propertyBValue;

            ret = dA.AboutEqual(dB);
         }
         else
         {
            ret = propertyAValue.Equals(propertyBValue);
         }

         return ret;
      }
      #endregion Private Methods
   }
}
