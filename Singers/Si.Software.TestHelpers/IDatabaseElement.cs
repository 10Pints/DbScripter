
#nullable enable
using C5;

namespace SI.Software.TestHelpers
{
   public interface IDatabaseElement : IElement
    {
        string? Database { get; }
        bool? CheckDbState { get; }
        void GetDatabases(TreeSet<string> set);
    }
}
