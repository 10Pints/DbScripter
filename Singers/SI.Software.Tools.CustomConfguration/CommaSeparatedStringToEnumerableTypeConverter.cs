using System;
using System.ComponentModel;
using System.Globalization;

namespace SI.Software.Tools.CustomConfiguration
{
   public class CommaSeparatedStringToEnumerableTypeConverter : TypeConverter
   {
      /// <summary>
      /// </summary>
      public CommaSeparatedStringToEnumerableTypeConverter()
      {
      }

      /// <summary>
      /// </summary>
      /// <param name="type"></param>
      public CommaSeparatedStringToEnumerableTypeConverter(Type type)
      {
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="context"></param>
      /// <param name="sourceType"></param>
      /// <returns></returns>
      public override bool CanConvertFrom(ITypeDescriptorContext context, Type sourceType) // => sourceType == typeof(string) || base.CanConvertFrom(context, sourceType);
      {
         if (sourceType == typeof(string)) return true;
         return base.CanConvertFrom(context, sourceType);
      }

      /// <summary>
      /// 
      /// </summary>
      /// <param name="context"></param>
      /// <param name="destinationType"></param>
      /// <returns></returns>
      public override bool CanConvertTo(ITypeDescriptorContext context, Type destinationType)
      {
         return true;
      }

      /// <inheritdoc />
      /// <summary>
      ///    From configuration to C#
      /// </summary>
      /// <param name="context"></param>
      /// <param name="culture"></param>
      /// <param name="value"></param>
      /// <returns></returns>
      public override object ConvertFrom(ITypeDescriptorContext context, CultureInfo culture, object value)
      {
         var ret = value is string csvString
            ? csvString.Split(',')
            : base.ConvertFrom(context, culture, value);

         return ret;
      }

      /// <inheritdoc />
      /// <summary>
      ///    From C# to configuration
      ///    oops we aren't doing this currently
      /// </summary>
      /// <param name="context"></param>
      /// <param name="culture"></param>
      /// <param name="value"></param>
      /// <param name="destinationType"></param>
      /// <returns></returns>
      public override object ConvertTo(ITypeDescriptorContext context, CultureInfo culture, object value, Type destinationType)
      {
         throw new NotImplementedException();
      }
   }
}