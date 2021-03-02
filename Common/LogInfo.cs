using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RSS.Common
{
    /*// <summary>
    /// Used to cache the essential logging information before the logger is initialised
    /// </summary>
    public class LogInfo
    {
        public LogInfo(string fileName, int lineNumber, LogMode logMode, string clsName, string method, LogType logType, string msg)
        {
            FileName = fileName;
            LineNumber = lineNumber;
            LogMode = logMode;
            ClsName = clsName;
            Method = method;
            LogType = logType;
            Msg = msg;
        }

        public readonly string FileName;
        public readonly int LineNumber;
        public readonly LogMode LogMode;
        public readonly string ClsName;
        public readonly string Method;
        public readonly LogType LogType;
        public readonly string Msg;

        public override string ToString()
        {
            var strLogType = (LogMode == LogMode.Message)  ? "Message"  :
                             (LogMode == LogMode.Starting) ? "Starting" :
                             (LogMode == LogMode.Leaving)  ? "Leaving"  : "???";

            var filePart = $"{FileName}({LineNumber})";
            var methodPart = $"{ClsName}.{Method}()";
            var message = (Msg != null) ? $"\t{Msg}" : "";
            var msgPart = $"{strLogType} {message}";
            string padding = "";
            return $"{filePart}\t{methodPart}\t{padding}{msgPart}";
        }
    }
    */
}
