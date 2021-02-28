
#nullable enable
using System;
using C5;

namespace SI.Software.TestHelpers
{
   public interface IElement : INamedElement
    {
        IElement? Parent { get; }
        IElement[]? GetChildren();
        IElementCollection? GetChildCollection();
        object? GetAttributeRecursive(string name);
        T? GetAttributeRecursive<T>(string name); 
        T? GetParentAttributeRecursive<T>( string name);
    }
}
