namespace SI.Common.Extensions
{
    /// <summary>
    /// Provides extension methods for chars.
    /// </summary>
    public static class CharExtensions
    {
        /// <summary>
        /// Get if a character is numeric.
        /// </summary>
        /// <param name="character">This character.</param>
        /// <returns>True if the character is a number, else false.</returns>
        public static bool IsNumeric(this char character)
        {
            return ((character >= 48) && (character <= 57));
        }
    }
}
