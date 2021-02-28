using System.Globalization;
using System.Linq;
using System.Windows.Controls;

namespace SI.Software.SharedControls.Validation.ValidationRules
{
    /// <summary>
    /// Represents a validation rule for verifying data entry is safe to use as a file name.
    /// </summary>
    public class FileNameSafeTextValidationRule : ValidationRule
    {
        #region Overrides of ValidationRule

        /// <summary>
        /// When overridden in a derived class, performs validation checks on a value.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.Windows.Controls.ValidationResult"/> object.
        /// </returns>
        /// <param name="value">The value from the binding target to check.</param><param name="cultureInfo">The culture to use in this rule.</param>
        public override ValidationResult Validate(object value, CultureInfo cultureInfo)
        {
            // check that it can parse
            if (string.IsNullOrEmpty(value?.ToString()))
            {
                // value can be empty
                return new ValidationResult(true, string.Empty);
            }

            // hold characters
            var unsafeCharacters = "\\/?%*:|<>.\"";

            // iterate characters
            if (value.ToString().ToUpper().Any(c => unsafeCharacters.Contains(c)))
            {
                // failed
                return new ValidationResult(false, $"Value must be only contain the characters {unsafeCharacters}");
            }

            // passed
            return new ValidationResult(true, string.Empty);
        }

        #endregion
    }
}
