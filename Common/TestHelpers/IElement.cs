
#nullable enable 

namespace RSS
{
   public interface IElement : INamedElement
    {
        IElement? Parent { get; }
        IElement[]? GetChildren();
        IElementCollection? GetChildCollection();
//        T? GetAttributeRecursive<T>(string name);
        T? GetAttributeRecursiveV<T>(string name) where T: struct;
        T? GetAttributeRecursiveR<T>(string name) where T: class;
    }
}
