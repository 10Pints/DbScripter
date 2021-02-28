
#nullable enable 
using C5;

namespace RSS
{
   public interface IDatabaseElement : IElement
    {
        string? Database { get; }
        bool? CheckDbState { get; }
        void GetDatabases(TreeSet<string> set);
    }
}
