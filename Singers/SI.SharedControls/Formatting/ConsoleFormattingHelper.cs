using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace SI.Software.SharedControls.Formatting
{
    /// <summary>
    /// Provides helper functionality for console applications.
    /// </summary>
    public static class ConsoleFormattingHelper
    {
        #region StaticFields

        private static readonly StringBuilder stringBuilder = new StringBuilder();

        #endregion

        #region Properties

        /// <summary>
        /// Get the default colours.
        /// </summary>
        public static readonly Dictionary<MessageType, ConsoleColor> DefaultColours = new Dictionary<MessageType, ConsoleColor>
        {
            { MessageType.Default, ConsoleColor.White },
            { MessageType.Info, ConsoleColor.Blue },
            { MessageType.Error, ConsoleColor.Red },
            { MessageType.FatalError, ConsoleColor.Red },
            { MessageType.Incoming, ConsoleColor.Yellow },
            { MessageType.Outgoing, ConsoleColor.Yellow },
            { MessageType.Title, ConsoleColor.Green },
            { MessageType.Break, ConsoleColor.DarkGray }
        };

        /// <summary>
        /// Get or set the line break character.
        /// </summary>
        public static char LineBreakCharacter { get; set; } = char.Parse("-");

        #endregion

        /// <summary>
        /// Append a line break.
        /// </summary>
        public static void AppendLineBreak()
        {
            AppendLineBreak(LineBreakCharacter);
        }

        /// <summary>
        /// Append a line break.
        /// </summary>
        /// <param name="character">The character to use for breaks.</param>
        public static void AppendLineBreak(char character)
        {
            stringBuilder.Clear();

            int width;

            try
            {
                width = Math.Max(0, Console.WindowWidth - 1);
            }
            catch (IOException)
            {
                width = 20;
            }
            
            for (var i = 0; i < width; i++)
                stringBuilder.Append(character);

            Console.ForegroundColor = ConsoleFormattingHelper.DefaultColours[MessageType.Break];
            Console.WriteLine(stringBuilder.ToString());
            Console.ForegroundColor = ConsoleFormattingHelper.DefaultColours[MessageType.Default];
        }

        /// <summary>
        /// Append a message to the default console.
        /// </summary>
        /// <param name="message">The message.</param>
        public static void AppendMessage(string message)
        {
            AppendMessage(message, false, false);
        }

        /// <summary>
        /// Append a message to the default console.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="lineBreakBefore">True if appending a line break before the message.</param>
        /// <param name="lineBreakAfter">True if appending a line break after the message.</param>
        public static void AppendMessage(string message, bool lineBreakBefore, bool lineBreakAfter)
        {
            if (lineBreakBefore)
                AppendLineBreak();

            Console.WriteLine(message);

            if (lineBreakAfter)
                AppendLineBreak();
        }

        /// <summary>
        /// Append a message to the default console.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="colour">The colour.</param>
        public static void AppendMessage(string message, ConsoleColor colour)
        {
            AppendMessage(message, false, false, colour);
        }

        /// <summary>
        /// Append a message to the default console.
        /// </summary>
        /// <param name="message">The message.</param>
        /// <param name="lineBreakBefore">True if appending a line break before the message.</param>
        /// <param name="lineBreakAfter">True if appending a line break after the message.</param>
        /// <param name="colour">The colour.</param>
        public static void AppendMessage(string message, bool lineBreakBefore, bool lineBreakAfter, ConsoleColor colour)
        {
            if (lineBreakBefore)
                AppendLineBreak();

            Console.ForegroundColor = colour;

            Console.WriteLine(message);

            Console.ForegroundColor = ConsoleFormattingHelper.DefaultColours[MessageType.Default];

            if (lineBreakAfter)
                AppendLineBreak();
        }
    }
}
